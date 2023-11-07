trigger ChatterGroupMemberTrigger on CollaborationGroupMember (after insert, after delete) {
    if(trigger.isAfter) {
        if(trigger.isInsert || trigger.isDelete) new ChatterGroupModel().processAfterEvents();
    }
}