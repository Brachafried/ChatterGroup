@isTest
public with sharing class ChatterGroup_TestClass {
    
    @isTest
    public static void ChatterGroup_TestClass() {

        Test.startTest();
        CollaborationGroup grp1 = new CollaborationGroup(Name = 'Test1', CollaborationType = 'Public');
        CollaborationGroup grp2 = new CollaborationGroup(Name = 'Test2', CollaborationType = 'Public');
        insert new List<CollaborationGroup>{grp1, grp2};
        
        Profile prof = [SELECT id FROM profile WHERE name LIKE '%System%' LIMIT 1];

        User u1 = new User(Alias = 'bt',
        Username = 'brac@testorg.com',
        Email='brac@testorg.com', 
        LastName='Testing', 
        ProfileId = prof.Id,
        TimeZoneSidKey = 'GMT',
        LanguageLocaleKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        LocaleSidKey = 'en_US');
        User u2 = new User(Alias = 'at',
        Username = 'asperii@testorg.com',
        Email='asperii@testorg.com', 
        LastName='Testing', 
        ProfileId = prof.Id,
        TimeZoneSidKey = 'GMT',
        LanguageLocaleKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        LocaleSidKey = 'en_US');
        insert new List<User>{u1, u2};
       
        collaborationgroupmember cgm1 = new collaborationgroupmember(CollaborationGroupId = grp1.Id, MemberId = u1.Id, CollaborationRole = 'Standard');
        collaborationgroupmember cgm2 = new collaborationgroupmember(CollaborationGroupId = grp1.Id, MemberId = u2.Id, CollaborationRole = 'Standard');
        collaborationgroupmember cgm3 = new collaborationgroupmember(CollaborationGroupId = grp2.Id, MemberId = u2.Id, CollaborationRole = 'Standard');
        insert new List<collaborationgroupmember>{cgm1, cgm2, cgm3};

        Set<String> grpNames = new Set<String>{grp1.Name, grp2.Name};

        for(Group grp: [SELECT Id, Name, (SELECT Id, UserOrGroupId FROM GroupMembers) FROM Group WHERE Name IN: grpNames]){
            // 3 cgm including the owner
            if(grp.Name == grp1.Name) Assert.areEqual(3, grp?.GroupMembers.size());
            else Assert.areEqual(grp2.Name, grp.Name);
        }

        delete cgm2;
        Test.stopTest();
        Assert.areEqual(2, [SELECT Id, Name, (SELECT Id, UserOrGroupId FROM GroupMembers) FROM Group WHERE Name =: grp1.Name LIMIT 1]?.GroupMembers.size());
        
    }
}

