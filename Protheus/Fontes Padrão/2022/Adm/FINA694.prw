#INCLUDE 'Protheus.ch'
#INCLUDE 'FWMVCDEF.ch'
#INCLUDE 'Fileio.ch'
#INCLUDE "FINA694.ch"

#DEFINE MILE_IMPORT '1'

/* Status apra os itens do extrato */
#DEFINE STS_IDINEXISTENTE		"0"		/* Nao possui correspondente no cadastro de viagens. */
#DEFINE STS_DIVERGENTE			"1"		/* ID encontrado no cadastro, mas os dados apresentam divergencias */		
#DEFINE STS_IDEXISTENOSISTEMA	"2"		/* ID encontrato no cadastro, sem divergencias entre os dados. */
#DEFINE STS_CONCILIADO			"3"		/* Item conciliado, com documento gerado. */
#DEFINE STS_CONCILIADOMANUAL	"4"		/* Item conciliado, mas com a viagem informada pelo usuario. */
#DEFINE STS_CONCILIADOERRO		"5"		/* Item conciliado, mas a viagem nao foi encontrada no sistema.*/
#DEFINE STS_JACONCILIADO		"6"		/* Item ja foi conciliado.*/
Static _oFINA694
STATIC __cNameArq	:= ''
Static __IteClv		:= .F.

/*
----------------------------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} FINA694
Rotina para tratamento de extratos com dados referentes à viagens: impprtação e consolidação.
@author William Matos
@since 03/07/15
/*/
/*--------------------------------------------------------------------------------------------------------------------*/
Function FINA694()
Local oBrowse	:= Nil
Local aCampos	:= {}

__IteClv	:= FWN->( ColumnPos("FWN_ITECTA") ) > 0 .and. FWN->( ColumnPos("FWN_CLVL") ) > 0

aCampos := {"FWN_CODIGO","FWN_EBTA","FWN_NUMFAT","FWN_DTFAT","FWN_CCUSTO","FWN_VTRANS","FWN_VIAGEM"}

If __IteClv
	FwFreeArray(aCampos)
	aCampos := {}
	aCampos := {"FWN_CODIGO","FWN_EBTA","FWN_NUMFAT","FWN_DTFAT","FWN_CCUSTO","FWN_VTRANS","FWN_VIAGEM","FWN_CLVL","FWN_ITECTA"}  
Endif

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("FWN")
oBrowse:SetDescription(STR0023) //"Consolidação de viagens"
oBrowse:DisableDetails()
oBrowse:SetOnlyFields(aCampos)
oBrowse:AddLegend("Empty(FWN_CONFER)","GREEN",STR0001) //"Não conciliado"
oBrowse:AddLegend("!Empty(FWN_CONFER)","RED",STR0002) //"Conciliado"
oBrowse:SetImpTXT(.F.)
oBrowse:SetExpTXT(.F.)
oBrowse:Activate()
oBrowse:Destroy()
oBrowse := Nil
Asize(aCampos,0)
aCampos := Nil
DelClassIntF()
	
Return()

/*
----------------------------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} ModelDef
Definição do modelo de dados - Conciliador EBTA
@author William Matos
@since 03/07/15
/*/
/*--------------------------------------------------------------------------------------------------------------------*/
Static Function ModelDef()
Local oModel	:= MPFormModel():New("FINA694",/*Pre*/,/*Pos*/,{|oModel| FN694GrvMod(oModel)}/*Commit/*,/*bCancel*/)
Local oFLQ		:= F694Struct()
Local oFWN		:= FWFormStruct(1,"FWN")

dbSelectArea("FLQ")

//Adiciona os campos para status e para a viagem consolidada */
oFWN:AddField(" ","","STSVIAG","BT",10,0,{|| .T.},NIL,{},NIL,FwBuildFeature(STRUCT_FEATURE_INIPAD,"'DISABLE'"),NIL,NIL,.T.)
oFWN:AddField(" ","","STATUS","C",1,0,{|| .T.},NIL,{},NIL,FwBuildFeature(STRUCT_FEATURE_INIPAD,"' '"),NIL,NIL,.T.)
oFWN:AddField(" ","","SEPCOL", "BT",10, 0,{|| .T.},NIL,{},NIL,FwBuildFeature(STRUCT_FEATURE_INIPAD,"'LBOK'"),NIL,NIL,.T.)
oFWN:AddField(AllTrim(SX3->(RetTitle("FL6_VIAGEM"))),"","FL6_VIAGEM","C",TamSX3("FL6_VIAGEM")[1],0,{|| .T.},NIL,{},NIL,FwBuildFeature(STRUCT_FEATURE_INIPAD,"' '"),NIL,NIL,.T.)
oFWN:AddField(AllTrim(SX3->(RetTitle("FL6_IDRESE"))),"","FL6_IDRESE","C",TamSX3("FL6_IDRESE")[1],0,{|| .T.},NIL,{},NIL,FwBuildFeature(STRUCT_FEATURE_INIPAD,"' '"),NIL,NIL,.T.)
oFWN:AddField(AllTrim(SX3->(RetTitle("FL6_DTCRIA"))),"","FL6_DTCRIA","C",TamSX3("FL6_DTCRIA")[1],0,{|| .T.},NIL,{},NIL,FwBuildFeature(STRUCT_FEATURE_INIPAD,"' '"),NIL,NIL,.T.)
oFWN:AddField(AllTrim(SX3->(RetTitle("FL6_TOTAL"))), "","FL6_TOTAL" ,"N",TamSX3("FL6_TOTAL")[1], 0,{|| .T.},NIL,{},NIL,FwBuildFeature(STRUCT_FEATURE_INIPAD,"0"),  NIL,NIL,.T.)
oFWN:AddField(AllTrim(SX3->(RetTitle("FLH_CC"))),    "","FLH_CC",    "C",TamSX3("FLH_CC")[1],    0,{|| .T.},NIL,{},NIL,FwBuildFeature(STRUCT_FEATURE_INIPAD,"' '"),NIL,NIL,.T.)
oFWN:AddField(AllTrim(SX3->(RetTitle("FLH_ITECTA"))),    "","FLH_ITECTA",    "C",TamSX3("FLH_ITECTA")[1],    0,{|| .T.},NIL,{},NIL,FwBuildFeature(STRUCT_FEATURE_INIPAD,"' '"),NIL,NIL,.T.)
oFWN:AddField(AllTrim(SX3->(RetTitle("FLH_CLVL"))),    "","FLH_CLVL",    "C",TamSX3("FLH_CLVL")[1],    0,{|| .T.},NIL,{},NIL,FwBuildFeature(STRUCT_FEATURE_INIPAD,"' '"),NIL,NIL,.T.)
oFWN:SetProperty("FL6_IDRESE",MODEL_FIELD_WHEN,{|oModel| FN694PreLn(oModel)})

oFWN:AddTrigger( "FWN_VTRANS" , "FWN_VTRANS"	, {|| .T. }  , {|oModel| F694Gat(oModel) }  )
//Inicializador padrão do campo FWN_ARQUIV.
oFWN:SetProperty("FWN_ARQUIV", MODEL_FIELD_INIT,FwBuildFeature( STRUCT_FEATURE_INIPAD,'FN694IniCp()' ) )

oModel:AddFields("FLQMASTER",/*cOwner*/,oFLQ)
oModel:AddGrid('FWNDETAIL','FLQMASTER',oFWN,{|oModel,nLine,cAction,cField,xValue,xOldValue| FN694VerRes(oModel,nLine,cAction,cField,xValue,xOldValue)})

oModel:GetModel("FLQMASTER"):SetOnlyQuery( .T. )

oModel:GetModel("FWNDETAIL"):SetLoadFilter(,"FWN_CONFER = ' '")

oModel:SetRelation("FWNDETAIL",{{"FWN_FILIAL","xFilial('FWN')"}})
oModel:SetPrimaryKey({'FLQ_FILIAL','FLQ_CONFER'})
oModel:SetActivate({|oModel| FINA694Act(oModel)})

Return oModel

/*
----------------------------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} ViewDef 
Definição do interface - Conciliador EBTA
@author William Matos
@since 03/07/15
/*/
/*--------------------------------------------------------------------------------------------------------------------*/
Static Function ViewDef()
Local oFLQ		:= FWFormStruct(2, 'FLQ')
Local oModel	:= FWLoadModel("FINA694")
Local oFWN		:= FWFormStruct(2,'FWN', { |x| ALLTRIM(x) $ 'FWN_IDRESE|FWN_CCUSTO|FWN_NUMFAT|FWN_EBTA|FWN_VTRANS'})
Local oView		:= FWFormView():New()
Local aMVPar	:= F694LoadPer(.F.)
Local nCpo		:= 0

If __IteClv
	FwFreeObj(oFWN)
	oFWN := NIL
	oFWN := FWFormStruct(2,'FWN', { |x| ALLTRIM(x) $ 'FWN_IDRESE|FWN_CCUSTO|FWN_NUMFAT|FWN_EBTA|FWN_VTRANS|FWN_CLVL|FWN_ITECTA'})
Endif	

//
oView:SetModel( oModel )
/*
Adiciona os campos para status e para a viagem consolidada */
oFWN:AddField('STSVIAG',   '01',             " "," ",{},'C','@BMP',NIL,'',.F.,NIL,NIL,{},NIL,'{|| "DISABLE"}',.T.,NIL)
oFWN:AddField('SEPCOL',    StrZero(++nCpo,2)," "," ",{},'C','@BMP',NIL,'',.F.,NIL,NIL,{},NIL,'{|| "LBOK"}',.T.,NIL)
oFWN:AddField('FL6_IDRESE',StrZero(++nCpo,2),SX3->(RetTitle("FL6_IDRESE"))," ",{},'C','',NIL,'VIAG',.T.,NIL,NIL,{},NIL,'{|| " "}',.T.,NIL)
oFWN:AddField('FL6_TOTAL', StrZero(++nCpo,2),SX3->(RetTitle("FL6_TOTAL")), " ",{},'N',PesqPict("FL6","FL6_TOTAL"),NIL,'',.F.,NIL,NIL,{},NIL,'{|| 0}',.T.,NIL)
oFWN:AddField('FLH_CC',    StrZero(++nCpo,2),SX3->(RetTitle("FLH_CC")),    " ",{},'C','',NIL,'',.F.,NIL,NIL,{},NIL,'{|| " "}',.T.,NIL)
oFWN:AddField('FLH_ITECTA',StrZero(++nCpo,2),SX3->(RetTitle("FLH_ITECTA")),    " ",{},'C','',NIL,'',.F.,NIL,NIL,{},NIL,'{|| " "}',.T.,NIL)
oFWN:AddField('FLH_CLVL',  StrZero(++nCpo,2),SX3->(RetTitle("FLH_CLVL")),    " ",{},'C','',NIL,'',.F.,NIL,NIL,{},NIL,'{|| " "}',.T.,NIL)

oFLQ:RemoveField('FLQ_STATUS')
oFLQ:RemoveField('FLQ_DATA')
oFLQ:RemoveField('FLQ_PEDIDO')
oFLQ:RemoveField('FLQ_DNATUR')
oFLQ:RemoveField('FLQ_DCPAG')
//
//Remove campos da View
//FL6 - Conferencia
//Gera titulo CP
If aMVPar[1] == 1
	oFLQ:RemoveField('FLQ_PEDIDO')
	oFLQ:RemoveField('FLQ_COND')
	oFLQ:RemoveField('FLQ_ORIGEM')
	oFLQ:RemoveField('FLQ_PREFIX')
	oFLQ:RemoveField('FLQ_NUMTIT')
	oFLQ:RemoveField('FLQ_PARC')
//Gera pedido de compra
ElseIf aMVPar[1] == 2	
	oFLQ:RemoveField( 'FLQ_PREFIX' )
	oFLQ:RemoveField( 'FLQ_NUMTIT' )
	oFLQ:RemoveField( 'FLQ_PARC'   )
	oFLQ:RemoveField( 'FLQ_VENCTO' )
	oFLQ:RemoveField( 'FLQ_NATUR'  )
	oFLQ:RemoveField( 'FLQ_ORIGEM' )
//Gera Nota fiscal de Entrada
ElseIf aMVPar[1] == 3
	oFLQ:RemoveField( 'FLQ_PEDIDO' )
	oFLQ:RemoveField( 'FLQ_VENCTO' )
	oFLQ:RemoveField( 'FLQ_ORIGEM' )			
	oFLQ:RemoveField( 'FLQ_PARC'   )
	oFLQ:SetProperty('FLQ_PREFIX',MVC_VIEW_TITULO,SX3->(RetTitle("FLQ_PREFIX")))
	oFLQ:SetProperty('FLQ_NUMTIT',MVC_VIEW_TITULO,SX3->(RetTitle("FLQ_NUMTIT")))
Endif

oFWN:SetProperty('STSVIAG' 		,MVC_VIEW_ORDEM,'01')
oFWN:SetProperty('FWN_NUMFAT' 	,MVC_VIEW_ORDEM,'02')
oFWN:SetProperty('FWN_EBTA' 	,MVC_VIEW_ORDEM,'03')
oFWN:SetProperty('FWN_IDRESE' 	,MVC_VIEW_ORDEM,'04')
oFWN:SetProperty('FWN_CCUSTO' 	,MVC_VIEW_ORDEM,'05')

If __IteClv
	oFWN:SetProperty('FWN_ITECTA' 	,MVC_VIEW_ORDEM,'06')
	oFWN:SetProperty('FWN_CLVL' 	,MVC_VIEW_ORDEM,'07')
	oFWN:SetProperty('FWN_VTRANS' 	,MVC_VIEW_ORDEM,'08')
	oFWN:SetProperty('SEPCOL'	 	,MVC_VIEW_ORDEM,'09')
	oFWN:SetProperty('FL6_IDRESE' 	,MVC_VIEW_ORDEM,'10')
	oFWN:SetProperty('FL6_TOTAL'	,MVC_VIEW_ORDEM,'11')
	oFWN:SetProperty('FLH_CC' 		,MVC_VIEW_ORDEM,'12')
	oFWN:SetProperty('FLH_ITECTA' 	,MVC_VIEW_ORDEM,'13')
	oFWN:SetProperty('FLH_CLVL' 	,MVC_VIEW_ORDEM,'14')
Else
	oFWN:SetProperty('FWN_VTRANS' 	,MVC_VIEW_ORDEM,'06')
	oFWN:SetProperty('SEPCOL'	 	,MVC_VIEW_ORDEM,'07')
	oFWN:SetProperty('FL6_IDRESE' 	,MVC_VIEW_ORDEM,'08')
	oFWN:SetProperty('FL6_TOTAL'	,MVC_VIEW_ORDEM,'09')
	oFWN:SetProperty('FLH_CC' 		,MVC_VIEW_ORDEM,'10')
	oFWN:SetProperty('FLH_ITECTA' 	,MVC_VIEW_ORDEM,'11')
	oFWN:SetProperty('FLH_CLVL' 	,MVC_VIEW_ORDEM,'12')
Endif	

//
oFWN:SetProperty('FWN_NUMFAT'	,MVC_VIEW_CANCHANGE, .F.)
oFWN:SetProperty('FWN_EBTA'		,MVC_VIEW_CANCHANGE, .F.)
oFWN:SetProperty('FWN_IDRESE'	,MVC_VIEW_CANCHANGE, .F.)

oFWN:SetProperty("FL6_IDRESE"	,MVC_VIEW_LOOKUP,"CONVAG")

//*/
oView:CreateHorizontalBox('BOX_FLQ',030)
oView:CreateHorizontalBox('BOX_FWN',070)
//
oView:AddField("VIEW_FLQ", oFLQ, "FLQMASTER")
oView:AddGrid('VIEW_FWN',oFWN,'FWNDETAIL')
oView:SetNoInsertLine('VIEW_FWN')
oView:SetNoDeleteLine('VIEW_FWN')
//
oView:SetOwnerView('VIEW_FLQ','BOX_FLQ')
oView:SetOwnerView('VIEW_FWN','BOX_FWN')
oView:EnableTitleView('VIEW_FLQ' , 'Conciliação' ) 
//
oView:EnableTitleView('VIEW_FWN' , 'Viagens Conciliadas' ) 

oView:AddUserButton( STR0035,'' , {|oView| FN694Legenda()})		//"Legenda"

oView:SetAfterViewActivate({|oView| Processa({|| FN694Consol(oView)},STR0007,,.F.)})		//"Verificando as viagens pendentes."

oView:ShowUpdateMsg(.F.)		//nao exibe a mensagem de atualizacao

oView:SetViewProperty("VIEW_FWN", "GRIDFILTER"	, {.T.})
oView:SetViewProperty("VIEW_FWN", "GRIDSEEK"		, {.T.})

Return oView

/*
----------------------------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} FN694Import 
Importação do Arquivo CSV|TXT
@author William Matos
@param Obj - Processamento
@since 06/07/15
/*/
/*--------------------------------------------------------------------------------------------------------------------*/
Function FN694Import(oProcess)
Local oModel		:= Nil
Local nRet 		:= 0
Local oMILE		:= Nil 
Local cLayout 	:= ""
Local cArquivo	:= ""
Local aLines		:= {}
Local oFile		:= Nil
Local oTMP			:= Nil
Local cArq			:= ""
Local cBuffer		:= ""
Local nX			:= 0
Local cAux			:= ""
Local cTmp			:= ""
Local nOutfile  	:= 0
Local nLinha		:= MV_PAR03
Local cSepar    	:= IIf(MV_PAR04 == 1, "I;","I")

If F694NFile(MV_PAR02)
	//
	oMILE		:= FWMile():New(.T.)
	cTmp		:= CurDir() + 'TMP' + DTOS(Date()) + '.totvs'
	nOutfile  	:= FCREATE(cTmp, FC_NORMAL)
	//
	cLayout	:= MV_PAR01 
	FT_FUSE( MV_PAR02 )
	FT_FGOTOP()
	
	While !(FT_FEOF())
		nX++
		If nX >= nLinha
			cBuffer := Alltrim(FT_FREADLN())
			cAux 	:= cSepar + cBuffer + CRLF  
			//MV_PAR04 = 1 - Aéreo|2 - Hotel.
			If MV_PAR04 = 1 .OR. ( MV_PAR04 = 2 .AND. Substr(cAux,38,2) == "02" ) 
				FWRITE( nOutfile , cAux )
			EndIf
			
		EndIf
		FT_FSkip()
	EndDo
	
	FCLOSE(nOutfile)
	
	If oMILE:SetLayout(cLayout)
		oMILE:SetTXTFile(cTmp) //Definição de qual arquivo será processado.
		oMILE:SetOperation(MILE_IMPORT) 
		If oMILE:Activate()
			oMILE:Import()
			If oMile:Error()
				Help("  ",1,"ERRO",,oMile:GetError(),1,0)
			EndIf	
			
		EndIf 
	EndIf
	oMILE:DeActivate()
	
	FErase(cTmp)
	__cNameArq := ''
Else
	Help(" ",1,"F694IMPORT",,STR0038 + __cNameArq + STR0039,1,0)	
EndIf	

Return 


/*
----------------------------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} Menudef
definie as opções do menu
@author Marcello Gabriel
@since 08/07/15
/*/
/*--------------------------------------------------------------------------------------------------------------------*/
Static Function MenuDef()     
Local aRotina	:= {}

ADD OPTION aRotina TITLE STR0003 ACTION 'FN694NovExt()' OPERATION 3 ACCESS 0 //"Importar extrato de viagens"
ADD OPTION aRotina TITLE STR0004 ACTION 'FN694VIEW()' OPERATION 4 ACCESS 0 //"Conciliar viagens"
ADD OPTION aRotina TITLE STR0044 ACTION 'FN694Del' OPERATION 5 ACCESS 0 //"Excluir"

Return(Aclone(aRotina))
 
/*
----------------------------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} FN694NovExt
definie as opções do menu
@author William Matos
@since 10/07/15
/*/ 
/*--------------------------------------------------------------------------------------------------------------------*/
Function FN694NovExt()

Local oProcesso := Nil
Local bProcess 	:= { |oObj|, FN694Import(oObj) } 

oProcesso := tNewProcess():New("FINA694",; //Nome da função
									STR0006,; //"Conciliador"
									bProcess,; //Bloco de execução
									STR0036,; //Descrição da rotina ###"Efetua a importação do arquivo com o extrato de despesas de viagens, disponibilizando-as para conciliação."
									"FINA694",;// Pergunte
									{},; //Informações adicionais
									.T.,; //Se cria um novo painel auxiliar
									5,; //Tamanho do painel
									'',; //"Descrição do painel Auxiliar"
									.T.) //Se cria uma regua de processamento

Return  

/*
----------------------------------------------------------------------------------------------------------------------*/ 
/*/{Protheus.doc} FN694Consol 
Relaciona os registros de viagens com os do extrato.

@param oModel - modelo onde será exibida a conciliação.
@param cExtrato - código do extrato de viagens EBTA

@author Marcello Gabriel
@since 07/07/2015
/*/
/*--------------------------------------------------------------------------------------------------------------------*/
Function FN694Consol(oView)
Local nTipoDoc	:= F694LoadPer(.F.)[1]
Local nX		:= 0
Local nTamFWN	:= 0
Local lRet		:= .F.
Local oModel	:= Nil
Local aStatus	:= Nil
Local aArea		:= Nil
Local oModFWN	:= Nil
Local oModelFLQ	:= Nil

oModel := oView:GetModel()
oModelFLQ := oModel:GetModel("FLQMASTER")

//Carregamento da Fields (FLQ)
oModelFLQ:LoadValue("FLQ_FORNEC" ,  SuperGetMv("MV_RESCAGE",,"") )
oModelFLQ:LoadValue("FLQ_LOJA"   ,  SuperGetMv("MV_RESLAGE",,"") )
oModelFLQ:LoadValue("FLQ_NOMEFO" ,  F686NomFor()			 )
oModelFLQ:LoadValue("FLQ_NATUR"  ,  SuperGetMv("MV_RESNTCF",,"") )
oModelFLQ:LoadValue("FLQ_TPPGTO" ,  Alltrim(Str( nTipoDoc )))
oModelFLQ:LoadValue("FLQ_ORIGEM" ,  "FINA694"  )
oModelFLQ:LoadValue("FLQ_CONFER" ,  GETSXENUM("FLQ", "FLQ_CONFER")   )

If nTipoDoc > 1
	oModelFLQ:LoadValue("FLQ_VENCTO"  , dDatabase + 1		 )
EndIf

aArea := GetArea()

oModFWN := oModel:GetModel("FWNDETAIL")
oModFWN:SetNoInsertLine(.F.)

nTamFWN := oModFWN:Length()

oModelFLQ:SetValue('FLQ_TOTAL', 0)

ProcRegua(nTamFWN)

For nX := 1 To nTamFWN
	oModFWN:GoLine(nX)
	
	IncProc(Alltrim(STR0011) + ": " + oModFWN:GetValue("FWN_IDRESE"))		//"Verificando dados da viagem"
	
	lRet := FN694VerViag(oModFWN,@aStatus)
	
	/* dados da viagem */
	oModFWN:SetValue("SEPCOL",FN694ImgSt(aStatus[1],2))
	oModFWN:SetValue("FL6_VIAGEM",aStatus[3])
	oModFWN:SetValue("FL6_IDRESE",aStatus[2])
	oModFWN:SetValue("FLH_CC",aStatus[4])
	oModFWN:SetValue("FL6_TOTAL",aStatus[5])
	oModFWN:SetValue("FLH_ITECTA",aStatus[6])
	oModFWN:SetValue("FLH_CLVL",aStatus[7])
	/* dados do extrato */
	oModFWN:SetValue("STSVIAG",FN694ImgSt(aStatus[1],1))
	oModFWN:SetValue("STATUS",aStatus[1])
	oModFWN:SetValue("FWN_VIAGEM",aStatus[3])
	//Atualiza o Total.
	If lRet
		oModelFLQ:SetValue('FLQ_TOTAL', oModelFLQ:GetValue('FLQ_TOTAL') + oModFWN:GetValue("FWN_VTRANS"))
	Endif
Next
RestArea(aArea)
Asize(aArea,0)
aArea := Nil
/*-*/
oModFWN:SetNoInsertLine(.T.)
oModFWN:GoLine(1)
/*-*/
oView:Refresh()
Return()

/*
----------------------------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} FN694verVlr 
Verifica se o valor informado corresponde ao valor total da viagem. 

@param nVlrViag - valor informado
@param cViagem - código (interno) da viagem.

@author Marcello Gabriel
@since 07/07/2015
/*/
/*--------------------------------------------------------------------------------------------------------------------*/
Function FN694VerVlr(nVlrViag,cIdRese,nValor)
Local lRet		:= .F.
Local cQuery	:= ""
Local cAliasFL6	:= ""
Local cAliasAtu	:= ""

Default nValor	:= 0

cAliasAtu := Alias()
cQuery := " SELECT FL6_TOTAL TOTALVIAGEM FROM " + RetSqlName("FL6")
cQuery += " WHERE FL6_FILIAL = '" + xFilial("FL6") + "'"
cQuery += " AND FL6_IDRESE = '" + cIdRese + "'"
cQuery += " AND FL6_TIPO = '1'"				//somnente itens tipo "voo"
cQuery += " AND FL6_VCONFE < FL6_TOTAL"
cQuery += " AND D_E_L_E_T_= ' '"

cQuery := ChangeQuery(cQuery)
cAliasFL6 := GetNextAlias()
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasFL6,.F.,.T.) 
If !((cAliasFL6)->(Eof()))
	nValor := (cAliasFL6)->TOTALVIAGEM 
	lRet := ((cAliasFL6)->TOTALVIAGEM = nVlrViag)
Endif
DbSelectArea(cAliasFL6)
DbCloseArea()
DbSelectArea(cAliasAtu)
Return(lRet)

/*
----------------------------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} FN694verCC 
Verifica se as entidades contábeis informadas correspondem aos que estão no rateio da viagem. 

@param nVlrViag - centros de custos
@param cViagem - código (interno) da viagem.

@author Marcello Gabriel
@since 07/07/2015
/*/
/*--------------------------------------------------------------------------------------------------------------------*/
Function FN694VerCC(cCC,cViagem,cCCusto,cEntidade)
Local lRet		:= .F.
Local cQuery	:= ""
Local cAliasFLH	:= ""
Local cAliasAtu	:= ""
Local cCampo	:= ""

Default cCCusto	:= ""
Default cEntidade := "CTT"

If cEntidade == "CTT"
	cCampo := "FLH_CC"
ElseIf cEntidade == "CTD"
	cCampo := "FLH_ITECTA"
ElseIf cEntidade == "CTH"
	cCampo := "FLH_CLVL"
Endif

cAliasAtu := Alias()
cAliasFLH := GetNextAlias()
cQuery := " SELECT "+cCampo+" FROM " + RetSqlName("FLH")
cQuery += " WHERE FLH_FILIAL = '" + xFilial("FLH") + "'"
cQuery += " AND FLH_VIAGEM = '" + cViagem + "'"
cQuery += " AND "+cCampo+" = '" + cCC + "'"
cQuery += " AND D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasFLH,.F.,.T.) 
lRet := !((cAliasFLH)->(Eof()))
DbSelectArea(cAliasFLH)
DbCloseArea()
/*-*/
If lRet
	cCCusto := cCC
Else
	cQuery := " SELECT "+cCampo+" FROM " + RetSqlName("FLH")
	cQuery += " WHERE FLH_FILIAL = '" + xFilial("FLH") + "'"
	cQuery += " AND FLH_VIAGEM = '" + cViagem + "'"
	cQuery += " AND D_E_L_E_T_= ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasFLH,.F.,.T.)
	If !((cAliasFLH)->(Eof()))
		cCCusto := (cAliasFLH)->(&cCampo)
	Endif
	DbSelectArea(cAliasFLH)
	DbCloseArea()
Endif
DbSelectArea(cAliasAtu)
Return(lRet)

/* 
----------------------------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} FN694SelViag 
Exibe as viagens em aberto, permitindo a conciliação manual.

@author Marcello Gabriel
@since 09/07/2015
/*/
/*--------------------------------------------------------------------------------------------------------------------*/
Function FN694SelViag()
Local cAliasTmp	:= GetNextAlias()
Local cNomeArq	:= ""
Local nReg		:= 0
Local lRet		:= .F.
Local aArea		:= {}
Local oBrwViag	:= Nil
Local oSize		:= Nil
Local oDlg		:= Nil

aArea := GetArea()

MsgRun(STR0007,STR0008,{|| FN694TmpViag(@cNomeArq,@cAliasTmp)}) //"Verificando as viagens pendentes."###"Aguarde."

If !Empty(cNomeArq)
	oSize := FwDefSize():New(.T.)	
	oSize:lLateral := .F.
	oSize:AddObject("MASTER",100,100,.T.,.T.)
	oSize:lProp := .T.
	oSize:Process()
	DEFINE MSDIALOG oDlg TITLE STR0009 From oSize:aWindSize[1]*0.5,oSize:aWindSize[2]*0.5 To oSize:aWindSize[3]*0.5,oSize:aWindSize[4]*0.5 OF oMainWnd PIXEL //"Viagens"
		oBrwViag:= TCBrowse():New(0,0,10,10,,,,oDlg,,,,,,,,,,,,,cAliasTmp,.T.,,,,.T.,)
			oBrwViag:AddColumn(TCColumn():New(SX3->(RetTitle("FL5_IDRESE")),{|| (cAliasTmp)->FL5_IDRESE},,,,,040,.F.,.F.,,,,,))
			oBrwViag:AddColumn(TCColumn():New(SX3->(RetTitle("FL5_VIAGEM")),{|| (cAliasTmp)->FL5_VIAGEM},,,,,040,.F.,.F.,,,,,))
			oBrwViag:AddColumn(TCColumn():New(SX3->(RetTitle("FL6_TOTAL")), {|| (cAliasTmp)->FL5_VALOR},PesqPict("FL6","FL6_TOTAL"),,,,060,.F.,.F.,,,,,))
			oBrwViag:AddColumn(TCColumn():New(SX3->(RetTitle("FLH_CC")),{|| (cAliasTmp)->FL5_CC},,,,,040,.F.,.F.,,,,,))
			oBrwViag:Align := CONTROL_ALIGN_ALLCLIENT
			oBrwViag:bLDblClick := {|| nReg := (cAliasTmp)->REGNO,lRet := .T.,oDlg:End()} 
			oBrwViag:Refresh()
	ACTIVATE DIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nReg := (cAliasTmp)->REGNO,lRet := .T.,oDlg:End()},{|| lRet := .F.,oDlg:End()},,) CENTERED 
	DbSelectArea(cAliasTmp)
	DbCloseArea()
	If(_oFINA694 <> NIL)

		_oFINA694:Delete()
		_oFINA694 := NIL 

	EndIf
	oDlg := Nil
	oBrwViag := Nil
	oSize := Nil
	If lRet 
		FL5->(DbGoTo(nReg))
	Endif
Else
	Help("  ",1,"NAOVIAGCONC",,STR0010,1,0) //"Não se encontrou viagens com valor igual ou maior que o do item do extrato."
	lRet := .F.
Endif  
RestArea(aArea)
Asize(aArea,0)
aArea := Nil
Return(lRet)

/* 
----------------------------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} FN694tmpViag 
Cria um arquivo temporário com dados sobre viagens.

@author Marcello Gabriel
@since 14/07/2015
/*/
/*--------------------------------------------------------------------------------------------------------------------*/
Function FN694TmpViag(cNomeArq,cAliasTmp)
Local cQuery	:= ""
Local cAliasFL5	:= ""
Local cCC		:= ""
Local cAliasAtu	:= ""
Local nValor	:= 0
Local nValorExt	:= 0
Local nReg		:= 0
Local nLinha	:= 0
Local aEstr		:= {}
Local lRet		:= .F.
Local oModel	:= Nil
Local oModFWN	:= Nil

cAliasAtu := Alias()
oModel := FWModelActive()
oModFWN := oModel:GetModel("FWNDETAIL")
nLinha	:= oModFWN:GetLine()
nValorExt := oModFWN:GetValue("FWN_VTRANS")

AAdd(aEstr,{"FL5_IDRESE","C",TamSX3("FL5_IDRESE")[1],0})
AAdd(aEstr,{"FL5_VIAGEM","C",TamSX3("FL5_VIAGEM")[1],0})
AAdd(aEstr,{"FL5_VALOR", "N",TamSX3("FL6_TOTAL")[1],TamSX3("FL6_TOTAL")[2]})
AAdd(aEstr,{"FL5_CC", "C",TamSX3("FLH_CC")[1],0})
AAdd(aEstr,{"REGNO","N",10,0})

If(_oFINA694 <> NIL)

	_oFINA694:Delete()
	_oFINA694 := NIL

EndIf

_oFINA694 := FwTemporaryTable():New(cAliasTmp)
_oFINA694:SetFields(aEstr)
_oFINA694:AddIndex("1",{"FL5_IDRESE","FL5_VIAGEM"})
_oFINA694:Create()

cNomeArq := _oFINA694:GetRealName()

cAliasFL5 := GetNextAlias()
cQuery := "	SELECT FL6_IDRESE,FL6_VIAGEM,FL6.R_E_C_N_O_,FL6_TIPO FROM " + RetSQLName("FL6") + " FL6"
cQuery += " 	WHERE FL6_FILIAL = '" + xFilial("FL6") + "'"
cQuery += " 	AND FL6_TIPO = '1'"
cQuery += "	AND FL6_VCONFE < FL6_TOTAL"
cQuery += " 	AND FL6.D_E_L_E_T_= ' '"
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasFL5,.F.,.T.)
While !((cAliasFL5)->(Eof()))
	If !oModFWN:SeekLine({{"FL6_IDRESE",(cAliasFL5)->FL6_IDRESE}})
		lRet := FN694VerVlr(nValorExt,(cAliasFL5)->FL6_IDRESE,@nValor)
		If lRet
			FN694VerCC("",(cAliasFL5)->FL6_VIAGEM,@cCC)
			RecLock(cAliasTmp,.T.)
			Replace (cAliasTmp)->FL5_IDRESE	With (cAliasFL5)->FL6_IDRESE
			Replace (cAliasTmp)->FL5_VIAGEM	With (cAliasFL5)->FL6_VIAGEM
			Replace (cAliasTmp)->FL5_VALOR	With nValor
			Replace (cAliasTmp)->FL5_CC		With cCC
			Replace (cAliasTmp)->REGNO		With (cAliasFL5)->R_E_C_N_O_
			MsUnLock()
		Endif
	Endif
	(cAliasFL5)->(DbSkip())
Enddo
DbSelectArea(cAliasFL5)
DbCloseArea()
oModFWN:GoLine(nLinha)
Asize(aEstr,0)
aEstr := Nil
DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

Return()

/*
----------------------------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} FN694verViag 
Analisa o registro do extrato, se há viagem correspondente e se há divergências entre os dados da viagem e do registro.

@param oModFWN - modelo (MVC) usado.
@param aStatus (passado por referência) - array que receberá os dados da viagem encontrada: Status,ID da reserva, 
		Código da viagem, centro de custo, valor (soma de FL6). 

@return lRet - indica se há viagem correspondente para conciliação: .T. viagem encontrada; .F. encontrada, mas com 
		divergências (valor), ou não encontrada.
 
@author Marcello Gabriel
@since 07/07/2015
/*/
/*---------------------------------------------------------------------------------------------------------------------*/
Function FN694VerViag(oModFWN,aStatus)
Local aAreaFL6	:= {}
Local aArea		:= {}
Local aViagem	:= {}
Local cViagem	:= ""
Local cStatus	:= ""
Local cCC		:= ""
Local nValor	:= 0
Local lRet		:= .F.
Local cItem		:= ""
Local cClvl		:= ""

aArea := GetArea()
DbSelectArea("FL6")
aAreaFL6 := GetArea()
cViagem := oModFWN:GetValue("FWN_VIAGEM")
If !Empty(cViagem)
	FL6->(DbSetOrder(1))
	If FL6->(DbSeek(xFilial("FL6") + cViagem))
		lRet := FN694VerVlr(oModFWN:GetValue("FWN_VTRANS"),FL6->FL6_IDRESE,@nValor)
		FN694VerCC(oModFWN:GetValue("FLH_CC"),FL6->FL6_VIAGEM,@cCC,"CTT")
		FN694VerCC(oModFWN:GetValue("FLH_ITECTA"),FL6->FL6_VIAGEM,@cItem,"CTD")
		FN694VerCC(oModFWN:GetValue("FLH_CLVL"),FL6->FL6_VIAGEM,@cClvl,"CTH")
		
		If FL6->FL6_IDRESE == oModFWN:GetValue("FWN_IDRESE")
			If !lRet 
				cStatus := STS_DIVERGENTE
				lRet := .T.
			Else 
				cStatus := STS_CONCILIADO
			Endif
		Else 
			cStatus := STS_CONCILIADOMANUAL
		Endif
		aStatus := {cStatus,FL6->FL6_IDRESE,FL6->FL6_VIAGEM,cCC,nValor,cItem,cClvl}
	Else
		lRet := .F.
		cStatus := STS_CONCILIADOERRO
		aStatus := {cStatus,"","","",0,"",""}
	Endif  
Else
	FL6->(DbSetOrder(3))
	If FL6->(DbSeek(xFilial("FL6") + oModFWN:GetValue("FWN_IDRESE")))
		nValor := 0
		cCC := ""
		lRet := FN694VerVlr(oModFWN:GetValue("FWN_VTRANS"),FL6->FL6_IDRESE,@nValor)
		FN694VerCC(oModFWN:GetValue("FLH_CC"),FL6->FL6_VIAGEM,@cCC,"CTT")
		FN694VerCC(oModFWN:GetValue("FLH_ITECTA"),FL6->FL6_VIAGEM,@cItem,"CTD")
		FN694VerCC(oModFWN:GetValue("FLH_CLVL"),FL6->FL6_VIAGEM,@cClvl,"CTH")
		
		If lRet
			cStatus := STS_IDEXISTENOSISTEMA
		Else
			If nValor == 0
				cStatus := STS_JACONCILIADO
			Else
				cStatus := STS_DIVERGENTE
				lRet := .T.
			EndIf
		Endif
		aStatus := {cStatus,FL6->FL6_IDRESE,FL6->FL6_VIAGEM,cCC,nValor,cItem,cClvl}
	Else
		lRet := .F.
		aStatus := {STS_IDINEXISTENTE,"","","",0,"",""}
	Endif
Endif
RestArea(aAreaFL6)
RestArea(aArea)
Asize(aAreaFL6,0)
Asize(aArea,0)
aAreaFL6 := Nil
aArea := Nil
Return(lRet)

/*
----------------------------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} FN694PreLn 
Pré-Validação do modelo de dados FWNDETAIL.  
@param oModel - FWNDETAIL
@param nLine - Linha Atual.
@param cAction - Ação do usuário (Insert, delete, undelete, update).
@param cField - Campo que esta recebendo a ação.
@param xValue - Valor Atual.
@param xOldValue - Valor antes da ação do usuário.
@author William Matos
@since 12/07/2015
/*/
/*--------------------------------------------------------------------------------------------------------------------*/
Function FN694PreLn(oModel, nLine, cAction, cField, xValue, xOldValue) 
Local lRet 		:= .T.

If !(FWIsInCallStack("FN694Import"))
	lRet := !(oModel:GetValue("STATUS") $ STS_DIVERGENTE + "|" + STS_CONCILIADO + "|" + STS_IDEXISTENOSISTEMA)
Endif

Return lRet

/*
----------------------------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} FN694View() 
  
/*/
/*--------------------------------------------------------------------------------------------------------------------*/
Function FN694VIEW()
Local aEnableButtons	:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,STR0012},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}  //'Efetivar conciliacao'###'Cancelar'
Local lRet 				:= .T.
Local lcontinua 		:= .T.

If !FWIsInCallStack("FN694Import")
	While lContinua
		lRet := Pergunte("FINA694A", .T. )
		If (lRet)
			If MV_PAR01 > 1 .AND. ( Empty(MV_PAR02) .OR. Empty(MV_PAR03) )  
				Help("  ",1,"PRODINVLD",,STR0022,1,0) //"Para gerar documentos de entrada ou pedidos de compra, é necessario informar o código do produto e o tipo de entrada."
				lRet := .F.
			Else
				lContinua := .F.
			EndIf
		Else
			lContinua := .F.
		EndIf
	Enddo 
	If lRet 
		FWExecView(STR0023, "FINA694",MODEL_OPERATION_UPDATE, /*oDLG*/, /**/,/**/,/**/,aEnableButtons ) //"Conciliação"
	EndIf
EndIf
Return() 

/*
----------------------------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} FN694ImgSt 
Define a imagem,  para exibição em grides, que representam a situação em que se encontra o item de extrato / viagem.  
@author Marcello Gabriel
@since 10/07/2015
/*/
/*--------------------------------------------------------------------------------------------------------------------*/
Function FN694ImgSt(cStatus,nImg)
Local cImagem	:= "BR_BRANCO"

Default nImg	:= 1
Default cStatus	:= STS_IDINEXISTENTE

Do Case
	Case nImg == 1
		Do Case
			Case cStatus == STS_DIVERGENTE
				cImagem := "BR_AMARELO"
			Case cStatus == STS_IDEXISTENOSISTEMA
				cImagem := "BR_VERDE"
			Case cStatus == STS_IDINEXISTENTE
				cImagem := "BR_VERMELHO"
			Case cStatus == STS_CONCILIADO
				cImagem := "BR_VERDE"
			Case cStatus == STS_CONCILIADOMANUAL
				cImagem := "BR_AZUL"
			Case cStatus == STS_CONCILIADOERRO
				cImagem := "BR_PRETO"
			Case cStatus == STS_JACONCILIADO
				cImagem := "BR_CINZA"
		EndCase
	Case nImg == 2
		cImagem := If(cStatus == STS_IDINEXISTENTE,"BR_CANCEL","TRIRIGHT")
EndCase
Return(cImagem)

/*
----------------------------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} FN694VALMOD
Verifica os dados do modelo para geração dos documentos de conciliação (fatura, pedido, título).
 
@author Marcello Gabriel

@param oModel - Modelo de dados.

@since 14/07/2015
/*/
/*--------------------------------------------------------------------------------------------------------------------*/ 
Function FN694ValMod(nTipoPag,oModel)
Local lRet		:= .T.
Local cCpos		:= ""
Local nX		:= 0
Local nLenCpos	:= 0
Local aCposVld	:= {}

/*
Verifica se foram preenchidos os campos necessarios para o documento */
Do Case
	Case nTipoPag == 1
		aCposVld := {"FLQ_FORNEC","FLQ_LOJA","FLQ_NATUR","FLQ_VENCTO"}
	Case nTipoPag == 2
		aCposVld := {"FLQ_FORNEC","FLQ_LOJA","FLQ_COND"}
	Case nTipoPag == 3
		aCposVld := {"FLQ_FORNEC","FLQ_LOJA","FLQ_NATUR","FLQ_VENCTO","FLQ_COND","FLQ_PREFIX","FLQ_NUMTIT"}
EndCase
nX := 0
cCpos := ""
nLenCpos := Len(aCposVld)
While nX < nLenCpos
	nX++
	If Empty(oModel:GetValue("FLQMASTER",aCposVld[nX]))
		cCpos += AllTrim(SX3->(RetTitle(aCposVld[nX]))) + CRLF
	Endif
Enddo
If !Empty(cCpos) 
	oModel:SetErrorMessage("",,oModel:GetId(),"","VLDMOD",AllTrim(STR0013) + ":" + CRLF + CRLF + cCpos)		//"Para a geraçao do documento, também é necessário preencher o(s) seguinte(s) campo(s)"
	lRet := .F.
Else
	/*
	Verifica se o documento a ser gerada ja existe */
	Do Case
		Case nTipoPag == 3		//nota fiscal
			SF1->(DbSetOrder(1))
			cCpos := xFilial("SF1")
			cCpos += oModel:GetValue("FLQMASTER","FLQ_NUMTIT")
			cCpos += SerieNFId("SF1",4,"F1_SERIE",dDataBase,"NFE",oModel:GetValue("FLQMASTER","FLQ_PREFIX"))
			cCpos += oModel:GetValue("FLQMASTER","FLQ_FORNEC")
			cCpos += oModel:GetValue("FLQMASTER","FLQ_LOJA")
			If SF1->(DbSeek(cCpos))
				oModel:SetErrorMessage("",,oModel:GetId(),"","VLDMODNFE",AllTrim(STR0025) + ": "  + AllTrim(oModel:GetValue("FLQMASTER","FLQ_PREFIX")) + " " + oModel:GetValue("FLQMASTER","FLQ_NUMTIT")) //"O documento a ser gerado já existe"
				lRet := .F.
			Endif
	EndCase
Endif
aSize(aCposVld,0)
aCposVld := Nil
Return(lRet)

 
/*
----------------------------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} FN694GrvMod 
@author William Matos
@param oModel - Modelo de dados.
@since 10/07/2015
/*/
/*--------------------------------------------------------------------------------------------------------------------*/
Function FN694GrvMod(oModel)
Local lRet 	 	:= .F.
Local aMVPar 	:= F694LoadPer(.F.)
Local oProcess	:= Nil

If (FWIsInCallStack("FN694Import"))
	lRet := .T.
	FWFormCommit(oModel)
Else
	If oModel:GetValue("FLQMASTER","FLQ_TOTAL") > 0 .And. MsgYesNo(STR0026,STR0023)		//"Conciliacao de viagens" //"Deseja gerar o documento para efetivar a conciliação?"
		If FN694ValMod(aMVPar[1],oModel)
			oProcess := MsNewProcess():New({|lEnd| lRet := FN694Efetivar(oModel,oProcess)},STR0023) //"Conferência de viagens"
			oProcess:Activate()
		Endif
		oProcess := Nil
	Else
		lRet := .T.
		FWFormCommit(oModel)
	Endif
Endif	
Return(lRet)
 
/*
----------------------------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} FN694Efetivar 
@author William Matos
@param oModel - Modelo de dados.
@since 10/07/2015
/*/
/*--------------------------------------------------------------------------------------------------------------------*/
Function FN694Efetivar(oModel,oProcess)
Local nX		:= 0
Local nVlrConf	:= 0
Local nVlrTotal	:= 0
Local cViagem	:= ""
Local cDoc		:= ""
Local lRet 	 	:= .F.
Local aMVPar 	:= F694LoadPer(.F.)
Local oAux		:= oModel:GetModel("FWNDETAIL")
Local oView		:= FWViewActive()

oProcess:SetRegua1(6)
oProcess:SetRegua2(0)

BeginTran()
	Do Case 
		Case aMVPar[1] == 1 //Contas a Pagar.
			lRet := F694GeraTit(oModel,oProcess)
			cDoc := AllTrim(STR0027) + ": " + oModel:GetValue("FLQMASTER","FLQ_NUMTIT") //"Título gerado"
		Case aMVPar[1] == 2 //Pedido de Compra.
			lRet := F694GeraPed(oModel,oProcess)
			cDoc := AllTrim(STR0017) + ": " + oModel:GetValue("FLQMASTER","FLQ_PEDIDO")
		Case aMVPar[1] == 3 //Documento de Entrada.
			lRet := F694GeraNFE(oModel,oProcess)
			cDoc := AllTrim(STR0021) + ": " + oModel:GetValue("FLQMASTER","FLQ_NUMTIT")
	EndCase
	
	If lRet
		oProcess:IncRegua1("Atualizando as tabelas de conferência.")
		nVlrTotal := oModel:GetValue("FLQMASTER","FLQ_TOTAL")
		/*
		Atualizando a tabela de conferencia */	
		DbSelectArea("FLQ")
		RecLock("FLQ",.T.)
		Replace FLQ->FLQ_FILIAL	With xFilial("FLQ")
		Replace FLQ->FLQ_CONFER	With oModel:GetValue("FLQMASTER","FLQ_CONFER") 
		Replace FLQ->FLQ_FORNEC	With oModel:GetValue("FLQMASTER","FLQ_FORNEC")
		Replace FLQ->FLQ_LOJA	With oModel:GetValue("FLQMASTER","FLQ_LOJA")
		Replace FLQ->FLQ_TOTAL	With nVlrTotal
		Replace FLQ->FLQ_DATA	With oModel:GetValue("FLQMASTER","FLQ_DATA")
		Replace FLQ->FLQ_HISTOR	With oModel:GetValue("FLQMASTER","FLQ_HISTOR")
		Replace FLQ->FLQ_PREFIX	With oModel:GetValue("FLQMASTER","FLQ_PREFIX")
		Replace FLQ->FLQ_NUMTIT	With oModel:GetValue("FLQMASTER","FLQ_NUMTIT")
		Replace FLQ->FLQ_STATUS	With '1'
		Replace FLQ->FLQ_VENCTO	With oModel:GetValue("FLQMASTER","FLQ_VENCTO")
		Replace FLQ->FLQ_PEDIDO	With oModel:GetValue("FLQMASTER","FLQ_PEDIDO")
		Replace FLQ->FLQ_TPPGTO	With oModel:GetValue("FLQMASTER","FLQ_TPPGTO")
		Replace FLQ->FLQ_NATUR	With oModel:GetValue("FLQMASTER","FLQ_NATUR")
		Replace FLQ->FLQ_TIPO	With oModel:GetValue("FLQMASTER","FLQ_TIPO")
		Replace FLQ->FLQ_COND	With oModel:GetValue("FLQMASTER","FLQ_COND")
		Replace FLQ->FLQ_ORIGEM	With oModel:GetValue("FLQMASTER","FLQ_ORIGEM")
		MsUnLock()
		
		oProcess:IncRegua1(STR0028)		//"Atualizando as tabelas de conferência."
		oProcess:SetRegua2(oAux:Length())
		//Atualiza o status das viagens
		cViagem := ""
		dbSelectArea("FL5")
		FL5->(dbSetOrder(2)) 
		FL6->(DbSetOrder(3)) //FL6_FILIAL + FL6_IDRESE
		//
		For nX := 1 To oAux:Length()	
			oAux:GoLine( nX )
			cViagem := oAux:GetValue("FWN_IDRESE", nX)
			
			If !Empty(cViagem)
				nVlrConf := oAux:GetValue("FWN_VTRANS",nX)
				oAux:LoadValue('FWN_CONFER', oModel:GetValue("FLQMASTER","FLQ_CONFER") )
				//		
				If FL6->(dbSeek( xFilial("FL6") + cViagem ))

					If FL6->FL6_VCONFE < FL6->FL6_TOTAL
						/*
						Atualiza o valor conferido e o status da viagem */
						RecLock("FL6",.F.)
						nVlrConf := FL6->FL6_VCONFE + (nVlrConf * (FL6->FL6_TOTAL / oAux:GetValue("FL6_TOTAL",nX)))
						Replace FL6->FL6_VCONFE	With nVlrConf
						If nVlrConf >= FL6->FL6_TOTAL
							Replace FL6->FL6_STATUS	With "2"		//totalmente conferido
						Else
							Replace FL6->FL6_STATUS	With "1"		//parcialmente conferido
						Endif 					
						//Grava tabela FLV - Pedido vs Conferencia
						RecLock("FLV",.T.)
						FLV->FLV_FILIAL := xFilial("FLV")
						FLV->FLV_CONFER := oModel:GetValue("FLQMASTER","FLQ_CONFER") 
						FLV->FLV_VIAGEM := FL6->FL6_VIAGEM
						FLV->FLV_ITEM   := FL6->FL6_ITEM
						FLV->FLV_VALOR  := oAux:GetValue("FL6_TOTAL", nX)
						FLV->FLV_STATUS := '1'
						MsUnlock()
					EndIf

				EndIf	
				//
				If FL5->( MsSeek( xFilial( 'FL5' ) + cViagem ) )
					Reclock("FL5",.F.)
					FL5->FL5_STATUS := FN685STAT(cViagem)
					MsUnlock()
				Endif
			EndIf
			oProcess:IncRegua2(" ")	
		Next
		//
		oProcess:IncRegua1(STR0028) //"Atualizando as tabelas de conferência."
		FWFormCommit(oModel)
	EndIf
	MsUnLockAll()
/*-*/
If lRet
	oProcess:IncRegua1(STR0028)		//"Atualizando as tabelas de conferência."
	EndTran()	
	oView:ShowUpdateMsg(.T.)
	oView:SetUpdateMessage(STR0023,cDoc)		//Consolidacao de viagens
Else
	DisarmTransaction()
Endif
Return(lRet)

/*
----------------------------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} F694Struct 
Monta a estrutura da entidade FLQ
@author William Matos
@since 10/07/2015
/*/
/*--------------------------------------------------------------------------------------------------------------------*/
Function F694Struct()
Local nTipoDoc	:= F694LoadPer(.F.)[1]
Local oStruct 	:= FWFormStruct( 1, 'FLQ', /*bAvalCampo*/, /*lViewUsado*/ )
Local aFields	:= {}
Local nX		:= 0
If !(FWIsInCallStack("FN694Import"))
	If nTipoDoc == 1		//Contas a Pagar
			oStruct:SetProperty("FLQ_CONFER" , MODEL_FIELD_WHEN , {|| .F. } )
			oStruct:SetProperty("FLQ_TPPGTO" , MODEL_FIELD_WHEN , {|| .F. } )			
			oStruct:AddTrigger( "FLQ_NATUR", "FLQ_DNATUR", {|| .T. }  , {|| Posicione("SED",1,xFilial("SED")+M->FLQ_NATUR,"ED_DESCRIC")})
	ElseIf nTipoDoc == 2	//Pedido de Compra
			oStruct:SetProperty("FLQ_CONFER" , MODEL_FIELD_WHEN , {|| .F. } )
			oStruct:SetProperty("FLQ_TPPGTO" , MODEL_FIELD_WHEN , {|| .F. } )
			oStruct:SetProperty("FLQ_VENCTO" , MODEL_FIELD_WHEN , {|| .F. } )	
			oStruct:AddTrigger( "FLQ_COND" , "FLQ_DCPAG"	, {|| .T. }  , {|| Posicione("SE4",1,xFilial("SE4")+M->FLQ_COND,"E4_DESCRI")}  )		
	ElseIf nTipoDoc == 3	//Nota Fiscal de Entrada (NFE)
			oStruct:SetProperty("FLQ_CONFER" , MODEL_FIELD_WHEN , {|| .F. } )
			oStruct:SetProperty("FLQ_TPPGTO" , MODEL_FIELD_WHEN , {|| .F. } )
			oStruct:SetProperty("FLQ_NUMTIT" , MODEL_FIELD_WHEN , {|| .T. } )
			oStruct:SetProperty("FLQ_PREFIX" , MODEL_FIELD_WHEN , {|| .T. } )	
			oStruct:AddTrigger( "FLQ_COND" , "FLQ_DCPAG"	, {|| .T. }  , {|| Posicione("SE4",1,xFilial("SE4")+M->FLQ_COND ,"E4_DESCRI")}) 
			oStruct:AddTrigger( "FLQ_NATUR", "FLQ_DNATUR"   , {|| .T. }  , {|| Posicione("SED",1,xFilial("SED")+M->FLQ_NATUR,"ED_DESCRIC")})
	Endif
Endif
oStruct:AddTrigger( "FLQ_LOJA" , "FLQ_LOJA"   , {|| .T. }  , {|| F686NomFor() }  )
oStruct:SetProperty("*" , MODEL_FIELD_OBRIGAT ,  .F.  )
Return oStruct

/*
----------------------------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} F694LoadPer
/*/
/*--------------------------------------------------------------------------------------------------------------------*/
Function F694LoadPer(lMostra)
Default lMostra := .F.
Pergunte("FINA694A",lMostra)

Return { MV_PAR01, MV_PAR02, MV_PAR03 }

/*
----------------------------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} F694GeraTit

/*/
/*--------------------------------------------------------------------------------------------------------------------*/
Static Function F694GeraTit(oModel,oProcess)
Local oModelFLQ	:= oModel:GetModel("FLQMASTER")
Local oModelFWN	:= oModel:GetModel("FWNDETAIL")
Local aArea		:= GetArea()
Local _aTit 	:= {}
Local lRet		:= .F.
Local cPrefixo  := SuperGetMV("MV_RESPRCF",.T.,"CNF")
Local cFornece	:= oModelFLQ:GetValue("FLQ_FORNEC")
Local cLoja		:= oModelFLQ:GetValue("FLQ_LOJA")
Local cNaturez	:= oModelFLQ:GetValue("FLQ_NATUR")
Local dDtVenc	:= oModelFLQ:GetValue("FLQ_VENCTO")
Local nVlrTit	:= 0	
Local cTipo		:= SuperGetMV("MV_RESTPAD",.T.,"DP ")
Local nTamPrf	:= TamSx3("E2_PREFIXO")[1]
Local nTamNum	:= TamSx3("E2_NUM")[1]
Local nTamParc	:= TamSx3("E2_PARCELA")[1]
Local nTamTipo	:= TamSx3("E2_TIPO")[1]
Local nTamNat	:= TamSx3("E2_NATUREZ")[1]
Local cNumTit	:= ""
Local aCC		:= {}
Local aAuxSEV	:= {} //Auxiliar para Natureza.
Local aAuxSEZ	:= {} //Auxiliar para Centro de Custo.
Local aRatSEZ	:= {}
Local aRatSEVEZ := {}
Local nX				:= 0
Local nSoma		:= 0
Local nSmVl		:= 0

Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.

oProcess:IncRegua1(STR0015)			 //"Gerando titulo a pagar	
oProcess:SetRegua2(oModelFWN:Length())

//Gero numero do titulo
cNumTit	:= ProxTitulo("SE2",cPrefixo)

For nX := 1 to oModelFWN:Length()
	oModelFWN:GoLine(nX)
	If !Empty(oModelFWN:GetValue("FWN_VIAGEM"))
		nVlrTit += oModelFWN:GetValue("FWN_VTRANS",nX)
	Endif
	oProcess:IncRegua2(" ")
Next
		
_aTit := {}
AADD(_aTit , {"E2_NUM"    ,PadR(cNumTit,nTamNum)           ,NIL})
AADD(_aTit , {"E2_PREFIXO",PadR(cPrefixo,nTamPrf)          ,NIL})
AADD(_aTit , {"E2_PARCELA",Space(nTamParc)                 ,NIL})
AADD(_aTit , {"E2_TIPO"   ,PadR(cTipo,nTamTipo)            ,NIL})
AADD(_aTit , {"E2_NATUREZ",PadR(cNaturez,nTamNat)          ,NIL})
AADD(_aTit , {"E2_FORNECE",cFornece                        ,NIL})
AADD(_aTit , {"E2_LOJA"   ,cLoja                           ,NIL})
AADD(_aTit , {"E2_EMISSAO",dDatabase                       ,NIL})
AADD(_aTit , {"E2_VENCTO" ,dDtVenc			               ,NIL})
AADD(_aTit , {"E2_VENCREA",DataValida(dDtVenc,.T.) 		   ,NIL})
AADD(_aTit , {"E2_EMIS1"  ,dDatabase                       ,NIL})
AADD(_aTit , {"E2_MOEDA"  ,1 					           ,NIL})               
AADD(_aTit , {"E2_VALOR"  ,nVlrTit		                   ,NIL})
AADD(_aTit , {"E2_ORIGEM" ,"FINA686"                       ,NIL})	
AADD(_aTit , {"E2_HIST"   ,AllTrim(STR0014) + " " + oModel:GetValue('FLQMASTER','FLQ_CONFER') ,Nil}) //"Conferencia"
//Calcula a proporção do centro de custo para o título.
aCC := FN694CC( oModel )

nTam := Len(aCC)

For nX := 1 To nTam
	
	nSoma += aCC[nX,3]
	nSmVl += aCC[nX,2]
	
Next nX
//
If Len(aCC) == 1
	AADD(_aTit , {"E2_CCUSTO"  , aCC[1][1] , Nil }) 
	AADD(_aTit , {"E2_ITEMCTA" , aCC[1][4] , Nil }) 
	AADD(_aTit , {"E2_CLVL"    , aCC[1][5] , Nil }) 	
Else
	aAdd( aAuxSEV ,{"EV_NATUREZ" , PadR(cNaturez,nTamNat),NIL})
    aAdd( aAuxSEV ,{"EV_VALOR"   , nVlrTit , Nil })//valor do rateio na natureza
    aAdd( aAuxSEV ,{"EV_PERC"    , "100"	 , Nil })//percentual do rateio na natureza
    aAdd( aAuxSEV ,{"EV_RATEICC" , "1"			 , Nil })//indicando que há rateio por centro de custo
	   
	For nX := 1 To Len(aCC)
		   
		aAdd( aAuxSEZ ,{"EZ_CCUSTO" ,aCC[nX][1] , Nil })//centro de custo da natureza
		aAdd( aAuxSEZ ,{"EZ_VALOR"  ,aCC[nX][2] , Nil })//valor do rateio neste centro de custo
		aAdd( aAuxSEZ ,{"EZ_PERC"   ,aCC[nX][3] , NIl })
		aAdd( aAuxSEZ ,{"EZ_ITEMCTA",aCC[nX][4] , Nil })
		aAdd( aAuxSEZ ,{"EZ_CLVL"   ,aCC[nX][5] , Nil })		   
		aAdd( aRatSEZ,aClone(aAuxSEZ))
		aSize(aAuxSEZ,0)
		aAuxSEZ := {}
 	Next nX
	//		
	aAdd(aAuxSEV,{"AUTRATEICC" , aRatSEZ, Nil })//recebendo dentro do array da natureza os multiplos centros de custo
	aAdd(aRatSEVEZ,aAuxSEV)//adicionando a natureza ao rateio de multiplas naturezas	
	//
	aAdd(_aTit ,{"E2_MULTNAT","1"		 	  ,NIL}) 	
	aAdd(_aTit ,{"AUTRATEEV" ,aRatSEVEZ,Nil})//adicionando ao vetor aCab o vetor do rateio
	
EndIf

If nVlrTit > 0	
	//Chamada da rotina automatica 3 = inclusao
	oProcess:IncRegua1(AllTrim(STR0015) + ": " + PadR(cNumTit,nTamNum))
	MSExecAuto({|x, y| FINA050(x, y)}, _aTit, 3)
	If lMsErroAuto
		MOSTRAERRO()
		lMsErroAuto := .F.
		lRet := .F.
		oModel:SetErrorMessage("",,oModel:GetId(),"","GERDOCTIT","O processo de conferência foi interrompido, pois não foi possível criar o documento correspondente.")
	Else
		lRet := .T.
		//Atualizo o status da conferência
		oModelFLQ:SetValue("FLQ_PREFIX", cPrefixo )
		oModelFLQ:SetValue("FLQ_NUMTIT", cNumTit )
		oModelFLQ:SetValue("FLQ_TIPO"  , cTipo )
		oModelFLQ:SetValue("FLQ_FORNEC", cFornece )
		oModelFLQ:SetValue("FLQ_LOJA", cLoja )
		oModelFLQ:SetValue("FLQ_TOTAL", nVlrTit)					
	EndIf
	oProcess:IncRegua2(" ")
Else
	lRet := .F.
	oModel:SetErrorMessage("",,STR0018)		//"Não há itens conciliados para geração do documento"
Endif
RestArea(aArea)
aSize(aCC, 0)
aSize(aAuxSEV,0)		
aSize(aAuxSEZ,0)		
aSize(aRatSEZ,0)		
aSize(aRatSEVEZ,0)
oProcess:IncRegua2(" ")
Return lRet

/*
----------------------------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} F694GeraPed
Gera pedido de compras para as viagens conciliadas.

@author Marcello Gabriel
@since 13/07/2015
/*/
/*--------------------------------------------------------------------------------------------------------------------*/
Static Function F694GeraPed(oModel,oProcess)
Local aArea		:= GetArea()
Local lRet		:= .T.
Local cDoc		:= ""
Local cFornece	:= oModel:GetValue("FLQMASTER","FLQ_FORNEC")
Local cLoja		:= oModel:GetValue("FLQMASTER","FLQ_LOJA")
Local cCondPag	:= oModel:GetValue("FLQMASTER","FLQ_COND")
Local oModelFWN	:= oModel:GetModel('FWNDETAIL')
Local nTamDoc	:= TamSx3("C7_NUM")[1]
Local cC7Item 	:= ""
Local nX     	:= 0
Local nZ		:= 0
Local nItem		:= 0
Local nTotal	:= 0
Local aCabec	:= {}
Local aItens	:= {}
Local aLinha	:= {}
Local aCC 		:= {}
Local aSCH		:= {}
Local aAux		:= {}
Local aRateio	:= {}

Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.

//Seto a ordem do arquivo de cabeçalho da nota 
DbSelectArea("SC7")	
DbSetOrder(1)
//Centro de Custo da Viagem.
DbSelectArea("FLH")
DbSetOrder(1)	

aCabec := {}
aItens := {}		

oProcess:IncRegua1(STR0016)			 //"Geração do pedido de compras."
oProcess:SetRegua2(oModelFWN:Length())

//Inclusão do pedido de compras
For nX := 1 to oModelFWN:Length()
	oModelFWN:GoLine(nX)
	If !Empty(oModelFWN:GetValue("FWN_VIAGEM"))
		If Empty(aCabec)
			cDoc := GetNumSC7()
			aadd(aCabec,{"C7_NUM" 		, PadR(cDoc,nTamDoc)	})
			aadd(aCabec,{"C7_EMISSAO"	, dDataBase				})
			aadd(aCabec,{"C7_FORNECE"	, cFornece				})
			aadd(aCabec,{"C7_LOJA" 		, cLoja					})
			aadd(aCabec,{"C7_COND" 		, cCondPag				})
			aadd(aCabec,{"C7_CONTATO" 	, " "					})
			aadd(aCabec,{"C7_FILENT" 	, cFilAnt				})
		Endif
		aLinha := {}
		nTotal += oModelFWN:GetValue("FWN_VTRANS")
		nItem++
		cC7Item := StrZero(nItem,TamSX3("C7_ITEM")[1])
		aAdd(aLinha,{"C7_ITEM"    , cC7Item								,Nil})
		aadd(aLinha,{"C7_PRODUTO" , MV_PAR02							,Nil})
		aadd(aLinha,{"C7_QUANT"   , 1									,Nil})
		aadd(aLinha,{"C7_PRECO"   , oModelFWN:GetValue("FWN_VTRANS")	,Nil})
		aadd(aLinha,{"C7_TOTAL"   , oModelFWN:GetValue("FWN_VTRANS")	,Nil})
		aadd(aLinha,{"C7_TES" 	  , MV_PAR03							,Nil})
		aadd(aLinha,{"C7_ORIGEM"  , "FINA686"       					,Nil})
		aadd(aLinha,{"C7_OBS"	  , AllTrim(STR0014) + " " + oModel:GetValue('FLQMASTER','FLQ_CONFER') ,Nil})		//"Conf. de Serviços" 

		//Centro de Custo no Pedido de Compra.
		If FLH->(DbSeek(xFilial('FLH') + oModelFWN:GetValue("FWN_VIAGEM", nX)))
			While !FLH->(Eof()) .AND. xFilial('FLH') + FLH->FLH_VIAGEM == (xFilial('FLH') + oModelFWN:GetValue("FWN_VIAGEM", nX) )
				aAdd(aCC, { FLH->FLH_CC, FLH->FLH_PORCEN, FLH->FLH_ITECTA, FLH->FLH_CLVL} )	
				FLH->(dbSkip())
			EndDo
		EndIf		
					
		If !Empty(aCC)
			If Len(aCC) > 1 //Preenche SCH - Rateio por Pedido de Compra.
				For nZ := 1 To Len(aCC)
					aAux := {}
					aAdd(aAux, {'CH_FORNECE', cFornece , Nil})
					aAdd(aAux, {'CH_LOJA'	, cLoja	   , Nil})
					aAdd(aAux, {'CH_CC'		, aCC[nZ,1], Nil})
					aAdd(aAux, {'CH_PERC'	, aCC[nZ,2], Nil})
					aAdd(aAux, {'CH_ITEMCTA', aCC[nZ,3], Nil})
					aAdd(aAux, {'CH_CLVL'	, aCC[nZ,4], Nil})					   			
					aAdd(aAux, {'CH_ITEM'	, StrZero(nZ,TamSX3("CH_ITEM")[1])})
					//	
					aAdd(aRateio, aClone(aAux))
					aAdd(aLinha,{"C7_RATEIO", '1', Nil})
				Next nZ	

				aAdd(aSCH, {cC7Item, aClone(aRateio)} ) 
			
			Else
				aAdd(aLinha,{"C7_CC"		, aCC[1,1], Nil } )	
				aAdd(aLinha,{"C7_ITEMCTA"	, aCC[1,3], Nil } )
				aAdd(aLinha,{"C7_CLVL"		, aCC[1,4], Nil } )  
			EndIf
		EndIf
		aAdd(aItens,AClone(aLinha))
		aSize(aCC, 0)
		aSize(aRateio, 0)
		aSize(aAux, 0)
		aAux	:= {}
		aRateio := {}
		aCC 	:= {}	
	Endif
	oProcess:IncRegua2(" ")
Next nX
If !Empty(aItens)
	oModel:Setvalue("FLQMASTER","FLQ_TOTAL",nTotal)
	oModel:Setvalue("FLQMASTER","FLQ_PEDIDO",cDoc)
	oProcess:IncRegua1(AllTrim(STR0016) + ": " + cDoc)
	MATA120(1,aCabec,aItens,3, .F.,aSCH)
	oProcess:IncRegua2(" ") 
	If lMsErroAuto
		MOSTRAERRO()
		lMsErroAuto := .F.
		lRet := .F.
		oModel:SetErrorMessage("",,oModel:GetId(),"","GERDOCPED",STR0029)		//"O processo de conferência foi interrompido, pois não foi possível criar o documento correspondente."
	Endif
Else
	lRet := .F.
	oModel:SetErrorMessage("",,STR0018)		//"Não há itens conciliados para geração do documento"
Endif
aSize(aSCH, 0)
aSize(aRateio,0)
aSCH 	:= {}
aRateio := {}
	
RestArea(aArea)

oProcess:IncRegua2(" ") 
Return lRet

/*
----------------------------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} FN694CC


/*/
/*--------------------------------------------------------------------------------------------------------------------*/
Function FN694CC(oModel)
Local nX   	:= 0
Local oFWN 	:= oModel:GetModel("FWNDETAIL")
Local nPorCC	:= 0
Local nValCC	:= 0
Local nPos		:= 0
Local aRet		:= {}
Local nValor	:= 0
Local cCC		:= ""
Local cClasse	:= ""
Local cItem	:= ""
Local cViagem := ""
Local nTotal  := oModel:GetValue("FLQMASTER","FLQ_TOTAL")
Local nSoma	:= 0
Local nModelo	:= oFWN:Length()
Local nPorSom	:= 0


For nX := 1 to nModelo

	If oFWN:GetValue('STSVIAG', nX) != "BR_VERMELHO"
		nValCC := oFWN:GetValue("FWN_VTRANS", nX )
		cCC		:= oFWN:GetValue("FWN_CCUSTO", nX )

		If __IteClv
			cItem	:= oFWN:GetValue("FWN_ITECTA", nX )
			cClasse:= oFWN:GetValue("FWN_CLVL", nX )
		Endif	
		
		nPorCC := Round(nValCC / nTotal, 2 )
		
		If nX <= (nModelo - 1)
			nSoma	+= nValCC
			nPorSom+= nPorCC
		Else
			nValCC := nTotal - nSoma
			nPorCC := 1-nPorSom
		Endif
		
		If (nPos := Ascan(aRet,{|x| AllTrim(x[1] + x[4] + x[5]) == AllTrim(cCC + cItem + cClasse)})) > 0
			aRet[nPos][2] := aRet[nPos][2] + nValCC //Acumula valor do CC.
			aRet[nPos][3] := aRet[nPos][3] + nPorCC //Acumula porcentagem do CC.
		Else
			aAdd(aRet, { cCC, nValCC, nPorCC, cItem, cClasse } )
		EndIf
	EndIf	
Next nX

Return aRet

/*
----------------------------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} F694GeraNFe


/*/
/*--------------------------------------------------------------------------------------------------------------------*/
Static Function F694GeraNFE( oModel,oProcess)
Local aArea		:= GetArea()
Local lRet		:= .F.
Local dDtVenc	:= oModel:GetValue("FLQMASTER","FLQ_VENCTO")
Local cSerie	:= oModel:GetValue("FLQMASTER","FLQ_PREFIX")
Local cDoc		:= oModel:GetValue("FLQMASTER","FLQ_NUMTIT")
Local cFornece	:= oModel:GetValue("FLQMASTER","FLQ_FORNEC")
Local cLoja		:= oModel:GetValue("FLQMASTER","FLQ_LOJA")
Local cNaturez	:= oModel:GetValue("FLQMASTER","FLQ_NATUR")
Local cCondPag	:= oModel:GetValue("FLQMASTER","FLQ_COND")
Local cTipo		:= SuperGetMV("MV_RESTPAD",.T.,"DP ")
Local nTamSer	:= TamSx3("F1_SERIE")[1]
Local nTamDoc	:= TamSx3("F1_DOC")[1]
Local nTamParc	:= TamSx3("E2_PARCELA")[1]
Local nTamNat	:= TamSx3("E2_NATUREZ")[1]
Local nX     	:= 0
Local nTotal	:= 0
Local aCabec	:= {}
Local aItens	:= {}
Local aLinha	:= {}
Local aCC		:= {}
Local aRateio	:= {}
Local aAux		:= {}
Local nY		:= 0
Local nItem		:= 0
Local cD1Item	:= ''
Local aSDE		:= {}
Local oModelFWN := oModel:GetModel("FWNDETAIL")
Local aMVPar	:= F694LoadPer(.F.)

Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.


oProcess:IncRegua1(STR0019) //"Geração da nota fiscal"
oProcess:SetRegua2(oModelFWN:Length())

dbSelectArea("FLH")

//Seto a ordem do arquivo de cabeçalho da nota 
DbSelectArea("SF1")	
DbSetOrder(2)	

aCabec := {}
aItens := {}		

//Inclusão da NFE

aAdd(aCabec, {"F1_TIPO"   	, "N"					})		
aAdd(aCabec, {"F1_FORMUL" 	, "N"					})		
aAdd(aCabec, {"F1_DOC"    	, PadR(cDoc,nTamDoc)	})		
aAdd(aCabec, {"F1_SERIE"  	, PadR(cSerie,nTamSer)	})		
aAdd(aCabec, {"F1_EMISSAO"	, dDataBase				})		
aAdd(aCabec, {"F1_FORNECE"	, cFornece				})		
aAdd(aCabec, {"F1_LOJA"   	, cLoja					})		
aAdd(aCabec, {"F1_ESPECIE"	, "NFE"					})		
aAdd(aCabec, {"F1_COND"   	, cCondPag				})
aAdd(aCabec, {'F1_ORIGLAN'   ,"CS"		            })
aAdd(aCabec, {"E2_NATUREZ"	, PadR(cNaturez,nTamNat)})

For nX := 1 To oModelFWN:Length()
	oModelFWN:GoLine(nX)
	If !Empty(oModelFWN:GetValue("FWN_VIAGEM"))
		aLinha := {}
		nItem++
		nTotal += oModelFWN:GetValue("FWN_VTRANS", nX) 			
		cD1Item := StrZero(nItem,TamSX3("D1_ITEM")[1])
		aAdd(aLinha,{"D1_ITEM"	, cD1Item								,Nil})
		aAdd(aLinha,{"D1_COD"  	, aMVPar[2]								,Nil})			
		aAdd(aLinha,{"D1_QUANT"	, 1										,Nil})			
		aAdd(aLinha,{"D1_VUNIT"	, oModelFWN:GetValue("FWN_VTRANS", nX)	,Nil})			
		aAdd(aLinha,{"D1_TOTAL"	, oModelFWN:GetValue("FWN_VTRANS", nX)	,Nil})			
		aAdd(aLinha,{"D1_TES"	, aMVPar[3]								,Nil})			
		//
		If FLH->(DbSeek(xFilial('FLH') + oModelFWN:GetValue("FWN_VIAGEM", nX)))
			While !FLH->(Eof()) .AND. xFilial('FLH') + FLH->FLH_VIAGEM == (xFilial('FLH') + oModelFWN:GetValue("FWN_VIAGEM", nX) )
				aAdd(aCC, { FLH->FLH_CC, FLH->FLH_PORCEN, FLH->FLH_ITECTA, FLH->FLH_CLVL} )	
				FLH->(dbSkip())
			EndDo
		EndIf	
		//
		If !Empty(aCC)
			If Len(aCC) > 1 //Preenche SCH - Rateio por Pedido de Compra.
				For nY := 1 To Len(aCC)
					aAux := {}
					aAdd(aAux, {'DE_CC'		, aCC[nY,1], Nil})
					aAdd(aAux, {'DE_PERC'	, aCC[nY,2], Nil})
					aAdd(aAux, {'DE_ITEMCTA', aCC[nY,3], Nil})
					aAdd(aAux, {'DE_CLVL'   , aCC[nY,4], Nil})						
					aAdd(aAux, {'DE_ITEM'	, StrZero(nY,TamSX3("DE_ITEM")[1])})
					//
					aAdd(aRateio, aClone(aAux))
				Next nY	
				//
				aAdd(aLinha,{"D1_RATEIO ", '1', Nil})
				aAdd(aSDE, {cD1Item, aClone(aRateio)} ) 
				//
			Else
				aAdd(aLinha,{"D1_CC"	 , aCC[1,1], Nil } )
				aAdd(aLinha,{"D1_ITEMCTA", aCC[1,3], Nil } )
				aAdd(aLinha,{"D1_CLVL"	 , aCC[1,4], Nil } )					
			EndIf
		EndIf	

		aAdd(aItens,aClone(aLinha))
		aRateio	:= {}
		aAux	:= {}
		aCC		:= {}
	Endif
	oProcess:IncRegua2(" ")
Next nX	
If !Empty(aItens)
	//Inclusao de NFE  
	oProcess:IncRegua1(AllTrim(STR0020) + ": " + cDoc)                                          		
	MSExecAuto({|x,y,z,a,b,c,d,e,f| mata103(x,y,z,a,b,c,d,e,f)},aCabec,aItens,/**/,/**/,/**/,/**/,/**/,/**/,aSDE)
	If lMsErroAuto
		MOSTRAERRO()
		lMsErroAuto := .F.
		lRet := .F.
		oModel:SetErrorMessage("",,oModel:GetId(),"","GERDOCNFE",STR0029) //"O processo de conferência foi interrompido, pois não foi possível criar o documento correspondente."
	Else
		lRet := .T.
		//Atualizo o status da conferência
		oModel:SetValue("FLQMASTER","FLQ_PREFIX", cSerie )
		oModel:SetValue("FLQMASTER","FLQ_NUMTIT", cDoc )
		oModel:SetValue("FLQMASTER","FLQ_TIPO"  , "NFE" )
		oModel:SetValue("FLQMASTER","FLQ_FORNEC", cFornece )
		oModel:SetValue("FLQMASTER","FLQ_LOJA"  , cLoja )
		oModel:SetValue("FLQMASTER","FLQ_TOTAL" , nTotal )
	EndIf
	oProcess:IncRegua2(" ")
Else
	lRet := .F.
	oModel:SetErrorMessage("",,STR0018)		//"Não há itens conciliados para geração do documento"
Endif
	
aSize(aSDE,0)
aSDE := {}
RestArea(aArea)

oProcess:IncRegua2(" ")
Return lRet

/*
----------------------------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} FN694VerRes
Valida a viagem conciliada manualmente.

@author Marcello Gabriel
@since 13/07/2015
/*/
/*--------------------------------------------------------------------------------------------------------------------*/
Function FN694VerRes(oModel,nLine,cAction,cField,xValue,xOldValue)
Local lRet		:= .T.
Local lAchou	:= .F.
Local nOrdFL6	:= 0
Local nValor	:= 0
Local cCC		:= ""
Local cViagem	:= ""
Local oMod		:= Nil
Local cItem		:= ""
Local cClvl		:= ""

If !(FWIsInCallStack("FN694Consol") .Or. FWIsInCallStack("FN694Import"))
	If cField == "FL6_IDRESE"
		If cAction == "SETVALUE"
			oMod := oModel:GetModel()
			nOrdFL6 := FL6->(IndexOrd())
			FL6->(DbSetOrder(3))
			If Empty(xValue)
				lAchou := .F.
				lRet := .T.
				cCC := " "
				cItem := " "
				cClvl := " "
				cViagem := " "
				nValor := 0
			Else
				If FL6->(DbSeek(xFilial("FL6") + xValue))
					lRet := FN694VerVlr(oModel:GetValue("FWN_VTRANS"),FL6->FL6_IDRESE,@nValor)
					FN694VerCC("",FL6->FL6_VIAGEM,@cCC,"CTT")
					FN694VerCC("",FL6->FL6_VIAGEM,@cItem,"CTD")
					FN694VerCC("",FL6->FL6_VIAGEM,@cClvl,"CTH")

					If lRet
						cViagem := FL6->FL6_VIAGEM
						lAchou := .T.
						nVlrTran := oMod:GetValue("FLQMASTER","FLQ_TOTAL") + oMod:GetValue("FWNDETAIL","FWN_VTRANS")
						oMod:SetValue("FLQMASTER","FLQ_TOTAL",nVlrTran)
					Else
						Help("  ",1,"VLRVIAGINF",,STR0024,1,0) //"Esta viagem não pode ser selecionada, pois seu valor é inferior ao que consta no extrato."
						nValor := 0
						cCC := " "
						cItem := " "
						cClvl := " "
						cViagem := " "		
						lAchou := .F.		
					Endif
				Else
					Help("  ",1,"RECNO",,"",1,0)
					nValor := 0
					cCC := " "
					cItem := " "
					cClvl := " "
					cViagem := " "
					lRet := .F.
					lAchou := .F.
				Endif
			Endif
			If lRet
				oModel:SetValue("FL6_TOTAL",nValor)
				oModel:SetValue("FLH_CC",cCC)
				oModel:SetValue("FLH_ITECTA",cItem)
				oModel:SetValue("FLH_CLVL",cClvl)				
				oModel:SetValue("FWN_VIAGEM",cViagem)		
				oModel:SetValue("STSVIAG",FN694ImgSt(If(lAchou,STS_CONCILIADOMANUAL,STS_IDINEXISTENTE),1))
				oModel:SetValue("SEPCOL",FN694ImgSt(If(lAchou,STS_CONCILIADOMANUAL,STS_IDINEXISTENTE),2))
				FL6->(DbSetOrder(nOrdFL6))
				If !Empty(xOldvalue)
					nVlrTran := oMod:GetValue("FLQMASTER","FLQ_TOTAL") - oMod:GetValue("FWNDETAIL","FWN_VTRANS")
					oMod:SetValue("FLQMASTER","FLQ_TOTAL",nVlrTran)
				Endif
			Endif
		Endif
	Endif
Endif
Return(lRet) 

/*
----------------------------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} LMLegenda
Monta a legenda dos registros apresentados no Grid.

@author Marcello Gabriel
@since 17/07/2013
/*/
/*--------------------------------------------------------------------------------------------------------------------*/
Function FN694Legenda()
Local aLeg	:= {}

Aadd(aLeg,{FN694ImgSt(STS_IDINEXISTENTE,1)		,STR0001})	//"Não conciliadao"
Aadd(aLeg,{FN694ImgSt(STS_DIVERGENTE,1)			,STR0030})	//"Conciliado, mas com divergencia de valores."
Aadd(aLeg,{FN694ImgSt(STS_IDEXISTENOSISTEMA,1)	,STR0031})	//"Conciliado automaticamente."
Aadd(aLeg,{FN694ImgSt(STS_CONCILIADOMANUAL,1)	,STR0032})	//"Conciliado manualmente (informada pelo usuário)."
Aadd(aLeg,{FN694ImgSt(STS_CONCILIADOERRO,1)		,STR0033})	//"Conciliado, mas a viagem não foi encontrada no cadastro."
Aadd(aLeg,{FN694ImgSt(STS_JACONCILIADO,1)		,STR0045})	//"Viagem já conciliada."
/*_*/
BrwLegenda(STR0034, STR0035,aLeg) 							//"Conciliação de viagens"###"Legenda"
Asize(aLeg,0)
aLeg := Nil
Return(.T.)

/*
----------------------------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} F694Gat
Realiza o gatilho para o total da conciliação.

@author Alvaro Camillo Neto
@since 13/05/2016
/*/
/*--------------------------------------------------------------------------------------------------------------------*/
Function F694Gat(oModelpAR)
Local oModel		:= oModelpAR:GetModel()
Local oModelFLQ	:= oModel:GetModel("FLQMASTER")
Local oModelFWN	:= oModel:GetModel("FWNDETAIL")
Local nRet			:= oModelFWN:GetValue('FWN_VTRANS')			
Local nX			:= 0
Local nTotal		:= 0

For nX := 1 To oModelFWN:Length()
	
	nTotal += oModelFWN:GetValue('FWN_VTRANS',nX)
	
Next nX


oModelFLQ:LoadValue('FLQ_TOTAL',nTotal)

Return nRet

/*/{Protheus.doc}FN694IniCp
Inicializador padrão do campo FWN_ARQUIV
@author William Matos
@since 21/06/16
/*/
Function FN694IniCp()

Return AllTrim(__cNameArq)

/*/{Protheus.doc}FN694Del
Exclusão dos arquivos importados.
@author William Matos
@since 21/06/16
/*/
Function FN694Del()
Local aRet		:= {}
Local cQuery 	:= ''
Local cFWN		:= '' 
Local cArqTot	:= '' 
Local aArea	:= {}

	If	ParamBox({	{6,'Arquivo:',Padr("",150),"",,"",90 ,.T.,STR0043,"",;
		GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE}},; 
		STR0042,@aRet) 
		//
		aArea	:= GetArea()
		dbSelectArea('FWN')
		//
		If F694NFile(aRet[1],2)
			//		
			cQuery	:= ''
			cQuery += "SELECT FWN_CODIGO FROM " + RetSqlName("FWN") 	+ " FWN "
			cQuery += "WHERE FWN_FILIAL = '" 	 + xFilial("FWN")		 	+ "'"
			cQuery += "AND FWN_ARQUIV = '" 		 + AllTrim(__cNameArq) 	+ "'" 
			cQuery += "AND D_E_L_E_T_ = ' '"
			cQuery += "ORDER BY FWN_ARQUIV" 
			cQuery := ChangeQuery(cQuery)
			cFWN:= GetNextAlias()
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cFWN,.T.,.T.)
		   	dbSelectArea(cFWN)
		   (cFWN)->(dbGoTop())
		  	//
	  		While (cFWN)->(!Eof())
	  			If FWN->(dbSeek( xFilial('FWN') + (cFWN)->FWN_CODIGO  ))
					Reclock('FWN',.F.)
					FWN->(dbDelete())
				EndIf
				(cFWN)->(dbSkip()) 	 		
	  		EndDo
		Else
			Help(" ",1,"F694DEL",,STR0041 + STR0038 + __cNameArq + STR0040,1,0)	
		EndIf
		RestArea( aArea )
	EndIf		
		
Return 


/*/{Protheus.doc}FN694Del
Nome do Arquivo.
@author William Matos
@since 21/06/16
/*/
Function F694NFile(cFile,cType)
Local lRet 	:= .F.
Local cQuery	:= ''
Local cArqTot	:= GetNextAlias()
Local nPos		:= 0
Default cFile	:= ''
Default cType	:= 1

	__cNameArq := cFile
	nPos := Rat('\',__cNameArq)
	__cNameArq := Substr(AllTrim(__cNameArq),nPos + 1, Len(__cNameArq) )
	//
	cQuery += "SELECT COUNT(FWN_CODIGO) TOT FROM " + RetSqlName("FWN") + " FWN "
	cQuery += "WHERE FWN_FILIAL = '" + xFilial("FWN") + "'"
	cQuery += "AND FWN_ARQUIV = '" + AllTrim(__cNameArq) + "'"
	If cType > 1
		cQuery += "AND FWN_CONFER <> ' ' "	 
	EndIf
	cQuery += "AND D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	cArqTot:= GetNextAlias()
	//	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cArqTot,.T.,.T.)
   	dbSelectArea(cArqTot)
	lRet := (cArqTot)->TOT = 0

Return lRet

/*/{Protheus.doc}FINA694Act

Funcao chamada pelo método SetActivate

@author TOTVS
@since 25/07/2016
/*/
Function FINA694Act(oModel)
Local lRet := .T.

oModel:LoadValue("FLQMASTER","FLQ_ORIGEM","FINA694")

//--------------------------------------------------------------
// Atribuo o valor pois a operacao é 4-Alteracao nao ativando o 
// inicializador padrao impactando no estorno da conciliacao
//--------------------------------------------------------------
If FWIsInCallStack('FN694VIEW')
	oModel:SetValue("FLQMASTER","FLQ_DATA",dDataBase)
EndIf

Return lRet
