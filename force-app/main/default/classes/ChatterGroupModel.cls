public with sharing class ChatterGroupModel {

    public void processAfterEvents() {

        if (Trigger.isInsert) handleChatterGroupMember(Trigger.New);
        if (Trigger.isDelete) handleChatterGroupMember(Trigger.Old);
    }
   
    public static void handleChatterGroupMember(List<CollaborationGroupMember> triggeredMembers) {
        String memberAction = Trigger.isDelete ? 'Remove' : 'Add';
        system.debug(memberAction);
        List<ChatterGroupMemberEvent__e> eventsToPublish = new List<ChatterGroupMemberEvent__e>();
        Set<Id> chatterGroupIds = new Set<Id>();
        for (CollaborationGroupMember member : triggeredMembers) chatterGroupIds.add(member.CollaborationGroupId);
        Map<Id, CollaborationGroup> chatterGroups = new Map<Id, CollaborationGroup>([SELECT Id, Name FROM CollaborationGroup WHERE Id IN: chatterGroupIds]);
        for (CollaborationGroupMember member : triggeredMembers) {
                ChatterGroupMemberEvent__e event = new ChatterGroupMemberEvent__e(
                    ChatterGroupName__c = chatterGroups.get(member.CollaborationGroupId).Name,
                    UserId__c = member.MemberId,
                    Action__c = memberAction
                );
                eventsToPublish.add(event);
        }

        // Publish the Platform Events to the EventBus
        if (!eventsToPublish.isEmpty()) {
            List<Database.SaveResult> results = EventBus.publish(eventsToPublish);
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) System.debug('Successfully published event.');
                else {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Error returned when publishing event: ' + err.getStatusCode());
                    }
                } 
            }
        }
    }
}