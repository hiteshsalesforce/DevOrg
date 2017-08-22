global class DAL_Search extends DAL_BaseObject
{
	public static final Integer MIN_LENGTH_OF_SEARCH_TERM = 3;
	private static final Integer MAX_OFFSET = 2000;
	private static final Integer MAX_PAGE_SIZE = 2000;
	public static final String LIKE_WILD_CARD_CHAR = '%';
	private static final String OFFSET_FMT = ' OFFSET {0}';
	private static final String SOQL_SEARCH_TERM_FMT = '{0}{1}{0}';
	private static final String SOSL_LIMIT_FMT = 'LIMIT {0} OFFSET {1}';
	private static final String SOSL_WILD_CARD = '*';
	private static final String FIELD_SEPARATOR = ',';
	private static final String SOQL_QUERY_FMT = 	
		'FIND :searchTerm IN ALL FIELDS ' + //search term required
		'RETURNING ' +
		'{0} ' + //object to be retrieved required
				'(' +
					'{1} ' + //Fields to return required
					'{2} ' + //where clause optional
					'{3} ' + //Order by clause optional
					'{4}' + //offset clause required
				')';
				
	private static final String SOQL_WHERE = 'WHERE ';
	private static final String SOQL_ORDER_BY = 'ORDER BY';
	
	private static final Set<String> DEFAULT_SEARCH_FIELDS = new Set<String> {DAL_BaseObject.ID_FIELD, DAL_BaseObject.NAME_FIELD};
	
	public class SearchException extends Exception{}
	
	public virtual class ResultRow 
	{			
		public String id {get;set;}
		public String text;
		
		public ResultRow(){}

		public ResultRow(SObject obj) 
		{
			this();
			assign(obj);
		}

		public virtual void assign(Sobject obj) 
		{
			id = (ID)obj.get(DAL_BaseObject.ID_FIELD);
			text = (String)obj.get(DAL_BaseObject.NAME_FIELD);
		}
	}
		
	global virtual class SearchParameters
	{
		public SObjectType objectType;
		public String searchTerm;
		public Set<String> selectFields;
		public List<String> orderByFields;
		public al.NestableCondition searchConditions;
		public Integer pageSize
		{
			get
			{
				if (pageSize == null || pageSize > MAX_PAGE_SIZE || pageSize <= 0)
					return MAX_PAGE_SIZE;
				else
					return pageSize;
			}
			set;
		}
		public Integer pageNr
		{
			get
			{
				return pageNr > 0 ? pageNr - 1 : 0;	
			}
			set;
		}
		public Type resultItemType;
		public String objectName 
		{
			get
			{
				return objectType == null ? al.StringUtils.EMPTY : objectType.getDescribe().getLocalName();
			}
		}
		
		public Integer offset
		{
			get
			{
				Integer offset = pageSize * pageNr;
				
				if (offset > MAX_OFFSET)
					return MAX_OFFSET;
				else if (offset < 0)
					return 0;
					
				return offset;
			}
		}
		
		public SearchParameters()
		{
			resultItemType = ResultRow.class;
			searchConditions = new al.AndCondition();
			selectFields = new Set<String>(DEFAULT_SEARCH_FIELDS);	
			orderByFields = new List<String>();	
		}
		
		public SearchParameters(SObjectType objectType, String searchTerm)
		{
			this();
			this.objectType = objectType;
			this.searchTerm = String.escapeSingleQuotes(searchTerm);
		}
	}
	
	global class SOQLSearchParameters extends SearchParameters
	{
		public Set<String> searchFields;
		
		public SOQLSearchParameters(SObjectType objectType, String searchTerm)
		{
			super(objectType, searchTerm);
			
			this.searchTerm = String.format(SOQL_SEARCH_TERM_FMT, new String[]{LIKE_WILD_CARD_CHAR, searchTerm});
			searchFields = new Set<String>();
			searchFields.add(DAL_BaseObject.NAME_FIELD);			
		}
	}
	
	global class SOSLSearchParameters extends SearchParameters
	{
		public SOSLSearchParameters(SObjectType objectType, String searchTerm)
		{
			super(objectType, searchTerm);	
			this.searchTerm = searchTerm + SOSL_WILD_CARD;
		}
	}
	
	global class SearchResponse 
	{
		private transient Type itemType;
		private List<ResultRow> items;
		public Integer totalItems {get; set;}
		public List<ResultRow> ItemList 
		{
			get 
			{
				return items;
			}
		}

		public SearchResponse() 
		{
			this(ResultRow.class);
		}

 	  	public SearchResponse(Type itemType) 
 	  	{
	    	this.itemType = (itemType == null ? ResultRow.class : itemType);
	    	
	    	items = new List<ResultRow>();
		}

		public ResultRow add(SObject obj) 
		{
			ResultRow result = (ResultRow)itemType.newInstance();
			
			result.assign(obj);
			
			ItemList.add(result);
			
			return result;
		}
		
		public void add(List<SObject> objects)
		{
			for(SObject obj : objects)
				add(obj);
		}
	}
	
	/*
	* @description This method will generate a paged SOQL Query up to maximum of 50,000 rows will be returned
	*/
	private static SearchResponse soqlSearch(SOQLSearchParameters parameters, List<SObject> results) 
	{
		SearchResponse searchResponse = new SearchResponse(parameters.resultItemType);

		al.OrCondition orConditions = new al.OrCondition();
		for (String searchField : parameters.searchFields) 
			orConditions.add(new al.FieldCondition(searchField, al.Operator.LIKEX, parameters.searchTerm));
				
		parameters.searchConditions.add(orConditions);

		//Check how many rows we have, if there are no rows, we do not need to run a second query
		al.SoqlBuilder soqlCount = 
			new al.SoqlBuilder()
				.selectCount()
				.fromx(parameters.objectName)
				.wherex(parameters.searchConditions);

		searchResponse.totalItems = Database.countQuery(soqlCount.toSoql());
		
		//If the total number of rows is less than the offset, it means the next query will return no results, so we can return
		if (searchResponse.totalItems <= parameters.offset)
			return searchResponse;
			
		List<al.OrderBy> orderByClause = new List<al.Orderby>();
		for (String orderByField : parameters.orderByFields)
			orderByClause.add(new al.OrderBy(orderByField));
		
		al.SoqlBuilder builder = 
			new al.SoqlBuilder()
				.selectx(parameters.selectFields)
				.fromx(parameters.objectName)
				.wherex(parameters.searchConditions)
				.orderbyx(orderByClause);
		
		builder.limitx(parameters.pageSize);

		//Generate the query append the offset manually as the Soqlbuilder class does not support offset term
		String query = builder.toSoql() + String.format(OFFSET_FMT, new String[]{String.valueOf(parameters.offset)});

		//Use a SOQL For Loop to avoid heap size limit 
		for (List<SObject> items : Database.query(query))
		{
			searchResponse.add(items);
			results.addAll(items);
		}
			
		return searchResponse;
	}

	/*
	* @description This method will generate a paged SOQL Query up to maximum of 50,000 rows will be returned
	*/
	public static SearchResponse soqlSearch(SOQLSearchParameters parameters) 
	{
		List<SObject> results = new List<SObject>();
		return soqlSearch(parameters, results);
	}

	/*
	* @description This method will generate a paged SOQL Query up to maximum of 50,000 rows will be returned
	*/
	public static List<SObject> getObjects(SOSLSearchParameters parameters) 
	{
		List<SObject> results = new List<SObject>();
		soslSearch(parameters, results);
		return results;
	}
	
	/*
	* @description This method will generate a paged SOSL Query based on the passed parameters
	*/
	public static List<SObject> getObjects(SOQLSearchParameters parameters) 
	{
		List<SObject> results = new List<SObject>();
		soqlSearch(parameters, results);
		return results;
	}

    public static List<SObject> getAll(SObjectType objectType, String searchTerm)
    {
        Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
        Map<String, Schema.SObjectField> objectFields = objectDescribe.Fields.getMap();

        DAL_Search.SOQLSearchParameters parameters = new DAL_Search.SOQLSearchParameters(objectType, searchTerm);
        
        parameters.selectFields.addAll(objectFields.keySet());
        
        return getObjects(parameters);
    }
	
	private static SearchResponse soslSearch(SOSLSearchParameters parameters, List<SObject> results) 
	{
		SearchResponse searchResponse = new SearchResponse(parameters.resultItemType);
		
		//Compose individual SOSL Clauses to be joined into final Query
		String selectClause = al.StringUtils.joinStrings(parameters.selectFields, FIELD_SEPARATOR);
		
		String whereClause = parameters.searchConditions.toSoql();
		if (String.isNotBlank(whereClause))
			whereClause = SOQL_WHERE + whereClause;
			
		String orderByClause = al.StringUtils.joinStrings(parameters.orderByFields, FIELD_SEPARATOR);
		if (String.isNotBlank(orderByClause))
			orderByClause = SOQL_ORDER_BY + orderByClause;
			
		String offsetClause = String.format(SOSL_LIMIT_FMT, new String[]{String.valueOf(parameters.pageSize), String.valueOf(parameters.offset)});
		
		//Put together the final SOSL Statement
		String query = String.Format(SOQL_QUERY_FMT, new String[]
		{
			parameters.objectName,
			selectClause == null ? DAL_BaseObject.ID_FIELD: selectClause,
			whereClause == null ? al.StringUtils.EMPTY : whereClause,
			orderByClause == null ? al.StringUtils.EMPTY : orderByClause,
			offsetClause
		});
		
		//Create a simple variable so that we can bind the search term directly into the query
		String searchTerm = parameters.searchTerm;

		List<List<SObject>> searchResults = Search.query(query);
		
		if (!searchResults.isEmpty())
		{
			searchResponse.add(searchResults[0]);
			//Since we cannot do a Count query with SOSL the total items is arbitrary unless we the results returned are less than that requested
			searchResponse.totalItems = searchResponse.ItemList.size() < parameters.pageSize ? searchResponse.ItemList.size() : MAX_PAGE_SIZE;
		}
			
		return searchResponse;
	}	
	
	/*
	* @description This method will generate a paged SOSL Query based on the passed parameters
	*/
	public static SearchResponse soslSearch(SOSLSearchParameters parameters) 
	{
		List<SObject> results = new List<SObject>();		
		return soslSearch(parameters, results);
	}
    
    public static List<SObject> soslSearch(String objectName, String searchTerm) 
    {
        DAL_Search.SOSLSearchParameters parameters = new DAL_Search.SOSLSearchParameters(UTIL_System.getSObjectTypeByName(objectName), searchTerm);
        return getObjects(parameters);
    }

    public static List<SObject> dynamicSearch(String objectName, String searchTerm, List<String> searchFields, Set<String> selectFields, al.NestableCondition additionalWhereConditions, Integer pageSize, Integer pageNr) 
    {
        DAL_Search.SOQLSearchParameters parameters = new DAL_Search.SOQLSearchParameters(UTIL_System.getSObjectTypeByName(objectName), searchTerm);
        
        //Set up addtional parameters for the search
        parameters.searchFields.addAll(searchFields);
        parameters.selectFields.addAll(selectFields);
        parameters.searchConditions = additionalWhereConditions == null ? parameters.searchConditions : additionalWhereConditions;
        parameters.pageNr = pageNr;
        parameters.pageSize = pageSize;

        return getObjects(parameters);
    }
}