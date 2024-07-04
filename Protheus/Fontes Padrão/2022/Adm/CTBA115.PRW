#include "ctba115.ch"
#include "protheus.ch"

Static _oCTBA1151
Static __oTempTbVisGer

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Ctba115 ³ Autor ³ ----------------------- ³ Data ³ 01/09/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cadastro de Quadros Contabeis Configuraveis                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB - Cadastros Auxiliares de Demonstrativos Gerenciais ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctba115(xAutoCab,xAutoItens,nOpcAuto)

Local cFilPad	:= ""
Local cAlias	:= "CVQ"

Private aRotina := MenuDef()
Private PARAMIXB := {} // Para validação das formulas
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Variaveis para rotina automatica    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

Private lCtb115Auto 	:= ( ValType(xAutoCab) == "A" .And. ValType(xAutoItens) == "A" )
Private aAutoCab   		:= {}
Private aAutoItens	 	:= {}
Private lRpc       		:= Type("oMainWnd") = "U"		// Chamada via Rpc nao tem tela
Private cCadastro  		:= STR0001 // "Cadastro de Quadros Contabeis Configuraveis" 			
Private aIndexFil		:= {}
Private bFiltraBrw

If (!AMIIn(34)) .And. (!lCtb115Auto)	// Acesso somente pelo SIGACTB ou Rotina automatica
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cFilPad := "CVQ_FILIAL = '"+xFilial("CVQ")+"'"+" AND CVQ_ITEM = '"+StrZero(1,TamSx3("CVQ_ITEM")[1])+"'"

If lCtb115Auto
	aAutoCab   := xAutoCab
	aAutoItens := xAutoItens
	MBrowseAuto(nOpcAuto,Aclone(aAutoCab),"CVQ")
Else
	mBrowse( 6,1,22,75,"CVQ",,,,,,,,,,,,,,cFilPad)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera a Integridade dos dados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("CVQ")
CVQ->( dbSetOrder(1) )

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Ctb115PES³ Autor ³ --------------------- ³ Data ³ 01/09/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pesquisa com filtro                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTB115PES()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA115                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb115Pes()
AxPesqui()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ Ctb115Cad ³ Autor ³ ----------------------- ³ Data ³ 01/09/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Programa de inclusao de Grupos de Rateios                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb115Cad(cAlias,nReg,nOpcx)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias = Alias do arquivo                                     ³±±
±±³          ³ nReg   = Numero do registro                                   ³±±
±±³          ³ nOpcx  = Opcao selecionada                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba115                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb115Cad(cAlias,nReg,nOpcx)

Local oDlg
Local nOpcA
Local oGet
Local cArqTmp
Local oFnt
Local oCod
Local oDesc
Local oTot

Local aArea      := GetArea()		
Local aDados     := {}
Local aAltera    := {}
Local aGetDB     := {}		// Campos da GetDados

Local nOpcGDB    := nOpcX	// Variavel para carregar a GetDB
Local nOpcao     := If(nOpcX == 3, 4, nOpcX)

Local lDigita    := (nOpcx == 3 .or. nOpcx == 4)		// LÓGICO - INDICA QUANDO OS CAMPOS PODEM SER EDITADOS (INCLUSAO OU ALTERACAO)

Local cAliasTmp  := ""
Local aButtons	 := {} 
Local oSize
Local nLinIni	:= 0
Local nColIni	:= 0
Local nLinEnd	:= 0
Local nColEnd	:= 0

Private aHeader  := {}

Private cCVQ_Codigo
Private cCVQ_Desc
Private	cCVQ_Totaliza
Private aCVQ_Totaliza	:= CtbCbox("CVQ_IMPTOT","",TamSx3("CVQ_IMPTOT")[1])

(cAlias)->(DbClearFil())
RestArea(aArea)

aGetDB 		:= {	"CVQ_ITEM","CVQ_DESCIT","CVQ_CDVGIT","CVQ_FORMPA","CVQ_FORMPC" }
cAliasTmp 	:= "TMP"

If nOpcX == 3 // Inclusao
	cCVQ_Codigo 		:= CriaVar("CVQ_CODIGO")
	cCVQ_Desc   		:= CriaVar("CVQ_DESCRI")
	cCVQ_Totalizaade  	:= CriaVar("CVQ_IMPTOT")
Else
	cCVQ_Codigo 		:= CVQ->CVQ_CODIGO
	cCVQ_Desc   		:= CVQ->CVQ_DESCRI
	cCVQ_Totalizaade	:= CVQ->CVQ_IMPTOT
Endif

Ctb115aHeader(cAlias,aGetDb,aAltera)
Ctb115CriaTmp(cAlias, cAliasTmp)	 // Cria tabela temporaria no banco de dados
Ctb115Carr(nOpcX)					 // Carrega dados no temporario

If !lCtb115Auto
	DEFINE FONT oFnt	NAME "Arial" Size 10,15
	
	DbSelectArea(cAlias)
	DEFINE MSDIALOG oDlg TITLE STR0001  From 0,0 To 423,702 PIXEL OF oMainWnd //"Cadastro de Quadros Contabeis Configuraveis"
	oSize := FwDefSize():New(.T.,,,oDlg)
	oSize:AddObject( "CABECALHO",  100, 20, .T., .T. ) // Totalmente dimensionavel
	oSize:AddObject( "GETDADOS" ,  100, 60, .T., .T. ) // Totalmente dimensionavel 
	oSize:AddObject( "RODAPE",  100, 20, .T., .T. ) // Totalmente dimensionavel
	
	oSize:lProp 	:= .T. // Proporcional             
	oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

	oSize:Process() 	   // Dispara os calculos  
	
	nLinIni := oSize:GetDimension("CABECALHO","LININI")
	nColIni := oSize:GetDimension("CABECALHO","COLINI")
	
	@ nLinIni+13,   4 TO 39, 349		OF oDlg PIXEL 
	@ nLinIni+23,   9 SAY STR0002	OF oDlg PIXEL	//	"Cod Indice"
	@ nLinIni+21,  47 MSGET oCod VAR cCVQ_Codigo           OF oDlg SIZE 30, 9 PIXEL PICTURE PesqPict("CVQ","CVQ_CODIGO");
												   When nOpcX == 3 ;
												   Valid Ctb115Valid("CVQ_CODIGO",cCVQ_Codigo) .and. FreeForUse("CVQ",cCVQ_Codigo)
	oCod:cSX1Hlp := "CVQ_CODIGO"
												   
	@ nLinIni+23, 100 SAY STR0003		OF oDlg PIXEL	//	"Descrição"
	@ nLinIni+21, 135 MSGET oDesc VAR cCVQ_Desc  		OF oDlg SIZE 80, 9 PIXEL PICTURE PesqPict("CVQ","CVQ_DESCRI");
	 											When nOpcX == 3 .Or. nOpcX == 4 ;                   
	 										    Valid Ctb115Valid("CVQ_DESCRI",cCVQ_Desc)
	oDesc:cSX1Hlp := "CVQ_DESCRI"
	
	@ nLinIni+23, 242 SAY STR0004 OF oDlg PIXEL	//	"Totalizar"
	@ nLinIni+21, 272 MSCOMBOBOX oTot VAR cCVQ_Totalizaade ITEMS aCVQ_Totaliza OF oDlg PIXEL SIZE 60,9  ;
													When nOpcX == 3 
	nLinIni 	:= oSize:GetDimension("RODAPE","LININI")
	nColIni	 := oSize:GetDimension("RODAPE","COLINI")
	nLinEnd	 := oSize:GetDimension("RODAPE","LINEND")	
	nColEnd	 := oSize:GetDimension("RODAPE","COLEND")													
	@ nLinIni,  nColIni TO  nLinEnd - 5,nColEnd -5		 OF oDlg PIXEL 
	
	oTot:cSX1Hlp := "CVQ_IMPTOT"

	nLinIni := oSize:GetDimension("GETDADOS","LININI")
	nColIni := oSize:GetDimension("GETDADOS","COLINI")
	nLinEnd := oSize:GetDimension("GETDADOS","LINEND")
	nColEnd := oSize:GetDimension("GETDADOS","COLEND" )	

	oGet := MSGetDb():New(nLinIni,nColIni,nLinEnd,nColEnd,nOpcao,"Ctb115LOk", "Ctb115TOk", "+CVQ_ITEM",.T.,aAltera,,.T.,,cAliasTmp,,,,,,,)

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,;
			{||nOpca:=1,If(Ctb115TOK(nOpcX,cCVQ_Codigo),oDlg:End(),nOpca := 0)},;
			{||nOpca:=2,oDlg:End()},,aButtons) VALID nOpca != 0
Else
	cCVQ_Codigo 	:= aAutoCab[01,02]
	cCVQ_Desc 		:= aAutoCab[02,02]
	cCVQ_Totaliza 	:= aAutoCab[03,02]
	lOk	:= MsGetDBAuto(	"TMP",;
						aAutoItens,;
						"Ctb115LOK",;
						{ || Ctb115TOk(nOpcX,cCVQ_Codigo) },;
						aAutoCab,;
						nOpcGDB )

	nOpcA := If( lOk,1,0 )
EndIf

If nOpcA == 1 .and. nOpcX <> 2
	Begin Transaction
		If !lCtb115Auto
			AADD(aDados,{"CVQ_CODIGO"	,cCVQ_Codigo})
			AADD(aDados,{"CVQ_DESCRI"	,cCVQ_Desc  })
			AADD(aDados,{"CVQ_IMPTOT" 	,cCVQ_Totalizaade  })
		Else
			// Se estiver executando rotina automatica e NAO FOR Exclusao,
			// alimentar "aDados" com todos os elementos da matriz recebida
			If nOpcX <> 5
				AADD(aDados,{"CVQ_CODIGO"	,aAutoCab[01,02]})
				AADD(aDados,{"CVQ_DESCRI"	,aAutoCab[02,02]})
				AADD(aDados,{"CVQ_IMPTOT" 	,aAutoCab[03,02]})
			Else
				// Se estiver executando rotina automatica e FOR Exclusao,
				// alimentar "aDados" apenas com o codigo do grupo de rateio, 
				// que eh o primeiro elemento da matriz recebida
				aDados := {	{"CVQ_CODIGO",aAutoCab[01,02]} }
			EndIf
		EndIf
		Ctb115Grava(cAlias,aDados,nOpcX)
	End Transaction
EndIf

RetIndex("CVQ")

DbSelectArea(cAliasTmp)
dbCloseArea()

//Limpa os arquivos temporários 
TempQuad()

dbSelectArea("CVQ")
Set Filter TO &('CVQ_FILIAL=="'+xFilial("CVQ")+'"'+' .And. CVQ_ITEM=="'+StrZero(1,TamSx3("CVQ_ITEM")[1])+'"')

RestArea(aArea)
dbSelectArea(cAlias)

Return nOpcA

/*/
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ctb115aHea³ Autor ³ --------------------- ³ Data ³ 01/09/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Prepar aHeader para GetDb                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba115                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ctb115aHeader(cAlias,aGetDb,aAltera)
Local aArea  := GetArea()

dbSelectArea("SX3")
dbSetOrder(1)

dbSeek(cAlias)
While !EOF() .And. (x3_arquivo == cAlias)

	IF X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. (Ascan(aGetDb,Trim(x3_campo)) > 0 .Or. X3_PROPRI == 'U')
	
		AADD(aHeader,{	TRIM(X3Titulo()),;
						x3_campo,;
						x3_picture,;
					 	x3_tamanho,;
					 	x3_decimal,;
					 	x3_valid,;
					 	x3_usado,;
					 	x3_tipo,;
					 	"TMP",;
					 	x3_context } )
	
		If Alltrim(x3_campo) <> "CVQ_ITEM"
			Aadd(aAltera,Trim(X3_CAMPO))
		EndIf			 
	
	ENDIF

	Skip
	
EndDo

RestArea(aArea)

Return Nil

/*/
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ctb115Grav³ Autor ³ --------------------- ³ Data ³ 01/09/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava as informacoes do cadastro                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba115                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ctb115Grava(cAlias,aDados,nOpcX)

Local aArea			:= GetArea()
Local aOrder		:= {2,3,4,5}

Local nAscan, nX	:= 0
Local nCont			:= 0

Local cCVQ_Codigo	:= ""
Local cCVQ_Totalizaade	:= ""
Local cMsg			:= ""

Local lDelSEQ1		:= .F.
Local lInclui		:= .T.
Local aDadosCVQ		:= {}
Local aDelCVQ		:= {} 
Local nCountSeq		:= 0

cCVQ_Codigo 	:= aDados[Ascan(aDados,{|e| e[1] = "CVQ_CODIGO" } )][2]	 // Obtem o codigo do cadastro

(cAlias)->(dbSetOrder(1))

If nOpcX == 5	//	Se for Exclusao

	If (cAlias)->(MsSeek(xFilial(cAlias)+cCVQ_Codigo))
		While (cAlias)->(!Eof() .And. xFilial(cAlias) == CVQ_FILIAL .And. CVQ_CODIGO == cCVQ_Codigo)
			
			RecLock(cAlias,.F.,.T.)
			(cAlias)->(dbDelete())
			(cAlias)->(dbSkip())
			
		EndDo
	EndIf

Else              
   
    // Se for Inclusao em rotina automatica, verificar se o indice ja existe. Se existir, 
    // nao deixar incluir e abandonar a rotina.
	If lCtb115Auto
		If (cAlias)->(MsSeek(xFilial(cAlias)+cCVQ_Codigo))
			lInclui := .F.
		EndIf
	EndIf

	If lInclui	
	
		TMP->(dbGoTop())
		While TMP->(!Eof())
			(cAlias)->(dbSetOrder(1))
			If TMP->CVQ_FLAG  //  Se a linha estiver excluida
				If nOpcX == 3  //  Se for Inclusao
					If TMP->CVQ_ITEM == StrZero(1,LEN(TMP->CVQ_ITEM)) // Se excluiu a primeira linha
						lDelSEQ1 := .T.
					Endif		
				Else
					If (cAlias)->(dbSeek(xFilial(cAlias)+cCVQ_Codigo+TMP->CVQ_ITEM))
						If TMP->CVQ_ITEM == StrZero(1,LEN(TMP->CVQ_ITEM))
							lDelSEQ1 := .T.
						Endif
						
						Reclock(cAlias,.F.,.T.)
						(cAlias)->(dbDelete())
						(cAlias)->(MsUnlock())

					EndIf
				EndIf
			Else		               

				If ! (cAlias)->(dbSeek(xFilial(cAlias)+cCVQ_Codigo+TMP->CVQ_ITEM))
					RecLock(cAlias,.T.)
				Else
					RecLock(cAlias,.F.)
				EndIf

				For nX := 1 To (cAlias)->(fCount())
					cNomeCpo := (cAlias)->(FieldName(nx))
					If cNomeCpo == "CVQ_FILIAL"
						(cAlias)->CVQ_FILIAL := xFilial("CVQ")
					ElseIf lDelSEQ1 .and. cNomeCpo == "CVQ_ITEM"		/// SE DELETOU A 1ª SEQUENCIA RENUMERA AS DEMAIS SEQUENCIAS
						nCountSeq++
						(cAlias)->CVQ_ITEM := StrZero(nCountSeq,LEN(TMP->CVQ_ITEM))
					Else
						// Pesquisa o campo atual em aHeader
						nAscan := Ascan(aHeader,{|e| Upper(AllTrim(e[2])) == Upper(AllTrim((cAlias)->(FieldName(nX))))})
						If nAscan > 0 .And. (cAlias)->(FieldPos(TMP->(FieldName(nX)))) > 0             
							(cAlias)->(FieldPut(nX,TMP->(FieldGet(nX)))) // CVQ e TMP tem a mesma estrutura
						Else
							nAscan := Ascan(aDados, {|e| e[1] == (cAlias)->(FieldName(nX))})
							If nAscan > 0
								(cAlias)->(FieldPut(nX,aDados[nAscan][2]))
							Endif	
						Endif
					Endif
				Next
				
				(cAlias)->(MsUnlock())
			EndIf
			TMP->(dbSkip())
		EndDo
	EndIf
	
ENDIF

RestArea(aArea)
Return


/*/
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ctb115Cria³ Autor ³ --------------------- ³ Data ³ 01/09/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Prepara arquivo temporario para GetDb a partir do CVQ      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba115                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ctb115CriaTmp(cAlias,cAliasTmp)
Local aArea	:= GetArea()
Local aStru   := (cAlias)->(DbStruct())
		
//--------------------------
//Monta os campos da tabela
//--------------------------

aadd(aStru,{"CVQ_FLAG","L",01,0})

If _oCTBA1151 <> Nil
	_oCTBA1151:Delete()
	_oCTBA1151 := Nil
Endif

_oCTBA1151 := FWTemporaryTable():New( cAliasTmp )  
_oCTBA1151:SetFields(aStru) 
_oCTBA1151:AddIndex("1", {"CVQ_DESCRI"} )

//------------------
//Criação da tabela temporaria
//------------------
_oCTBA1151:Create()  

RestArea(aArea)

Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ctb115Carr³ Autor ³ --------------------- ³ Data ³ 01/09/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega dados para GetDB                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb115Carr(nOpc)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA115                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                  					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ctb115Carr(nOpc)
Local aSaveArea := GetArea()
Local nPos
Local nCont
Local cAliasTmp	:= "TMP"
Local cGrupo

If nOpc != 3						// Visualizacao / Alteracao / Exclusao
	cGrupo := CVQ->CVQ_CODIGO
	dbSelectArea("CVQ")
	dbSetOrder(1)
	If dbSeek(xFilial()+cGrupo)
		While !Eof() .And. (CVQ->(CVQ_FILIAL + CVQ_CODIGO)) == (xFilial("CVQ") + cGrupo)
			dbSelectArea(cAliasTmp)
			dbAppend()
			For nCont := 1 To Len(aHeader)
				nPos := FieldPos(aHeader[nCont][2])
				If (aHeader[nCont][08] <> "M" .And. aHeader[nCont][10] <> "V" )
					FieldPut(nPos,CVQ->(FieldGet(FieldPos(aHeader[nCont][2]))))
				EndIf
			Next
			dbSelectArea("CVQ")
			dbSkip()
		EndDo
	EndIf
Else
	dbSelectArea(cAliasTmp)
	dbAppend()
	For nCont := 1 To Len(aHeader)
		If (aHeader[nCont][08] <> "M" .And. aHeader[nCont][10] <> "V" )
			nPos := FieldPos(aHeader[nCont][2])
			FieldPut(nPos,CriaVar(aHeader[nCont][2],.T.))
		EndIf
	Next nCont                      
	(cAliasTmp)->CVQ_ITEM := "001" 
EndIf
	
dbSelectArea(cAliasTmp)
dbGoTop()

RestArea(aSaveArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ctb115TOK ³ Autor ³ --------------------- ³ Data ³ 01/09/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao completa da GetDb e dados do cabeçalho           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb115TOK(nOpcX)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRet                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA115                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nOpcX = Opcao selecionada             					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb115TOk(nOpcX)

LOCAL lRet    	:= .T.
LOCAL nRecno  	:= TMP->(Recno())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Validacao dos campos obrigatorios do cabecalho                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF 	Empty(cCVQ_Codigo) 	.OR.;
	Empty(cCVQ_Desc)	.OR.;
	Empty(cCVQ_Totaliza)
	Help("",1,"OBRIGCAMPO") // CAMPOS OBRIGATORIOS NÃO PREENCHIDOS
	lRet := .F.
ENDIF


IF lRet .And. (nOpcX == 3 .Or. nOpcX == 4)
    TMP->( DbGoTop() )
    While ! TMP->(EOF())
    	IF !TMP->CVQ_FLAG 
			If !Ctb115LOk()
				lRet := .F.
				Exit
			EndIf			
		EndIf
		TMP->( DbSkip() )
	EndDo
ENDIF

TMP->(MsGoTo(nRecno))
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Ctb115Validº Autor ³ ------------------ º Data ³  01/09/09     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validar a digitacao do codigo e descricao do cadastro          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA115                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ctb115Valid(cCampo,xConteudo)
Local lRet  := .T., aArea := GetArea()

If Empty(xConteudo)
	lRet := .f.
	Help(" ",1,"VAZIO")
Else
	If cCampo = "CVQ_CODIGO"
		DbSelectArea("CVQ")
		dbSetOrder(1)
		If CVQ->(MsSeek(xFilial("CVQ")+xConteudo))
			lRet := .F.
			Help(" ",1,"JAEXISTINF")
		Endif
	EndIf
Endif
RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ctb115LOk ºAutor  ³ ------------------ º Data ³  01/09/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua a validação de linha da tela de cadastro             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA115                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ctb115LOk()

LOCAL lRet	 		:= .T.

If !TMP->CVQ_FLAG			/// SE NÃO ESTIVER DELETADO

	//Validação de nenhuma informação preenchida
	IF lRet .And. Empty(TMP->CVQ_CDVGIT) .And. Empty(TMP->CVQ_FORMPA) .And. Empty(TMP->CVQ_FORMPC)   
		Help("CTBA115",1,"HELP","CVQTCODENT",STR0005,1,0)
		lRet := .F.
	ENDIF
	
	// Validacao para avaliar se existem outras linhas com a mesma visao		
	If lRet .And. !Empty(TMP->CVQ_CDVGIT)
		IF  !CT115VLLIN(TMP->CVQ_CDVGIT)
			Help("",1,"EXISTCHAV") // Esta chave já existe
			lRet := .F.
		ENDIF
	EndIf
	
   // Validacao do preenchimento do campo codigo da entidade gerencial  
 	IF lRet .And. !Empty(TMP->CVQ_CDVGIT) .And. ( !Empty(TMP->CVQ_FORMPA) .Or. !Empty(TMP->CVQ_FORMPC))   
		Help("CTBA115",1,"HELP","CVQCODBR",STR0006,1,0)
		lRet := .F.
	ENDIF

	//Validacao do preenchimento dos campos formula dos periodos
 	IF lRet .And. Empty(TMP->CVQ_CDVGIT) .And. (Empty(TMP->CVQ_FORMPA) .Or. Empty(TMP->CVQ_FORMPC))   
		Help("CTBA115",1,"HELP","CVQPERBR",STR0007,1,0)
		lRet := .F.
	ENDIF

Endif

Return lRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CT115VLLIN  ºAutor  ³ Arnaldo Raymundo Jr.    º Data ³ 28/01/08 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida se existe outra linha com a mesma visao gerencial.      º±±
±±º          ³                                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA115                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                       
Static Function CT115VLLIN(cVisao)

Local nRecno := TMP->( Recno() )
Local lRet 	:= .T.

TMP->(DbGotop())
While TMP->(!EOF())
	
	IF !TMP->CVQ_FLAG .AND. TMP->(Recno()) != nRecno .AND. TMP->CVQ_CDVGIT == cVisao
			lRet := .F.
	ENDIF

	TMP->(DbSkip())
End

TMP->(DbGoto(nRecno))
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTB115VLVIS ºAutor  ³ Arnaldo Raymundo Jr.    º Data ³ 28/01/08 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida a digitacao do codigo da visao gerencial			      º±±
±±º          ³                                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA115                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                       
Function CTB115VLVIS()
LOCAL lRet 			:= .F.

lRet := ExistCpo("CTS",M->CVQ_CDVGIT,1)

If lRet
	If Empty(CTBTotVis(M->CVQ_CDVGIT))
		Help("CTBA115",1,"HELP","CVQVISINV",STR0008,1,0)
		lRet := .F.
	EndIf
EndIf

Return lRet



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ --------------------- ³ Data ³ -------- ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados         ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

LOCAL aRotina 	:= {}
LOCAL aCtb115BUT:= {}
LOCAL nX		:= 0

AADD(aRotina, {STR0009, "Ctb115Pes", 0, 1})//	"Pesquisar"
AADD(aRotina, {STR0010, "Ctb115Cad", 0, 2})//	"Visualizar"
AADD(aRotina, {STR0011, "Ctb115Cad", 0, 3})//	"Incluir"
AADD(aRotina, {STR0012, "Ctb115Cad", 0, 4})//	"Alterar"
AADD(aRotina, {STR0013, "Ctb115Cad", 0, 5})//	"Excluir"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PONTO DE ENTRADA PARA ADICAO DE ITENS NO AROTINA                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF ExistBlock("Ctb115BUT")
	aCtb115BUT := ExecBlock("Ctb115BUT",.F.,.F.,aRotina)
	
	IF ValType(aCtb115BUT) == "A" .AND. Len(aCtb115BUT) > 0
		FOR nX := 1 to len(aCtb115BUT)
			aAdd(aRotina,aCtb115BUT[nX])
		NEXT
	ENDIF
ENDIF              
Return(aRotina)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ctb115SelQd º Autor ³ Alvaro Camillo Neto     º Data ³ 09/08/09 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta a tela para escolha dos quadros gerenciais retornando um º±±
±±º          ³ array com as entidades selecionadas pelo usuario ou a STRING   º±±
±±º          ³ para realizar a clausula IN.                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Relatórios CTB                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ctb115SelQd(cTipo)

Local aChave		:= {}
Local aArea			:= GetArea()
Local aCposAlias	:= {"CVQ_CODIGO","CVQ_DESCRI"}
Local cAlias	 	:= "CVQ"
Local cTitulo	 	:= (SX2->(DbSeek(cAlias)),X2NOME()) 
Local cFilAlias 	:= xFilial(cAlias)
Local lOK		 	:= .T.
Local nX			:= 0
Local aCabec		:= {}

// Variaveis utilizadas na selecao de categorias
Local oDlg,oChkQual,lQual,oQual,oBtnOK,oBtnCan,oBtnFil,oGroup
// Carrega bitmaps
Local oOk       := LoadBitmap( GetResources(), "LBOK")
Local oNo       := LoadBitmap( GetResources(), "LBNO")
Local xRet		:= Nil
Local cExpSis   := "CVQ_ITEM == STRZERO(1,TamSX3('CVQ_ITEM')[1]) "
Local cExpUser  := ""
Local bDBLClick, bClick, bSetGet

Default cTipo := "A"

cTipo := AllTrim(Upper(cTipo)) 

IF EMPTY(cTipo) .OR. !(cTipo $ "AC") 
	Help("CTBA115",1,"HELP","CTB115INV",STR0014,1,0)
	lOk := .F.
ENDIF

If lOk
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta array aChave com os itens que serao exibidos em tela   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CtbChave(cAlias,cFilAlias,aCposAlias,cExpSis,cExpUser,@aChave)
	IF Len(aChave) > 0 
		SX3->(dbSetOrder(2))
		For nX := 1 to Len(aCposAlias) + 1
			If nX == 1 
				aAdd(aCabec, "" )
			Else
				aAdd(aCabec,  (SX3->(MsSeek(aCposAlias[ nX - 1 ] )), X3Titulo() )  )
			EndIf  
		Next nX
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta tela para selecao dos itens da entidade contabil       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oDlg:= MSDIALOG():New(000,000,300,625, cTitulo,,,,,,,,,.T.)
		oDlg:lEscClose := .F.
		oGroup := TGROUP():New(005,015,125,300,cTitulo,oDlg,,,.T.)
		
		bClick := {||(AEval(aChave, {|z| z[1] := If(z[1]==.T.,.F.,.T.)}), oQual:Refresh(.F.))}
		bSetGet:= {|l| IIF(PCount()>0,lQual:=l,lQual)}
		oChkQual:= tCheckBox():New(15,20,STR0015,bSetGet,oDlg,50,10,,bClick,,,,,,.T.) //"Inverte Seleção"
	    
		bDBLClick := {|| (aChave:=CtbTroca(oQual:nAt,aChave),oQual:Refresh())}
		oQual := TwBrowse():New(30,20,273,090,, aCabec ,,oDlg,,,,,bDBLClick,,,,,,,.F.,,.T.,,.F.,,,)
		oQual:SetArray(aChave)
		oQual:bLine := { || {If(aChave[oQual:nAt,1],oOk,oNo),aChave[oQual:nAt,2],aChave[oQual:nAt,3]}}
	    
		oBtnOK  := SBUTTON():New(134, 210, 01, {|| IIF(CtbMarcaOk(aChave),(lRet := .T.,oDlg:End()),)}, oDlg, .T., , {|| .T.}) 
		oBtnCan := SBUTTON():New(134, 240, 02, {|| (lRet := .F.,oDlg:End())}		, oDlg, .T., , {|| .T.}) 
		oBtnFil := SBUTTON():New(134, 270, 17, {|| (	cExpUser := BuildExpr(cAlias),;
														CtbChave(cAlias,cFilAlias,aCposAlias,cExpSis,cExpUser,@aChave),;
														oQual:SetArray(aChave),;
														oQual:bLine := { || {If(aChave[oQual:nAt,1],oOk,oNo),aChave[oQual:nAt,2],aChave[oQual:nAt,3]}},;
														oQual:Refresh())}	, oDlg, .T., , {|| .T.})
	
		oDlg:lCentered := .T.
		oDlg:Activate()
	ELSE
		HELP(" ",1,"NORECS",,STR0017,1,0)
	ENDIF

	If cTipo == "A" //Retorno Array
		xRet := {}
		For nX :=1 to Len(aChave)
			If(aChave[nX][1])
				aAdd(xRet,aChave[nX][2])
			EndIf
		Next nX		
	ElseIf cTipo == "C" //Retorno clausula para o IN
		xRet := ""
		For nX :=1 to Len(aChave)
			If(aChave[nX][1])
				xRet += aChave[nX][2] + "/" 
			EndIf
		Next nX 
		If !Empty(xRet)
			xRet := Left( xRet, Len(xRet)-1 )
			xRet := FormatIn(xRet,"/")			
		EndIf
	EndIf
	
EndIf


RestArea(aArea)
RETURN xRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CtbChave º Autor ³ Alvaro Camillo Netoº Data ³  08/09/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retorna os item do listbox de acordo com o filtro          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbChave(cAlias,cFilAlias,aCposAlias,cExpSis,cExpUser,aChave)
Local aArea 		:= GetArea()
Local cFilConPad	:= ""
Local cPrefix 		:= PrefixoCpo(cAlias)
Local nQtdCpo		:= Len(aCposAlias) + 1
Local nX		  		:= 0 
Local bBlock
Local xResult

aChave := {}

Default cExpSis := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ aChave    - Contem as entidades que serao exibidas na tela de  |
//| selecao.                                                       |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF SXB->(DbSeek(PADR(cAlias,6,"")+"6"+"01")) .AND. !Empty(SXB->XB_CONTEM)
	cFilConPad := ALLTRIM(SXB->XB_CONTEM)
ENDIF

cExpSis := IIF(Empty(cExpSis), ".T.", cExpSis )

IF Empty(cExpUser) .AND. Empty(cFilConPad)
	cExpUser := ".T."
ELSEIF Empty(cExpUser) .AND. !Empty(cFilConPad)
	cExpUser := cFilConPad
ELSEIF !Empty(cExpUser) .AND. !Empty(cFilConPad)
	cExpUser += " .AND. ("+cFilConPad+")"
ENDIF

//Proteção para caso o filtro do usuario esteja errado
bBlock := ErrorBlock( { |e| ChecErro(e) } )
BEGIN SEQUENCE
	xResult := (cAlias)->&(cExpUser)
RECOVER
	cExpUser := ".T."
END SEQUENCE
ErrorBlock(bBlock)


DbSelectArea(cAlias)
DbGotop()
Do While (cAlias)->(!Eof()) .AND. (cAlias)->&(cPrefix+"_FILIAL") == cFilAlias
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ aChave    - Contem as entidades que serao exibidas na tela de  |
	//| selecao.                                                       |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF (cAlias)->&(cExpSis) .AND. (cAlias)->&(cExpUser)
		Aadd(aChave,Array( nQtdCpo ) )
		For nX := 1 to nQtdCpo
			If nX == 1
				aChave[Len(aChave)][1] := .F.
			Else
			   aChave[Len(aChave)][ nX ] := (cAlias)->&(aCposAlias[ nX - 1 ])
			EndIf
		Next nX
	ENDIF
	(cAlias)->(dbSkip())
EndDo

RestArea(aArea)
Return     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CtbTroca º Autor ³ Arnaldo R. Junior  º Data ³  28/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA278                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbTroca(nIt,aArray)

aArray[nIt,1] := !aArray[nIt,1]
Return aArray

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbMarcaOkº Autor ³ Arnaldo R. Junior  º Data ³  28/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA278                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbMarcaOk(aArray)

LOCAL lRet:=.F.
LOCAL nx:=0

// Checa marcacoes efetuadas
For nx:=1 To Len(aArray)
	If aArray[nx,1]
		lRet:=.T.
	EndIf
Next nx
// Checa se existe algum item marcado na confirmacao
If !lRet
	Help("CTBMARCA",1,"HELP","NOMARKITENS",STR0016,1,0) 
EndIf

Return lRet   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CTBGERQDO  ºAutor  ³ Alvaro Camillo Neto     º Data ³ 28/01/08 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida a digitacao do codigo da visao gerencial			      º±±
±±º          ³                                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACTB - CONTABILIDADE GERENCIAL                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                       
Function CTBGERQDO(cCodCVQ,aParamCVQ,cAliasTemp,oMeter,oText,oDlg,aSetOfBooks,lEnd)

Local aArea		:= GetArea()
Local cFilCVQ	:= xFilial("CVQ")
Local aStruTMP 	:= {}
Local aTamSx3	:= {}
Local aSaldos	:= {}
Local cEntidade	:= ""
Local xResult
Local bBlock
Local cArqTemp
Local cArqInd

Private PARAMIXB:= ACLONE(aParamCVQ)
/*
[01][C] := Código do Exercicio Contábil
[02][D] := Data de referencia
[03][L] := Demonstra período anteriord (S/N)
[04][L] := Posicao anterior a LP (S/N)
[05][D] := Data de lucros e perdas
[06][C] := Moeda
[07][C] := Tipo de saldo
[08][L] := Consolidar Saldo (S/N)
[09][C] := Saldos a Consolidar
[10][D] := dDataIni
[11][D] := dDataFin
*/
Default cAliasTemp:= "CVQQDO"

aTamSx3 := TamSx3("CT2_FILIAL")
AADD(aStruTMP,{"FILIAL"		,"C",aTamSx3[1],00})
AADD(aStruTMP,{"ITEM"		,"C",03,00})
AADD(aStruTMP,{"DESCRICAO"	,"C",40,00})  
aTamSx3 := TamSx3("CT2_VALOR")
AADD(aStruTMP,{"SALDOANT"	,"N",aTamSx3[1],aTamSx3[2]})
AADD(aStruTMP,{"SALDOATU"	,"N",aTamSx3[1],aTamSx3[2]})

IF SELECT(cAliasTemp) > 0
	DbSelectArea(cAliasTemp)
	DbCloseArea()
ENDIF

If __oTempTbVisGer <> Nil
	__oTempTbVisGer:Delete()
	__oTempTbVisGer := Nil
Endif

__oTempTbVisGer := FWTemporaryTable():New( cAliasTemp ) 
__oTempTbVisGer:SetFields(aStruTMP) 
__oTempTbVisGer:AddIndex("1", {"DESCRICAO"} )

//------------------
//Criação da tabela temporaria
//------------------
__oTempTbVisGer:Create()  

IF Len(aParamCVQ) < 11
	// Retorna após a criação, para que o Alias exista sem informações
	// Não gerando erro na aplicação chamadora
	Return
ENDIF

DbSelectArea("CVQ")
DbSetOrder(1)
DbSeek(cFilCVQ+cCodCVQ)
While CVQ->(!EOF()) .AND. CVQ->CVQ_CODIGO == cCodCVQ
	
	aSaldos := {0,0}
	aSldTmp := {0,0,0,0,0,0,0,0}
		
	IF !Empty(CVQ->CVQ_CDVGIT) .AND. aSetOfBooks[5] == CVQ->CVQ_CDVGIT

		aSldTmp := GetSldVis( CVQ->CVQ_CDVGIT,; // /* 01- cCodVis */
		                      0,; // /* 02- nTpSaldo */
		                      oMeter,; // /* 03- oMeter */
		                      oText,; // /* 04- oText */
		                      oDlg,; // /* 05- oDlg */
		                      lEnd,; // /* 06- lEnd */
		                      aParamCVQ[10],; // /* 07- dFinalA */
		                      aParamCVQ[11],; // /* 08- dFinal */
		                      aParamCVQ[09],; // /* 09- cSaldos */
		                      .T.,; // /* 10- lVlrZerado */
		                      aParamCVQ[06],; // /* 11- cMoedaDesc */
		                      .F.,; // /* 12- lMovPeriodo */
		                      aSetOfBooks,; // /* 13- aSetOfBook */
		                      aParamCVQ[06],; // /* 14- cMoeda */
		                      aParamCVQ[04],; // /* 15- lImpAntLP */
		                      aParamCVQ[05],; // /* 16- dDataLP */
		                      aParamCVQ[08])  // /* 17- lConsSaldo */

		aSaldos := {aSldTmp[6],aSldTmp[1]}	
	
	ELSE
	
		IF !EMPTY(CVQ->CVQ_FORMPA)

			bBlock := ErrorBlock( { |e| ChecErro(e) } )
			BEGIN SEQUENCE
				xResult := &(CVQ->CVQ_FORMPA)
			RECOVER
				xResult := 0
			END SEQUENCE
			ErrorBlock(bBlock)
     		aSaldos[1] := IIF(ValType(xResult) == "N",xResult,0)
		
		ELSE
			aSaldos[1] := 0
		ENDIF
	
		IF !EMPTY(CVQ->CVQ_FORMPC)

			bBlock := ErrorBlock( { |e| ChecErro(e) } )
			BEGIN SEQUENCE
				xResult := &(CVQ->CVQ_FORMPC)
			RECOVER
				xResult := 0
			END SEQUENCE
			ErrorBlock(bBlock)
   		aSaldos[2] := IIF(ValType(xResult) == "N",xResult,0)
		
		ELSE
			aSaldos[2] := 0
		ENDIF

	ENDIF
	
	RECLOCK(cAliasTemp,.T.)
	(cAliasTemp)->FILIAL	:= cFilCVQ
	(cAliasTemp)->DESCRICAO	:= CVQ->CVQ_DESCIT
	(cAliasTemp)->SALDOANT	:= aSaldos[1]
	(cAliasTemp)->SALDOATU	:= aSaldos[2]
	MSUNLOCK()
	
	CVQ->(DbSkip())
	        
	If lEnd
		Exit
	EndIf
End

RestArea(aArea)
Return 

//-------------------------------------------------------------------
/*{Protheus.doc} TempQuad
Função responsável por limpar os arquivos temporário do banco gerados pelas rotinas CTBA115 e CTBR610 

@author Fabio Casagrande Lima

@version P12
@since   18/10/2016
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Function TempQuad()
 
If _oCTBA1151 <> Nil
	_oCTBA1151:Delete()
	_oCTBA1151 := Nil
Endif

If __oTempTbVisGer <> Nil
	__oTempTbVisGer:Delete()
	__oTempTbVisGer := Nil
Endif

Return