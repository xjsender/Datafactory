/*******************************************************************************
 *  Test Data Factory used for preparing Test data.
 *  copyright (c) 2011 
 *  Apex Class		: DataFactory.cls 
 *  Summary			: 
 *  Refer Object    : 
 *  Author          : Mouse.liu(mouse.liu@yahoo.com)　       
 *  CreatedDate    	: 
 *  Change Log     	: 
 ******************************************************************************/	
public class DataFactory {
	
	private final static Set<string> EXCLUDE_FIELD_NAME = new Set<String> 	{'LastModifiedById', 'LastModifiedId', 'CreatedById', 
																		 	 'SystemModstamp', 'LastModifiedDate',
																		 	 'CreatedDate','ListPrice', 'TotalPrice',
																			 'RecurrenceType', 'RecurrenceTimeZoneSidKey', 
																			 'RecurrenceStartDateTime', 'RecurrenceMonthOfYear', 
																			 'RecurrenceInterval', 'RecurrenceInstance', 
																			 'RecurrenceEndDateOnly', 'RecurrenceDayOfWeekMask', 
																			 'RecurrenceDayOfMonth', 'IsRecurrence', 'DurationInMinutes',
																			 'RecurrenceStartDateOnly'};
																			 	
	private final static Set<String> FIELD_TYPE_TEXT = new Set<String>   	{'STRING', 'TEXTAREA','PHONE','URL','ENCRYPTEDSTRING'};
	private final static Set<String> FIELD_TYPE_PICKLIST = new Set<String>  {'MUTIPICKLIST','PICKLIST'};															    	 
	private final static Set<String> FIELD_TYPE_EMAIL = new Set<String>  	{'EMAIL'};
	private final static Set<String> FIELD_TYPE_NUMBER = new Set<String> 	{'INTEGER', 'PERCENT', 'DECIMAL', 'DOUBLE', 'CURRENCY'};
	private final static Set<String> FIELD_TYPE_TIME = new Set<String>   	{'TIME','DATETIME'};
	private final static Set<String> FIELD_TYPE_DATE = new Set<String>      {'DATE'};
	private final static Set<String> FIELD_TYPE_BOOLEAN = new Set<String>	{'BOOLEAN'};
	
	//给用户提供可以修改不同数据类型的值的接口。
	private static String emailValue = 'mouse.liu@yahoo.com';
	private static Integer numberValue = 90;
	private static Boolean booleanValue = true;
	private static Date dateValue = System.today();
	private static Datetime datetimeValue = System.now();
	
	private static Map<String, Id> sobjectNameToIdMap = new Map<String, Id>();
	
	public static void setEmail(String inputEmail){
		emailValue = inputEmail;
	}
	
	public static void setNumberValue(Integer inputNumberValue){
		numberValue = inputNumberValue;
	}
	
	public static void setBooleanValue(Boolean inputBooleanValue){
		booleanValue = inputBooleanValue;
	}
	
	public static void setDateValue(Date inputDateValue){
		dateValue = inputDateValue;
	}
	
	public static void setDatetimeValue(Datetime inputDatetimeValue){
		datetimeValue = inputDatetimeValue;
	}
	
	public class UnsupportedObjectTypeException extends Exception{}
	/*
	 *	objName ===> 'Account', cascade is true means that it will create all lookup ReferenceTo SObjects.
	 *	If isQuery is true, query the record from SFDC，if have，then CLONE。if not，then create a new one.
	 */
	public static SObject createSObject(String objName, Boolean cascade, Boolean isQuery){
		
		Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 		
		SObjectType soType = gd.get(objName);
		if(soType == null){
			throw new UnsupportedObjectTypeException(System.label.UnsupportedSObjectTypeException + ': ' + objName);
		}
		
		SObject so = soType.newSObject();
		if(isQuery){
			try{
				so = Database.query(DataFactory.getSOQLFieldlist( soType ));
				so = so.clone(false);
				setFieldValue(so, so.getSObjectType(), false);
				System.debug( so.getSObjectType().getDescribe().getName() +'============>' + so );
			}catch(QueryException e){
				System.debug('System.QueryException: List has no rows for assignment to SObject : [' + objName + ']' );
				setFieldValue( so, soType , cascade );
			}
		}else{
			setFieldValue( so, soType , cascade );
		}

		return so;
	}
	
	public static void setFieldValue(SObject so, SObjectType soType, Boolean cascade){	
		
		String objName = so.getSObjectType().getDescribe().getName();
		Map<String, Schema.SObjectField> fieldNamesMap = soType.getDescribe().fields.getMap();
		for (Schema.SObjectField fName : fieldNamesMap.values()){		
			Schema.DescribeFieldResult des = fName.getDescribe();	
			if(EXCLUDE_FIELD_NAME.contains(des.getName())){
				continue;
			}
			
			if(des.isCreateable()){
			   	// System.debug('Field Name===========> ' + des.getName()); 
			   	if(FIELD_TYPE_TEXT.contains(des.getType().name())){
			   		// generally，Just Text field type maybe the Unique Field，so We need to add the unique appendix to it.
			   		// If the String field length exteed the maximum length
			   		if (des.getName() == 'Username' && objName == 'User') {
			   		    so.put(des.getName(), emailValue + '.test'); 	
			   		}
			   		else {
				   		String str = des.getType().name() + System.now();
				   		Integer endIndex = str.length() >= des.getLength() ? des.getLength() : str.length();
				   		so.put(des.getName(), str.subString(0, endIndex));
			   		}
			   	}else if(FIELD_TYPE_EMAIL.contains(des.getType().name())) {   	
			   		so.put(des.getName(), emailValue);
			   	}else if(FIELD_TYPE_BOOLEAN.contains(des.getType().name())) {
			   		so.put(des.getName(), booleanValue);
			   	}else if(FIELD_TYPE_NUMBER.contains(des.getType().name())) {
			   		so.put(des.getName(), numberValue);
			   	}else if(FIELD_TYPE_TIME.contains(des.getType().name())) {
			   		so.put(des.getName(), datetimeValue);
			   	}else if(FIELD_TYPE_DATE.contains(des.getType().name())) {
			   		so.put(des.getName(), dateValue);
			   	}else if(FIELD_TYPE_PICKLIST.contains(des.getType().name())) {
			   		so.put(des.getName(), des.getPicklistValues()[0].getValue());
			   	}else if (des.getType() == Schema.DisplayType.Reference) {
			   		
					string referenceObjectType = des.getReferenceTo()[0].getDescribe().getName();
					if (referenceObjectType == 'RecordType') {
						setRecordType(so);
					}else if (referenceObjectType.equalsIgnoreCase('USER')) {
						so.put(des.getName(), UserInfo.getUserId());
					}else if (!des.isNillable() && cascade && referenceObjectType != objName) {
						// TODO avoid infinite loop for same-type references
						System.debug('ObjName and FieldName: ===================>' + referenceObjectType + ', ' + des.getName());
						if(sobjectNameToIdMap.get(referenceObjectType) == null){
							SObject reference = createSObject(referenceObjectType);
							System.debug('reference=======================>' + reference);
							insert reference;
							sobjectNameToIdMap.put(referenceObjectType, reference.Id);
							so.put(des.getName(), reference.Id);
						}else{
							so.put(des.getName(), sobjectNameToIdMap.get(referenceObjectType));
						}
					}
				} 
			}
		}
	}
	
	private static void setRecordType(SObject obj) {
		List<Schema.RecordTypeInfo> recordTypes = obj.getSObjectType().getDescribe().getRecordTypeInfos();
		
		if (recordTypes.size() > 1) { // all objects have default Master type
			System.debug('RecordTypes===================>' + recordTypes);
			for (Schema.RecordTypeInfo recordType : recordTypes) {
				if (recordType.isAvailable() && recordType.isDefaultRecordTypeMapping()) {
					obj.put('RecordTypeId', recordType.getRecordTypeId());
				}
			}
		}
		
	}
	
	public static SObject createSObject(string objectType) {
		return createSObject(objectType, true, true);
	}
	
	public static String getSOQLFieldlist(SObjectType soType){
		Map<String, Schema.SObjectField> fieldNamesMap = soType.getDescribe().fields.getMap();
		String soql = '';
		
		for (Schema.SObjectField fName : fieldNamesMap.values()){	
			soql = soql + fName.getDescribe().getName()+',';
		}
		
		soql = soql.subString(0,soql.length()-1);
		soql = 'SELECT '+ soql +' FROM '+ soType.getDescribe().getName() +' LIMIT 1';
		System.debug('SOQL========================>'+ soql);
		
		return soql;
	}
	
	// Gets the object record type name according to the recordTypeId.
	public static String getRecordtypeNameById(String objectName, Id recordTypeId) {
		Schema.SobjectType d = Schema.getGlobalDescribe().get(objectName);
		Map<Id, Schema.RecordTypeInfo> rtMapById = d.getDescribe().getRecordTypeInfosById();
		Schema.RecordTypeInfo rtById = rtMapById.get(recordTypeId);
		
		return rtById.getName();
	}
	
	// Gets the object record type id according to the recordType name.
	public static String getRecordtypeIdByName(String objectName, String recordTypeName) {
		Schema.SobjectType d = Schema.getGlobalDescribe().get(objectName);
		Map<String, Schema.RecordTypeInfo> rtMapByName = d.getDescribe().getRecordTypeInfosByName();
		Schema.RecordTypeInfo rtByName = rtMapByName.get(recordTypeName);
		
		return rtByName.getRecordTypeId();
	}

}