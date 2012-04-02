/*******************************************************************************
 *  Test for all triggers and classes.
 *  copyright (c) 2011 breakingpoint.com Co.,Ltd. 
 *  Apex Class		: AllUnitTest.cls 
 *  Summary			: 
 *  Refer Object    : 
 *  Author          : Mouse.liu(mouse.liu@yahoo.com)　       
 *  CreatedDate    	: 2011-09-07
 *  Change Log     	: 
 ******************************************************************************/	
@isTest
private class AllUnitTest {
	
	private static User u = [Select Id from User Where User.Profile.Name like 'Sales Rep%' limit 1];
		
    static testMethod void TrgOnAttachmentTest() {
    	
    	//Test create Attachment
    	Account acc = UtilUnitTest.createAccountByRecordtypeName(UtilUnitTest.RECORDTYPE_NAME_ACCOUNT_COMPETITOR_ACCOUNT);
    	System.runAs( u ){
			Attachment att = UtilUnitTest.createAttachment(acc);
			System.assertEquals(att.Id, null);
    	}
    	
		//Test Create Attachment with current User in Account Team or Owner.
		Attachment att = UtilUnitTest.createAttachment(acc);
		System.assert( att.Id != null );
		
    }
    
    static testMethod void TrgOnContactTest() {
    	
    	//Test create Contact
    	Account acc = UtilUnitTest.createAccountByRecordtypeName(UtilUnitTest.RECORDTYPE_NAME_ACCOUNT_COMPETITOR_ACCOUNT);
    	System.runAs( u ){
			Contact con = UtilUnitTest.createContact(acc);
			System.assertEquals(con.Id, null);
    	}
    	
		//Test Create Contact with current User in Account Team or Owner.
		Contact con = UtilUnitTest.createContact(acc);
		System.assert( con.Id != null );
		
		//Test the non-AccountId update.
		try{
			con.FirstName = 'mouse';
			update con;
			System.assert( con.AccountId == acc.Id);
		}
		catch(Exception e) {
			System.debug('update contact failed + ' + e.getMessage());
		}
		
		//Test the AccountId update.
		Account salesRepAcc = new Account();
		System.runAs( u ){
			salesRepAcc = UtilUnitTest.createAccount();
		}
		try{
			con.AccountId = salesRepAcc.Id;
			update con;
		}
		catch(Exception e) {
			System.assert( e.getMessage().contains('because you are not Account Team Member') );
		}
    }
    
    static testMethod void TrgOnTaskTest() {
    	
    	//Test create Task
    	Account acc = UtilUnitTest.createAccountByRecordtypeName(UtilUnitTest.RECORDTYPE_NAME_ACCOUNT_COMPETITOR_ACCOUNT);
    	System.runAs( u ){
			Task ta = UtilUnitTest.createTask(acc);
			System.assertEquals(ta.Id, null);
    	}
    	
		//Test Create Task with current User in Account Team or Owner.
		Task ta = UtilUnitTest.createTask(acc);
		System.assert(ta.Id != null);
		
		//Test the non-AccountId update.
		try{
			ta.Description = 'mouse';
			update ta;
			System.assert( ta.WhatId == acc.Id);
		}
		catch(Exception e) {
			System.debug('update Task failed + ' + e.getMessage());
		}
		
		//Test the AccountId update.
		Account salesRepAcc = new Account();
		System.runAs( u ){
			salesRepAcc = UtilUnitTest.createAccount();
		}
		try{
			ta.WhatId = salesRepAcc.Id;
			update ta;
		}
		catch(Exception e) {
			System.assert( e.getMessage().contains('because you are not Account Team Member') );
		}
    } 
    
    static testMethod void TrgOnEventTest() {
    	
    	//Test create Task
    	Account acc = UtilUnitTest.createAccountByRecordtypeName(UtilUnitTest.RECORDTYPE_NAME_ACCOUNT_COMPETITOR_ACCOUNT);
    	System.runAs( u ){
			Event ev = UtilUnitTest.createEvent(acc);
			System.assertEquals(ev.Id, null);
    	}
    	
		//Test Create Event with current User in Account Team or Owner.
		Event ev = UtilUnitTest.createEvent(acc);
		System.assert(ev.Id != null);
		
		//Test the non-AccountId update.
		try{
			ev.Description = 'mouse';
			update ev;
			System.assert( ev.WhatId == acc.Id);
		}
		catch(Exception e) {
			System.debug('update Event failed + ' + e.getMessage());
		}
		
		//Test the AccountId update.
		Account salesRepAcc = new Account();
		System.runAs( u ){
			salesRepAcc = UtilUnitTest.createAccount();
		}
		try{
			ev.WhatId = salesRepAcc.Id;
			update ev;
		}
		catch(Exception e) {
			System.assert( e.getMessage().contains('because you are not Account Team Member') );
		}
    } 
    
    static testMethod void TrgOnOpportunityTest() {
    	
    	//Test create Opportunity
    	Account acc = UtilUnitTest.createAccountByRecordtypeName(UtilUnitTest.RECORDTYPE_NAME_ACCOUNT_COMPETITOR_ACCOUNT);
    	System.runAs( u ){
			Opportunity opp = UtilUnitTest.createOpportunity(acc);
			System.assertEquals(opp.Id, null);
    	}
    	
		//Test Create Opportunity with current User in Account Team or Owner.
		AccountTeamMember member = UtilUnitTest.createAccountTeamMember(acc);
		Opportunity opp = UtilUnitTest.createOpportunity(acc);
		System.assert( opp.Id != null );
		
		//Test the non-AccountId update.
		try{
			opp.Name = 'mouse';
			update opp;
			System.assert( opp.AccountId == acc.Id);
		}
		catch(Exception e) {
			System.debug('update Opportunity failed + ' + e.getMessage());
		}
		
		//Test the AccountId update.
		Account salesRepAcc = new Account();
		System.runAs( u ){
			salesRepAcc = UtilUnitTest.createAccount();
		}
		try{
			opp.AccountId = salesRepAcc.Id;
			update opp;
		}
		catch(Exception e) {
			System.assert( e.getMessage().contains('because you are not Account Team Member') );
		}
    } 
    
    static testMethod void ExtCloneOrderTest() {

		Account acc = UtilUnitTest.createAccount();
		Opportunity opp = UtilUnitTest.createOpportunityWithProducts(acc);
		Quote qu = UtilUnitTest.createQuoteWithLineItem(opp);
		
		//Test Clone Quote with no Error
		try{
	        PageReference pr = new PageReference('/apex/CloneOrder?id=' + qu.id);
	        Test.setCurrentPage(pr);
	        ExtCloneOrder eco = new ExtCloneOrder(new ApexPages.StandardController(qu));
	        eco.getQu().Status = 'Draft';
			eco.save();
			System.assertEquals(eco.getHasMessage(), false);
			System.assert(eco.getQlis().size() > 0);
			System.assertEquals(eco.getHasProduct(), true);	
		}
		catch(Exception e){
			throw e;
			System.debug('Clone Quote failed, ' + e.getMessage());
		}
		
		//Test Quote update
		try{
			qu.Status = 'Draft';
			update qu;
		}
		catch(Exception e){
			System.debug('Update Quote failed ' + e.getMessage());
		}
		
		//Test Clone Quote With Error.
		Quote quoteWithError = UtilUnitTest.createQuoteWithLineItem(opp);
		try{
	        PageReference pr = new PageReference('/apex/CloneOrder?id=' + quoteWithError.id);
	        Test.setCurrentPage(pr);
	        ExtCloneOrder eco = new ExtCloneOrder(new ApexPages.StandardController(quoteWithError));
	        eco.getQu().Status = 'Signed off';
			eco.save();
			System.assertEquals(eco.getHasMessage(), true);	
		}
		catch(Exception e){
			throw e;
			System.debug('Clone Quote failed, ' + e.getMessage());
		}
    }
    
    static testMethod void ExtCreateAmountAllocationTest() {
    	
		Account acc = UtilUnitTest.createAccount();
		Opportunity opp = UtilUnitTest.createOpportunityWithProducts(acc);

		//Test Create AmountAllocation with no Error
		try{
	        PageReference pr = new PageReference('/apex/CreateAmountAllocation?id=' + opp.id);
	        Test.setCurrentPage(pr);
	        ExtCreateAmountAllocation eca = new ExtCreateAmountAllocation(new ApexPages.StandardController(opp));
	        eca.getAlloc().Percentage__c = 20;
	        eca.getAlloc().Internal_User_Name__c = UserInfo.getUserId();
			eca.save();
			System.assertEquals(eca.getHasMessage(), false);
			System.assert(eca.getAlloc() != null);
			System.assertEquals(eca.getOppId(), opp.Id);	
		}
		catch(Exception e){
			throw e;
			System.debug('Clone Quote failed, ' + e.getMessage());
		}

    }
    
    static testMethod void ExtLookupFilterTest() {
    	
    }
}