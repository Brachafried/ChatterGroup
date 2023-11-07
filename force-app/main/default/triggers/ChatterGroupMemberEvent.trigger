trigger ChatterGroupMemberEvent on ChatterGroupMemberEvent__e (after insert) {

    new ChatterGroupMemberEventModel().handleChatterGroupMemberEvent();

}