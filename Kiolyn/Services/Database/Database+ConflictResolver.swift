//
//  Database.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 2/24/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper


/// Conflict resolving logic of `Database`, including both Remote and Peer sync.
extension Database {
    
    // http://developer.couchbase.com/documentation/mobile/current/training/develop/adding-synchronization/index.html
    
    //private static LiveQuery _conflictsLiveQuery
    
       func startConflictLiveQuery() {
        // TRAINING: Detecting when conflicts occur
        //    _conflictsLiveQuery = database.CreateAllDocumentsQuery().ToLiveQuery()
        //    _conflictsLiveQuery.AllDocsMode = AllDocsMode.OnlyConflicts
        //    _conflictsLiveQuery.Changed += ResolveConflicts
        //    _conflictsLiveQuery.Start()
    }
    
    ///
    /// Stops the live query that is watching for conflicts
    ///
    func stopConflictLiveQuery() {
        //    var q = Interlocked.Exchange(ref _conflictsLiveQuery, null)
        //    q?.Stop()
        //    q?.Dispose()
    }
    
    ///
    /// Resolve conflicts
    ///
    /// <param name="sender"></param>
    /// <param name="e"></param>
    //private void ResolveConflicts(object sender, QueryChangeEventArgs e)
    //{
    //    // Get the conflicted documents
    //    var rows = _conflictsLiveQuery?.Rows
    //    // Return if there is no conflict
    //    if (rows == null) return
    //
    //    // Try to resolve each document
    //    foreach (var row in rows)
    //    {
    //        // Get conflict revisions
    //        var conflicts = row.GetConflictingRevisions().ToArray()
    //        // Skip if there is less than 1 conflict revision
    //        if (conflicts.Length <= 1) continue
    //        // Get the first conflict revision
    //        //var defaultWinning = conflicts[0]
    //        // Get the type - we are not hoping same document but different type
    //        //var type = defaultWinning.GetProperty("type") as string ?? ""
    //        //switch (type)
    //        //{
    //        //  // TRAINING: Automatic conflict resolution
    //        //  case "task-list":
    //        //  case "task-list.user":
    //        //var props = defaultWinning.UserProperties
    //        //    var image = defaultWinning.GetAttachment("image")
    //        ResolveConflictsDefault(conflicts)
    //        //    break
    //        //  // TRAINING: N-way merge conflict resolution
    //        //  case "task":
    //        //    var merged = NWayMergeConflicts(conflicts)
    //        //    ResolveConflicts(conflicts, merged.Item1, merged.Item2)
    //        //    break
    //        //  default:
    //        //    break
    //        //}
    //    }
    //}
    
    ///
    /// Resolve conflict by using the default winning
    ///
    /// <param name="revs"></param>
    //private void ResolveConflictsDefault(SavedRevision[] revs)
    //{
    //    database.RunInTransaction(() =>
    //        {
    //            var i = 0
    //            foreach (var rev in revs)
    //            {
    //                var newRev = rev.CreateRevision()
    //                // Default winning revisionm is the first one
    //                if (i == 0) newRev.SetUserProperties(rev.UserProperties)
    //                // Delete all other conflict revisions
    //                else newRev.IsDeletion = true
    //                // Save the new revision
    //                try
    //                {
    //                    newRev.Save(true)
    //                }
    //                catch (Exception e)
    //                {
    //                    E($"Could not resolve conflicts", e)
    //                    return false
    //                }
    //
    //                i += 1
    //            }
    //
    //            return true
    //        })
    //}
    
    //private static Tuple<IDictionary<string, object>, Attachment> NWayMergeConflicts(SavedRevision[] revs)
    //{
    //  var parent = FindCommonParent(revs)
    //  if (parent == null)
    //  {
    //    var defaultWinning = revs[0]
    //    var props = defaultWinning.UserProperties
    //    var image = defaultWinning.GetAttachment("image")
    //    return Tuple.Create(props, image)
    //  }
    
    //  var mergedProps = parent.UserProperties ?? new Dictionary<string, object>()
    //  var mergedImage = parent.GetAttachment("image")
    //  var gotTask = false
    //  var gotComplete = false
    //  var gotImage = false
    //  foreach (var rev in revs)
    //  {
    //    var props = rev.UserProperties
    //    if (props != null)
    //    {
    //      if (!gotTask)
    //      {
    //        var task = Lookup<string>(props, "task")
    //        if (task != Lookup<string>(mergedProps, "task"))
    //        {
    //          mergedProps["task"] = task
    //          gotTask = true
    //        }
    //      }
    
    //      if (!gotComplete)
    //      {
    //        var complete = LookupNullable<bool>(props, "complete")
    //        if (complete != LookupNullable<bool>(mergedProps, "complete"))
    //        {
    //          mergedProps["complete"] = complete.Value
    //          gotComplete = true
    //        }
    //      }
    
    //      if (!gotImage)
    //      {
    //        var attachment = rev.GetAttachment("image")
    //        var attachmentDigest = attachment?.Metadata[AttachmentMetadataDictionaryKeys.Digest] as string
    //        if (attachmentDigest != mergedImage?.Metadata?["digest"] as string)
    //        {
    //          mergedImage = attachment
    //          gotImage = true
    //        }
    //      }
    
    //      if (gotTask && gotComplete && gotImage)
    //      {
    //        break
    //      }
    //    }
    //  }
    
    //  return Tuple.Create(mergedProps, mergedImage)
    //}
}
