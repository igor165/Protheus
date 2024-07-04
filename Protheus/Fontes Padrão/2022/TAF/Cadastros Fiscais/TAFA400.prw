#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"

Function TAFA400()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( 'Regime da Empresa' )	
oBrw:SetAlias( 'T39' )
oBrw:SetMenuDef( 'TAFA400' )

T39->(DbSetOrder(1))

oBrw:Activate()
Return

Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title 'Visualizar'  Action 'VIEWDEF.TAFA400' OPERATION 2 ACCESS 0
ADD OPTION aRotina Title 'Incluir'     Action 'VIEWDEF.TAFA400' OPERATION 3 ACCESS 0
ADD OPTION aRotina Title 'Alterar'     Action 'VIEWDEF.TAFA400' OPERATION 4 ACCESS 0
ADD OPTION aRotina Title 'Excluir'     Action 'VIEWDEF.TAFA400' OPERATION 5 ACCESS 0
ADD OPTION aRotina Title 'Imprimir'    Action 'VIEWDEF.TAFA400' OPERATION 8 ACCESS 0
//ADD OPTION aRotina Title 'Copiar'      Action 'VIEWDEF.TAFA400' OPERATION 9 ACCESS 0
ADD OPTION aRotina TITLE 'Autor'       Action 'VIEWDEF.TAFA400' OPERATION 3 ACCESS 0

Return aRotina
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model
@return oModel - Objeto do Modelo MVC
@author Marcos Buschmann
@since 28/09/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruT39 :=	FWFormStruct( 1, 'T39' )
Local oStruT38 :=	FWFormStruct( 1, 'T38' )
Local oStruT36 :=	FWFormStruct( 1, 'T36' )
//Local oStruT35 :=	FWFormStruct( 1, 'T35' )

Local oModel 	 := MPFormModel():New( 'TAFA400MVC', ,{ |oModel| COMP011POS( oModel ) })


oModel:AddFields('MODEL_T39', /*cOwner*/, oStruT39)
oModel:GetModel( 'MODEL_T39' ):SetPrimaryKey( { "T39_ID" } )

oModel:AddGrid(  'MODEL_T38', 'MODEL_T39', oStruT38 )
oModel:GetModel( 'MODEL_T38' ):SetUniqueLine( { 'T38_MES' } )
oModel:GetModel( 'MODEL_T38' ):SetOptional( .T. ) //Torna a Grid opcional para inserir ou não dados

oModel:AddGrid(  'MODEL_T36', 'MODEL_T39', oStruT36 )
oModel:GetModel( 'MODEL_T36' ):SetUniqueLine( { 'T36_CODDIS', 'T36_CODLOC'} )
oModel:GetModel( 'MODEL_T36' ):SetOptional( .T. ) //Torna a Grid opcional para inserir ou não dados

/*
oModel:AddGrid(  'MODEL_T35', 'MODEL_T39', oStruT35 )
oModel:GetModel( 'MODEL_T35' ):SetUniqueLine( { 'T35_CODAJU' } )
oModel:GetModel( 'MODEL_T35' ):SetOptional( .T. ) //Torna a Grid opcional para inserir ou não dados
*/

oModel:SetRelation( 'MODEL_T38', { { 'T38_FILIAL', 'xFilial( "T38" )' }, { 'T38_ID', "T39_ID" }}, T38->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_T36', { { 'T36_FILIAL', 'xFilial( "T36" )' }, { 'T36_ID', "T39_ID" }}, T36->( IndexKey( 1 ) ) )
//oModel:SetRelation( 'MODEL_T35', { { 'T35_FILIAL', 'xFilial( "T35" )' }, { 'T35_ID', "T39_ID" }}, T35->( IndexKey( 1 ) ) )

	
Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC
@author Marcos Buschmann
@since 28/09/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel  := FWLoadModel( 'TAFA400' )

Local oStruT39 := FWFormStruct( 2, 'T39' )
Local oStruT38 := FWFormStruct( 2, 'T38' )
Local oStruT36 := FWFormStruct( 2, 'T36' )
//Local oStruT35 := FWFormStruct( 2, 'T35' )

Local oView    := FWFormView():New()

//Remover Campos da tela
oStruT39:RemoveField( 'T39_ANOREF' )
oStruT39:RemoveField( 'T39_ID' )
oStruT38:RemoveField( 'T38_ID' )
oStruT36:RemoveField( 'T36_ID' )
oStruT36:RemoveField( 'T36_IDCODI' )
oStruT36:RemoveField( 'T36_IDCODL' )
/*
oStruT35:RemoveField( 'T35_ID' )
oStruT35:RemoveField( 'T35_IDCODA' )
*/

oView:SetModel( oModel )

oView:AddField( 'VIEW_T39', oStruT39, 'MODEL_T39' )
oView:EnableTitleView( 'VIEW_T39', "Regime da Empresa")

oView:AddGrid ( 'VIEW_T38', oStruT38, 'MODEL_T38' )
oView:AddGrid ( 'VIEW_T36', oStruT36, 'MODEL_T36' )
//oView:AddGrid ( 'VIEW_T35', oStruT35, 'MODEL_T35' )

//Criando Parte Visual
oView:CreateHorizontalBox( 'FIELDST39', 30)
oView:CreateHorizontalBox( 'FIELDST38', 70)

oView:CreateFolder( 'FOLDER1','FIELDST38')
oView:AddSheet( 'FOLDER1', 'ABA01', 'Receita Bruta' )
oView:AddSheet( 'FOLDER1', 'ABA02', 'Distribuição' )
//oView:AddSheet( 'FOLDER1', 'ABA03', 'Ajustes' )

oView:CreateHorizontalBox( 'GRID_T38', 100,,, 'FOLDER1', 'ABA01' )
oView:CreateHorizontalBox( 'GRID_T36', 100,,, 'FOLDER1', 'ABA02' )
//oView:CreateHorizontalBox( 'GRID_T35', 100,,, 'FOLDER1', 'ABA03' )

oView:SetOwnerView( 'VIEW_T39', 'FIELDST39' )
oView:SetOwnerView( 'VIEW_T38', 'GRID_T38' )
oView:SetOwnerView( 'VIEW_T36', 'GRID_T36' )
//oView:SetOwnerView( 'VIEW_T35', 'GRID_T35' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} 
Funcao Validação do campo T39_PERINI, T39_PERFIN, T38_MESREG

@return oView - Objeto da View MVC
@author Marcos Buschmann
@since 28/09/2015
@version 1.0
/*/
//-------------------------------------------------------------------

Function VldTafa400(cOpc) // cOcp 1-Data Inicial, 2-Data Final, 3-Mes

Local DatInicial 	:= FwFldGet("T39_PERINI")
Local DatFim     	:= FwFldGet("T39_PERFIN")
Local DatIniT39 	:= ""
Local DatFimT39  	:= ""
Local AnoRef		:= Substr(DatInicial,4,4)
Local dDatMes
Local cIDT39		:= FwFldGet("T39_ID")

//Carregando as datas com formato Dia/Mês/Ano - Para comparações posteriores
	DatInicial := CToD('01/' + DatInicial)
	//DatFim     := If(Empty(DatFim) .OR. DatFim == "  /    ","",CToD('01/' + DatFim))

	If Empty(DatFim) .OR. DatFim == "  /    "
		DatFim := ""
	Else
		If Substr(DatFim,1,2) > '12' .OR. Substr(DatFim,1,2) < '01'
	  		Help(,,'T39_PERFIN',,,1,0)
			Return .F.
		Else
			DatFim :=	CToD('01/' + DatFim)
		EndIf
	EndIf
	
//Validação do do Mês do período Inicial e Final.
	If Substr(DtoC(DatInicial),4,2) > '12' .OR. Substr(DtoC(DatInicial),4,2) < '01'
		Help(,,'T39_PERINI',,,1,0)
		Return .F.
	EndIf

	If !Empty(DatFim)
		If Substr(DtoC(DatFim),4,2) > '12' .OR. Substr(DtoC(DatFim),4,2) < '01'
      		Help(,,'T39_PERFIN',,,1,0)
			Return .F.
		EndIf
	EndIf
	
	DbSelectArea("T39")
	DbSetOrder(1)
	If T39->( MsSeek( xFilial("T39" ) ) )
		Do Case
		Case cOpc == "1"
			While T39->(!EOF()) .AND. T39->T39_FILIAL == xFilial("T39")
				DatIniT39 := CToD('01/' + T39->T39_PERINI)
				DatFimT39 := If(Empty(T39->T39_PERFIN) .OR. T39->T39_PERFIN == "  /    ","",CToD('01/' + T39->T39_PERFIN))
			
				If cIDT39 == T39->T39_ID
					T39->(DbSkip())
					Loop
				Endif
				If DatInicial >= DatIniT39 //.AND. ( DatInicial <= DatFimT39 .OR. Empty(DatFimT39) )
					If !Empty(DatFimT39)
						If DatInicial <= DatFimT39
				      		Help(,,'T39_PERINI',,,1,0)
							Return .F.
						EndIf
					Else
			      		Help(,,'T39_PERINI',,,1,0)
						Return .F.
					EndIf
				EndIf
				T39->(DbSkip())
			EndDo
	    
	    Case cOpc == "2" 
	    	If !Empty(DatFim)
	    		If DatFim < DatInicial
		      		Help(,,'T39_PERFIN',,,1,0)
					Return .F. 
	    		EndIf
	    	EndIf 
			While T39->(!EOF()) .AND. T39->T39_FILIAL == xFilial("T39")
				DatIniT39 := CToD('01/' + T39->T39_PERINI)
				DatFimT39 := If(Empty(T39->T39_PERFIN) .OR. T39->T39_PERFIN == "  /    ","",CToD('01/' + T39->T39_PERFIN))
				
				If cIDT39 == T39->T39_ID
					T39->(DbSkip())
					Loop
				Endif
				If Empty(DatFim)
					If Empty(DatFimT39)
			      		Help(,,'T39_PERFIN',,,1,0)
						Return .F. 
					Else
						If Datinicial <= DatFimT39
				      		Help(,,'T39_PERFIN',,,1,0)
							Return .F. 
						EndIf
					EndIf
				Else
					If DatFim >= DatIniT39
						If DatFim <= DatFimT39				 
				      		Help(,,'T39_PERFIN',,,1,0)
							Return .F. 
						EndIf
						If DatInicial <= DatIniT39 .AND. DatFim >= DatIniT39
				      		Help(,,'T39_PERFIN',,,1,0)
							Return .F. 
						EndIf
					EndIf
				EndIf	
				T39->(DbSkip())
			EndDo
	    Case cOpc == "3"
	    	if Empty(DatInicial)
	      		Help(,,'T39_PERINI',,,1,0)
	    		Return .F.
	    	EndIf
	       dDatMes := CToD('01/' + cValToChar(M->T38_MES) + '/' + AnoRef )
	       If !Empty(DatFim)
		       If dDatMes < DatInicial .OR. dDatMes > DatFim
		      		Help(,,'T38_MES',,,1,0)
					Return .F. 
		       EndIf
		    Else
		       If dDatMes < DatInicial
		      		Help(,,'T38_MES',,,1,0)
					Return .F. 
		       EndIf
	        EndIf
	    EndCase 
	EndIf    
Return .T. 
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Taf400Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacões caso seja necessario gerar um XML

lJob - Informa se foi chamado por Job

@return .T.

@author Daniel Maniglia
@since 24/11/2015
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function Taf400Vld( cAlias, nRecno, nOpc, lJob ) 

Local cChave 	 := ""
Local aLogErro := {}
Local DatInicial := CToD('01/' + T39->T39_PERINI) 
Local DatFim     := If(!Empty(T39->T39_PERFIN),CToD('01/' + T39->T39_PERFIN),"")
Local cFilialAnt := T39->T39_filial 
Local cAnoRefant := T39->T39_ANOREF 
Local cIdAnt     := T39->T39_ID
Local dDatMes
Local aAreaAnt   


DbSelectArea("T38")
DbSelectArea("T36")
//DbSelectArea("T35")
DbSelectArea("T37")
DbSelectArea("C07")
//DbSelectArea("T34")

If T39->T39_PERFIN == "  /    "
	T39->T39_PERFIN := ""
EndIF	

If (T39->T39_STATUS $ (' 1')) // se vai ser consistido  
    
    aAreaAnt   := GetArea() 
    
	If Empty( T39->T39_PERINI) 
		aAdd(aLogErro,{"T39_PERINI","000010","T39",nRecno}) //campo vazio 
	EndIf    
	
	If T39->T39_PERINI > T39->T39_PERFIN .AND. !Empty(T39->T39_PERFIN) 
		aAdd(aLogErro,{"T39_TIPREG","000294","T39",nRecno})  //Data Ini > data fim 
	endif 

	If Empty( T39->T39_TIPREG)    
		aAdd(aLogErro,{"T39_TIPREG","000010","T39",nRecno}) //campo vazio 
	EndIf    

	If !(T39->T39_TIPREG $ ('01|05|06|07|08|12'))
		aAdd(aLogErro,{"T39_TIPREG","000006","T39",nRecno}) //Campo inválido 
	EndIf

	T38->(DbSetOrder(1))
	If T38->(DbSeek(xFilial("T38")+T39->T39_ID))
		WHILE !EOF() .AND. T38->T38_ID == T39->T39_ID .AND. xFilial("T38") == T39->T39_filial 
	        dDatMes    := CToD('01/' + cValToChar(T38->T38_MES) + '/' + T39->T39_ANOREF )
	        If dDatMes < DatInicial .OR. dDatMes > DatFim 
	        	aAdd(aLogErro,{"T39_TIPREG","000010","T39",nRecno}) //	
	        EndIf 
	        T38->(DbSkip())
		EndDo
	EndIF 

	T36->(DbSetOrder(1))
	If T36->(DbSeek(xFilial("T36")+T39->T39_ID)) 
		WHILE !EOF() .AND. T36->T36_ID == T39->T39_ID .AND. xFilial("T36") == T39->T39_filial 
			T37->(DbSetOrder(1))
			If !(T37->(DbSeek(xFilial("T37")+T36->T36_IDCODI)))
	        	aAdd(aLogErro,{"T36_CODDIS","000006","T36",nRecno}) 
	        EndIf 

			C07->(DbSetOrder(4))
			If !(C07->(DbSeek(xFilial("C07")+"000020"+T36->T36_IDCODL))) // "000020" - Rio de Janeiro + Codigo da localidade IBGE
	        	aAdd(aLogErro,{"T36_CODLOC","000006","T36",nRecno}) 
	        EndIf 
	        T36->(DbSkip())
		EndDo
	EndIF 

	/*
	T35->(DbSetOrder(1))
	If DbSeek(xFilial("T35")+T39->T39_ID) 
		WHILE !EOF() .AND. T35->T35_ID == T39->T39_ID .AND. xFilial("T35") == T39->T39_filial 
			T34->(DbSetOrder(1))
			If !DbSeek(xFilial("T34")+T35->T35_IDCODA)
	        	aAdd(aLogErro,{"T35_CODAJU","000006","T35",nRecno}) 
	        EndIf 
	        T35->(DbSkip())
		EndDo
	EndIF
	*/ 

	//Valida o período 
	//T39->(DbGoTop())
	DbSelectArea("T39")
	T39->(DbSetOrder(2))
	If DbSeek(xFilial("T39")) 
		While T39->(!EOF()) .AND. T39->T39_FILIAL  == cFilialAnt 
			If cIdAnt != T39->T39_ID //comparar com os demais registros da T39  
				If DatInicial >= CToD('01/' + T39->T39_PERINI) .AND.  (DatInicial <= CToD('01/' + T39->T39_PERFIN) .OR. Empty(T39->T39_PERFIN))
					Aadd( aLogErro, { "T39_PERINI", "000009", "T39", nRecno } ) //000010 - Período já existente 
		  		EndIf
		  		
		  		If T39->T39_PERFIN == "  /    "
					T39->T39_PERFIN := ""
				EndIF
		  				  		
		  		If !Empty(DatFim)
					If DatFim >= CToD('01/' + T39->T39_PERINI) .AND. DatFim <= CToD('01/' + T39->T39_PERFIN) 
						Aadd( aLogErro, { "T39_PERINI", "000009", "T39", nRecno } ) //000010 - Período já existente
					EndIf
					If DatInicial <= CToD('01/' + T39->T39_PERINI) .AND. DatFim >= CToD('01/' + T39->T39_PERINI)
						Aadd( aLogErro, { "T39_PERINI", "000009", "T39", nRecno } ) //000010 - Período já existente
					EndIf
				Else 
					If DatInicial <= CToD('01/' + T39->T39_PERFIN)
						Aadd( aLogErro, { "T39_PERINI", "000009", "T39", nRecno } ) //000010 - Período já existente
					EndIF 	
				EndIf
			EndIf 	 	
			T39->(DbSkip())
		EndDo
	EndIf 	
	RestArea(aAreaAnt)

EndIf 

Return( aLogErro )


Static Function COMP011POS(oModel)
	Local lRet			:= .T.
	Local oModelT38	:= oModel:GetModel( 'MODEL_T38' )
	Local nOpc			:= oModel:GetOperation()
	Local nX 			:= 0
	Local dDatMes		:= 0
	Local DatInicial	:= CToD('01/' + FwFldGet('T39_PERINI')) 
	Local DatFim		:= If(Empty(FwFldGet('T39_PERFIN')).OR. FwFldGet('T39_PERFIN') == "  /    ","",CToD('01/' + FwFldGet('T39_PERFIN')))
	Local cAnoRef		:= SubStr(FwFldGet('T39_PERINI'),4,4)
	
	//If !oModelT38:IsDeleted()
	If !VldTafa400("1")
  		Help( ,, 'T39_PERINI',, 'Inconsitências na Data Inicial', 1, 0 )
		Return .F.
	EndIf
	
	If !VldTafa400("2")
  		Help( ,, 'T39_PERFIN',, 'Inconsitências na Data Final', 1, 0 )
  		Return .F.
	EndIf
	
	//nOpc = 5 deleção do model
	If nOpc <> 5
		For nX := 1 To oModelT38:Length(.T.)
			oModelT38:GoLine( nX )
			
			dDatMes := CToD('01/' + FwFldGet('T38_MES',nX) + '/' + cAnoRef )
			
			If Empty(FwFldGet('T38_MES',nX)) .AND. FwFldGet('T38_RECBRU',nX) == 0 .AND. FwFldGet('T38_RECEMP',nX) == 0 .AND. !oModelT38:IsDeleted()
				oModelT38:DeleteLine()
			Else
		       If !Empty(DatFim) .AND. !oModelT38:IsDeleted()
			       If dDatMes < DatInicial .OR. dDatMes > DatFim
						Help(,, 'T38_MES',, 'Mês ' + FwFldGet('T38_MES',nX) + ' esta fora do periodo! Linha: ' + Alltrim( Str( nX ) ), 1, 0 )
						lRet := .F. 
			       EndIf
			    Else
			       If dDatMes < DatInicial
						Help( ,, 'Help',, 'Mês ' + FwFldGet('T38_MES',nX) + ' esta fora do periodo! Linha: ' + Alltrim( Str( nX ) ) )
						lRet := .F. 
			       EndIf
		        EndIf
			EndIf
		Next
	EndIf
	
Return lRet
