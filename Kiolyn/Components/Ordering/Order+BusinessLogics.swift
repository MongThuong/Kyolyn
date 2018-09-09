//
//  Order+Ordering.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/13/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation

// MARK: - Order related
extension Order {
    /// Close this Order.
    ///
    /// - Parameters:
    ///   - employee: The `Employee` who close this order.
    ///   - voided: `true` if this order is closed because it is voided.
    /// - Returns: the current `Order`.
    func close(by employee: Employee, voided: Bool = false) -> Order {
        orderStatus = voided ? .voided : .checked
        closedBy = employee.id
        closedAt = BaseModel.timestamp
        return self
    }
    
    /// Set customer information.
    ///
    /// - Parameter c: the `Customer` of this `Order`.
    /// - Returns: the `Order` itself.
    func set(customer c: Customer?) -> Order {
        customer = c?.id ?? ""
        customerName = c?.name ?? ""
        customerAddress = c?.address ?? ""
        customerEmail = c?.email ?? ""
        customerPhone = c?.mobilephone ?? ""
        return self
    }
    
    /// Set driver information.
    ///
    /// - Parameter d: the `Employee` of this `Order`.
    /// - Returns: the `Order` itself.
    func set(driver d: Employee?) -> Order {
        driver = d?.id ?? ""
        driverName = d?.name ?? ""
        return self
    }
    
    
    /// Merge the list of orders to this order.
    ///
    /// - Parameter mergedOrders: the list of orders to merge to
    /// - Returns: the `Order` itself.
    func merge(orders mergedOrders: [Order]) -> Order {
        for order in mergedOrders {
            // add the persons
            persons += order.persons
            // add the items
            for orderItem in order.items {
                // The merged item has modifiers/note, then for sure there is not matched target item, thus add it to target list
                guard !orderItem.hasModifiers, !orderItem.hasNote else {
                    items.append(orderItem)
                    continue
                }
                if let existingItem = items.first(where: { oi -> Bool in
                    oi.itemID == orderItem.itemID
                        && oi.status == orderItem.status
                        && oi.togo == orderItem.togo
                        && oi.hold == orderItem.hold
                        && !oi.hasModifiers && !oi.hasNote
                        && oi.count + orderItem.count < 99
                }) {
                    existingItem.count += orderItem.count
                    existingItem.updateCalculatedValues()
                } else {
                    items.append(orderItem)
                }
            }
        }
        updateCalculatedValues()
        // Sort by id to reflect the order of item adding
        items.sort { $0.id < $1.id }
        // Update service fee
        serviceFee = SP.authService.settings?.find(groupGratuity: persons)?.percent ?? 0
        serviceFeeReason = ""
        return self
    }
}

// MARK: - Items related
extension Order {
    
    /// `true` if there is anything inside
    var hasItems: Bool { return items.count > 0 }
    
    /// Return all the new (not yet submitted/printed) items.
    var newItems: [OrderItem] { return items.filter{ $0.isNew } }
    
    /// `true` if there is new item in order.
    var hasNewItems: Bool { return items.contains { $0.isNew } }
    
    /// Return all the new (not yet submitted/printed) items that can be submitted.
    var submittableItems: [OrderItem] { return items.filter { $0.isNew && !$0.hold } }
    
    /// `true` if there is item to submit
    var hasSubmittableItems: Bool { return items.contains { $0.isNew && !$0.hold } }
    
    /// Return all the already submitted items.
    var submittedItems: [OrderItem] { return items.filter{ $0.isSubmitted || $0.isChecked } }
    
    /// `true` if Order contains submitted items.
    var hasSubmittedItems: Bool { return items.contains(where: { $0.isSubmitted || $0.isChecked }) }
    
    /// Return all items that are in hold.
    var holdItems: [OrderItem] { return items.filter { $0.hold } }
    
    /// Return `true` if there is hold items in this order.
    var hasHoldItems: Bool { return holdItems.contains { $0.hold } }
    
    /// Return all the items that are not fully billed.
    var unbilledItems: [OrderItem] { return items.filter { $0.isNotNew && $0.isNotVoided && $0.billedCount < $0.count } }
    
    /// `true` if there is unbilled items.
    var hasUnbilledItems: Bool { return items.contains { $0.isNotNew && $0.isNotVoided && $0.billedCount < $0.count } }
    
    /// Return the list of unpaid bills.
    var unpaidBills: [Bill] { return bills.filter{ !$0.paid } }
    
    /// True if there is at least on bill.
    var hasBills: Bool { return bills.isNotEmpty }
    
    /// True if there is no bill.
    var noBills: Bool { return bills.isEmpty }
    
    /// `true` if everything in order is already paid
    var allPaid: Bool { return unpaidBills.isEmpty && newItems.isEmpty && unbilledItems.isEmpty }
    
    /// Add item to current Order.
    ///
    /// - Parameter item: the item to add.
    /// - Returns: The same `Order`.
    func add(item: OrderItem) -> OrderItem {
        // Try get the first same item without modifier, note or togo
        if let existingOI = items.first(where: { oi -> Bool in
            return oi.isNew && oi.itemID == item.itemID && !oi.hasNote && !oi.hasModifiers && !oi.togo && oi.count < 99
        }) {
            // ... found, then just increase count value
            existingOI.count += 1
            existingOI.updateCalculatedValues()
            return existingOI
        } else {
            // ... otherwise append new order item
            items.append(item)
            return item
        }
    }

    /// Change order item to updated status.
    ///
    /// - Parameter items: the updated `OrderItem`s.
    /// - Returns: the current `Order`.
    func update(items: [OrderItem]) -> Order {
        for oi in items {
            oi.isUpdated = true
        }
        return self
    }
    
    /// Mark given items as Submitted, change Order to Submitted if not changed already.
    ///
    /// - Parameter items: The `OrderItem`s to update.
    /// - Returns: the current `Order`.
    func save(items: [OrderItem]) -> Order {
        // Update status of Order Item
        for orderItem in items {
            orderItem.status = .submitted
        }
        // Update Order status
        if isNew {
            orderStatus = .submitted
        }
        return self
    }

    /// Void a list of checked items
    ///
    /// - Parameter items: the checked items to be voided.
    /// - Returns: the Order itself.
    func void(items voidItems: [OrderItem], with reason: String, by employee: Employee) -> Order? {
        guard voidItems.any({ $0.isNew || $0.isSubmitted }) else { return nil }
        
        // Remove the new items in given list
        let newItems = voidItems.filter { $0.isNew }.map { $0.id }
        items = items.filter { !newItems.contains($0.id) }
        // Void submitted items
        let unpaidBills = self.unpaidBills
        for oi in voidItems.filter({ $0.isSubmitted }) {
            oi.status = .voided
            oi.voidReason = reason
            // Remove voided items from bills
            for bill in unpaidBills {
                guard let bi = bill.items.index(where: { $0.id == oi.id }) else {
                    continue
                }
                bill.items.remove(at: bi)
                bill.updateCalculatedValues()
                if bill.items.isEmpty, let bi = bills.index(of: bill) {
                    bills.remove(at: bi)
                }
            }
        }
        updateCalculatedValues()
        if items.all({ $0.isVoided }) {
            return close(by: employee, voided: true)
        }
        return self
    }
    
    /// Add `Modifier/Option` to `OrderItem`.
    ///
    /// - Parameters:
    ///   - option: The `Option`.
    ///   - modifier: The `Modifier`.
    ///   - item: The target `OrderItem`.
    /// - Returns: The same `Order`.
    func add(option: Option, of modifier: Modifier, to item: OrderItem) -> Order {
        // Find the existing order modifier
        if let existingMod = item.modifiers.first(where: { modifier.id == $0.id }) {
            // If there is already a selected modifier, then we need to make sure the multiplicity of it.
            // If multiple, we check and add/remove. If single, we remove all then add this one.
            // Find the existing option that match the selected option
            let existingOpt = existingMod.options.first(where: { $0.id == option.id })
            if modifier.multiple {
                if existingOpt != nil {
                    // If there is a match, REMOVE it
                    existingMod.options.delete(existingOpt!)
                    if existingMod.options.isEmpty {
                        item.modifiers.delete(existingMod)
                    }
                } else {
                    // If there is no match, ADD it
                    existingMod.options.append(option)
                }
            } else {
                // Single selection mean that only 1 option is accepted, thus we remove all existing
                // and add the new item
                existingMod.options.removeAll()
                // If it is already added, then readd (because user want to remove it)
                if existingOpt == nil {
                    existingMod.options.append(option)
                }
            }
        } else {
            item.modifiers.append(OrderModifier(modifier: modifier, selectedOptions: [option]))
        }
        item.updateCalculatedValues()
        return self
    }
    
}

// MARK: - Bills related
extension Order {
    /// Find Bill with given id.
    ///
    /// - Parameter id: The bill's id.
    /// - Returns: `Bill` with matched id.
    func bill(with id: String) -> Bill? {
        return self.bills.first(where: { $0.id == id })
    }
    
    /// Check a bill (marked it as printed)
    ///
    /// - Parameters:
    ///   - bill: The `Bill` to check.
    ///   - order: The `Order` to check.
    func check(bill: Bill?) -> Order? {
        guard isNotClosed else {
            return nil
        }
        // Update order status if needed
        if isSubmitted { orderStatus = .printed }
        // Check single bill
        let check = { (bill: Bill) -> Void in
            guard bill.isNotPaid, bill.notPrinted, bill.items.isNotEmpty else { return }
            // Update Bill Printed status
            bill.printed = true
            // Update the order items
            for billItem in bill.items {
                if let orderItem = self.items.first(where: { $0.id == billItem.id}),
                    orderItem.isSubmitted {
                    orderItem.status = .checked
                }
            }
        }
        // Now check the single given bill or the entire unpaid bills under
        if let bill = bill {
            check(bill)
        } else {
            for bill in bills { check(bill) }
        }
        return self
    }
    
    /// Checkout all unbill items of the given Order,
    /// no saving is performed.
    ///
    /// - Returns: the same `Order` if success, nil otherwise.
    func checkout() -> Order? {
        // Get the unbilled items
        let unbilledItems = self.unbilledItems
        // Do nothing if there is no unbilled items
        guard unbilledItems.isNotEmpty else {
            return nil
        }
        // Get the main bill which is the first unpaid bill
        var mainBill = self.bills.first { $0.isNotPaid && $0.isNotSplitted }
        // There is no main bill, create one
        if mainBill == nil {
            mainBill = Bill(order: self)
            self.bills.append(mainBill!)
        }
        // Bring all the unbilled items over to main bill
        for orderItem in unbilledItems {
            let billOrderItem = orderItem.billItem
            if orderItem.billedCount > 0 {
                // Bring over all the unbilled count
                billOrderItem.count = orderItem.count - orderItem.billedCount
            }
            // Update the billed count value to current count value
            orderItem.billedCount = orderItem.count
            // Update the calculated values
            billOrderItem.updateCalculatedValues()
            mainBill?.items.append(billOrderItem)
        }
        // Update te calculated values
        mainBill?.updateCalculatedValues()
        return self
    }
    
    /// Merge all unpaid Bill to the first unpaid Bill.
    ///
    /// - Parameter order: The `Order` to have its Bills reset.
    /// - Returns: the same `Order` if success, nil otherwise.
    func resetBills() -> Order? {
        guard isNotClosed else {
            return nil
        }
        
        let splittedBillGroups = bills
            .filter { $0.isSplitted }
            .group { $0.parentBill }
        
        for (_, splittedBills) in splittedBillGroups {
            let unpaidSplittedBills = splittedBills.filter { $0.isNotPaid }
            // Not enough bill for merging
            guard unpaidSplittedBills.count > 1,
                // Get the first target bill inside group
                let targetBillInGroup = unpaidSplittedBills.first
                else { continue }
            if unpaidSplittedBills.count == splittedBills.count {
                // Nothing got paid, we remove all except the first bill which will be unsplit
                for bill in unpaidSplittedBills[1..<unpaidSplittedBills.count] {
                    if let billIndex = bills.index(of: bill) {
                        bills.remove(at: billIndex)
                    }
                }
                // Unsplit the first bill
                targetBillInGroup.unsplit()
            } else {
                for bill in unpaidSplittedBills[1..<unpaidSplittedBills.count] {
                    if let billIndex = bills.index(of: bill) {
                        bills.remove(at: billIndex)
                    }
                    // merge to target bill in group
                    targetBillInGroup.total += bill.total
                }
            }
        }
        // Filter out the empty bills
        bills = bills.filter { $0.items.isNotEmpty }
        // Now deal with the whole unpaid bill
        let unpaidBills = bills.filter { $0.isNotPaid && $0.isNotSplitted }
        if let mainBill = unpaidBills.first {
            for bill in unpaidBills[1..<unpaidBills.count] {
                // Get the index in original bills list
                guard let billIndex = bills.index(of: bill) else { continue }
                // Merge to main bill
                mainBill.add(items: bill.items)
                // Remove the merged bill
                bills.remove(at: billIndex)
            }
        }
        return self
    }
    
    /// Add a blank empty bill.
    ///
    /// - Parameter order: The `Order` to have new bill added.
    /// - Returns: the same `Order` if success, nil otherwise.
    func addBill() -> Order? {
        guard isNotClosed else {
            return nil
        }
        let bill = Bill(order: self)
        bills.append(bill)
        return self
    }
    
    /// Remove a bill by merging its item back to main bill OR unbill it completely.
    ///
    /// - Parameters:
    ///   - bill: The `Bill` to be removed.
    ///   - order: The active `Order`.
    /// - Returns: the same `Order` if success, nil otherwise.
    func remove(bill: Bill) -> Order? {
        // Get the bill index
        guard let bindex = bills.index(of: bill) else {
            return nil
        }
        
        let targetBill = bill.isSplitted
            ? bills.first(where: { $0.isNotPaid && $0.id != bill.id && $0.parentBill == bill.parentBill })
            :  bills.first(where: { $0.isNotPaid && $0.id != bill.id && $0.isNotSplitted })
        
        // Try to merge to main bill
        if let targetBill = targetBill {
            if bill.isSplitted {
                // If there is only 1 bill left, then unsplit the target bill
                if bills.filter({ $0 != targetBill && $0.parentBill == targetBill.parentBill }).count == 1 {
                    targetBill.unsplit()
                } else {
                    targetBill.total += bill.total
                }
            } else {
                // Normal merging process
                targetBill.add(items: bill.items)
            }
        } else if bill.isSplitted {
            // This is just to be sure, remove is only applicable when there are at least 2 unpaid bill of the same parent
            return nil
        } else {
            // If there is no main bill, it means we unbill this whole bill, thus we need to update the items inside Order to reflect this fact
            for billItem in bill.items {
                if let orderItem = items.first(where: { $0.id == billItem.id }) {
                    // Removed the billed count of Bill's OrderItem from its Order's OrderItem
                    orderItem.billedCount -= billItem.count
                    // If the current status is checked, and everything got removed, then turn
                    // back to submitted status
                    if orderItem.isChecked && orderItem.billedCount == 0 {
                        orderItem.status = .submitted
                    }
                }
            }
        }
        // Remove the bill
        bills.remove(at: bindex)
        return self
    }
    
    /// Move selected item to a given bill, nil means we have to create a new one.
    ///
    /// - Parameters:
    ///   - items: The `Item`s to move.
    ///   - bill: The `Bill` to move to.
    /// - Returns: the same `Order` if success, nil otherwise.
    func move(items: [OrderItem], from fromBill: Bill, to toBill: Bill?) -> Order? {
        guard isNotClosed, fromBill.isNotPaid, items.isNotEmpty else {
            return nil
        }
        
        var targetBill: Bill? = toBill
        if targetBill == nil {
            targetBill = Bill(order: self)
            bills.append(targetBill!)
        }
        
        for movedItem in items {
            // Remove from the old bill
            guard let findex = fromBill.items.index(where: { $0.id == movedItem.id }) else {
                continue
            }
            let fromItem = fromBill.items[findex]
            fromItem.count -= movedItem.count
            if fromItem.count == 0 {
                fromBill.items.remove(at: findex)
            } else {
                fromItem.updateCalculatedValues()
            }
            fromBill.updateCalculatedValues()
            
            // Move to new bill
            if let toItem = targetBill!.items.first(where: { $0.id == movedItem.id }) {
                toItem.count += movedItem.count
                toItem.updateCalculatedValues()
            } else {
                targetBill!.items.append(movedItem)
            }
        }
        targetBill?.updateCalculatedValues()
        return self
    }
    
    /// Pay `Bill` with given `Transction` using given employee as the one who triggers the payment
    ///
    /// - Parameters:
    ///   - bill: the `Bill` to pay for.
    ///   - trans: the `Transaction` to use as payment method.
    ///   - employee: the `Employee` requesting the payment.
    /// - Returns: the `Order` if success, nil otherwise
    func pay(bill: Bill, with trans: Transaction, by employee: Employee) -> String? {
        var message: String?
        // partially paid will generate a new bill with the remaing amount
        if (bill.total - trans.approvedAmount >= 0.01) {
            i("Extra bill created: Total \(bill.total) / Approved Amt. \(trans.approvedAmount) / New Bill Amount: \(lround(bill.total*100) - lround(trans.approvedAmount*100))")
            guard let bindex = bills.index(of: bill) else {
                e("[PNP] Transaction \(trans.id) has paid for a not existing Bill (\(bill.id)) in Order (\(self.id))")
                return "Could not find Bill in being paid Order."
            }
            // Split a new bill
            let balance = bill.total - trans.approvedAmount
            let newBill = bill.split(amount: balance)
            // Conver to split
            bill.toSplit(amount: trans.approvedAmount)
            // Insert after the source bill
            bills.insert(newBill, at: bindex + 1)
            // Set the message
            message = "Please see the Bill #\(bindex + 2) for Remaining Balance: \(balance.asMoney)"
        }
        bill.transaction = trans.id
        bill.voided = false
        bill.paidBy = employee.id
        bill.paidAt = BaseModel.timestamp
        bill.paid = true
        // Change order item state
        for bItem in bill.items {
            guard let oItem = items.first(where: { $0.id == bItem.id }) else {
                continue
            }
            oItem.status = .paid
        }
        // Mark Order as Checked when the last item was paid
        if allPaid {
            _ = close(by: employee)
        }
        return message
    }
    
    /// Void a `Bill` inside this `Order`.
    ///
    /// - Parameter bill: the `Bill` to voi.
    /// - Returns: the same `Order` if success, nil otherwise.
    func void(bill: Bill) -> Order? {
        guard bill.paid else { return nil }
        // If order is in paid status, convert it back to checked/printed status.
        if self.isChecked {
            orderStatus = .printed
        }
        // Update bills
        bill.voidedTransactions.append(bill.transaction)
        bill.transaction = ""
        bill.paid = false
        bill.paidAt = ""
        bill.paidBy = ""
        bill.voided = false
        // Update Order's OrderItem status
        // issue #559 [PC 1.2.1023.2] [Void Bill] Relating data status(order, order's items, transaction) should be updated after voiding a bill
        let paidBills = bills.filter { $0.paid }
        // Update statuses
        for bi in bill.items {
            // Just update the order item that is voided together with this bill
            guard let oi = items.first(where: { $0.id == bi.id }) else { continue }
            // Calculate the paid count of this item
            let paidCount: Double = paidBills.reduce(0, { (total, paidBill) -> Double in
                guard let pbi = paidBill.items.first(where: { $0.id == oi.id }) else { return total }
                return total + pbi.count
            })
            // If nothing got paid, move it back to checked status
            if paidCount == 0 {
                oi.status = .checked
            }
        }
        return self
    }
}
