#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"

//Programa responsável por agrupar as funções resposta para as mensagens vindas do webservice

//-- Diretivas indicando as colunas para Matriz de Prioridades de Entrega
#DEFINE PE_QTDCOL 5         
#DEFINE PE_CODPRI 1
#DEFINE PE_TIPPRI 2                          
#DEFINE PE_DEPRI  3
#DEFINE PE_ATEPRI 4
#DEFINE PE_CORPRI 5 

//-- Diretivas indicando as colunas dos documentos da viagem Do TMSA141
#DEFINE VGSTATUS	 1
#DEFINE VGSTROTA	 2
#DEFINE VGMARCA	 3
#DEFINE VGSEQUEN	 4
#DEFINE VGARMAZE	 5
#DEFINE VGLOCALI	 6                                           
#DEFINE VGFILDOC	 7
#DEFINE VGDOCTO	 8
#DEFINE VGSERIE	 9
#DEFINE VGQTDVOL	15
#DEFINE VGPLIQUI	17
#DEFINE VGVIAGEM	20
#DEFINE VGDOCROT	30	//-- Codigo que identifica a q rota pertence o documento

//-- Diretivas indicando as colunas dos documentos da viagem
#DEFINE CTSTATUS	 1
#DEFINE CTSTROTA	 2
#DEFINE CTMARCA	 3
#DEFINE CTSEQUEN	 4
#DEFINE CTARMAZE	 5
#DEFINE CTLOCALI	 6
#DEFINE CTFILDOC	 7
#DEFINE CTDOCTO	 8
#DEFINE CTSERIE	 9
#DEFINE CTREGDES	10                                           
#DEFINE CTDATEMI	11
#DEFINE CTPRZENT	12
#DEFINE CTNOMREM	13
#DEFINE CTNOMDES	14
#DEFINE CTQTDVOL	15
#DEFINE CTVOLORI	16
#DEFINE CTPLIQUI	17
#DEFINE CTPESOM3	18
#DEFINE CTVALMER	19
#DEFINE CTVIAGEM	20
#DEFINE CTSEQDA7	21
#DEFINE CTSOLICI	22			//-- DUE_NOME
#DEFINE CTENDERE	23			//-- DUE_END
#DEFINE CTBAIRRO	24			//-- DUE_BAIRRO
#DEFINE CTMUNICI	25			//-- DUE_MUN
#DEFINE CTDATSOL	26			//-- DT5_DATSOL
#DEFINE CTHORSOL	27			//-- DT5_HORSOL
#DEFINE CTDATPRV	28			//-- DT5_DATPRV
#DEFINE CTHORPRV	29			//-- DT5_HORPRV
#DEFINE CTDOCROT	30			//-- Codigo que identifica a q rota pertence o documento
#DEFINE CTBLQDOC	31			//-- Tipos de bloqueio do documento
#DEFINE CTNUMAGE	32			//-- Numero do Agendamento( Carga Fechada ).
#DEFINE CTITEAGE	33			//-- Item do Agendamento( Carga Fechada ).
#DEFINE CTSERTMS	34			//-- Tipo do Servico.
#DEFINE CTDESSVT	35			//-- Descricao do Servico.
#DEFINE CTESTADO	36
#DEFINE CTDATENT	37
#DEFINE CTUNITIZ	38
#DEFINE CTCODANA	39

#DEFINE NPOSQTDVOL  02
#DEFINE NPOSVALFRE  03
#DEFINE NPOSVALOR   04
#DEFINE NPOSPESO    05
#DEFINE NPOSPESOM3  06
#DEFINE NPOSMETRO3  07
#DEFINE NPOSDOCTOS  08

//-- TMSA200A - Calculo do Lote
#DEFINE LTMARCA  1 
#DEFINE LTCORBRW 2
#DEFINE LTFILORI 3
#DEFINE LTLOTNFC 4
#DEFINE LTDATLOT 5
#DEFINE LTHORLOT 6
#DEFINE LTQTDLOT 7
#DEFINE LTTIPLOT 8
#DEFINE LTSTALOT 9
#DEFINE LTRATEIO 10
#DEFINE LTBACRAT 11
#DEFINE LTCRIRAT 12
#DEFINE LTPRORAT 13
#DEFINE LTORIRAT 14
#DEFINE LTCALRAT 15
#DEFINE LTTABRAT 16
#DEFINE LTTIPRAT 17
#DEFINE LTTPLOTE 18 
#DEFINE LTNUMNFC 19
#DEFINE LTSERNFC 20
#DEFINE LTCLIREM 21
#DEFINE LTLOJREM 22

#DEFINE NROCPOS  22

Static aDadosZona := {}                       
Static aDadosSetor:= {}
Static cNumTmp    := ''    //Numero da programacao temporaria
Static cSeqPrg    := ''    //Sequencia da programacao 
Static cSeqEnt    := ''    //Sequencia de Entrega dos Documentos de Transporte
Static __TotalOff := .T.
Static aRegDF8    := {}
Static aRegVgeInt := {}
Static lTmsa029   := FindFunction("TMSA029USE") 
Static aCliRestri := {} 	// Recebe os Clientes Restritos
Static lPesqRes   := .F.
Static dDtPrvIni  := ''
Static dDtPrvFim  := ''
Static dDtEmiIni  := ''
Static dDtEmiFim  := ''
Static lPerfPrg   := .F. //Performance Programacao 
Static RegID      := ""
Static ViagID     := ""

Static _dePara := {{"publishReleasedTrip","_NS2_publishReleasedTrip"}}

/*/{Protheus.doc} CarregaTrips
	Carrega os dados da mensagem de cancelamento e reprogramação
@author siegklenes.beulke
@since 01/09/2016
@version undefined
@param oObj, object, Instancia da classe, ServiceReprogram que conterá as viagens e os documentos recebidos.
@example
(examples)
@see (links_or_references)
/*/
Static Function CarregaTrips(oObj)
	Local oTrip
	Local aTrips
	Local aLoads
	Local oLoad
	Local nX
	Local nY
	
	oObj:basketSourceId := TMSXGetItens("basketSourceId")
	oObj:regionSourceId := TMSXGetItens("regionSourceId")
	aTrips := TMSXGetAll("trips:trip")
	
	For nX := 1 To Len(aTrips)
		XMLREC := aTrips[nX]
		oTrip := oObj:newtrip()
		oTrip:tripId := TMSXGetItens("tripId","N")
		aLoads := TMSXGetAll("loads:load")
		For nY := 1 To Len(aLoads)
			XMLREC := aLoads[nY]
			oLoad := oTrip:newload()
			oLoad:loadid := TMSXGetItens("loadid","N")
			oLoad:loadSourceId := TMSXGetItens("loadSourceId")
		Next nY
	Next nX
Return


/*/{Protheus.doc} LimpaVar
	Procura antecipar a limpeza de variaveis do tipo Objeto
@author siegklenes.beulke
@since 01/09/2016
@version undefined
@param xVar, , a variável
@example
(examples)
@see (links_or_references)
/*/
Static Function LimpaVar(xVar)
	If !Empty(xVar)
		If ValType(xVar) == "O"
			FreeObj(xVar)
		ElseIf ValType(xVar) == "A"
			aSize(xVar,0)
		EndIf
	EndIf
	xVar := Nil
Return
 
/*/{Protheus.doc} TMSXGetItens
	Facilita a leitura de um objeto xml posicionado a partida da hierarquia passada
@author siegklenes.beulke
@since 01/09/2016
@version undefined
@param cHierarquia, characters, Hierarquia do xml desejado. Sempre a partir de um objeto xml de referencia sendo o objeto Private XMLREC o padrão.
@param cTipo, characters, tipo do retorno digitado.
	Nil: Retorna o valor do objeto, :TEXT da tag ou "" se não encontrar.
	"A": Retorna um Array se encontrar o objeto, ou "" se não encontrar.
	"O": Retorna a instancia solicitada na hierarquia, ou "" se não encontrar.
	"N":Retorna o valor do objeto, Val(:TEXT) da tag ou 0 se não encontrar.
@param cObjBase, characters, Nome da variavel privada que conten a instância do xml para pesquisa. Padrão XMLREC
@param cConteudo, characters, conteúdo do XML.
@example
(examples)
@see (links_or_references)
/*/
Function TMSXGetItens(cHierarquia,cTipo,cObjBase, cConteudo)
	Local xRet
	Local nPos
	Local aNivel := StrToKarr(cHierarquia,":")
	Local nX
	Local nY
	Local cObj := ""
	Local aName
	Default cObjBase := "XMLREC"
	Default cConteudo := ""
	
	For nX := 1 to Len(aNivel)
		nPos := aScan(_dePara,{|x|x[1] == aNivel[nX]})
		aNivel[nX] := upper(aNivel[nX])
		If nPos > 0
			If Alltrim(cConteudo) = ""
				aNivel[nX] := _dePara[nPos][2]
			Else
				aNivel[nX] := TMSXGetChild(aNivel[nX], cConteudo, .F.)
			EndIf
		Else
			If Type(cObjBase + If(!Empty(cObj),":" + cObj,"") + ":_" + aNivel[nX]) == "U"
				aName := classdataarr(&(cObjBase + If(!Empty(cObj),":" + cObj,"")))[1]
				For nY := 1 To Len(aName)	
					If ValType(aName[nY]) == "C" .And. At(aNivel[nX],aName[nY]) > 0
						aNivel[nX] := aName[nY]
						Exit
					EndIf
				Next nY
			Else
				aNivel[nX] := "_" + aNivel[nX]
			EndIf
		EndIf
		
		If !Empty(cObj)
			cObj += ":"
		EndIf
		
		cObj += aNivel[nX]
	Next nX
	
	cObj := cObjBase + ":" + cObj
	
	If Type(cObj) == "A"
		xRet := &(cObj)
	ElseIf Type(cObj) == "O"
		If cTipo == "A"
			xRet := {&(cObj)}
		Else
			If cTipo != "O"
				cObj += ":TEXT"
			EndIf
			xRet := &(cObj)
			If cTipo == "N"
				xRet := Val(xRet)
			EndIf
		EndIf
	Else
		If cTipo == "N"
			xRet := 0.0
		Else
			xRet := ""
		EndIf
	EndIf
		
Return xRet

//Recursiva, recupera todos os registros de uma tag informada, que estejam na mesma hierarquia de outros registros
/*/{Protheus.doc} TMSXGetAll
	Recursiva, recupera todos os registros de uma tag informada, que estejam na mesma hierarquia de outros registros, em um array, a partir de um nível
@author siegklenes.beulke
@since 01/09/2016
@version undefined
@param cHierarquia, characters, Hierarquia do xml desejado. Sempre a partir de um objeto xml de referencia sendo o objeto Private XMLREC o padrão.
@example
(examples)
@see (links_or_references)
/*/
Function TMSXGetAll(cHierarquia)
	Local xRet := {}
	Local aRet := {}
	Local cHrTemp := ""
	
	Local aNivel := StrToKarr(cHierarquia,":")
	
	Local nX
	Local nY
	Local nR
	Local nZ
	
	Local oObjBkp
	
	Local Item
	Local aItem
	Local nNivel := 1
	Local nLimite := Len(aNivel)
	
	nX := nNivel
	While nX <= Len(aNivel)
		
		Item := TMSXGetItens(aNivel[nX],"O")
		
		If nX != nLimite
			If ValType(Item) == "A"
			
				For nR := nX+1 to Len(aNivel)
					If !Empty(cHrTemp)
						cHrTemp += ":"
					EndIf
					cHrTemp += aNivel[nR]
				Next nR
				
				aSize(aNivel,nX-1)
				aItem := aClone(Item)
				oObjBkp := XMLREC
			
				For nY := 1 to Len(aItem)
										
					XMLREC := aItem[nY]
					aRet := TMSXGetAll(cHrTemp)
					
					For nZ := 1 to Len(aRet)
						aAdd(xRet,aRet[nZ])
					Next nZ
					
				Next nY
				
				XMLREC := oObjBkp
			ElseIf ValType(Item) == "O"
				XMLREC := Item
			EndIf
		Else
			If ValType(Item) == "A"
				For nY := 1 To Len(Item)
					aAdd(xRet,Item[nY])
				Next nY
			ElseIf ValType(Item) == "O"
				aAdd(xRet,Item)
			EndIf
		EndIf
		nX++
	EndDo	
	
Return xRet
/*/{Protheus.doc} TMSWSInit
	Inicializa o ambiente da thread
@author siegklenes.beulke
@since 01/09/2016
@version undefined
@param pPreparein, , Empresa,Filial
@param cFunc, characters, Função que solicitou a abertura, apenas para constar no console.
@example
(examples)
@see (links_or_references)
/*/
Function TMSWSInit(pPreparein,cFunc)
	Local lReturn := .T.
	Local cPrepareIn
	Local aPreparein := pPreparein
	Local lOms := .F.
	
	If Type("cEmpAnt")=="U"
		If Empty(aPreparein)
			cPrepareIn := GetPvProfString(GetWebJob() , "TMSPREPAREIN" , "ERROR" , GetAdv97() )
			If cPrepareIn == "ERROR" .Or. Empty(cPrepareIn)
				cPrepareIn := GetPvProfString(GetWebJob() , "OMSPREPAREIN" , "ERROR" , GetAdv97() )
				lOms := .T.
			EndIf
			aPreparein := StrTokArr(cPreparein,",")
		
			If aPreparein[1] == "ERROR"
				lReturn := .F.
				SetFaultTMS('Erro leitura [TMSPREPAREIN]',"CHAVE [TMSPREPAREIN] NAO ENCONTRADA NA SECAO ["+GetWebJob()+"] DO ARQUIVO DE CONFIGURACAO ["+GetAdv97()+"]","server")
				TmsLogMsg("WARN",'[' + cValToChar(ThreadId()) + '-' + cFunc + '] ' + " CHAVE [TMSPREPAREIN] NAO ENCONTRADA NA SECAO ["+GetWebJob()+"] DO ARQUIVO DE CONFIGURACAO ["+GetAdv97()+"]")
			EndIf
		EndIf		
	
		if lReturn
			TmsLogMsg("INFO",'[' + cValToChar(ThreadId())  + '-' + cFunc + '] ' + " INICIALIZACAO DO AMBIENTE-EMPRESA:"+aPreparein[1])
			SetsDefault()
			OpenSM0()
			If SM0->(DbSeek(aPreparein[1]+aPreparein[2]))
				RpcsetType(3)
				RpcSetEnv(aPrepareIn[1],aPrepareIn[2])
				If lOms
					SetModulo("SIGAOMS","OMS")
				Else
					SetModulo("SIGATMS","TMS")
				EndIf
				TmsLogMsg("INFO",'[' + cValToChar(ThreadId())  + '-' + cFunc + '] ' + " INICIALIZACAO DO AMBIENTE-EMPRESA:"+aPreparein[1]+ ": Concluido")
			Else
				lReturn := .F.
				If Empty(pPreparein)
					SetFaultTMS('Falha ambiente',"TMS-FALHA INICILIZACAO AMBIENTE - OpenSM0()","server")
				EndIf
			EndIf
		EndIf
	EndIf

Return lReturn
/*/{Protheus.doc} TMSXFWSDL
	Retorana os WSDLS compilados no RPO.
@author siegklenes.beulke
@since 01/09/2016
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Function TMSXFWSDL()
	Local nX
	OMSXCRIFOL("\system\TMSXWSDL\")
	aRes := GetResArray("TMSXWSDL*")
	For nX := 1 To Len(aRes)
		Resource2File(aRes[nX],"\system\TMSXWSDL\" + aRes[nX])
	Next nX
Return


// Classe MVC para capturar mensagens de help
Static Function ModelDef(bPos)
	Local oModel
	Local oStru := FWFormModelStruct():New()
	Local aIndex   := {1, "1", "T01_DUMMY", "T01_DUMMY"}
	
	oStru:AddTable('T01',{"T01_DUMMY"},"T01_DUMMY")
	
	oStru:AddIndex( ;
			aIndex[1]  , ;       // [01] Ordem do indice
			aIndex[2]  , ;       // [02] ID
			aIndex[3]  , ;       // [03] Chave do indice
			aIndex[4]  , ;       // [04] Descrição do indice
			''         , ;       // [05] Expressão de lookUp dos campos de indice
			''         , ;   		// [06] Nickname do indice
			.T.)                	// [07] Indica se o indice pode ser utilizado pela interface  
	
	oStru:AddField("T01_DUMMY", "T01_DUMMY",'T01_DUMMY', 'C', 1, 0, )

	oModel := MPFormModel():New('TMSXFUNW', /*bPreValidacao*/, bPos, { || .T.} /*bCommit*/, /*bCancel*/ )
	
	oModel:AddFields('MdFieldBAS',,oStru)
	oModel:GetModel('MdFieldBAS'):SetDescription("dummy")
	
Return oModel

Static Function ChamaBpos(oModel)

	oModel:Setvalue('MdFieldBAS','T01_DUMMY','1')
		
Return oModel:VldData() .And. oModel:GetModel("TMSXFUNW"):VldData()

Static Function ViewDef()
	Local oView
	Local oStru := FWFormViewStruct():New()
	
	oStru:AddField( "T01_DUMMY"   ,'01' , "G"           , " "            , NIL , 'G', '', NIL, NIL, .T., NIL, NIL, NIL,	NIL, NIL, .T. )
	
	oView := FWFormView():New()
	oView:SetModel(ModelDef())
	
	oView:AddField("MdFieldBAS", oStru)
	
	oView:CreateHorizontalBox( "MASTER", 100, /*cIDOwner*/, /*lFixPixel*/)
	oView:SetOwnerView("MdFieldBAS", "MASTER")
	
Return oview

//Recebe o array de help da FwGetUltHlp
//
Static Function ConvHelp(aHelp)
	Local cMsg := ""
	Local nX
	Local cCodHelp  := ""
	Local cProbHelp := ""
	Local cSoluHelp := ""
	
	If Len(aHelp) == 3
	
		cCodHelp := AllTrim(aHelp[1])
		
		For nX := 1 To Len(aHelp[2])
			If !Empty(cProbHelp)
				cProbHelp += " "
			EndIf
			cProbHelp += AllTrim(aHelp[2,nX])
		Next nX
		
		For nX := 1 To Len(aHelp[3])
			If !Empty(cSoluHelp)
				cSoluHelp += " "
			EndIf
			cSoluHelp += AllTrim(aHelp[3,nX])
		Next nX
		
	EndIf
	
	cMsg :=  cCodHelp + ": " + cProbHelp + " - " + cSoluHelp
	
Return cMsg

/*/{Protheus.doc} TMSXGetChild
	Retorna a tag com o namespace ou somente o namespace.
@author wander.horongoso
@since 14/01/2022
@params
cNode: node a ser localizado no arquivo
cConteudo: conteúdo do XML
lOnlyNS Se .F., retorna o namespace com o cNode, no formato _namespace_cNode
se .T., retorna o namespace. (usado no PE OMSCPLAV).
oXMLM: objeto TXMLManager com o conteúdo do XML, usado na chamada recursiva;
@return
@version undefined
@example
(examples)s
@see (links_or_references)
/*/
function TMSXGetChild(cNode, cConteudo, lOnlyNS, oXMLM)
Local cRet := ''
Local nX := 0
Local lFreeoXMLM := .F.
Default oXmlM := nil

	If ValType(oXMLM) == 'U'		
		oXmlM := TXmlManager():New()
		oXmlM:Parse(cConteudo)
		lFreeoXMLM := .T.
	EndIf
				
	If At(Upper(cNode),Upper(oXMLM:cName))
		cRet := '_' + StrTran(Substr(oXmlM:cPath, RAt('/',oXmlM:cPath)+1),':','_')
		//Se for retornar somente o namespace, retira o nó e também os '_'
		If lOnlyNS
			cRet := StrTran(Substr(cRet,1,At(cNode,cRet)-1),'_','')
		EndIf
	Else
		For nX := 1 To oXmlM:DOMChildCount()
			If nX == 1				
				oXMLM:DOMChildNode()
			/*Descomentar caso a função entre em looping infinito por recursividade.
		  	  Essa situação só ocorrerá caso haja leitura de publishReleasedTrip com algum filho
		      (ex: publishReleasedTrip:TRIPRELEASEREQUESTS:TRIPRELEASEREQUEST).
		      Essa chamada existe hoje na função TMSXFUNWADD mas que, segundo avaliado,
		      não é chamada*/
			//Else
			//	oXMLM:DOMNextNode()
			EndIf
			cRet := TMSXGetChild(cNode,,lOnlyNS,oXMLM)

			//Se encontrar sair do laço
			If !(AllTrim(cRet) == "")
				Exit
			EndIf
		Next nX

		/*Descomentar caso a função entre em looping infinito por recursividade.
		  Essa situação só ocorrerá caso haja leitura de publishReleasedTrip com algum filho
		  (ex: publishReleasedTrip:TRIPRELEASEREQUESTS:TRIPRELEASEREQUEST).
		  Essa chamada existe hoje na função TMSXFUNWADD mas que, segundo avaliado,
		  não é chamada*/
		//Se encontrar não precisa mais subir para o nó pai.
		//If (AllTrim(cRet) == "") .And. !oXmlM:DOMHasNextNode()
		//	oXmlM:DOMParentNode()
		//EndIf
	EndIf

	If lFreeoXMLM
		FwFreeObj(oXmlM)
	EndIf

Return cRet
