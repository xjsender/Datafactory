/***************************************************************************************************************
 *  The UtilUnitTest is used for preparing test data.
 *  copyright (c) 2011 breakingpoint.com Co., Ltd. 
 *  Apex Class		: UtilUnitTest
 *  Summary			: 
 *  Refer Object    : All Related Object
 *  Author          : Mouse.liu(mouse.liu@ibreakingpoint.com)　       
 *  CreatedDate    	: 2011/09/01
 *  Change Log     	: 		  
 **************************************************************************************************************/
public class UtilUnitTest {
	
	public static final String RECORDTYPE_NAME_ACCOUNT_COMPETITOR_ACCOUNT = 'Competitor Account';
	public static final String RECORDTYPE_NAME_ACCOUNT_PRIMARY_ACCOUNT_NAME = 'Primary Account Name';
	
	private static PricebookEntry pbe = [Select Id, Pricebook2Id, Product2Id 
										 From PricebookEntry 
										 Where IsActive = true 
										 And CurrencyIsoCode = 'USD' limit 1];
			
	public static Account createAccount() {
		Account acc =  new Account();
		try{
			acc = (Account) DataFactory.createSObject('Account', false, false);
			insert acc;
		}
		catch(Exception e){
			System.debug('Create Account failed, ' + e.getMessage());
		}
		return acc;
	}
	
	public static Account createAccountByRecordtypeName(String recordtypeName) {
		Account acc =  new Account();
		try{
			String recordtypeId = DataFactory.getRecordtypeIdByName('Account', recordtypeName);
			acc = (Account) DataFactory.createSObject('Account', false, false);
			acc.RecordTypeId = recordtypeId;
			insert acc;
		}
		catch(Exception e) {
			System.debug('Create account failed, ' + e.getMessage());
		}
		
		return acc;
	}

	public static Opportunity createOpportunity(Account acc) {
		Opportunity opp = new Opportunity();
		try{
			opp = (Opportunity) DataFactory.createSObject('Opportunity', false, false); 
			opp.AccountId = acc.Id;
			insert opp;
		}
		catch(Exception e) { 
			System.debug('Create opportunity failed, ' + e.getMessage());
		}
		
		return opp;
	}
	
	public static Opportunity createOpportunityWithProducts(Account acc) {
		Opportunity opp = new Opportunity();
		try{
			opp = (Opportunity) DataFactory.createSObject('Opportunity', false, false); 
			opp.AccountId = acc.Id;
			opp.CurrencyIsoCode = 'USD';
			insert opp;
			
			List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
			for(Integer i = 0 ; i <2 ; i++) {
				OpportunityLineItem oli = (OpportunityLineItem) DataFactory.createSObject('OpportunityLineItem', false, false);
				oli.OpportunityId = opp.Id;
				oli.PricebookEntryId = pbe.Id;
				olis.add(oli);
			}
			insert olis;
			
		}
		catch(Exception e) { 
			throw e;
			System.debug('Create opportunity failed, ' + e.getMessage());
		}
		
		return opp;
	}
	
	public static Contact createContact(Account acc) {
		Contact con = new Contact();
		try {
			con = (Contact) DataFactory.createSObject('Contact', false, false);
			con.AccountId = acc.Id;
			insert con;
		}
		catch(Exception e){
			System.debug('Create contact failed, ' + e.getMessage());
		}
		
		return con;
	}
	
	public static Task createTask(Account acc){
		Task t = new Task();
		try {
			DataFactory.setBooleanValue(false);
			t = (Task) DataFactory.createSObject('Task', false, false);
			t.WhatId = acc.Id;
			insert t;
		}
		catch(Exception e){
			System.debug('Create Task failed, ' + e.getMessage());
		}

		return t;
	}
	
	public static Event createEvent(Account acc){
		Event e = new Event();
		try {
			DataFactory.setBooleanValue(false);
			e = (Event) DataFactory.createSObject('Event', false, false);
			e.WhatId = acc.Id;
			insert e;
		}
		catch(Exception ex){
			System.debug('Create Event failed, ' + ex.getMessage());
		}
		
		return e;
	}
	
	public static Attachment createAttachment(Account acc){
		Attachment att = new Attachment();
		try {
			att = (Attachment) DataFactory.createSObject('Attachment', false, false);
			att.Body = Blob.valueOf('abc');
			att.ParentId = acc.Id;
			insert att;
		}
		catch(Exception e){
			System.debug('Create Attachment failed, ' + e.getMessage());
		}
		
		return att;
	}

	public static Quote createQuoteWithLineItem(Opportunity opp){
						  
		Quote qu = new Quote();
		try {	
			String pbId = [Select Pricebook2Id From Opportunity Where Id =: opp.Id].Pricebook2Id;
			qu = (Quote) DataFactory.createSObject('Quote', false, false);
			qu.OpportunityId = opp.Id;
			qu.Status = 'Signed off';
			qu.Pricebook2Id = pbId;
			insert qu;
			System.debug('qu=============>' + qu);
			
			QuoteLineItem qli = (QuoteLineItem) DataFactory.createSObject('QuoteLineItem', false, false);
			qli.QuoteId = qu.Id;
			qli.PricebookEntryId = pbe.Id;
			insert qli;
		}
		catch(Exception e){
			throw e;
			System.debug('Create Quote or QuoteLineItem failed, ' + e.getMessage());
		}
		
		return qu;
	}
	
	public static AccountTeamMember createAccountTeamMember(Account acc) {
		AccountTeamMember member = new AccountTeamMember();
		try{
			member = (AccountTeamMember) DataFactory.createSObject('AccountTeamMember', false, false);
			member.AccountId = acc.Id;
			member.UserId = UserInfo.getUserId();
			insert member;
		}
		catch(Exception e) { 
			System.debug('Create AccountTeamMember failed, ' + e.getMessage());
		}
		
		return member;		
	}
	/*
	public static Product2 createProduct(){
		Product2 pr = new Product2();
		try {
			pr = (Product2) DataFactory.createSObject('Product2', false, false);
			insert pr;
		}
		catch(Exception e) { 
			throw e;
			System.debug('Create Product2 failed, ' + e.getMessage());
		}
		
		return pr;
	}
	*/
	/*
	public static Quote createQuote(Opportunity opp){
		Quote qu = new Quote();
		try {
			qu = (Quote) DataFactory.createSObject('Quote', false, false);
			insert qu;
		}
		catch(Exception e){
			System.debug('Create Quote failed, ' + e.getMessage());
		}
		
		return qu;
	}
	*/
	/*
	public static User createUser(){
		User u = new User();
		try { 
			Profile p = [Select Id From Profile Where Name like 'Sales Rep%' limit 1];
			u = (User) DataFactory.createSObject('User', false, false);
			u.ProfileId = p.Id;
			insert u;
		}
		catch(Exception e){
			System.debug('Create User failed, ' + e.getMessage());
		}
		return u;
	}
	*/
}