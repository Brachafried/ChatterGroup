public with sharing class ChatterGroupMemberEventModel {

    //This class will always use the Trigger.New records because event can trigger only after insert
    static List<SObject> triggerRecords = Trigger.new;
    
    public  void handleChatterGroupMemberEvent() {

        List<GroupMember> groupMembersToAdd = new List<GroupMember>();
        Map<Id, Id> groupMembersToRemove = new Map<Id, Id>();
        Set<String> chatterGroupNames = new Set<String>();
        for (ChatterGroupMemberEvent__e event : (List<ChatterGroupMemberEvent__e>)triggerRecords) chatterGroupNames.add(event.ChatterGroupName__c);
        Map<String, Group> GroupToMember = new Map<String, Group>();
        List<Group> newGroups = new List<Group>();
        for (Group gtm : [SELECT Id, Name FROM Group WHERE Name IN : chatterGroupNames]) GroupToMember.put(gtm.Name, gtm);

        //create missing groups
        for(String chattername : chatterGroupNames){
            if(!GroupToMember.containsKey(chattername)) newGroups.add(new Group( Name = chattername, Type = 'Regular'));
        }

        try {
            if (!newGroups.isEmpty()) {
                insert newGroups;
            }

            //add new groups to GroupToMember
            for (Group gtm : [SELECT Id, Name FROM Group WHERE Id IN : newGroups]) GroupToMember.put(gtm.Name, gtm);

            for (ChatterGroupMemberEvent__e event : (List<ChatterGroupMemberEvent__e>)triggerRecords) {
                System.debug('from event ' + event.Action__c + '  ' + event);
                if(event.Action__c == 'Add') {
                    if(GroupToMember.containsKey(event.ChatterGroupName__c)) {
                        groupMembersToAdd.add(new GroupMember(GroupId = GroupToMember.get(event.ChatterGroupName__c)?.Id, UserOrGroupId = event.UserId__c));
                    }
                }
                // if action = remove so the group exsites and then we can just add to the remove list
                else groupMembersToRemove.put(event.UserId__c, GroupToMember.get(event.ChatterGroupName__c)?.Id);
            }
        } catch (Exception ex) {
            System.debug('Error inserting new group ' + ex.getMessage() + ' ' + ex.getStackTraceString());
        }

        try {
            if (!groupMembersToAdd.isEmpty()) insert groupMembersToAdd;
        } catch (Exception ex) {
            System.debug('Error inserting group members ' + ex.getMessage() + ' ' + ex.getStackTraceString());
        }

        try {
            if (!groupMembersToRemove.isEmpty()) {
                List<GroupMember> listGM  = [ SELECT Id FROM GroupMember WHERE UserOrGroupID IN :groupMembersToRemove.keyset() and GroupId  IN : groupMembersToRemove.values()];
                delete listGM;
            }
        } catch (Exception ex) {
            System.debug('Error deleting group members ' + ex.getMessage() + ' ' + ex.getStackTraceString());
        }    
    }
}
       