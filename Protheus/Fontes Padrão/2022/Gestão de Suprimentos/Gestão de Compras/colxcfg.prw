#Include "Protheus.ch"
#Include "ApWizard.ch"
#include "TopConn.ch"
#include "RwMake.ch"
#include "TbIconn.ch" 

#DEFINE _CRLF	Chr(13) + Chr(10)  

/*/{Protheus.doc} COLXCFG
Wizard para configuração do ambiente TOTVS Colaboração

@author Rafael Duram Santos
@since 21/10/2013
/*/

Function COLXCFG()  

Local oPanel	:= nil
Local nConfig	:= 1
Local cMVNGINN	:= Space(50)
Local cMVNGLID	:= Space(50)
Local cTitle	:= "Configurador do Totvs Colaboração / Importador XML"
Local cMessage	:= "Preencha os campos necessários para configuração do TOTVS Colaboração / Importador XML."
Local cText		:= "Essa ferramenta tem finalidade de facilitar a configuração do Totvs Colaboração / Importador XML"

Private oOK 		:= LoadBitmap(GetResources(),'BR_VERDE')
Private oNO 		:= LoadBitmap(GetResources(),'BR_VERMELHO') 
Private oBrw1
Private oBrw2
Private oBrw3
Private oBrw4
Private oBrw5
Private aParamF1	:= {{"MV_COMCOL1",CONSPAR("MV_COMCOL1")[2]},{"MV_COMCOL2",CONSPAR("MV_COMCOL2")[2]},{"MV_MSGCOL",CONSPAR("MV_MSGCOL")[2]},{"MV_FILREP",CONSPAR("MV_FILREP")[2]}} 
Private aParamF2	:= {{"MV_XMLCFPC",CONSPAR("MV_XMLCFPC")[2]},{"MV_XMLCFBN",CONSPAR("MV_XMLCFBN")[2]},{"MV_XMLCFDV",CONSPAR("MV_XMLCFDV")[2]},{"MV_XMLCFND",CONSPAR("MV_XMLCFND")[2]},{"MV_XMLCFNO",CONSPAR("MV_XMLCFNO")[2]}}
Private aParamF3	:= {{"MV_CTECLAS",CONSPAR("MV_CTECLAS")[2]},{"MV_XMLPFCT",CONSPAR("MV_XMLPFCT")[2]},{"MV_XMLTECT",CONSPAR("MV_XMLTECT")[2]},{"MV_XMLCPCT",CONSPAR("MV_XMLCPCT")[2]}}
Private aParamF4	:= {{"MV_DOCIMP",CONSPAR("MV_DOCIMP")[2]},{"MV_TRAXML",CONSPAR("MV_TRAXML")[2]},{"MV_XMLCID",CONSPAR("MV_XMLCID")[2]},{"MV_XMLCSEC",CONSPAR("MV_XMLCSEC")[2]},;
						{"MV_XMLDIAS",CONSPAR("MV_XMLDIAS")[2]},{"MV_XMLHIST",CONSPAR("MV_XMLHIST")[2]},{"MV_APITRAN",CONSPAR("MV_APITRAN")[2]},{"MV_TRAEXP",CONSPAR("MV_TRAEXP")[2]}}
Private aSM0		:= FwLoadSM0()
Private aEmpFil		:= WIZEMPFIL() 

DEFINE WIZARD oWizard 	TITLE cTitle ;
       					HEADER cTitle ;
       					MESSAGE cMessage ;
       					TEXT cText ;
       					NEXT {||.T.} ;
		 				FINISH {|| .T. } ;
       					PANEL
       					
// Primeira etapa	
CREATE PANEL oWizard ;
				MESSAGE cMessage ;
				HEADER cTitle;
				BACK {|| .T. } ;
				NEXT {|| WIZVLD(1,nConfig) } ;
				FINISH {||  } ;
				PANEL
				
oPanel	:= oWizard:GetPanel(2)
WIZPG(oPanel,1,@nConfig)

// Segunda Etapa
CREATE PANEL oWizard ;
				MESSAGE cMessage ;
				HEADER cTitle ;
				BACK {|| .T. } ;
				NEXT {|| .T. } ;
				FINISH {||  } ;
				PANEL
				
oPanel	:= oWizard:GetPanel(3)
WIZPG(oPanel,2)

// Terceira Etapa
CREATE PANEL oWizard ;
				MESSAGE cMessage ;
				HEADER cTitle ;
				BACK {|| .T. } ;
				NEXT {|| .T. } ;
				FINISH {||  } ;
				PANEL
				
oPanel	:= oWizard:GetPanel(4)
WIZPG(oPanel,3,,@cMVNGINN,@cMVNGLID)

// Quarta Etapa
CREATE PANEL oWizard ;
				MESSAGE cMessage ;
				HEADER cTitle ;
				BACK {|| .T. } ;
				NEXT {|| .T. } ;
				FINISH {|| } ;
				PANEL
				
oPanel	:= oWizard:GetPanel(5)
WIZPG(oPanel,4)

// Quinta Etapa
CREATE PANEL oWizard ;
				MESSAGE cMessage ;
				HEADER cTitle ;
				BACK {|| .T. } ;
				NEXT {|| .T. } ;
				FINISH {|| WIZCOMMIT(nConfig,cMVNGINN,cMVNGLID),.T.} ;
				PANEL
				
oPanel	:= oWizard:GetPanel(6)
WIZPG(oPanel,5)
       					    					
ACTIVATE WIZARD oWizard CENTERED
			
Return

/*/{Protheus.doc} WIZPG
Construção das etapas de configuração

@param oPanel	Objeto do painel a ser apresentado
@param nPg		Etapa
@param nConfig	1-Totvs Colaboração / 2-Importador XML
@param cNGINN	Parametro para importar XMLs
@param cNGLID	Parametro para salvar XMLs importados

@author rodrigo.mpontes
@since 05/08/19
/*/
Static Function WIZPG(oPanel,nPg,nConfig,cNGINN,cNGLID)

Local cDesc		:= ""
Local cLink		:= ""
Local cMVNGIN	:= SuperGetMV("MV_NGINN",.F.,Space(50))
Local cMVNGLI	:= SuperGetMV("MV_NGLIDOS",.F.,Space(50))
Local aConfig	:= {"Totvs Colaboração","Importador XML"}
Local aFolder	:= {"Geral","NF-e","CT-e"}
Local aFolder1	:= {"Parametros Transmite","Grupo/Empresas Transmite"}
Local aHdFold	:= {"Parametro","Conteudo"}
Local aTmFold	:= {10,50}
Local aHdEmp	:= {"","Empresa","Filial"}
Local aTmEmp	:= {10,8,8}

If nPg == 1 //Pagina 1
	oDesc := TSay():New(10,10,{|| "Informe se deseja configurar o TOTVS Colaboração ou Importador XML"},oPanel,,,,,,.T.,,,400,20)
	
	oRadio := TRadMenu():New (40,10,aConfig,,oPanel,,,,,,,,100,12,,,,.T.)
	oRadio:bSetGet := {|u|Iif (PCount()==0,nConfig,nConfig:=u)}
	
	cDesc := '<p>Link Guia de referência:</p>'
	cDesc += '<p>Totvs Colaboração</p>'
	cDesc += '<p><a href="http://tdn.totvs.com/pages/releaseview.action?pageId=271661626">http://tdn.totvs.com/pages/releaseview.action?pageId=271661626</a></p>'
	cDesc += '<p></p>'
	cDesc += '<p>Importador XML</p>'
	cDesc += '<p><a href="http://tdn.totvs.com/pages/releaseview.action?pageId=485858148">http://tdn.totvs.com/pages/releaseview.action?pageId=485858148</a></p>'
	cDesc += '<p></p>'
	
	oDesc2 := TSay():New(70,10,{||cDesc},oPanel,,,,,,.T.,,,400,300,,,,,,.T.)
	
Elseif nPg == 2 //Pagina 2
	cDesc := '<p>As configurações de <strong>Agendamento (COLAUTOREAD/SCHEDCOMCOL)</strong> e <strong>E-mail (Eventviewer - Evento 052/053)</strong> deverão ser realizadas manualmente.</p>'
	cDesc += '<p></p>'
	cDesc += '<p>Totvs Colaboração - Agendamento / E-mail</p>'
	cDesc += '<p><a href="http://tdn.totvs.com/pages/releaseview.action?pageId=271662306">http://tdn.totvs.com/pages/releaseview.action?pageId=271662306</a></p>'
	cDesc += '<p><a href="http://tdn.totvs.com/pages/releaseview.action?pageId=271662413">http://tdn.totvs.com/pages/releaseview.action?pageId=271662413</a></p>'
	cDesc += '<p></p>'
	cDesc += '<p>Importador XML - Agendamento / E-mail</p>'
	cDesc += '<p><a href="http://tdn.totvs.com/display/public/PROT/Agendamento+%28Schedule%29+-+Importador+XML">http://tdn.totvs.com/display/public/PROT/Agendamento+%28Schedule%29+-+Importador+XML</a></p>'
	cDesc += '<p><a href="http://tdn.totvs.com/display/public/PROT/E-mail+%28Eventviewer%29+-+Importador+XML">http://tdn.totvs.com/display/public/PROT/E-mail+%28Eventviewer%29+-+Importador+XML</a></p>'	
	
	oDesc3 := TSay():New(10,10,{||cDesc},oPanel,,,,,,.T.,,,250,300,,,,,,.T.)

Elseif nPg == 3 //Pagina 3
	If !Empty(cMVNGIN)
		cNGINN := cMVNGIN
	Endif
	
	If !Empty(cMVNGLI)
		cNGLID := cMVNGLI
	Endif
	
	cDesc := "Definir o caminho da onde serão importados os XML (Parâmetros)" + CRLF + CRLF +;
			 "Obs: o caminho deve estar dentro do DATA do Protheus."
	
	oDesc4 := TSay():New(10,10,{|| cDesc},oPanel,,,,,,.T.,,,400,20)
	
	oDesc5 := TSay():New(40,10,{|| "MV_NGINN: "},oPanel,,,,,,.T.,,,40,20)
	oGet1  := TGet():New(38,60,{|u|If(PCount()==0,cNGINN,cNGINN := u ) },oPanel,120,10,"@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cNGINN",,,,)
	
	oDesc6 := TSay():New(60,10,{|| "MV_NGLIDOS: "},oPanel,,,,,,.T.,,,40,20)
	oGet2  := TGet():New(58,60,{|u|If(PCount()==0,cNGLID,cNGLID := u ) },oPanel,120,10,"@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cNGLID",,,,)
	
	cLink := '<p>Totvs Colaboração - Estrutura</p>'
	cLink += '<p><a href="http://tdn.totvs.com/pages/releaseview.action?pageId=271662259">http://tdn.totvs.com/pages/releaseview.action?pageId=271662259</a></p>'
	cLink += '<p></p>'
	cLink += '<p>Importador XML - Estrutura</p>'
	cLink += '<p><a href="http://tdn.totvs.com/pages/releaseview.action?pageId=485869252">http://tdn.totvs.com/pages/releaseview.action?pageId=485869252</a></p>'
	
	oDesc7 := TSay():New(80,10,{||cLink},oPanel,,,,,,.T.,,,400,300,,,,,,.T.)
	
Elseif nPg == 4 //Pagina 4
	oTFolder := TFolder():New(05,05,aFolder,,oPanel,,,,.T.,,290,130)
	
	//Folder 1 - Geral
	oBrw1 	:= TWBrowse():New(05,05,280,115,,aHdFold,aTmFold,oTFolder:aDialogs[1],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oBrw1:SetArray(aParamF1)
	oBrw1:bLine	:= { || {   aParamF1[oBrw1:nAt,1],;
							aParamF1[oBrw1:nAt,2]}}
	oBrw1:bLDblClick := {|| SELPARAM(oBrw1,oBrw1:nAT,aParamF1)}
			
	//Folder 2 - NF-e
	oBrw2 	:= TWBrowse():New(05,05,280,115,,aHdFold,aTmFold,oTFolder:aDialogs[2],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oBrw2:SetArray(aParamF2)
	oBrw2:bLine	:= { || {   aParamF2[oBrw2:nAt,1],;
							aParamF2[oBrw2:nAt,2]}}
	oBrw2:bLDblClick := {|| SELPARAM(oBrw2,oBrw2:nAT,aParamF2)}
	
	//Folder 3 - CT-e
	oBrw3 	:= TWBrowse():New(05,05,280,115,,aHdFold,aTmFold,oTFolder:aDialogs[3],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oBrw3:SetArray(aParamF3)
	oBrw3:bLine	:= { || {   aParamF3[oBrw3:nAt,1],;
							aParamF3[oBrw3:nAt,2]}}
	oBrw3:bLDblClick := {|| SELPARAM(oBrw3,oBrw3:nAT,aParamF3)}
Elseif nPg == 5
	/*cDesc := "Configurar integração Totvs Transmite x Importador XML"
	oDesc8 := TSay():New(10,10,{|| cDesc},oPanel,,,,,,.T.,,,400,20) */

	oTFolder1 := TFolder():New(05,05,aFolder1,,oPanel,,,,.T.,,290,130)


	oBrw5 	:= TWBrowse():New(05,05,280,115,,aHdFold,aTmFold,oTFolder1:aDialogs[1],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oBrw5:SetArray(aParamF4)
	oBrw5:bLine	:= { || {   aParamF4[oBrw5:nAt,1],;
							aParamF4[oBrw5:nAt,2]}}
	oBrw5:bLDblClick := {|| SELPARAM(oBrw5,oBrw5:nAT,aParamF4)}

	oBrw4	:= TWBrowse():New(05,05,280,115,,aHdEmp,aTmEmp,oTFolder1:aDialogs[2],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oBrw4:SetArray(aEmpFil)
	oBrw4:bLine	:= { || {   If(aEmpFil[oBrw4:nAt,1],oOK,oNO),;
							aEmpFil[oBrw4:nAt,2],;
							aEmpFil[oBrw4:nAt,3]}}
	oBrw4:bLDblClick := {|| SELPARAM(oBrw4,oBrw4:nAT,aEmpFil,1)}
Endif 

Return

/*/{Protheus.doc} WIZEMPFIL
Browse com as empresas/filiais para integração com o Transmite

@author rodrigo.mpontes
@since 05/08/19
/*/

Static Function WIZEMPFIL()

Local nI		:= 0
Local aRet		:= {}
Local cAliTmp	:= ""
Local cQry		:= ""

For nI := 1 To Len(aSM0)
	aAdd(aRet,Array(3))

	aRet[Len(aRet),1] := .F. 
	aRet[Len(aRet),2] := aSM0[nI,SM0_GRPEMP]
	aRet[Len(aRet),3] := aSM0[nI,SM0_CODFIL]
Next nI

If ChkFile("DHW") 
	cAliTmp := GetNextAlias()

	cQry := " SELECT DHW_GRPEMP, DHW_FILEMP"
	cQry += " FROM " + RetSqlName("DHW")
	cQry += " WHERE D_E_L_E_T_ = ' '"

	cQry := ChangeQuery(cQry)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),cAliTmp,.T.,.T.)

	While (cAliTmp)->(!EOF())
		nPos := aScan(aRet,{|x| AllTrim(x[2]) == AllTrim((cAliTmp)->DHW_GRPEMP) .And. AllTrim(x[3]) == AllTrim((cAliTmp)->DHW_FILEMP)})
		If nPos > 0 
			aRet[nPos,1] := .T.
		Endif
		(cAliTmp)->(DbSkip())
	Enddo

	(cAliTmp)->(DbCloseArea())
Endif

Return aRet
 
/*/{Protheus.doc} WIZVLD
Validação de alguma informação

@param nPg		Etapa
@param nConfig	1-Totvs Colaboração / 2-Importador XML

@author rodrigo.mpontes
@since 05/08/19
/*/
Static Function WIZVLD(nPg,nConfig)

Local lRet		:= .T.
Local cTexto	:= ""
Local cTabCKO	:= ""

If nPg == 1 //Pagina 1
	If nConfig == 2 //Importador XML
		If CKO->(FieldPos("CKO_ARQXML")) == 0 .Or. Empty(CKO->(IndexKey(5)))
			cTexto := "Para utilizar o importador XML é necessario verificar compatibilidade." + CRLF + CRLF + ;
					  "http://tdn.totvs.com/display/public/PROT/IX01+-+Compatibilizadores"
					  
			WIZHLP(cTexto)
			lRet := .F.
		Endif

		If lRet .And. !ChkFile("DHW")
			cTexto := "Warning: Para utilizar integração Totvs Transmite x Importador XML é necessario possuir a tabela DHW"
			WIZHLP(cTexto)
		Endif
	Endif
	
	cTabCKO := RetSqlName("CKO")
	If cTabCKO <> "CKOCOL"
		If Empty(cTexto)
			cTexto := "Será necessario ajustar a tabela CKO, para CKOCOL na SX2"
		Else
			cTexto += "Será necessario ajustar a tabela CKO, para CKOCOL na SX2"
		Endif
		lRet := .F.
	Endif
	
	If !lRet
		WIZHLP(cTexto)
	Endif	
Endif

Return lRet

/*/{Protheus.doc} WIZHLP
Tela de apresentação de algum erro ou finalizando a configuração.

@param cTexto	Texto a ser apresentado

@author rodrigo.mpontes
@since 05/08/19
/*/
Static Function WIZHLP(cTexto)

DEFINE MSDIALOG oDlgHlp TITLE "Help" FROM 000,000 TO 300,400 PIXEL

oFont := TFont():New('Arial',,-14,.T.)
oMultHlp := tMultiget():new(00,00,{|u| if(pCount() > 0,cTexto := u,cTexto)},oDlgHlp,195,145,oFont,,,,,.T.,,,,,,.T.,,,,.F.,.T.)

ACTIVATE MSDIALOG oDlgHlp CENTERED

Return

/*/{Protheus.doc} SELPARAM
Selecionado parametro para modificação.
Apresentação detalhada do parametro

@param oObj		Objeto TwBrowse em edição
@param nLinha	Linha em edição
@param aParam	Array em edição

@author rodrigo.mpontes
@since 05/08/19
/*/
Static Function SELPARAM(oObj,nLinha,aParam,nOpc)

Local cDesc		:= ""
Local cParam	:= ""
Local xConteud
Local aInfo		:= {}

Default nOpc := 0

If nOpc == 0
	aInfo := CONSPAR(oObj:aArray[nLinha,1])

	cParam		:= aInfo[1]
	xConteud	:= aInfo[2]
	cDesc		:= aInfo[3]

	DEFINE MSDIALOG oDlgPar TITLE "Parametros" FROM 000,000 TO 300,400 PIXEL

	oNomPar 	:= TSay():New(10,05,{|| "Parametro: " + cParam},oDlgPar,,,,,,.T.,,,100,20)
	oConPar 	:= TSay():New(30,05,{|| "Conteudo: "},oDlgPar,,,,,,.T.,,,40,20)
	oDescPar 	:= TGet():New(28,50,{|u|If(PCount()==0,xConteud,xConteud := u ) },oDlgPar,120,10,"!@",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"xConteud",,,,)
		
	oFont := TFont():New('Arial',,-14,.T.)
	oMultPar := tMultiget():new(50,05,{|u| if(pCount() > 0,cDesc := u,cDesc)},oDlgPar,195,65,oFont,,,,,.T.,,,,,,.T.,,,,.F.,.T.)

	oBtn1 := TButton():New(125,110,"Salvar",oDlgPar,{|| SAVEPAR(oObj,nLinha,xConteud,aParam),oDlgPar:End()}, 40,20,,,.F.,.T.,.F.,,.F.,,,.F. ) 
	oBtn2 := TButton():New(125,150,"Cancelar",oDlgPar,{|| oDlgPar:End()}, 40,20,,,.F.,.T.,.F.,,.F.,,,.F. ) 

	ACTIVATE MSDIALOG oDlgPar CENTERED

Elseif nOpc == 1
	aParam[oObj:nAt,1] := !aParam[oObj:nAt,1]

	oObj:SetArray(aParam)
	oObj:bLine := {|| {If(aParam[oObj:nAT,1],oOK,oNo),aParam[oObj:nAt,02],aParam[oObj:nAt,03]}}
	oObj:Refresh()
Endif

Return

/*/{Protheus.doc} SAVEPAR
Salva edição do parametro / refresh em tela

@param oObj			Objeto TwBrowse em edição
@param nLinha		Linha em edição
@param xConteudo	Conteudo do parametro
@param aParam		Array em edição

@author rodrigo.mpontes
@since 05/08/19
/*/

Static Function SAVEPAR(oObj,nLinha,xConteudo,aParam)

aParam[nLinha,2]		:= xConteudo
oObj:aArray[nLinha,2]	:= xConteudo

oObj:SetArray(aParam)
oObj:bLine	:= { || {   aParam[oObj:nAt,1],;
						aParam[oObj:nAt,2]}}
oObj:Refresh()

Return

/*/{Protheus.doc} CONSPAR
Consulta parametro na SX6

@param cMVParam	Parametro para consulta na SX6

@author rodrigo.mpontes
@since 05/08/19
/*/

Static Function CONSPAR(cMVParam)

Local aRet		:= {}
Local cParam	:= ""
Local cDesc		:= ""
Local xConteudo

DbSelectArea("SX6")
If SX6->(DbSeek(xFilial("SX6") + cMVParam))
	cParam 		:= cMVParam
	xConteudo	:= X6Conteud()
	cDesc		:= AllTrim(X6Descric()) + AllTrim(X6Desc1()) + AllTrim(X6Desc2())
Endif

aAdd(aRet,cParam)
aAdd(aRet,xConteudo)
aAdd(aRet,cDesc)

Return aRet

/*/{Protheus.doc} WIZCOMMIT
Commit das alteração dos parametros

@param nConfig	1-Totvs Colaboração / 2-Importador XML
@param cMVNGINN	Parametro para importar XML
@param cMVNGLID	Parametro para salvar XMLs lidos

@author rodrigo.mpontes
@since 05/08/19
/*/

Static Function WIZCOMMIT(nConfig,cMVNGINN,cMVNGLID)

Local nI			:= 0
Local aSM0Dados		:= {}
Local nTamGrp		:= 0
Local nTamFil		:= 0
Local lFindDHW		:= .F.
Local cCodFil		:= ""

If nConfig == 2 //Importador XML
	PutMV("MV_IMPXML",.T.)
Endif

If !Empty(cMVNGINN)
	PutMV("MV_NGINN",cMVNGINN)
Endif

If !Empty(cMVNGLID)
	PutMV("MV_NGLIDOS",cMVNGLID)
Endif

For nI := 1 To Len(aParamF1)
	PutMV(aParamF1[nI,1],aParamF1[nI,2])
Next nI

For nI := 1 To Len(aParamF2)
	PutMV(aParamF2[nI,1],aParamF2[nI,2])
Next nI

For nI := 1 To Len(aParamF3)
	PutMV(aParamF3[nI,1],aParamF3[nI,2])
Next nI

For nI := 1 To Len(aParamF4)
	PutMV(aParamF4[nI,1],aParamF4[nI,2])
Next nI

If ChkFile("DHW")
	nTamGrp := TamSX3("DHW_GRPEMP")[1]
	nTamFil := TamSX3("DHW_FILEMP")[1]
	DbSelectArea("DHW") 
	DHW->(DbSetOrder(1))
	For nI := 1 To Len(aEmpFil)
		If aEmpFil[nI,1]
			
			lFindDHW := DHW->(DbSeek(xFilial("DHW") + PadR(aEmpFil[nI,2],nTamGrp) + PadR(aEmpFil[nI,3],nTamFil)))

			If !lFindDHW .Or. (lFindDHW .And. Empty(DHW_CODFIL))
				
				aSM0Dados 	:= FWSM0Util():GetSM0Data( aEmpFil[nI,2] , aEmpFil[nI,3] , { "M0_CGC","M0_INSC","M0_ESTENT" } ) 
				cCodFil		:= WIZCODFIL(aEmpFil[nI,2],aEmpFil[nI,3],aSM0Dados[1,2],aSM0Dados[2,2],aSM0Dados[3,2])
				
				If !Empty(cCodFil) 
					If RecLock("DHW",!lFindDHW)
						DHW->DHW_FILIAL := xFilial("DHW") 
						DHW->DHW_GRPEMP := aEmpFil[nI,2]
						DHW->DHW_FILEMP := aEmpFil[nI,3]
						DHW->DHW_CGC    := aSM0Dados[1,2]
						DHW->DHW_IE     := aSM0Dados[2,2]
						DHW->DHW_UF     := aSM0Dados[3,2]
						DHW->DHW_CODFIL := cCodFil
						
						DHW->(MsUnlock())
					Endif
				Endif
			Endif
		Endif
	Next nI
Endif

WIZHLP("Parametros atualizados com sucesso")

Return

/*/{Protheus.doc} WIZCODFIL
Integração com Transmite para busca Codigo Filial correspondente

@author rodrigo.mpontes
@since 05/08/19
/*/

Static Function WIZCODFIL(cEmp,cFil,cCGC,cIE,cUF)

Local oComTransmite	:= Nil
Local lImpXML       := SuperGetMv("MV_IMPXML",.F.,.F.) .And. CKO->(FieldPos("CKO_ARQXML")) > 0 .And. !Empty(CKO->(IndexKey(5)))
Local cConteudo		:= ""

If lImpXML
	oComTransmite := ComTransmite():New()

	If oComTransmite:TokenTotvsTransmite()
		cConteudo := oComTransmite:GetCodigoFilial(cCGC,cIE,cUF,cEmp,cFil)
	Endif
	
	FreeObj(oComTransmite)
Endif 

Return cConteudo
