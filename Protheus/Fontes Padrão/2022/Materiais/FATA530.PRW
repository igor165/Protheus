#INCLUDE "protheus.ch"   
#INCLUDE "RWMAKE.CH"
#INCLUDE "FATA530.CH"
#INCLUDE "TOPCONN.CH"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefinicoes utilizadas pelos modelosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#DEFINE TAR_INSTALADO	"PMSTASK4"
#DEFINE TAR_NAOINSTAL	"PMSTASK1"
#DEFINE TAR_PREINSTAL	"PMSTASK3"
#DEFINE EDT_INSTALADO	"BPMSEDT3"
#DEFINE EDT_NAOINSTAL	"BPMSEDT1"
#DEFINE EDT_PREINSTAL	"BPMSEDT4"
#DEFINE BMP_OK			"OK"
#DEFINE BMP_CANCELA		"CANCEL"   
#DEFINE oOkPrd    		"LBOK"
#DEFINE oNoPrd    		"LBNO"
#DEFINE oSetUP			"UP3_MDI
#DEFINE oSetDown		"DOWN3_MDI"

// Modo de visualiza็ใo do projeto
#DEFINE PMS_VIEW_TREE  1       

// TAREFA E EDT
#DEFINE PMS_TASK 	1
#DEFINE PMS_WBS		2   

//CONSTANTE PARA CONTROLE DE ATALHOS
#DEFINE ATA_PROJ_ESTRUTURA "0600."

//CONSTANTE DA TELA F3 ESPECIFICA
#DEFINE NMAXPAGE	40

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVariaveis estaticas de controleณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Static _lAlterou	:= .F.
Static _nRecAF2		:= 0
Static _aAdic		:= {}     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATA530A  บAutor  ณVendas CRM          บ Data ณ  20/12/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPrograma de manutecao de modelos de projetos.               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpN1: Opcao da operacao (2-Visual,3-Inclui,4-Altera,etc.)  บฑฑ
ฑฑบ          ณExpA2: Lista de campos a serem exibidos na enchoice         บฑฑ
ฑฑบ          ณExpC3: Nivel da tarefa                                      บฑฑ
ฑฑบ          ณExpL4: Indica se executa refresh ou nao                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FATA530A(nCallOpcx,aGetCpos,cNivTrf,lRefresh)

Local cFilter		:= 'AF1->AF1_TIPO == "1"'
Local lRet			:= .T.

SaveInter()

PRIVATE cCadastro	:= STR0089	//"Modelos de Projetos"
PRIVATE aMemos  	:={{"AF1_OBS","AF1_CODMEM"},{"AF2_OBS","AF2_CODMEM"},{"AF5_OBS","AF5_CODMEM"}}
Private aRotina		:= MenuDef()
PRIVATE aBAtalhos	:=	{}
PRIVATE bBlocoAtalho:=	{}
Private lEmAtalho	:=	.F.
Private lFt530Mod	:=	.T.

dbSelectArea("AF1")
dbSetOrder(8)	//AF1_FILIAL+AF1_ORCAME+AF1_VERSAO

// Somente para os modulos SIGAPMS SIGAFAT e SIGATEC
If ( nModulo == 44 .OR. nModulo == 05 .OR. nModulo == 28 .OR. nModulo == 73 ) .AND. AMIIn(nModulo)
	If nCallOpcx == Nil
		dbClearFilter()
		dbSetFilter({||&cFilter},cFilter)
		mBrowse(6,1,22,75,"AF1")
	Else
		lRet := FTA530Dlg("AF5",AF5->(RecNo()),nCallOpcx,,,aGetCpos,cNivTrf,@lRefresh,, AF1->AF1_TIPO)
	EndIf
EndIf

RestInter()

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATA530B  บAutor  ณVendas CRM          บ Data ณ  20/12/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPrograma de manutecao de simulacoes de horas de projeto.    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FATA530B(nCallOpcx,cCodOrc,aGetCpos,cNivTrf,lRefresh)

Local cTipo			:= "2" // Proposta de Servicos
Local cFilter		:= 'AF1->AF1_TIPO == "2"'      
Local lRet			:= .T.
Local aRet			:= {lRet,,,}

SaveInter()

PRIVATE cCadastro	:= STR0002 //"Proposta de servicos"
PRIVATE aMemos  	:={{"AF1_OBS","AF1_CODMEM"},{"AF2_OBS","AF2_CODMEM"},{"AF5_OBS","AF5_CODMEM"}}

PRIVATE aRotina 	:= MenuDef()
PRIVATE aBAtalhos	:=	{}
PRIVATE bBlocoAtalho:=	{}
Private lEmAtalho	:=	.F. 
Private lFt530Mod	:=	.F.



dbSelectArea("AF1")
dbSetOrder(8)	//AF1_FILIAL+AF1_ORCAME+AF1_VERSAO

If AMIIn(44)
	If nCallOpcx == Nil
		dbClearFilter()
		dbSetFilter({||&cFilter},cFilter)
		mBrowse(6,1,22,75,"AF1")
	Else   
		If IsInCallStack("A600SERVICOS") .Or. IsInCallStack("A020Servicos")
			DbSelectArea("AF1")
			AF1->(DbSetOrder(9))	//AF1_FILIAL+AF1_CODORC+AF1_ORCAME+AF1_VERSAO
			AF1->(DbSeek(xFilial("AF1")+cCodOrc))
			aRet := Ft530VerPRJ(AF1->AF1_ORCAME,AF1->AF1_VERSAO) 
			If	Len(aRet) > 0 
				If !aRet[1] .And. Empty(aRet[2])
					aRet := FTA530Dlg("AF1",AF1->(RecNo()),nCallOpcx,,,aGetCpos,cNivTrf,@lRefresh,cCodOrc,cTipo)
				EndIf	
			Endif 				
		Else	
			aRet := FTA530Dlg("AF1",AF1->(RecNo()),nCallOpcx,,,aGetCpos,cNivTrf,@lRefresh,cCodOrc,cTipo)
		EndIf	
	EndIf
EndIf

RestInter()

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATA530C  บAutor  ณVendas CRM          บ Data ณ  20/12/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPrograma de manutecao de simulacoes de horas de projeto,    บฑฑ
ฑฑบ          ณvistoria tecnica.                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FATA530C(nCallOpcx,cCodOrc,aGetCpos,cNivTrf,lRefresh)

Local cTipo 		:= "3"
Local cFilter		:= 'AF1->AF1_TIPO == "3"'      
Local lRet			:= .T.

SaveInter()

PRIVATE cCadastro	:= STR0088	// "Vistoria T้cnica"
PRIVATE aMemos  	:={{"AF1_OBS","AF1_CODMEM"},{"AF2_OBS","AF2_CODMEM"},{"AF5_OBS","AF5_CODMEM"}}

PRIVATE aRotina 	:= MenuDef()
PRIVATE aBAtalhos	:=	{}
PRIVATE bBlocoAtalho:=	{}
Private lEmAtalho	:=	.F. 
Private lFt530Mod	:=	.F.

dbSelectArea("AF1")
dbSetOrder(1)

If AMIIn(44)
	If nCallOpcx == Nil
		dbClearFilter()
		dbSetFilter({||&cFilter},cFilter)
		mBrowse(6,1,22,75,"AF1")
	Else
		lRet := FTA530Dlg("AF1",AF1->(RecNo()),nCallOpcx,,,aGetCpos,cNivTrf,@lRefresh,cCodOrc,cTipo)
	EndIf
EndIf

RestInter()

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณFTA530Dlgณ Autor ณ Vendas Clientes        ณ Data ณ 20/12/2007 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Programa de Inclusao,Alteracao,Visualizacao e Exclusao       ณฑฑ
ฑฑณ          ณ de Pre-Projetos.                                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ                                                              ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FTA530Dlg(cAlias,nReg,nOpcx,xReserv,yReserv,aGetCpos,cNivTrf,lRefresh,cCodOrc,cTipo,cProjeto,cVersao,lNovaVers)

Local aTree	  		:= {}
Local aAreaAF1		:= {}
Local oTree	  		:= Nil
Local nz
Local lOk
Local oDlg
Local nX 
Local lRet			:= .T.
Local aRet			:= {lRet,,,}
Local lXInclui		:= .F.
Local lXVisual		:= .F.
Local lXAltera		:= .F.
Local lXExclui 		:= .F.
Local lContinua 	:= .T.
Local lExistAF1		:= .F.
Local cArquivo		:= CriaTrab(,.F.)
Local cModCopia		:= ""
Local cSearch		:= Space(TamSX3("AF5_DESCRI")[1])
Local aMenuAt  		:= {}
Local aMenu	   		:= {}
Local lChgCols 		:= .F.  
Local cFilter 		:= AF1->(DbFilter())
Local lFat530A		:= FunName() == "FATA530A"
Local nRecAF1		:= 0
Local cTpOrc		:= SuperGetMv("MV_FATTPOR",,"0001")		//Tipo de orcamento do projeto
Local nTentativas	:= 1 
Local cTpEntidade 	:= ""
Local oMenu
Local lFT530BUT 	:= ExistBlock("FT530BUT")

Default aGetCpos	:= {}
Default lRefresh	:= .T.
Default lNovaVers	:= .F.

Private aObj		:= {}
Private oGd			:= {Nil,Nil,Nil,Nil}

AF1->(DbClearFilter())

_aAdic	:= {}
 
// define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)
If cAlias <> "AF1"
	Do Case
		Case nOpcx == 2
			lXVisual 	:= .T.
		Case nOpcx == 3
			Inclui		:= .T.
			lXInclui	:= .T.
		Case nOpcx == 4
			Altera		:= .T.
			lXAltera	:= .T.
		Case nOpcx == 5
			lOk			:= .F.
			lXExclui	:= .T.
			lXVisual	:= .T.
	EndCase
Else
	Do Case
		Case aRotina[nOpcx,4] == 2
			lXVisual 	:= .T.
		Case aRotina[nOpcx,4] == 3
			Inclui		:= .T.
			lXInclui	:= .T.
		Case aRotina[nOpcx,4] == 4
			Altera		:= .T.
			lXAltera	:= .T.
			_nRecAF2	:= 0
		Case aRotina[nOpcx,4] == 5
			lOk			:= .F.
			lXExclui	:= .T.
			lXVisual	:= .T.
	EndCase
EndIF

If lXInclui
	RegToMemory( cAlias, Inclui )
	
	If lFat530A
		M->AF1_TIPO	:= "1"	//Modelo
	Else
		M->AF1_TIPO	:= cTipo // Proposta de Servicos ou Vistoria Tecnica
	EndIf
	
	If !Empty( aGetCpos )
		aGetEnch	:= {}
		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek("AF5")
		While !SX3->(Eof()) .and. SX3->X3_ARQUIVO == "AF5"
			IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
				nPosCpo	:= aScan(aGetCpos,{|x| x[1]==Alltrim(X3_CAMPO)})
				If nPosCpo > 0
					If aGetCpos[nPosCpo][3]
						aAdd(aGetEnch,AllTrim(X3_CAMPO))
					EndIf
				Else
					aAdd(aGetEnch,AllTrim(X3_CAMPO))
				EndIf
			EndIf
			dbSkip()
		End
		For nx := 1 to Len(aGetCpos)
			cCpo	:= "M->"+Trim(aGetCpos[nx][1])
			&cCpo	:= aGetCpos[nx][2]
		Next nx
	EndIf
	
  If !Empty(cProjeto) .And. !Empty(cVersao)

		aAreaAF1	:= AF1->(GetArea())
		AF1->(DbSetOrder(8)) //AF1_FILIAL+AF1_ORCAME+AF1_VERSAO

		If AF1->(DbSeek(xFilial("AF1")+cProjeto+cVersao))

			nRecAF1	:= AF1->(Recno())                    
			RestArea(aAreaAF1)
			
			AF1->(DbGoTo(nRecAF1))
			
			RegToMemory("AF1",.F.)
					
			lContinua 		:= .T.    
			lExistAF1		:= .T.
    EndIf
	ElseIf Empty(cCodOrc)
		lContinua := FTA530Inc(cAlias,nReg,nOpcx,Ft530Field(cAlias,.T.),,,"FTA530OK()") == 1
		Else		
		aAreaAF1	:= AF1->(GetArea())
		AF1->(DbSetOrder(9)) //AF1_FILIAL+AF1_CODORC+AF1_ORCAME+AF1_VERSAO
		If AF1->(DbSeek(xFilial("AF1")+cCodOrc))

			nRecAF1	:= AF1->(Recno())                    
			RestArea(aAreaAF1)
			
			AF1->(DbGoTo(nRecAF1))
			
			RegToMemory("AF1",.F.)
						
			lContinua 		:= .T.    
			lExistAF1		:= .T.

		Else		
			RestArea(aAreaAF1)
			
			RecLock("AF1",.T.)
			AF1->AF1_FILIAL	:= xFilial("AF1")
			AF1->AF1_ORCAME	:= Ft530Num("AF1","AF1_ORCAME")
			AF1->AF1_VERSAO	:= "001"
			AF1->AF1_DESCRI	:= If(cTipo=="2",STR0002 +" Id: "+M->AF1_ORCAME+M->AF1_VERSAO , STR0088) //"Proposta de servicos" ou "Vistoria T้cnica"
			AF1->AF1_TIPO	:= If(lFat530A,"1","2")
			AF1->AF1_CODORC	:= AllTrim(cCodOrc)
			AF1->AF1_DATA	:= dDataBase
			AF1->AF1_TPORC	:= cTpOrc
			
			AF1->AF1_NOMPRJ	:= M->AF1_NOMPRJ			
			AF1->AF1_ENTIDA	:= cTpEntidade
			AF1->AF1_CODENT	:= M->ADY_CODIGO
			AF1->AF1_LOJENT	:= M->ADY_LOJA
			AF1->AF1_VEND	:= Posicione("AD1",1,xFilial("AD1")+M->ADY_OPORTU,"AD1_VEND")
			MsUnlock()
			
		EndIf
	EndIf
	
	If lContinua
	
		lRefresh	:= .T.
	
		If cAlias == "AF1"
			
			If !lExistAF1

				// Cria um registro na lista de EDTs 			
				AF1->(DbSetOrder(8))
				AF1->(DbSeek(xFilial("AF1")+AF1->AF1_ORCAME+AF1->AF1_VERSAO)) 
				
				DbSelectArea("AF5")
				RecLock("AF5",.T.)
				AF5->AF5_FILIAL	:= xFilial("AF5")
				AF5->AF5_ORCAME	:= AF1->AF1_ORCAME
				AF5->AF5_VERSAO	:= AF1->AF1_VERSAO
				AF5->AF5_EDT		:= AF1->AF1_ORCAME
				AF5->AF5_DESCRI	:= AF1->AF1_DESCRI
				AF5->AF5_NIVEL	:= "001"
				AF5->AF5_STATUS	:= "1"
				MsUnlock()			
				dbSelectArea("AF1")
				
				RecLock("AJF",.T.)
				AJF->AJF_FILIAL	:= xFilial("AJF")
				AJF->AJF_ORCAME	:= AF1->AF1_ORCAME
				AJF->AJF_VERSAO	:= AF1->AF1_VERSAO
				AJF->AJF_EDT		:= AF5->AF5_EDT
				AJF->AJF_USER		:= __cUserID
				AJF->AJF_ESTRUT	:= "3"
				AJF->AJF_DOCUME	:= "4"
				AJF->AJF_PROJET	:= "2"  
				MsUnlock()

			EndIf

		Else
			lContinua	:= .F.
		Endif
	Else
		lRefresh	:= .F.
	EndIf
ElseIf cAlias <> "AF1"

	If Type("aMemos") == "A"
		aMemoBk	:= aClone(aMemos)
		aMemos	:= {}
	EndIf

	If lxAltera
		dbSelectArea( cAlias )
		dbGoTo( nReg )
		AxAltera(cAlias,nReg,4)
	ElseIf lXVisual .AND. !lxExclui
		AxVisual(cAlias,nReg,2)
		lRefresh := .F.
	Else
		If lxExclui .AND. AxVisual(cAlias,nReg,2) == 1 
			lRefresh	:= .T.
			If cAlias == "AF5"
		 		MsgRun(STR0003,cCadastro,{||FTAExcAF5(,,nReg)})	//"Excluindo registros, aguarde..."
			ElseIf cAlias == "AF2"
		 		MsgRun(STR0003,cCadastro,{||FTAExcAF2(,,nReg)})	//"Excluindo registros, aguarde..."
			EndIf
		Else
			lRefresh	:= .F.
		EndIf
	EndIf
	
	If Type ("aMemos") == "A"
		aMemos	:= aClone(aMemoBk)
	EndIf
	
	lContinua := .F.

EndIf

If lContinua
	//Tratamento para uso exclusivo na alteracao
	If !lXVisual                               
		While !LockByName("FATA530LOCKPROC"+AF1->AF1_ORCAME+AF1->AF1_VERSAO+cEmpAnt,.T.,.T.,.T.)
			MsAguarde({|| Sleep(1000) }, STR0004+ALLTRIM(STR(nTentativas)), STR0005)//"Semaforo de processamento... tentativa "##"Aguarde, arquivo sendo alterado por outro usuแrio."
			nTentativas++
			
			If nTentativas > 5
				If MsgYesNo(STR0006) //"Nใo foi possํvel acesso exclusivo para edi็ใo do Pr้-Projeto da proposta. Deseja tentar novamente ?"
					nTentativas := 0
					Loop            
				Else
					Return(.F.)
				EndIf
			EndIf
		EndDo
	EndIf

	aAdd(aMenu, {STR0021,{|| Ft530SelMd(@oTree,@aTree,nOpcX) }, "SduCount", STR0020})	//"Selecionar Modelos"###"Sel.Modelo"
			
	aAdd(aMenu, {STR0098,{|| Ft530CpPRJ(@oTree,@aTree,nOpcX) }, "SduAppend", STR0097})	//""Copiar projeto existente""###"Copiar projeto"		
				
	aAdd(aMenu, {STR0136,{|| MsgRun(STR0156,STR0157,{|| FATA530E(AF1->AF1_ORCAME,AF1->AF1_VERSAO) } ) }, "MDIEXCEL", STR0136 })	//"Exportar"###"Exportar"###"Aguarde exportando projeto para Excel...","Exportar Projeto para Excel"
		
	aAdd(aMenu, {STR0023,{|| Ft531Def() }, "PARAMETROS", STR0022 }) //"Define traslado, turno e fator de multiplica็ใo para os produtos/servi็os"###"Defini็๕es"

	aAdd(aMenu, {STR0163,{||MsgRun(STR0164,STR0163,{|| Ft530ITDUP(@oTree,@aTree,nOpcX,AF1->AF1_ORCAME,AF1->AF1_VERSAO) } ) },"NCO",STR0165})	//"Componentes duplicados"###"Aguarde analisando projeto..."###"Componentes Duplicados"###"Comp.Duplic"

	aAdd(aMenu, {STR0025,  {|| SetAtalho(aMenuAt,aMenu,.T.)}, "ATALHO", STR0025}) //"Atalhos"				
	
	aAdd(aMenu, {STR0177,  {|| FATR110() }, "RELATORIO", STR0177}) //"Relat๓rio de Pr้-Escopo"
	
	aAdd(aMenu, {STR0178,  {|| FATR090() }, "RELATORIO", STR0178}) //"Relat๓rio horas or็adas x projeto oficial"
	
	aAdd(aMenu, {STR0181,  {|| Ft530Leg()}, STR0181, STR0181}) //"Legenda"
	// le os atalhos desde o profile
	CarregaAtalhos(aMenu,aMenuAt,Iif(lXVisual,"V","A")	)
	
	// configura as teclas de atalho
	SetAtalho(aMenuAt,aMenu,.F.)	

	If lFT530BUT
		aMenu := ExecBlock( "FT530BUT", .F.,.F., {aMenu} )
	EndIf
	
	aAreaAF1 := AF1->(GetArea())
	
	lRet := FTADlgAF1(cCadastro,@oMenu,@oTree,@aTree,,,@lOk,aMenu,@oDlg,nOpcx,lXVisual,cArquivo,@lRefresh,@cSearch)
	
	// grava os atalhos no profile.
	GravaAtalhos(aMenuAt,Iif(lXVisual,"V","A")	)
	
	If lChgCols
		FTA530Dlg(cAlias, nReg, nOpcx)
	Else
		If lXExclui .And. lOk
			Begin Transaction  
			MsgRun(STR0003,cCadastro,{||FTAExcAF1(,AF1->(RECNO()))}) //"Excluindo registros, aguarde..."
			End Transaction
		EndIf
	EndIf
	

	//Desbloqueia o projeto caso 
	If !lXVisual
		UnLockByName("FATA530LOCKPROC"+AF1->AF1_ORCAME+AF1->AF1_VERSAO+cEmpAnt,.T.,.T.,.T.)	    // VERIFICAR VERSAO
	EndIf
EndIf

FreeUsedCode(.T.)

If !Empty(cFilter)
	AF1->(DbSetFilter({||&cFilter},cFilter))
Endif

aRet := {lRet,AF1->AF1_ORCAME,AF1->AF1_VERSAO,lNovaVers}
Return aRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณMngItem    ณ Autor ณ Vendas Clientes      บ Data ณ 20/12/2007 บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณFuncao de controle de chamada da mBrowse.                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ                                                              ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MngItem(nOpc,oTree,aTree,cEDT,cArquivo,lRefresh)

Local aArea		:= GetArea()
Local cPrePro	:= ""
Local cNivAtu	:= ""
Local cTrfAtu	:= ""
Local cNivel	:= ""
Local nRec		:= 0
Local nQtdAnt	:= 0 
Local aGetCpos	:= {}    
Local cPrompt	:= ""   
Local cCargo	:= ""
Local cBmp		:= ""
Local nTamEDT	:= TAMSX3("AF5_EDT")[1]
Local nTamDEL	:= TAMSX3("AF1_DELIM")[1]
Local cNovEDT	:= ""
If oTree!= Nil
	cAlias	:= SubStr(oTree:GetCargo(),1,3)
	nRecAlias	:= Val(SubStr(oTree:GetCargo(),4,12))
Else
	cAlias := (cArquivo)->ALIAS
	nRecAlias := (cArquivo)->RECNO
	If nOpc == 3
		If cAlias == "AF2"
			Aviso(STR0026, STR0027, {"Ok"}, 2)//"Opcao invalida."###"A tarefa e o ultimo elemento na estrutura do projeto. Novos niveis e tarefas so poderao ser adicionados a uma EDT."
			Return
		EndIf
	EndIf
Endif

dbSelectArea(cAlias)
dbGoto(nRecAlias)
Do Case
	Case nOpc == 3
		If cEDT == "1"
			cNivel := If(cAlias=="AF5",AF5->AF5_NIVEL,"000")
			If cNivel <> "000"
				cPrePro	:= AF5->AF5_ORCAME
				cVersao	:= AF5->AF5_VERSAO
				cNivAtu	:= AF5->AF5_NIVEL
				cTrfAtu	:= AF5->AF5_EDT
			EndIf
			
			aGetCpos := {	{"AF5_ORCAME", AF5->AF5_ORCAME,.F.},;
							{"AF5_VERSAO", AF5->AF5_VERSAO,.F.},;
							{"AF5_NIVEL" , Soma1(cNivel),.F.},;
							{"AF5_EDTPAI", cTrfAtu,.F.}}
			
			aAdd(aGetCpos,{"AF5_EDT",FTAGetNum("1",AF5->AF5_ORCAME,cNivel,cTrfAtu,,.F.,AF5->AF5_VERSAO),.F.}) 

			nRec	:= FATA530A(3,aGetCpos,cNivel,@lRefresh)
			
			If lRefresh
				cBmp	:= Ft530Bmp("AF5") 
				cCargo	:= "AF5"+StrZero(AF5->(RecNo()),12)
				oTree:AddItem(AllTrim(Substr(AF5->AF5_DESCRI,1,50)),cCargo,cBmp,cBmp,2) 
			EndIf
		Else
			cNivel := If(cAlias=="AF5",AF5->AF5_NIVEL,"000")
			If cNivel <> "000"
				cPrePro	:= AF5->AF5_ORCAME
				cVersao	:= AF5->AF5_VERSAO
				cNivAtu	:= AF5->AF5_NIVEL
				cTrfAtu	:= AF5->AF5_EDT
			EndIf
			
			aGetCpos := {	{"AF2_ORCAME", AF5->AF5_ORCAME,.F.},;
							{"AF2_VERSAO", AF5->AF5_VERSAO,.F.},;
							{"AF2_NIVEL" , Soma1(cNivel),.F.},;
							{"AF2_EDTPAI", cTrfAtu,.F.}}
			
			If Substr(cTrfAtu,1,3) <> "ERR"

				cNovEDT := FTAGetNum("2",AF5->AF5_ORCAME,cNivel,cTrfAtu,,.F.,AF5->AF5_VERSAO)
			
				If (Len(AllTrim(cNovEDT))) <= nTamEDT
					
					aAdd(aGetCpos,{"AF2_TAREFA",cNovEDT,.F.})
			
					nRec	:= FATA531(3,aGetCpos,cNivel,@lRefresh)
					
					If nRec <> Nil
					 
						If lRefresh 
							AF2->(DbGoTo(nRec))
							cBmp	:= Ft530Bmp("AF2") 
							cCargo	:= "AF2"+StrZero(AF2->(RecNo()),12)
							oTree:AddItem(AllTrim(Substr(AF2->AF2_DESCRI,1,50)),cCargo,cBmp,cBmp,2) 
						EndIf
						
						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณTotaliza as quantidades do projetoณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
						
						aTreeIn(@oTree,@aTree,oTree:GetCargo(),"AF2"+Strzero(nRec,12))
						
					EndIf
				Else
					Aviso(STR0026, STR0074, {"Ok"}, 2)	//"Opcao invalida."##"O Codigo utilizado para a Tarefa atingiu o tamanho mแximo do campo."
				EndIf
			Else
				Aviso(STR0026, STR0075, {"Ok"}, 2)	//"Opcao invalida."##"Esta EDT nใo pode receber Tarefas."
			EndIf
		EndIf
	Case nOpc == 2 .And. cAlias == "AF5"
		FATA530A(2,,"000",@lRefresh)
	Case nOpc == 2 .And. cAlias == "AF2"
		FATA531(2,,"000",@lRefresh)
	Case nOpc == 4
	
		If cAlias == "AF5"		
		
			FATA530A(4,,"000",@lRefresh)		
			M->AF5_DESCRI	:= AF5->AF5_DESCRI
			cPrompt	:= AllTrim(Substr(AF5->AF5_DESCRI,1,50))
			
		ElseIf cAlias == "AF2"
		
			nQtdAnt	:= AF2->AF2_QUANT
		
			nRec := FATA531(4,,"000",@lRefresh)
		
			//Atualiza quantidades do projeto
			If lRefresh
				aTreeIn(@oTree,@aTree,oTree:GetCargo(),"AF2"+Strzero(nRec,12))
			EndIf
			
			M->AF2_DESCRI := AF2->AF2_DESCRI
			cPrompt	:= AllTrim(Substr(AF2->AF2_DESCRI,1,50))
			
		EndIf
		
		oTree:ChangePrompt(cPrompt,oTree:GetCargo())
	
	Case nOpc == 5 .AND. (cAlias == "AF2" .OR. cAlias == "AF5")
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Valida EDT e TAREFA obrigatoria ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If	Ft530vItObr(cAlias,nRecAlias)
			If Ft530VlPre(cAlias,nRecAlias,@aTree)
		
				oTree:Disable() 
			 
				If cAlias == "AF5"
					FATA530A(5,,"000",@lRefresh)
				ElseIf cAlias == "AF2"
						FATA531(5,,"000",@lRefresh)  
				EndIf
			
				If lRefresh
					oTree:DelItem()				
				EndIf              
			
				oTree:Enable()   
			
			Else
				lRefresh := .F.
			EndIf
		Endif 			

EndCase

FreeUsedCode(.T.)

RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณFTA530Altณ Autor ณ Vendas Clientes        บ Data ณ 20/12/2007 บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณFuncao de alteracao no cadastro do Pre-Projeto.               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ                                                              ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FTA530Alt(cAlias,nReg,nOpcx)

Local nOpc
Local aCposAlt	:= {}
Local aOldVal	:= {}
Local nx
Local aMemoBk	:= If(Type("aMemos")=="A",aClone(aMemos),{})

Do case
	Case cAlias == "AF1"
		aMemos  	:={{"AF1_OBS","AF1_CODMEM"}}
	Case cAlias == "AF2"
		aMemos  	:={{"AF2_OBS","AF2_CODMEM"}}
	Case cAlias == "AF5"
		aMemos  	:={{"AF5_OBS","AF5_CODMEM"}}
EndCase

For nx := 1 to Len(aCposAlt)
	If AF1->(FieldPos(aCposAlt[nx])) > 0
		aAdd(aOldVal,{aCposAlt[nx],AF1->(FieldGet(AF1->(FieldPos(aCposAlt[nx]))))})
	EndIf
Next

nOpc := AxAltera(cAlias,nReg,nOpcx,,,,,"FTA530OK()")

aMemos	:= aClone(aMemoBk)

Return nOpc

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณFTA530Ok ณ Autor ณ Vendas Clientes       บ Data ณ 20/12/2007  บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณValidacao TudoOk do cadastro de Pre-Projetos.                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ                                                              ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FTA530Ok()

Local lRet	:= .T.

If !MayIUseCode("AF1" + xFilial("AF1") + M->AF1_ORCAME + M->AF1_VERSAO) 
	lRet := .F.
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณAXCtrMenu  ณ Autor ณ Vendas Clientes     บ Data ณ 20/12/2007  บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณFuncao que controla as propriedades do Menu PopUp.            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ                                                              ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AXCtrMenu(oMenu,oTree,lVisual,cArquivo)

Local aArea		:= GetArea()
Local cAlias
Local nRecView

If oTree == Nil
	cAlias	:= (cArquivo)->ALIAS
	nRecView	:= (cArquivo)->RECNO
Else
	cAlias	:= SubStr(oTree:GetCargo(),1,3)
	nRecView	:= Val(SubStr(oTree:GetCargo(),4,12))
	oTree:TreeSeek(oTree:GetCargo())
EndIf

dbSelectArea(cAlias)
dbGoto(nRecView)

If !lVisual

	Do Case
		Case cAlias == "AF5" .And. AF5->AF5_NIVEL=="001"
			oMenu:aItems[1]:Enable()
			oMenu:aItems[2]:Enable()
			oMenu:aItems[3]:Enable()
			oMenu:aItems[4]:Enable()
			oMenu:aItems[5]:Enable()
			oMenu:aItems[6]:Disable()
			oMenu:aItems[7]:Enable()
			oMenu:aItems[8]:Enable()

		Case cAlias == "AF5" .And. AF5->AF5_NIVEL!="001"
			oMenu:aItems[1]:Enable()
			oMenu:aItems[2]:Enable()
			oMenu:aItems[3]:Enable()
			oMenu:aItems[4]:Enable()
			oMenu:aItems[5]:Enable()
			oMenu:aItems[6]:Enable()
			oMenu:aItems[7]:Enable()
			oMenu:aItems[8]:Enable()

		Case cAlias == "AF2"
			oMenu:aItems[1]:Disable()
			oMenu:aItems[2]:Disable()
			oMenu:aItems[3]:Enable()
			oMenu:aItems[4]:Enable()
			oMenu:aItems[5]:Enable()
			oMenu:aItems[6]:Enable()
			oMenu:aItems[7]:Disable()
			oMenu:aItems[8]:Enable()

		Otherwise
			oMenu:aItems[1]:Disable()
			oMenu:aItems[2]:Disable()
			oMenu:aItems[3]:Disable()
			oMenu:aItems[4]:Disable()
			oMenu:aItems[5]:Disable()
			oMenu:aItems[6]:Disable()
			oMenu:aItems[7]:Disable()
			oMenu:aItems[8]:Disable()
			
	EndCase
	
EndIf

RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณChangeEDT บAutor  ณVendas Clientes     บ Data ณ  20/12/2007 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza a troca da EDTPai da EDT/Tarefa selecionada.        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ChangeEDT(oTree,aTree,cArquivo)

Local cAlias	:= ""
Local cNivel	:= ""
Local cEDTPai	:= ""
Local cEDTAnt	:= ""
Local nRecno	:= 0
Local aEDT		:= {}
Local aArea		:= GetArea()
Local lRet		:= .F.
Local cOldCode	:= ""
Local cValor	:= ""
Local cEDTOrig	:= ""
Local cEDTDest	:= ""
Local cPrePro	:= ""
Local aAlter	:= {}
Local nX		:= 0
Local nY		:= 0
Local aRelac	:= {"AF3","AF7","ADX"}


// verifica o alias e recno do item selecionado
If oTree != Nil
	cAlias:= SubStr(oTree:GetCargo(),1,3)
	nRecno:= Val(SubStr(oTree:GetCargo(),4,12))
Else
	cAlias := (cArquivo)->ALIAS
	nRecNo := (cArquivo)->RECNO
EndIf

// somente permite a alteracao da EDT Pai de EDT's e Tarefas
If !(cAlias $ "AF2/AF5")
	Return(.F.)
EndIf

// valida o nivel e a data de inicializacao real da EDT/Tarefa selecionada.
// nao permite a troca da EDT principal e tambem de itens que ja foram
// iniciados.
dbSelectArea(cAlias)
dbGoTo(nRecNo)
If &(cAlias + "->"+cAlias+"_NIVEL") == "001"
	Return(.F.)
EndIf

If cAlias == "AF5"
	cPrePro    := AF5->AF5_ORCAME
	cVersao		 := AF5->AF5_VERSAO
	cEDTOrig   := AF5->AF5_EDT
Else
	cPrePro    := AF2->AF2_ORCAME
	cVersao		 := AF2->AF2_VERSAO
	cEDTOrig   := AF2->AF2_EDTPAI
EndIf

// exibe uma tela de selecao dos projetos para importacao
aEDT := SelEDT()

If (Len(aEDT) > 0)
	lRet:= .T.
	
	AF5->(dbGoTo(aEDT[2]))
	cEDTPai:= AF5->AF5_EDT
	cNivel := StrZero(Val(AF5->AF5_NIVEL) + 1, TamSX3("AF5_NIVEL")[1])
	
	Do Case
		Case cAlias == "AF2"

			dbSelectArea("AF2")
			dbGoTo(nRecNo)
			
			Ft530AltTT("AF2",nRecno,.F.)
			
			cValor	:= FTAGetNum("2",AF2->AF2_ORCAME,GetNivel(AF2->AF2_ORCAME,cEDTPai),cEDTPai,,,AF2->AF2_VERSAO) 

			RecLock("AF2",.F.)
			
			cEDTAnt:= AF2->AF2_EDTPAI
			cOldCode := AF2->AF2_TAREFA
			Replace AF2->AF2_TAREFA With cValor
			Replace AF2->AF2_EDTPAI With cEDTPai
			Replace AF2->AF2_NIVEL  With cNivel
			MsUnLock()

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAtualiza tabelas relacionadasณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			For nY := 1 to Len(aRelac)            
				aAlter := {}
				DbSelectArea(aRelac[nY])
				DbSetOrder(1)
				DbSeek(xFilial(aRelac[nY])+cPrePro+cOldCode)  
				
				While !(aRelac[nY])->(Eof())	.AND.;
					(aRelac[nY])->&(aRelac[nY]+"_FILIAL")	== xFilial(aRelac[nY])	.AND.;
					(aRelac[nY])->&(aRelac[nY]+"_ORCAME")	== cPrePro 				.AND.;
					(aRelac[nY])->&(aRelac[nY]+"_VERSAO")	== cVersao 				.AND.;
					(aRelac[nY])->&(aRelac[nY]+"_TAREFA")	== cOldCode
					AAdd(aAlter,(aRelac[nY])->(Recno()))
					(aRelac[nY])->(DbSkip())
				End
				
				For nX := 1 To Len(aAlter)
					(aRelac[nY])->(DbGoTo(aAlter[nX]))
					RecLock(aRelac[nY],.F.)
					Replace (aRelac[nY])->&(aRelac[nY]+"_TAREFA")	With cValor
					MsUnLock()
				Next nX
			Next nY
			
			Ft530AltTT("AF2",nRecno,.T.)
			
		Case cAlias == "AF5"
			// Verifica se a opera็ใo de troca de EDT
			// nใo causa uma refer๊ncia circular
			If !CheckRef(cPrePro, cEDTOrig, cEDTPai)

				dbSelectArea("AF5")
				dbGoTo(nRecNo)

				Ft530AltTT("AF5",nRecno,.F.)

				cValor	:= FTAGetNum("1",AF5->AF5_ORCAME,GetNivel(AF5->AF5_ORCAME, cEDTPai),cEDTPai,,,AF5->AF5_VERSAO) 
				
				RecLock("AF5",.F.)
				cEDTAnt:= AF5->AF5_EDT
				
				// altera o codigo da EDT se o modo de codigo for automatico
				cOldCode := AF5->AF5_EDT
				AF5->AF5_EDT := cValor
				Replace AF5->AF5_EDTPAI With cEDTPai
				Replace AF5->AF5_NIVEL  With cNivel
				MsUnLock()
				
				// recalcular os niveis abaixo dela
				AF5Nivel(AF5->AF5_ORCAME, cEdtAnt, AF5->AF5_NIVEL,cValor,AF5->AF5_VERSAO) 
				
				Ft530AltTT("AF5",nRecno,.T.)
				
			Else
				Aviso(STR0028,STR0029,{STR0030}, 2)//"Troca nao efetuada"###"Esta operacao de troca de EDT pai nao pode ser realizada pois causa uma referencia circular."###"Ok"
				
				lRet := .F.
			EndIf
	EndCase
	
EndIf

RestArea(aArea)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณMenuDef   ณ Autor ณVendas Clientes     บ Data ณ 20/12/2007  บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Utilizacao de menu Funcional                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณArray com opcoes da rotina.                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณParametros do array a Rotina:                               ณฑฑ
ฑฑณ          ณ1. Nome a aparecer no cabecalho                             ณฑฑ
ฑฑณ          ณ2. Nome da Rotina associada                                 ณฑฑ
ฑฑณ          ณ3. Reservado                                                ณฑฑ
ฑฑณ          ณ4. Tipo de Transao a ser efetuada:                        ณฑฑ
ฑฑณ          ณ		1 - Pesquisa e Posiciona em um Banco de Dados     ณฑฑ
ฑฑณ          ณ    2 - Simplesmente Mostra os Campos                       ณฑฑ
ฑฑณ          ณ    3 - Inclui registros no Bancos de Dados                 ณฑฑ
ฑฑณ          ณ    4 - Altera o registro corrente                          ณฑฑ
ฑฑณ          ณ    5 - Remove o registro corrente do Banco de Dados        ณฑฑ
ฑฑณ          ณ5. Nivel de acesso                                          ณฑฑ
ฑฑณ          ณ6. Habilita Menu Funcional                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ               ณ                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function MenuDef()
Local aRotina 	:= {}

aRotina := {{	STR0031,"AxPesqui"  , 0 , 1,,.F.}	,; //"Pesquisar"
			{	STR0010,"FTA530Dlg" , 0 , 2}		,; //"Visualizar"
			{ 	STR0032,"FTA530Dlg" , 0 , 3}		,; //"Incluir"
			{ 	STR0033,"FTA530Alt" , 0 , 4}		,; //"Alt.Cadastro"
			{ 	STR0034,"FTA530Dlg" , 0 , 4}		,; //"Alt.Estrutura"
			{ 	STR0011,"FTA530Dlg" , 0 , 5			}} //"Excluir"

Return aRotina

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณFTAGetNumณ Autor ณ Vendas Cliente         ณ Data ณ 09-02-2001 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณRetorna proximo numero da EDT do PreProjeto                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Generico                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FTAGetNum(cTipo, cPrePro, cNivelTrf, cEDTPai, cEDTAtual, lLiberaCod, cVerPro)
Local aArea		:= GetArea()
Local aAreaAF5	:= AF5->(GetArea())
Local aAreaAF1	:= AF1->(GetArea())
Local aAreaAF2	:= AF2->(GetArea())
Local cEDT      := ""
Local lZZ		:= .F.
Local cLastEDT  := ""
Local cLastEDT2 := ""
Local cEDTAux   := ""
Local cDelim    := ""
Local cMascara  := ""
Local aEDTAux   := {}
Local nI        := 0
Local nPos      := 0
Local nEDT      := 0
Local nDigitos  := 0
Local cOldNivelTrf := cNivelTrf
Local cEDTIni	:= ''

DEFAULT lLiberaCod	:= .T.
DEFAULT cEDTAtual := ""

//
// Busca no pre-projeto a mascara e delimitador.
//
AF1->(dbSetOrder(8))	//AF1_FILIAL+AF1_ORCAME+AF1_VERSAO
AF1->(DbSeek(xFilial("AF1")+cPrePro+cVerPro))

cDelim    := AllTrim(AF1->AF1_DELIM)
cMascara  := AllTrim(AF1->AF1_MASCAR)

//
// caso nao tenha informado a mascara.
//
If Empty(cMascara)
	cMascara := "111111111111111111"
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se a codificacao e normal ou estruturada.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Do Case
	Case Substr(cEDTAtual,1,3)=="ERR"
		AF5->(dbSetOrder(5))	//AF5_FILIAL+AF5_ORCAME+AF5_VERSAO+AF5_EDT+AF5_ORDEM
		AF2->(dbSetOrder(5))	//AF2_FILIAL+AF2_ORCAME+AF2_VERSAO+AF2_TAREFA+AF2_ORDEM
		cEDT	:=	Soma1(cEDTAtual)
		While AF5->(DbSeek(xFilial("AF5")+cPrePro+cVerPro+cEDT)).Or.AF2->(DbSeek(xFilial("AF2")+cPrePro+cVerPro+cEDT))     
			cEDT	:=	Soma1(cEDT)
		Enddo
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCodificacao Estruturada.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Case cTipo == "1"
		cNivelTrf := Soma1(cNivelTrf)
		
		nDigitos:= Val(SubStr(cMascara,Val(cNivelTrf)-1,1))
		
		If (nDigitos > 0)
			cEDTIni := IIf(cNivelTrf == "002",StrZero(1,nDigitos),AllTrim(cEDTPai)+ cDelim + StrZero(1,nDigitos))
		Else
			cEDTIni := IIf(cNivelTrf == "002","1",AllTrim(cEDTPai)+ cDelim + "1")
		EndIf
		
		
		If Empty(cEDTAtual)
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณPesquisa todas as EDT's filhas.ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			dbSelectArea("AF5")
			dbSetOrder(6)	//AF5_FILIAL+AF5_ORCAME+AF5_VERSAO+AF5_EDTPAI+AF5_ORDEM
			DbSeek(xFilial("AF5")+cPrePro+cVerPro+cEDTPai)                       
			While !AF5->(Eof()) .And. xFilial("AF5")+cPrePro+cVerPro+cEDTPai==;
				AF5->AF5_FILIAL+AF5->AF5_ORCAME+AF5->AF5_VERSAO+AF5->AF5_EDTPAI
				
				If Substr(AF5->AF5_EDT,1,2) == "ER"
					dbSkip()
					Loop
				EndIf
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณArmazena o codigo da ultima tarefa da edt.ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If Len(AllTrim(AF5->AF5_EDT))== Len(AllTrim(cEDTIni)) .And. cLastEDT < AF5->AF5_EDT //(AllTrim(cEDTPai) == Substr(AF5->AF5_EDTPAI,1,Len(AllTrim(cEDTPai))))
					cLastEDT := AllTrim(AF5->AF5_EDT)
				EndIf
				dbSkip()
			End
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณPesquisa todas as tarefas filhas.ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			dbSelectArea("AF2")
			dbSetOrder(6)	//AF2_FILIAL+AF2_ORCAME+AF2_VERSAO+AF2_EDTPAI+AF2_ORDEM
			DbSeek(xFilial("AF2")+cPrePro+cVerPro+cEDTPai)
			While !AF2->(Eof()) .And. xFilial("AF2")+cPrePro+cVerPro+cEDTPai==;  
				AF2->AF2_FILIAL+AF2->AF2_ORCAME+AF2->AF2_VERSAO+AF2->AF2_EDTPAI
				
				If Substr(AF2->AF2_TAREFA,1,2) == "ER"
					dbSkip()
					Loop
				EndIf
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณArmazena o codigo da ultima tarefa da edt.ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If Len(AllTrim(AF2->AF2_TAREFA))== Len(AllTrim(cEDTIni)) .And. cLastEDT < AF2->AF2_TAREFA //(AllTrim(cEDTPai) == Substr(AF2->AF2_EDTPAI,1,Len(AllTrim(cEDTPai))))
					cLastEDT := AllTrim(AF2->AF2_TAREFA)
				EndIf
				dbSkip()
			End
		Else
			cLastEDT := alltrim(cEDTAtual)
		EndIf
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณDesmembra o codigo da ultima EDT para facilitar a manipulcao dos dados.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		nPos:= 0
		cLastEDT2 := cLastEDT
		For nI:= 1 To Len(cLastEDT)
			If !Empty(cDelim)
				nPos   := AT(cDelim,cLastEDT)
				nPos   := IIf(nPos > 0,nPos,Len(cLastEDT)+1)
				cEDTAux:= SubStr(cLastEDT,1,IIf(nPos > 1,nPos-1,1))
			Else
				nPos    := Val(SubStr(cMascara,nI,1))
				cEDTAux := SubStr(cLastEDT,1,IIf(nPos > 1,nPos,1))
			EndIf
			
			If !Empty(cEDTAux)
				aAdd(aEDTAux,cEDTAux)
			EndIf
			
			cLastEDT:= SubStr(cLastEDT,nPos+1,Len(cLastEDT))
		Next nI
		
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณRealiza a analise dos niveis e compoe a numeracao da nova EDT.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		nEDT:= Val(cNivelTrf) - 1
		
		If Len(aEDTAux) == 0 .Or. (Len(aEDTAux) < Val(cNivelTrf) - 1)
			If (nDigitos > 0)
				cEDT := IIf(cNivelTrf == "002",StrZero(1,nDigitos),AllTrim(cEDTPai)+ cDelim + StrZero(1,nDigitos))
			Else
				cEDT := IIf(cNivelTrf == "002","1",AllTrim(cEDTPai)+ cDelim + "1")
			EndIf
		Else
			If aEDTAux[Val(cNivelTrf)-1] == replicate("Z",Len(aEDTAux[Val(cNivelTrf)-1]))
				cEDT := cLastEDT2
			Else
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณVerifica se os ultimos caracteres sao numeros ou letrasณ
				//ณpara realizar a adicao correta.                        ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				aEDTAux[nEDT]:= Soma1(aEDTAux[nEDT])
				
				If aEDTAux[nEDT] == Replicate("0",Len(aEDTAux[nEDT]))
					lZZ	:= .T.
				EndIf
				
				For nI:= 1 To Len(aEDTAux)
					cEDT += aEDTAux[nI]
					
					If nI <> Len(aEDTAux)
						cEDT+= cDelim
					EndIf
					
				Next nI
			EndIf
		EndIf
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifica se a numeracao ja existe ou se existe inconsistencia ณ
		//ณcom relacao ao tamanho da nova numeracao e o tamanho do campo.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		dbSelectArea("AF5")
		AF5->(dbSetOrder(5))	//AF5_FILIAL+AF5_ORCAME+AF5_VERSAO+AF5_EDT+AF5_ORDEM
		dbSelectArea("AF2")	
		AF2->(dbSetOrder(5))	//AF2_FILIAL+AF2_ORCAME+AF2_VERSAO+AF2_TAREFA+AF2_ORDEM
		
		//Se coicide com o codigo do Pre-Projeto incrementar um
		If AF5->(DbSeek(xFilial("AF5") + cPrePro + cVerPro + cEDT + Space(Len(AF5->AF5_EDT)-Len(cEDT)))) .And. AF5->AF5_NIVEL == "001"
			cEDT := Soma1(cEDT)
		Endif
		
		If (Len(cEDT) > Len(AF5->AF5_EDT)) .OR. ( AllTrim(cEDTAtual) == AllTrim(cEDT) ) .Or. lZZ
			dbSelectArea("AF2")
			dbSetOrder(5)	//AF2_FILIAL+AF2_ORCAME+AF2_VERSAO+AF2_TAREFA+AF2_ORDEM
			DbSeek(xFilial("AF2") + cPrePro + cVerPro + "ERR" + Replicate("Z",Len(AF2->AF2_TAREFA)-3),.T.)
			dbSkip(-1)
			If (xFilial("AF2") + cPrePro + cVerPro == AF2->AF2_FILIAL + AF2->AF2_ORCAME + AF2->AF2_VERSAO) .And. (AF2->AF2_NIVEL <> "001") .And. (SubStr(AF2->AF2_TAREFA,1,3) == "ERR")
				cEDT := Soma1(AF2->AF2_TAREFA)
			Else
				cEDT := "ERR" + StrZero(1,Len(AF2->AF2_TAREFA)-3)
			EndIf
			
			dbSelectArea("AF5")
			dbSetOrder(5)	//AF5_FILIAL+AF5_ORCAME+AF5_VERSAO+AF5_EDT+AF5_ORDEM
			DbSeek(xFilial("AF5") + cPrePro + cVerPro + "ERR" + Replicate("Z",Len(AF5->AF5_EDT)-3),.T.)
			dbSkip(-2) // Pula o Nivel 002
			If (xFilial("AF5") + cPrePro + cVerPro == AF5->AF5_FILIAL + AF5->AF5_ORCAME + AF5->AF5_VERSAO) .And. (AF5->AF5_NIVEL <> "001") .And. (SubStr(AF5->AF5_EDT,1,3) == "ERR")
				cEDT := If(Soma1(AF5->AF5_EDT)>cEDT,Soma1(AF5->AF5_EDT),cEDT)
			Else
				cEDT := If("ERR" + StrZero(1,Len(AF5->AF5_EDT)-3)>cEDT,"ERR"+StrZero(1,Len(AF5->AF5_EDT)-3),cEDT)
			EndIf
			
			While AF5->(DbSeek(xFilial("AF5")+cPrePro+cVerPro+cEDT)) .Or. AF2->(DbSeek(xFilial("AF2")+cPrePro+cVerPro+cEDT))
				If AF5->(!Eof())
					cEDT := Soma1(AF5->AF5_EDT)
				Else
					cEDT := Soma1(AF2->AF2_TAREFA)
				EndIf
			End
		EndIf
		
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCodificacao Sequencial Nao Estruturada.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Case cTipo == "2"

		nDigitos:= Val(SubStr(cMascara,Val(cNivelTrf)-1,1))
		
		AF2->( dbSetOrder(5) )	//AF2_FILIAL+AF2_ORCAME+AF2_VERSAO+AF2_TAREFA+AF2_ORDEM
		AF2->( dbSeek( xFilial("AF2")+cPrePro+cVerPro+Replicate("Z",Len(AF2->AF2_TAREFA)),.T.) )
		AF2->( dbSkip(-1) )  
		
		If AF2->( xFilial("AF2")+cPrePro+cVerPro == AF2->(AF2_FILIAL+AF2_ORCAME+AF2_VERSAO) .AND. AF2->AF2_NIVEL <> "001" .AND. AllTrim(AF2->AF2_EDTPAI) == AllTrim(cEDTPai) )
			cEDT := AllTrim(AF2->AF2_TAREFA)
			If !Empty(cDelim)
				nPos := Rat(cDelim,cEDT) 
				cEDT := SubStr(cEDT,1,nPos-1) + cDelim + Soma1(SubStr(cEDT,nPos+1,Len(cEDT)))
			Else
				cEDT := Soma1(cEDT)
			EndIf
		Else
			If (nDigitos > 0)
				cEDT := AllTrim(cEDTPai)+ cDelim + StrZero(1,nDigitos)
			Else
				cEDT := AllTrim(cEDTPai)+ cDelim + "1"
			EndIf
		EndIf
		
		While AF5->( dbSeek( xFilial("AF5")+cPrePro+cVerPro+cEDT ) ) .OR. AF2->( dbSeek( xFilial("AF2")+cPrePro+cVerPro+cEDT ) )
			If AF5->(!Eof())
				cEDT := AllTrim(AF5->AF5_EDT)
			Else
				cEDT := AllTrim(AF2->AF2_TAREFA)
			EndIf
			If !Empty(cDelim)
				nPos := Rat(cDelim,cEDT) 
				cEDT := SubStr(cEDT,1,nPos-1) + cDelim + Soma1(SubStr(cEDT,nPos+1,Len(cEDT)))
			Else
				cEDT := Soma1(cEDT)
			EndIf
		End
EndCase


//
// Verifica se o codigo gerado da tarefa esta sendo utilizado,
// em caso positivo gera um novo codigo.
// obs.: deve ser utiliza a string "AF5" pra chave. Pois para gerar o codigo da edt
//       ou tarefa depende sempre das tabelas AF5 e AF2. Evitando a duplicidade de chave.
//
dbSelectArea("AF2")
dbSetOrder(5)	//AF2_FILIAL+AF2_ORCAME+AF2_VERSAO+AF2_TAREFA+AF2_ORDEM
dbSelectArea("AF5")
dbSetOrder(5)	//AF5_FILIAL+AF5_ORCAME+AF5_VERSAO+AF5_EDT+AF5_ORDEM
While (AF5->(DbSeek(xFilial("AF5")+cPrePro+cVerPro+PadR(cEDT,Len(AF5->AF5_EDT)))) .Or. AF2->(DbSeek(xFilial("AF2")+cPrePro+cVerPro+PadR(cEDT,Len(AF2->AF2_TAREFA)))) .Or. !MayIUseCode("AF5"+xFilial("AF5")+cPrePro+cVerPro+PadR(cEDT,Len(AF5->AF5_EDT)))) .And. Len(cEDT) <= Len(AF5->AF5_EDT)
	cEDT := FTAGetNum(cTipo,cPrePro,cOldNivelTrf,cEDTPai,cEDT,lLiberaCod,cVerPro)
EndDo

If lLiberaCod
	FreeUsedCode(.T.)
Endif

RestArea(aAreaAF2)
RestArea(aAreaAF1)
RestArea(aAreaAF5)
RestArea(aArea)
Return cEDT

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณFTADlgAF1ณ Autor ณ Vendas Cliente         ณ Data ณ 08-01-2008 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณMonta a Dialog de visualizacao do Pre-Projeto                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณGenerico                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function FTADlgAF1(cTitle,oMenu,oTree,aTree,cFilhos,bChange,lConfirma,aMenu,oDlg,nOpcx,lXVisual,cArquivo,lRefresh,cSearch)

Local aAreaAF1		:= AF1->(GetArea())
Local oPanel
Local aSVAlias		:= {}
Local aHeadGD		:= {} 
Local aColsGD		:= {}
Local nTop      	:= oMainWnd:nTop+35
Local nLeft     	:= oMainWnd:nLeft+10
Local nBottom   	:= oMainWnd:nBottom-12
Local nRight    	:= oMainWnd:nRight-10
Local nBottomEn		:= 0
Local nOldEnch		:= 3
Local oFont
Local aButtons  	:= {}
Local nX        	:= 0
Local lMemory		:= .F.
Local oGetProd		:= Nil  
Local lModelo		:= IsInCallStack("FATA530A")
Local aTitles		:= {STR0035,STR0036}	//"Total de produtos"###"Produtos adicionais"
Local nGdOpc		:= IIf(INCLUI .OR. ALTERA,GD_INSERT+GD_UPDATE+GD_DELETE,0)
Local lRet			:= .T.
Local lAltBkp		:= ALTERA
Local lIncBkp		:= INCLUI
Local aCampos		:= {}
Local aFolder		:= {}    
Local nZ			:= 1
Local lFT530VdC 	:= ExistBlock("FT530Vdc")

PRIVATE bRefresh	:= {|| FTA530Tree(@oTree,@aTree,cFilhos,.T.,,,.T.),Eval(oTree:bChange)}
Private aTELA[0][0]
Private aGETS[0]

PRIVATE lExcMult 	:= .F.

DEFAULT bChange := {|| Nil }
DEFAULT cFilhos := "AF1,AF5,AF2,AF3"// Alias que sao amarrados ao TREE

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Carrega as variaveis de memoria do AF1.              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RegToMemory("AF1",.F.)
RegToMemory("AF5",.T.)
RegToMemory("AF2",.T.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAltera as variaveis de controle de inclusao/alteracao paraณ
//ณnao gerar erros nos inicializadores padrao da tabela AF3  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
INCLUI	:= .T.
ALTERA	:= .F.
RegToMemory("AF3",.T.)
ALTERA	:= lAltBkp
INCLUI	:= lIncBkp


DEFINE FONT oFont NAME "Arial" SIZE 0, -10
DEFINE MSDIALOG oDlg TITLE cTitle OF oMainWnd PIXEL FROM nTop,nLeft TO nBottom,nRight PIXEL STYLE nOr(WS_VISIBLE,WS_POPUP)
oDlg:lMaximized := .T.
       
For nx := 1 to Len(aMenu)
    Aadd(aButtons,{aMenu[nx][3],aMenu[nx][2],aMenu[nx][1],aMenu[nx][1],{|| .T.}})
Next 

oPanel 			:= TPanel():New(14,152,'',oDlg,oDlg:oFont, .T., .T.,, ,(nRight-nLeft)/2-152,((oDlg:nBottom-oDlg:nTop)/2)-38,.T.,.T. )
oPanel:Align	:= CONTROL_ALIGN_ALLCLIENT
lOneColumn		:= If((nRight-nLeft)/2-178>312,.F.,.T.)
nBottomEn		:= Int(((oDlg:nBottom-oDlg:nTop)/4))-30

aAdd(aSVAlias,"AF2")
AAdd(aObj,{Nil,{},{},Nil})

aAdd(aSVAlias,"AF5") 
AAdd(aObj,{Nil,{},{},Nil})

aAdd(aSVAlias,"AF1")
aCampos := Ft530Field("AF1",Nil,@aFolder)
aAdd(aObj,{MsMGet():New("AF1",AF1->(RecNo()),nOpcx,,,,,{0,0,nBottomEn-26,(nRight-nLeft)/2-145},,,,,,oPanel,,lMemory,,,,,aCampos,aFolder),aClone(aGets),aClone(aTela),Nil,Nil,Nil})

AAdd(aObj,{ Nil,{},{},Nil })

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTotaliza os produtos utilizados no pre-projetoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aObj[3][4] := TFolder():New(160,1,aTitles,{},oPanel,,,,.T.,.T.,(nRight-nLeft)/2-150,nBottomEn+40)

aObj[3][4]:bSetOption:={|nFolder| A530PrdSet(nFolder,aObj[3][4]:nOption) }
Ft530Prod(@aHeadGD,@aColsGD)
aObj[3][5] := MsNewGetDados():New(2,2,nBottomEn+23,(nRight-nLeft)/2-153,0,,,,,,512,,,,aObj[3][4]:aDialogs[1],aHeadGD,aColsGD)

ALTERA := .T.
INCLUI := .F.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณProdutos adicionaisณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aHeadGD := {}      
aColsGD := {}
FillGetDados(4,"AF3",5,xFilial("AF3")+M->AF1_ORCAME+M->AF1_VERSAO,{||AF3->AF3_FILIAL+AF3->AF3_ORCAME+AF3->AF3_VERSAO},;
	{||Empty(AF3->AF3_TAREFA)},{"AF3_FATOR","AF3_COMPOS","AF3_CALCTR","AF3_TURNO"},,,,,,@aHeadGD,@aColsGD)

//Inicializa o AF3_ITEM (sequencial da linha)
nX	:=  aScan(aHeadGD,{|x|AllTrim(x[2]) == "AF3_ITEM"})
If (nX > 0) .AND. (Len(aColsGD) == 1) .AND. Empty(aColsGD[1][nX])
	aColsGD[1][nX]	:= "01"
EndIf

aObj[3][6] := MsNewGetDados():New(2,2,nBottomEn+23,(nRight-nLeft)/2-153,nGdOpc,"A530PrLok","A530PrTok","+AF3_ITEM",,,512,,,,aObj[3][4]:aDialogs[2],aHeadGD,aColsGD)

//Prepara a funcao FTA531Prod para acessar dados desta getdados
nX := aScan(aObj[3][6]:aHeader,{|x|AllTrim(x[2])=="AF3_PRODUT"})
aObj[3][6]:aHeader[nX][6] := "FTA531Prod(.T.)"

//Torna o campo AF3_QUANT alteravel
nX := aScan(aObj[3][6]:aHeader,{|x|AllTrim(x[2])=="AF3_QUANT"}) 
aObj[3][6]:aInfo[nX][5] 	:= "A"
aObj[3][6]:aHeader[nX][14]	:= "A"

Ft530PutVl(@aObj[3][1])

oTree := xTree():New(14, 2,((oDlg:nBottom-oDlg:nTop)/2)-25, 150, oDlg)
oTree:SetFont(oFont)
oTree:Align 	:= CONTROL_ALIGN_LEFT
oTree:bChange 	:= {|| FTAView(@oDlg,@oTree,@aSVAlias,{0,0,nBottomEn,(nRight-nLeft)/2-145},@nOldEnch,@oPanel,nOpcx),Eval(bChange)}
oTree:lShowHint	:= .F.
oTree:bValid	:= {|| GrvItem(@oTree,@aTree,nOpcX,lExcMult)}
oTree:bRClicked	:= {|oObj,nX,nY| Ft530MenuPOP(oObj,nX,nY, @oTree,@aTree,cArquivo,@cSearch,@lRefresh,aAreaAF1,lXVisual,@oDlg,@aSVAlias, nBottomEn,nRight,nLeft, @nOldEnch,@oPanel,nOpcx)}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPermite selecionar item como marcado/desmarcado somenteณ
//ณna montagem do projeto                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !lModelo 
	oTree:bLDblClick:= {|| If(SubStr(oTree:GetCargo(),1,3)=="AF2" , Ft530ChgIt(@oTree,@aTree,,lExcMult),Nil)}
EndIf

FTA530Tree(@oTree,@aTree,cFilhos,.T.)

If !Empty(oTree:GetCargo())
	AtuMemory(SubStr(oTree:GetCargo(),1,3),Val(SubStr(oTree:GetCargo(),4,12)))
EndIf




ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,if(lConfirma<>nil,{||lConfirma:=.T.,oDlg:End()},;
										{|| If(GrvItem(@oTree,@aTree,nOpcX,lExcMult) .AND. Ft530GrPrA() , oDlg:End(),.F.)}),;
										If (lConfirma<>nil, {||lConfirma :=.F.,oDlg:End()},{|| lRet:=.F.,oDlg:End()}),,aButtons))
FATPDLogUser("FTADLGAF1")
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Ponto de Entrada para validar informacoes de usuarios ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lFT530VdC .and. lRet
	lRet := ExecBlock("FT530Vdc",.F.,.F.,{M->AF1_ORCAME,M->AF1_VERSAO})
	If ValType( lRet ) <> "L"
		lRet := .T.
	EndIf
Endif										
										
ALTERA := lAltBkp
INCLUI := lIncBkp
                                                                                                             
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณFTAView   ณ Autor ณ Vendas Cliente        ณ Data ณ 08-01-2008 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณFuncao que monta a Tarefa no Tree do Pre-Projeto              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ                                                              ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FTAView(oDlg,oTree,aSVAlias,aPos,nOldEnch,oPanel,nOpcx)

Local cAlias	:= SubStr(oTree:GetCargo(),1,3)
Local nRecView	:= Val(SubStr(oTree:GetCargo(),4,12))
Local nPosAlias	:= aScan(aSVAlias,cAlias)
Local nLeft     := oMainWnd:nLeft+10
Local nRight    := oMainWnd:nRight-10
Local nBottomEn	:= Int(((oDlg:nBottom-oDlg:nTop)/4))-30
Local aCampos	:= {}
Local aFolder	:= {}
Local aColsNew	:= {}
Local aHeadNew	:= {}
Local cCargo	:= oTree:GetCargo()
Local nItePosi	:= Val(oTree:CurrentNodeID)
Local nForcPos 	:= aScan(oTree:aCargo,{|x| x[1] == cCargo}) 

If 	nItePosi == 1 .OR. nForcPos == 1
	cAlias 		:= "AF1"
	AF1->(DbSetOrder(8))	//AF1_FILIAL+AF1_ORCAME+AF1_VERSAO
	AF1->(DbSeek(xFilial("AF1")+M->AF1_ORCAME+M->AF1_VERSAO))
	nRecView	:= AF1->(Recno())
EndIf

If nRecView <> 0

	//Oculta Enchoice
	If ( Len(aObj) >= nOldEnch ) .AND. (aObj[nOldEnch][1] <> Nil)
		aObj[nOldEnch][1]:Hide()
		
		If	ValType( aObj[4][1] ) == "O"
			aObj[4][1]:Hide()		
		Endif 
		
	EndIf 
	
	//Oculta Folder
	If ( Len(aObj) >= nOldEnch ) .AND. (aObj[nOldEnch][4] <> Nil)
		aObj[nOldEnch][4]:Hide()
		
		If	ValType( aObj[4][1] ) == "O"
			aObj[4][1]:Hide()		
		Endif 
		
	EndIf
	
	If (aObj[nOldEnch][2] <> Nil) .AND. (aObj[nOldEnch][3] <> Nil)
		aObj[nOldEnch][2]	:= aClone(aGets)
		aObj[nOldEnch][3]	:= aClone(aTela)
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณOculta Folderณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If nOldEnch == 3 .AND. (aObj[nOldEnch][4] <> Nil)
		aObj[nOldEnch][4]:Hide()
	EndIf

	Do Case
		Case cAlias == "AF1"
			aGets	:= aClone(aObj[3][2])
			aTela	:= aClone(aObj[3][3])
		Case cAlias == "AF5"
			aGets	:= aClone(aObj[2][2])
			aTela	:= aClone(aObj[2][3])
		Case cAlias == "AF2"
			aGets	:= aClone(aObj[1][2])
			aTela	:= aClone(aObj[1][3])
	EndCase

	dbSelectArea(cAlias)
	MsGoto(nRecView)
	
	If cAlias == "AF5"
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCalcula total da EDTณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
		Ft530TtAF5(AF5->AF5_ORCAME,AF5->AF5_EDT,AF5->AF5_VERSAO)
	EndIf

	AtuMemory(cAlias)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAtualiza dadosณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Do Case
		Case cAlias == "AF3"
			SB1->(dbSetOrder(1))
			SB1->(DbSeek(xFilial()+AF3->AF3_PRODUT))
			M->AF3_TIPO	:= SB1->B1_TIPO
			M->AF3_UM	:= SB1->B1_UM
			M->AF3_SEGUM := SB1->B1_SEGUM
			M->AF3_DESCRI:= SB1->B1_DESC
		Case cAlias == "AF7"
			AF2->(dbSetOrder(5))	//AF2_FILIAL+AF2_ORCAME+AF2_VERSAO+AF2_TAREFA+AF2_ORDEM
			AF2->(DbSeek(xFilial()+AF7->AF7_ORCAME+AF7->AF7_VERSAO+AF7->AF7_PREDEC)) 
			M->AF7_DESCRI := AF2->AF2_DESCRI
		Case cAlias == "AF1" 
			aColsNew	:= {}
			aHeadNew	:= {}
			Ft530Prod(@aHeadNew,@aColsNew)
			aObj[3][5]:SetArray(aColsNew,.T.)
			aObj[3][5]:Refresh()
	EndCase	      

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAtualiza interfaceณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If nPosAlias > 0
		Do Case
			Case cAlias == "AF2" 
				If aObj[1][1] == Nil
					aCampos	:= Ft530Field("AF2",Nil,@aFolder)
					aObj[1][1] := MsMGet():New("AF2",AF2->(RecNo()),nOpcx,,,,,{0,0,nBottomEn-20,(nRight-nLeft)/2-145},,,,,,oPanel,,.F.,,,,,aCampos,aFolder)
					Ft530PutVl(aObj[1][1])
				EndIf
				
				Ft530Fold(@oPanel,@oDlg,nOpcx)
				
				aObj[1][1]:Show()
				aObj[1][1]:Refresh()    
				aObj[1][4]:Show()
				aObj[1][4]:Refresh()				
				nOldEnch:=1				
				
		 		Ft530Prgt(@oPanel,@oDlg,nOpcx,"AF2","2",M->AF1_ORCAME,M->AF1_VERSAO,AF2->AF2_TAREFA)

				aObj[4][1]:Show()
				aObj[4][1]:Refresh()    
				    
			Case cAlias == "AF5"
				If aObj[2][1] == Nil 
					aCampos	:= Ft530Field("AF5",Nil,@aFolder)
					aObj[2][1] := MsMGet():New("AF5",AF5->(RecNo()),nOpcx,,,,,{0,0,nBottomEn-20,(nRight-nLeft)/2-145},,,,,,oPanel,,.F.,,,,,aCampos,aFolder)
					Ft530PutVl(aObj[2][1])
				EndIf
				aObj[2][1]:Show()
				aObj[2][1]:Refresh() 
				noldEnch:=2
								
				Ft530Prgt(@oPanel,@oDlg,nOpcx,"AF5","2",M->AF1_ORCAME,M->AF1_VERSAO,AF5->AF5_EDT)	//Folder de perguntas

				aObj[4][1]:Show()
				aObj[4][1]:Refresh()    
				    
			Case cAlias == "AF1"  
				aObj[3][4]:Show()
				aObj[3][1]:Show()
				aObj[3][1]:Refresh() 
				noldEnch:=3				
		EndCase
	EndIf
	
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณFTA530Treeณ Autor ณ Vendas Cliente        ณ Data ณ 08-01-2008 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณFuncao que realiza a montagem do Tree da Estrutura do         ณฑฑ
ฑฑณ          ณPre-Projeto atual                                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ                                                              ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function FTA530Tree(oTree,aTree,cFilhos,lReset,lInsTask,cModelo,lDisplay,aQlEDT,lMovTree,cVersao)

Local lRet                      
Local nLi 		:= 1

Default aQlEDT :={}

If	Len(aQlEDT) > 0

	For nLi:=1 To Len(aQlEDT)
		lRet := Processa({||AuxTree(oTree,aTree,cFilhos,lReset,lInsTask,aQlEDT[nLi,1],lDisplay,AQLEDT[nLi][2])},STR0040) //"Carregando Estrutura..."
	Next nLi
	                              
Else
	lRet := Processa({||AuxTree(oTree,aTree,cFilhos,lReset,lInsTask,cModelo,lDisplay, ,  ,lMovTree,cVersao)},STR0040) //"Carregando Estrutura..."
Endif 	

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณAuxTree   ณ Autor ณ Vendas Cliente        ณ Data ณ 08.01.2008 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณFuncao que monta o Tree do Pre-Projeto por EDT                ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณGenerico                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AuxTree(oTree,aTree,cFilhos,lReset,lInsTask,cModelo,lDisplay,aQlEDT,lCpaPrj,lMovTree,cVerMod)

Local aArea		:= GetArea()
Local cChaveAnt 	:= oTree:GetCargo()
Local lCopia	   := cModelo <> Nil
Local lRetorno 	:= .T.

Default cFilhos 	:= "AF1,AF5,AF2,AF3,AF7"// Alias que sao amarrados ao TREE
Default lReset 	:= .T.                                                    
Default lInsTask	:= .T.
Default cModelo	:= M->AF1_ORCAME 
Default cVerMod	:= M->AF1_VERSAO
Default lDisplay 	:= .F.
Default aQlEDT	:= {}
Default lCpaPrj	:= .F. 
Default lMovTree	:= .F. 

If	lCpaPrj
	Do Case 
		Case Empty(cModelo)
			ApMsgAlert(STR0101,STR0054)	//"Projeto nใo informado ou invalido !"###"Aten็ใo"
			lRetorno := .F.
		Case ( cModelo == M->AF1_ORCAME .And. cVerMod == M->AF1_VERSAO )
			ApMsgAlert(STR0179,STR0054)	//"Nใo serแ possํvel copiar a mesmo Projeto / Versใo!"###"Aten็ใo"
			lRetorno := .F.
	EndCase		
EndIf

If lRetorno  

	cModelo	:= cModelo + Space(Tamsx3("AF5_ORCAME")[1]-Len(cModelo))
	
	If lReset  
		aTree := {}
		oTree:BeginUpdate()
		oTree:Reset()
		oTree:EndUpdate()
	EndIf
	If	lCpaPrj
		lReset := .T.
	Endif 
	
	oTree:Disable()
	oTree:BeginUpdate()
	
	If lCopia	
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณPosiciona a Tree --------------------------------------  ณ
		//ณSomente o comando TreeSeek deveria funcionar, mas por    ณ
		//ณalgum motivo o arquivo de trabalho paralelo da arvore naoณ
		//ณfica posicionado apos insercoes seguidas.                ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		oTree:TreeSeek(aTree[1][1])	//Posiciona a arvore na raiz principal
		
		AF5->(DbGoTo(Val(SubStr(aTree[1][1],4,12)))) //Posiciona AF5 na raiz 
		AF7->(DbSetOrder(3)) //AF7_FILIAL+AF7_ORCAME+AF7_VERSAO+AF7_TAREFA+AF7_ITEM
		AF3->(DbSetOrder(5)) //AF3_FILIAL+AF3_ORCAME+AF3_VERSAO+AF3_TAREFA+AF3_ITEM
		AF2->(DbSetOrder(6)) //AF2_FILIAL+AF2_ORCAME+AF2_VERSAO+AF2_EDTPAI+AF2_ORDEM
		AF5->(DbSetOrder(6)) //AF5_FILIAL+AF5_ORCAME+AF5_VERSAO+AF5_EDTPAI+AF5_ORDEM
	
		cNextEDT	:= Ft530NwEdt()
	
		Begin Transaction
			nRec := Ft530Copia(cModelo,M->AF1_ORCAME,cNextEDT,,,AF5->AF5_EDT,aQlEDT,lCpaPrj,cVerMod,M->AF1_VERSAO)
		End Transaction
	
		If nRec > 0   
	
			AF5->(DbGoTo(nRec))    
		
			ProcRegua(Ft530Count("AF2",AF5->AF5_FILIAL+cModelo+cVerMod,6,"AF2->AF2_FILIAL+AF2->AF2_ORCAME+AF2->AF2_VERSAO"))
		
			AddEDT(@oTree,@aTree,AF5->AF5_ORCAME+AF5->AF5_VERSAO+AF5->AF5_EDT,cFilhos, 6,"AF5"+StrZero(AF5->(RecNo()),12),lInsTask)
			
		EndIf
		
	Else    
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณConta quantos itens tem o modeloณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If _nRecAF2 == 0
			_nRecAF2	:= Ft530Count("AF2",xFilial("AF2")+AF1->AF1_ORCAME+AF1->AF1_VERSAO,6,"AF2->AF2_FILIAL+AF2->AF2_ORCAME+AF2->AF2_VERSAO")
		EndIf
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCria elementos da arvoreณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		ProcRegua(_nRecAF2)
		AF5->( dbSetOrder(7) )	//AF5_FILIAL+AF5_ORCAME+AF5_VERSAO+AF5_NIVEL
		AF5->( dbSeek( xFilial("AF5")+AF1->AF1_ORCAME+AF1->AF1_VERSAO+"001") )
		cChaveAnt := "AF5"+StrZero(AF5->(RecNo()),12)
		
		While AF5->( !Eof() .AND. AF5_FILIAL+AF5_ORCAME+AF5_VERSAO+AF5_NIVEL == xFilial("AF5")+AF1->AF1_ORCAME+AF1->AF1_VERSAO+"001" )
			AddEDT(@oTree,@aTree,AF5->AF5_ORCAME+AF5->AF5_VERSAO+AF5->AF5_EDT,cFilhos,  6,"AF5"+StrZero(AF5->(RecNo()),12),lInsTask,,lMovTree)
			AF5->(dbSkip())
		End	
	
	EndIf
	
	oTree:EndUpdate()
	oTree:TreeSeek(cChaveAnt)
	oTree:Enable()
	
	If lDisplay
		oTree:Display()
		oTree:TreeSeek(cChaveAnt)
	EndIf
	
	RestArea(aArea)

EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณAddEDT   ณ Autor ณ Vendas Cliente         ณ Data ณ 08-01-2008 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณFuncao que monta o a Tarefa no Tree do Pre-Projeto.           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ                                                              ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AddEDT(oTree,aTree,cChave,cFilhos,nNivel,cSeekAdd,lInsTask,lCriacao,lMovTree)

Local nx		:= 0
Local aArea		:= GetArea()
Local aAreaAF5	:= AF5->(GetArea())
Local aAreaAF2	:= AF2->(GetArea())
Local aAuxArea  := {}
Local aDocAF5	:= {}
Local cCargo	:= "AF5"+StrZero(AF5->(RecNo()),12)
Local cBmp		:= ""
Local aNodes := {}
Local nNode  := 0   

Default lCriacao	:= .F.
If	lMovTree
	lCriacao :=.T.
Endif 

cBmp := Ft530Bmp("AF5")
aTreeIn(@oTree,@aTree,cSeekAdd,cCargo)
oTree:TreeSeek(cSeekAdd)  	

If Empty(oTree:aNodes) .OR. lCriacao   
	lCriacao	:= .T.     
	oTree:AddTree(AF5->AF5_DESCRI,cBmp,cBmp,cCargo)
Else
	oTree:AddItem(AF5->AF5_DESCRI,cCargo,cBmp,cBmp,2 ) 
EndIf       

cSeekAdd := cCargo
oTree:TreeSeek(cSeekAdd)

If lInsTask
	AF2->( dbSetOrder(6) )	//AF2_FILIAL+AF2_ORCAME+AF2_VERSAO+AF2_EDTPAI+AF2_ORDEM
	AF2->( dbSeek( xFilial("AF2")+cChave) )
	While AF2->( !Eof() .AND. AF2_FILIAL+AF2_ORCAME+AF2_VERSAO+AF2_EDTPAI == xFilial("AF2")+cChave )
		aAdd(aNodes, {PMS_TASK,;
		              AF2->(Recno()),;
		              If(Empty(AF2->AF2_ORDEM), "000", AF2->AF2_ORDEM),;
		              AF2->AF2_TAREFA})
		AF2->( dbSkip() )
	End
EndIf

AF5->( dbSetOrder(6) )	//AF5_FILIAL+AF5_ORCAME+AF5_VERSAO+AF5_EDT+AF5_ORDEM
AF5->( dbSeek(xFilial()+cChave) )

While AF5->( !Eof() .And. AF5_FILIAL+AF5_ORCAME+AF5_VERSAO+AF5_EDTPAI == xFilial("AF5")+cChave )
		
	If !Empty ( AF5->AF5_ORCAME ) .And. !Empty(AF5->AF5_VERSAO) // Protege contra linha em branco
		aAdd(aNodes, {PMS_WBS,;
		              AF5->(Recno()),;
		              If(Empty(AF5->AF5_ORDEM), "000", AF5->AF5_ORDEM),;
		              AF5->AF5_EDT})
	EndIf
	AF5->( dbSkip() )
EndDo

aSort(aNodes, , , {|x, y| x[3]+x[4] < y[3]+y[4]})

For nNode := 1 To Len(aNodes)
	If aNodes[nNode][1] = PMS_TASK
	
		IncProc(STR0041) //"Carregando itens da proposta"

		AF2->(dbGoto(aNodes[nNode][2]))
		
		cCargo := "AF2"+StrZero(AF2->(RecNo()),12)
		cBmp	:= Ft530Bmp("AF2")
		aTreeIn(@oTree,@aTree,cSeekAdd,cCargo) 

		oTree:TreeSeek(cSeekAdd)  
		
		If lCriacao
			oTree:AddTree(AllTrim(Substr(AF2->AF2_DESCRI,1,50)),cBmp,cBmp,cCargo)
			oTree:EndTree()
		Else
			oTree:AddItem(AllTrim(Substr(AF2->AF2_DESCRI,1,50)),cCargo,cBmp,cBmp,2) 
		EndIf
		
		oTree:TreeSeek(cCargo) 

	Else
		AF5->(dbGoto(aNodes[nNode][2]))

		AddEDT( @oTree,@aTree, AF5->AF5_ORCAME+AF5->AF5_VERSAO+AF5->AF5_EDT   ,cFilhos,nNivel,cSeekAdd,lInsTask,lCriacao,lMovTree)
	EndIf
Next

If lCriacao
	oTree:EndTree()
EndIf

RestArea(aAreaAF2)
RestArea(aAreaAF5)
RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ   GetNivel ณ Autor ณ Vendas Cliente       ณ Data ณ 08-01-2008 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Retorna o codigo de nivel de uma EDT                          ณฑฑ
ฑฑณ          ณ                                                               ณฑฑ
ฑฑณ          ณ Esta funcao retorna o codigo de nivel de uma EDT.             ณฑฑ
ฑฑณ          ณ                                                               ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GetNivel(cPrePro, cEDT)

Local aArea		:= GetArea()
Local aAreaAF5	:= AF5->(GetArea())
Local cNivel	:= "000"  

AF5->(dbSetOrder(1))  //AF5_FILIAL+AF5_ORCAME+AF5_EDT+AF5_ORDEM

If AF5->( dbSeek(xFilial("AF5")+cPrePro+cEDT) )
	cNivel := AF5->AF5_NIVEL
EndIf

RestArea(aAreaAF5)
RestArea(aArea)

Return cNivel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณCheckRef ณ Autor ณ Vendas Cliente         ณ Data ณ 08/01/2008 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Verifica se ้ a partir da EDT destino ้ possํvel             ณฑฑ
ฑฑณ          ณ chegar a EDT de origem, ou seja, ela percorre a              ณฑฑ
ฑฑณ          ณ a แrvore na ordem inversa, at้ chegar na EDT                 ณฑฑ
ฑฑณ          ณ principal ou encontrar a EDT origem.                         ณฑฑ
ฑฑณ          ณ                                                              ณฑฑ
ฑฑณ          ณ Assume que a EDT origem e a EDT destino pertencem ao mesmo   ณฑฑ
ฑฑณ          ณ pre-projeto.                                                 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CheckRef(cPrePro, cEDTOrig, cEDTDest)
Local aArea    := GetArea()
Local aAreaAF5 := AF5->(GetArea())
Local cEDTProx := ""
Local lRet     := .T.   

// a EDT origem e EDT destino nใo podem
// ser a mesma
If cEDTOrig  == cEDTDest
	lRet := .T.	
Else
	// se a EDT destino for igual o or็amento
	// a EDT origem nใo foi encontrada
	If AllTrim(cEDTDest) == AllTrim(cPrePro)
		lRet := .F.
	Else
		AF5->(dbSetOrder(1)) 	//AF5_FILIAL+AF5_ORCAME+AF5_EDT
		If AF5->(DbSeek(xFilial("AF5") + cPrePro + cEDTDest))
			cEDTProx := AF5->AF5_EDTPAI
			lRet := CheckRef(cPrePro, cEDTOrig, cEDTProx)
		EndIf
	
	EndIf
EndIf  

RestArea(aAreaAF5)
RestArea(aArea)   

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณFTAExcAF1  ณ Autor ณ Vendas Cliente       ณ Data ณ 08-01-2008 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณExecuta a exclusao de um Pre-Projeto                          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณExpC1 : Codigo do Orcamento                                   ณฑฑ
ฑฑณ          ณExpN2 : RecNo do Orcam. ( Opcional )                          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณGenerico                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FTAExcAF1(cPrePro,nRecAF1,cVersao)

Local aArea	:= GetArea()
Local aAreaAF3	:= AF3->(GetArea())
Local aAreaAF2	:= AF2->(GetArea())
Local aAreaAF5	:= AF5->(GetArea())
Local aAreaAF7	:= AF7->(GetArea())
Local aRecnos	:= {}
Local nX		:= 0
Local lContinua	:= .T.
Local cTpPerg	:= If(IsInCallStack("FATA530A"),"2","3")

If nRecAF1 <> Nil
	dbSelectArea("AF1")
	dbGoto(nRecAF1)
	cPrePro	:= AF1->AF1_ORCAME
	cVersao := AF1->AF1_VERSAO
Else
	dbSelectArea("AF1")
	dbSetOrder(8)	//AF1_FILIAL+AF1_ORCAME+AF1_VERSAO
	lContinua	:= DbSeek(xFilial()+cPrePro+cVersao)
	nRecAF1		:= RecNo()
EndIf

If lContinua

	Begin Transaction

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica a existencia de registros nas EDTs                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea("AF5")
	dbSetOrder(5)	//AF5_FILIAL+AF5_ORCAME+AF5_VERSAO+AF5_EDT+AF5_ORDEM
	DbSeek(xFilial()+cPrePro+cVersao)
	While !AF5->(Eof()) .And. xFilial("AF5")+cPrePro+cVersao==AF5->AF5_FILIAL+AF5->AF5_ORCAME+AF5->AF5_VERSAO
		FTAExcAF5(,,AF5->(RecNo()))
		dbSkip()
	EndDo

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณExclui registros de produtos adicionais (sem tarefa)ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea("AF3")
	dbSetOrder(5)	//AF3_FILIAL+AF3_ORCAME+ AF3_VERSAO+AF3_TAREFA+AF3_ITEM
	DbSeek(xFilial()+cPrePro+cVersao)
	While !AF3->(Eof()) .And. xFilial("AF3")+cPrePro+cVersao==AF3->AF3_FILIAL+AF3->AF3_ORCAME+AF3->AF3_VERSAO
		RecLock("AF3",.F.)
		dbDelete()
		MsUnLock()
		AF3->(DbSkip())
	End
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณExclui perguntas relacionadas ao AF1ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea("AG6")
	dbSetOrder(4) //AG6_FILIAL+AG6_TIPO+AG6_CODPRO+AG6_VERSAO+AG6_LOCAL+AG6_CODPER
	dbSeek(xFilial("AG6")+cTpPerg+cPrePro+cVersao)
	aRecnos	:= {}
	
	While !AG6->(Eof()) 					.AND.;
		AG6->AG6_FILIAL	== xFilial("AG6")	.AND.;
		AG6->AG6_TIPO	== cTpPerg			.AND.;
		AG6->AG6_CODPRO	== cPrePro    .AND.;
		AG6->AG6_VERSAO	== cVersao  
		
		AAdd(aRecnos,AG6->(Recno()))
		
		AG6->(DbSkip())
	End
	
	For nX := 1 to Len(aRecnos)

		AG6->(DbGoTo(aRecnos[nX]))
		RecLock("AG6",.F.)
		DbDelete()
		MsUnLock()

	Next nX
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Exclui o refistro do AF1                                        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea("AF1")
	dbGoto(nRecAF1)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณExclui o memo, se houverณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Type("aMemos") == "A"
		For nX := 1 to Len(aMemos)
			cVar := aMemos[nX][1]
			If (PrefixoCpo("AF1") $ cVar) .AND. !Empty(AF1->&(aMemos[nX][2]))
				MSMM( AF1->&(aMemos[nX][2]),,,,2)
			EndIf
		Next nX
	EndIf
	
	RecLock("AF1",.F.,.T.)
	dbDelete()
	MsUnlock()
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Exclui os segmentos de negocios relacionados ao Modelo. ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	DbSelectArea("AG0")
	DbSetOrder(1)
	If DbSeek(xFilial("AG0")+cPrePro)
		While !AG0->(Eof()) .AND. AG0->AG0_MODELO == cPrePro
			RecLock("AG0",.F.)
			dbDelete()
			MsUnLock()
			AG0->(DbSkip())
		End
	EndIf
	
	End Transaction
EndIf

RestArea(aAreaAF2)
RestArea(aAreaAF3)
RestArea(aAreaAF5)
RestArea(aAreaAF7)
RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณFTAExcAF2  ณ Autor ณ Vendas Cliente       ณ Data ณ 08-01-2008 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณExecuta a exclusao de uma Tarefa.                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณExpC1 : Codigo do Pre-Projeto                                 ณฑฑ
ฑฑณ          ณExpC3 : Codigo da Tarefa                                      ณฑฑ
ฑฑณ          ณExpN4 : RecNo da Tarefa ( Opcional )                          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณGenerico                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FTAExcAF2(cPrePro,cTarefa,nRecAF2,cVersao)

Local aArea	:= GetArea()
Local aAreaAF2	:= AF2->(GetArea())
Local aAreaAF3	:= AF3->(GetArea())
Local aAreaAF5	:= AF5->(GetArea())
Local aAreaAF7	:= AF7->(GetArea())
Local lContinua	:= .T.
Local cEdtPai   := ""
Local nX		:= 0
Local nQuant	:= 0 
Local aRecnos	:= {}  
Local cTpPerg	:= If(IsInCallStack("FATA530A"),"2","3")

If nRecAF2<>Nil
	dbSelectArea("AF2")
	dbGoto(nRecAF2)
	cPrePro	:= AF2->AF2_ORCAME
	cVersao := AF2->AF2_VERSAO
	cNivelTrf	:= AF2->AF2_NIVEL
	cTarefa		:= AF2->AF2_TAREFA
	cEdtPai     := AF2->AF2_EDTPAI
Else
	dbSelectArea("AF2")
	dbSetOrder(5)	//AF2_FILIAL+AF2_ORCAME+AF2_VERSAO+AF2_TAREFA+AF2_ORDEM
	lContinua	:= DbSeek(xFilial()+cPrePro+cVersao+cTarefa)
	nRecAF2		:= RecNo()
	cEdtPai     := AF2->AF2_EDTPAI
EndIf

If lContinua  
	
	Begin Transaction

	nQuant		:= AF2->AF2_QUANT
	
	DbSelectArea("AF5")
	DbSetOrder(5) //AF5_FILIAL+AF5_ORCAME+AF5_VERSAO+AF5_EDT+AF5_ORDEM
	If DbSeek(xFilial("AF5")+cPrePro+cVersao+cEdtPai)
		RecLock("AF5",.F.)
		AF5->AF5_QUANT	-= nQuant
		MsUnLock()
		While !Empty(AF5->AF5_EDTPAI)
			cEdtPai := AF5->AF5_EDTPAI
			If AF5->(DbSeek(xFilial("AF5")+cPrePro+cVersao+cEdtPai))
				RecLock("AF5",.F.)
				AF5->AF5_QUANT	-= nQuant
				MsUnLock() 
			EndIf
		End
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica a existencia de registros no AF3 e efetua a exclusao   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea("AF3")
	dbSetOrder(5)	//AF5_FILIAL+AF5_ORCAME+AF5_VERSAO+AF5_EDT+AF5_ORDEM
	DbSeek(xFilial()+cPrePro+cVersao+cTarefa)
	While !AF3->(Eof()) .And. xFilial("AF3")+cPrePro+cVersao+cTarefa == AF3->AF3_FILIAL+AF3->AF3_ORCAME+AF3->AF3_VERSAO+AF3->AF3_TAREFA
		RecLock("AF3",.F.,.T.)
		dbDelete()
		MsUnlock()
		dbSkip()
	EndDo

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica a existencia de registros no AF7 e efetua a exclusao   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea("AF7")
	dbSetOrder(3)	//AF7_FILIAL+AF7_ORCAME+AF7_VERSAO+AF7_TAREFA+AF7_ITEM
	DbSeek(xFilial()+cPrePro+cVersao+cTarefa)
	While !AF7->(Eof()) .And. xFilial("AF7")+cPrePro+cVersao+cTarefa == AF7->AF7_FILIAL+AF7->AF7_ORCAME+AF7->AF7_VERSAO+AF7->AF7_TAREFA
		RecLock("AF7",.F.,.T.)
		dbDelete()
		MsUnlock()
		dbSkip()
	EndDo

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica a existencia de registros no AF7 e efetua a exclusao   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea("AF7")
	dbSetOrder(4)	//AF7_FILIAL+AF7_ORCAME+AF7_VERSAO+AF7_PREDEC
	DbSeek(xFilial()+cPrePro+cVersao+cTarefa)
	While !AF7->(Eof()) .And. xFilial("AF7")+cPrePro+cVersao+cTarefa == AF7->AF7_FILIAL+AF7->AF7_ORCAME+AF7->AF7_VERSAO+AF7->AF7_PREDEC
		RecLock("AF7",.F.,.T.)
		dbDelete()
		MsUnlock()
		dbSkip()
	EndDo

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica a existencia de registros no AF3 e efetua a exclusao   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea("ADX")
	dbSetOrder(2)	//ADX_FILIAL+ADX_ORCAME+ADX_VERSAO+ADX_TAREFA+ADX_ITEM
	DbSeek(xFilial("ADX")+cPrePro+cVersao+cTarefa)
	While !ADX->(Eof()) .And. xFilial("ADX")+cPrePro+cVersao+cTarefa == ADX->ADX_FILIAL+ADX->ADX_ORCAME+ADX->ADX_VERSAO+ADX->ADX_TAREFA
		
		If !Empty(ADX->ADX_CODMEM)
			MSMM( ADX->ADX_CODMEM,,,,2)		
		EndIf      
		
		RecLock("ADX",.F.,.T.)
		dbDelete()
		MsUnlock()
		dbSkip()
		
	EndDo

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณExclui perguntas relacionadas ao AF2ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea("AG6")
	dbSetOrder(4) //"AG6_FILIAL+AG6_TIPO+AG6_CODPRO+AG6_VERSAO+AG6_LOCAL+AG6_CODPER"
	dbSeek(xFilial("AG6")+cTpPerg+cPrePro+cVersao+cTarefa)
	aRecnos	:= {}
	
	While !AG6->(Eof()) 					.AND.;
		AG6->AG6_FILIAL	== xFilial("AG6")	.AND.;
		AG6->AG6_TIPO	== cTpPerg			.AND.;
		AG6->AG6_CODPRO	== cPrePro			.AND.;
		AG6->AG6_VERSAO	== cVersao			.AND.;
		AG6->AG6_LOCAL	== cTarefa
		
		AAdd(aRecnos,AG6->(Recno()))
		
		AG6->(DbSkip())
	End
	
	For nX := 1 to Len(aRecnos)

		AG6->(DbGoTo(aRecnos[nX]))
		RecLock("AG6",.F.)
		DbDelete()
		MsUnLock()

	Next nX
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Exclui o refistro do AF2                                        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea("AF2")
	dbGoto(nRecAF2)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณExclui o memo, se houverณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Type("aMemos") == "A"
		For nX := 1 to Len(aMemos)
			cVar := aMemos[nX][1]
			If (PrefixoCpo("AF2") $ cVar) .AND. !Empty(AF2->&(aMemos[nX][2]))
				MSMM( AF2->&(aMemos[nX][2]),,,,2)
			EndIf
		Next nX
	EndIf
	
	RecLock("AF2",.F.,.T.)
	dbDelete()
	MsUnlock()
	
	End Transaction
	
EndIf	
	
RestArea(aAreaAF2)
RestArea(aAreaAF3)
RestArea(aAreaAF5)
RestArea(aAreaAF7)
RestArea(aArea) 

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณFTAExcAF5  ณ Autor ณ Edson Maricate       ณ Data ณ 09-02-2001 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณExecuta a exclusao de uma EDT.                                ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณExpC1 : Codigo do Orcamento                                   ณฑฑ
ฑฑณ          ณExpC3 : Codigo da EDT                                         ณฑฑ
ฑฑณ          ณExpN4 : RecNo da EDT    ( Opcional )                          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณGenerico                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FTAExcAF5(cPrePro,cEDT,nRecAF5,cVersao)

Local aArea	:= GetArea()
Local aAreaAF2	:= AF2->(GetArea())
Local aAreaAF3	:= AF3->(GetArea())
Local aAreaAF5	:= AF5->(GetArea())
Local aAreaAF7	:= AF7->(GetArea())
Local lContinua	:= .T.
Local nX		:= 0

If nRecAF5<>Nil
	dbSelectArea("AF5")
	dbGoto(nRecAF5)
	cPrePro	:= AF5->AF5_ORCAME
	cVersao := AF5->AF5_VERSAO
	cEDT	:= AF5->AF5_EDT
Else
	dbSelectArea("AF5")
	dbSetOrder(5)	//AF5_FILIAL+AF5_ORCAME+AF5_VERSAO+AF5_EDT+AF5_ORDEM
	lContinua	:= DbSeek(xFilial()+cPrePro+cVersao+cEDT)
	nRecAF5		:= RecNo()
EndIf

If lContinua

	Begin Transaction

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica a existencia de registros no AF2 e efetua a exclusao   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	AF5->( dbSetOrder(6) )	//AF5_FILIAL+AF5_ORCAME+AF5_VERSAO+AF5_EDTPAI+AF5_ORDEM
	AF5->( dbSeek( xFilial("AF5")+cPrePro+cVersao+cEDT ) )
	While AF5->( !Eof() .And. xFilial("AF5")+cPrePro+cVersao+cEDT == AF5_FILIAL+AF5_ORCAME+AF5_VERSAO+AF5_EDTPAI )
		FTAExcAF5(,,AF5->(RecNo()))
		AF5->( dbSkip() )
	EndDo

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica a existencia de registros no AF2 e efetua a exclusao   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	AF2->( dbSetOrder(6) )	//AF2_FILIAL+AF2_ORCAME+AF2_VERSAO+AF2_EDTPAI+AF2_ORDEM
	AF2->( dbSeek( xFilial("AF2")+cPrePro+cVersao+cEDT ) )
	While AF2->( !Eof() .And. xFilial("AF2")+cPrePro+cVersao+cEDT == AF2_FILIAL+AF2_ORCAME+AF2_VERSAO+AF2_EDTPAI )
		FTAExcAF2(,,AF2->(RecNo()))
		AF2->( dbSkip() )
	EndDo

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Exclui o registro do AF5                                        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	AF5->( dbGoto(nRecAF5) )
	RecLock("AF5",.F.,.T.) 
	
	If Type("aMemos") == "A"
		For nX := 1 to Len(aMemos)
			cVar := aMemos[nX][1]
			If (PrefixoCpo("AF5") $ cVar) .AND. !Empty(AF5->&(aMemos[nX][2]))
				MSMM( AF5->&(aMemos[nX][2]),,,,2)
			EndIf
		Next nX
	EndIf
	
	AF5->( dbDelete() )
	AF5->( MsUnlock() )
	
	End Transaction
	
EndIf	
	
RestArea(aAreaAF2)
RestArea(aAreaAF3)
RestArea(aAreaAF5)
RestArea(aAreaAF7)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFTA530Inc บAutor  ณMicrosiga           บ Data ณ  01/09/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณSubstitui a funcao axInclui para que seja possivel nao usar บฑฑ
ฑฑบ          ณo RegToMemory.                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FTA530Inc(cAlias,nReg,nOpc,aAcho,cFunc,aCpos,cTudoOk,lF3,cTransact,aButtons,aParam,aAuto,lVirtual,lMaximized)
Local aArea		:= GetArea()
Local nTop		:= 0
Local nLeft		:= 0
Local nBottom	:= 0
Local nRight	:= 0
Local oDlg
Local aSvRot   := Nil   
Local aObjects  := {} 
Local aPosObj   := {} 
Local aSizeAut  := MsAdvSize()
Local cMemo    := ""
Local nX       := 0
Local nOpcA    := 0
Local nLenSX8  := GetSX8Len()
Local bCampo   := {|nCPO| Field(nCPO) }
Local bOk      := Nil
Local bOk2     := {|| .T.}
Local cAliasMemo
Local bEndDlg := {|lOk| lOk:=oDlg:End(), nOpcA:=1, lOk}
Local oEnc01

Private aTELA[0][0]
Private aGETS[0]

Default cTudoOk := ".T."
Default bOk     := &("{|| "+cTudoOk+"}")
Default lF3     := .F.
Default lVirtual:= .F.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Processamento de codeblock de validacao de confirmacao            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty(aParam)
	bOk2 := aParam[2]
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta a entrada de dados do arquivo							 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nOpc == Nil
	nOpc := 3
	If Type("aRotina") == "A"
		aSvRot := aClone(aRotina)
	EndIf
	Private aRotina := { { " "," ",0,1 } ,{ " "," ",0,2 },{ " "," ",0,3 } }
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Inicializa variaveis para campos Memos Virtuais (GILSON)			 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Type("aMemos")=="A"
	For nX :=1 To Len(aMemos)
		cMemo := aMemos[nX][1]
		If ExistIni(cMemo)
			&cMemo := InitPad(SX3->X3_RELACAO)
		Else
			&cMemo := ""
		EndIf
	Next nX
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Funcoes executadas antes da chamada da Enchoice      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If cFunc != NIL
	&cFunc.()
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Processamento de codeblock de antes da interface                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty(aParam)
	Eval(aParam[1],nOpc)
EndIf

// Build com corre็ใo no tratamento dos controles pendentes na dialog ao executar o m้todo End()
If GetBuild() >= "7.00.060302P" 
	bEndDlg := {|lOk| If(lOk:=oDlg:End(),nOpcA:=1,nOpcA:=3), lOk}
EndIf

If SetMDIChild()
	oMainWnd:ReadClientCoors()
	nTop := 40
	nLeft := 30 
	nBottom := oMainWnd:nBottom-80
	nRight := oMainWnd:nRight-70		
Else
	nTop := 135
	nLeft := 0
	nBottom := TranslateBottom(.T.,28)
	nRight := 632
EndIf

aObjects := {}
AAdd( aObjects, {100,100, .T., .T. } )  
aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 } 
aPosObj := MsObjSize( aInfo, aObjects, .T. ) 

DEFINE MSDIALOG oDlg TITLE cCadastro From aSizeAut[7],0 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL 
EnChoice( cAlias, nReg, nOpc,,,,aAcho, aPosObj[1], aCpos,,,, cTudoOk,,lF3,lVirtual)   

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(Obrigatorio(aGets,aTela).And.Eval(bOk).And.Eval(bOk2,nOpc),Eval(bEndDlg),(nOpcA:=3,.f.))},{|| nOpcA := 3,oDlg:End()},,aButtons)

If nOpcA == 1
	If nOpc == 3 .OR. nOpc == 4 .OR. nOpc == 5
		Begin Transaction
			RecLock(cAlias, nOpc == 3)
			If nOpc == 5
				If Type("aMemos") == "A"
					For nX := 1 to Len(aMemos)
						cVar := aMemos[nX][1]
						If (PrefixoCpo(cAlias) $ cVar)
							MSMM( &(aMemos[nX][2]),TamSx3(aMemos[nX][1])[1],,&cVar,2,,,cAlias,aMemos[nX][2])
						EndIf
					Next nX
				EndIf
	
				(cAlias)->( dbDelete() )
			ElseIf nOpc == 3 .OR. nOpc == 4
				For nX := 1 TO FCount()
					If "_FILIAL"$FieldName(nX)
						FieldPut(nX,xFilial(cAlias))
					Else
						FieldPut(nX,M->&(EVAL(bCampo,nX)))
					EndIf
				Next nX
	
				If Type("aMemos") == "A"
					For nX := 1 to Len(aMemos)
						cVar := aMemos[nX][1] 
						If (PrefixoCpo(cAlias) $ cVar)
							MSMM((cAlias)->&(aMemos[nX][2]),TamSx3(aMemos[nX][1])[1],,&cVar,1,,,cAlias,aMemos[nX][2])
						EndIf
					Next nX
				EndIf
				
				While ( GetSX8Len() > nLenSX8 )
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณConfirma a numeracao com a verificacao do numero gravado ativado  ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					ConfirmSx8()
				EndDo
			Endif
			
			If cTransact != Nil
				If !("("$cTransact)
					cTransact+="()"
				EndIf
				&cTransact
			EndIf
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Processamento de codeblock dentro da transacao                    ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If !Empty(aParam)
				Eval(aParam[3],nOpc)
			EndIf
			
			msUnlock()
		End Transaction
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Processamento de codeblock fora da transacao                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !Empty(aParam)
		Eval(aParam[4],nOpc)
	EndIf
Else
	While ( GetSX8Len() > nLenSX8 )
		RollBackSX8()
	EndDo
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Restaura a integridade dos dados                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If aSvRot != Nil
	aRotina := aClone(aSvRot)
EndIf
RestArea(aArea)
lRefresh := .T.

Return nOpcA

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATA530   บAutor  ณMicrosiga           บ Data ณ  01/14/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SelEDT()

Local aArea		:= GetArea()
Local oTreeSel	:= Nil
Local oDlg		:= Nil 
Local aRet		:= {} 
Local lOk		:= .F.

DEFINE MSDIALOG oDlg TITLE STR0042 FROM 0,0 TO 400,440 PIXEL //"Sele็ใo de EDT"

@ 01,05 TO 180,214 LABEL STR0043 PIXEL OF oDlg //"Selecione a EDT desejada:"

oTreeSel := xTree():New(14, 10,170,205, oDlg)
oTreeSel:lShowHint:= .F. 

FTA530Tree(@oTreeSel,,,,.F.)

DEFINE SBUTTON FROM 184,006 TYPE 1 ENABLE OF oDlg;
	Action(	aRet:={	SubStr(oTreeSel:GetCargo(),1,3),;
					Val(SubStr(oTreeSel:GetCargo(),4,12))},;
			oDlg:End())
			
DEFINE SBUTTON FROM 184,040 TYPE 2 ENABLE OF oDlg Action(oDlg:End())

ACTIVATE MSDIALOG oDlg CENTERED

RestArea(aArea)

Return aRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณPMSAF5Nivณ Autor ณ  Adriano Ueda          ณ Data ณ 24-03-2004 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Funcao para recalculo de nivel (orcamento)                   ณฑฑ
ฑฑณ          ณ                                                              ณฑฑ
ฑฑณ          ณ Esta funcao recursiva recalcula o nivel das tarefas e EDTs   ณฑฑ
ฑฑณ          ณ a partir de uma EDT.                                         ณฑฑ
ฑฑณ          ณ                                                              ณฑฑ
ฑฑณ          ณ EDTs abaixo da EDT atual sao calculadas atraves de uma       ณฑฑ
ฑฑณ          ณ chamada recursiva                                            ณฑฑ
ฑฑณ          ณ                                                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ cOrcamento - codigo do orcamento                             ณฑฑ
ฑฑณ          ณ cEdtAnt    - codigo da EDT                                   ณฑฑ
ฑฑณ          ณ cNivel     - nivel da EDT                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ Nenhum                                                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ PMSA100, SIGAPMS                                             ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function AF5Nivel(cPreProj, cEdtAnt, cNivel, cNewEdt, cVersao)    

Local aArea		:= GetArea()
Local aAreaAF5	:= AF5->(GetArea())
Local aAreaAF2	:= AF2->(GetArea())
Local aRecnos	:= {}
Local nX		:= 0
Local nAF2Nivel	:= TamSX3("AF2_NIVEL")[1]
Local nAF5Nivel	:= TamSX3("AF5_NIVEL")[1] 

// recalcula o nivel das tarefas abaixo
// da EDT atual (cEDT)	
dbSelectArea("AF2")
AF2->(dbSetOrder(6))	//AF2_FILIAL+AF2_ORCAME+AF2_VERSAO+AF2_EDTPAI+AF2_ORDEM

If AF2->(DbSeek(xFilial("AF2") + cPreProj + cVersao + cEdtAnt))
	While	!AF2->(EoF())					.AND.;
		AF2->AF2_FILIAL == xFilial("AF2")	.And.;
	    AF2->AF2_ORCAME == cPreProj			.And.;
	    AF2->AF2_VERSAO == cVersao			.And.;
	    AF2->AF2_EDTPAI == cEdtAnt

	    AAdd(aRecnos,AF2->(Recno()))
		
		AF2->(dbSkip())
	End
	
	For nX := 1 to Len(aRecnos)
		AF2->(DbGoTo(aRecnos[nX]))
		RecLock("AF2", .F.)
		AF2->AF2_NIVEL	:= StrZero(Val(cNivel) + 1, nAF2Nivel)
		AF2->AF2_EDTPAI	:= cNewEDT
		MsUnlock()
	Next nX
	
EndIf

aRecnos	:= {}

// recalcula o nivel das EDTs abaixo
// da EDT atual (cEDT)
dbSelectArea("AF5")
AF5->(dbSetOrder(6))  // AF5_FILIAL + AF5_ORCAME + AF5_VERSAO + AF5_EDTPAI + AF5_ORDEM

If DbSeek(xFilial("AF5") + cPreProj + cVersao + cEdtAnt)
	While !AF5->(EoF())				   		.AND.;
		AF5->AF5_FILIAL == xFilial("AF5")	.And.;
		AF5->AF5_ORCAME == cPreProj			.And.;
		AF5->AF5_VERSAO == cVersao			.And.;
		AF5->AF5_EDTPAI == cEdtAnt

		AAdd(aRecnos,AF5->(Recno()))
		
		AF5->(dbSkip())
	End
	
	For nX := 1 To len(aRecnos)
		AF5->(DbGoTo(aRecnos[nX]))
		RecLock("AF5", .F.)
		AF5->AF5_NIVEL 	:= StrZero(Val(cNivel) + 1, nAF5Nivel)
		AF5->AF5_EDTPAI	:= cNewEDT
	  	MsUnlock()

		// recalcula o nivel da EDT abaixo da atual
		AF5Nivel(AF5->AF5_ORCAME, AF5->AF5_EDT, AF5->AF5_NIVEL,, AF5->AF5_VERSAO)

	Next nX
EndIf

RestArea(aAreaAF2)	
RestArea(aAreaAF5)
RestArea(aArea)

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATA530   บAutor  ณMicrosiga           บ Data ณ  01/15/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft530Psq(cAlias)

Local cWhere	:= "" 
Local cPreProj	:= ""
Local cJoin		:= ""   
Local aCposLst	:= {}
Local nOrder	:= 1  
Local cCpoPesq	:= ""
Local cRetCpo	:= ""
Local cRetorno	:= ""  
Local lRet		:= .F.
Local cTable	:=""
                 
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณNao eh necessario utilizar o pre-projeto na pesquisa do mesmoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Do Case
	Case cAlias == "AF1"
		aCposLst	:= {"AF1_ORCAME","AF1_DESCRI"}
		cWhere		:= "AF1_TIPO = '1'"
		nOrder		:= 2  
		cCpoPesq	:= "AF1_DESCRI" 
		cRetCpo		:= "AF1_ORCAME"
	Case cAlias == "AF2"
		cWhere		:= "AF2_ORCAME = '" + M->AF1_ORCAME + "'"
		aCposLst	:= {"AF2_TAREFA","AF2_DESCRI"}
		nOrder		:= 1
		cCpoPesq	:= "AF2_DESCRI"
		cRetCpo		:= "AF2_TAREFA" 
		cPreProj	:= M->AF1_ORCAME
	Case cAlias == "SA1"
		aCposLst	:= {"A1_COD","A1_LOJA","A1_NOME"}
		nOrder		:= 1
		cCpoPesq	:= "A1_NOME"
		cRetCpo		:= "A1_COD"  
		cTable		:= "SA1001"
	Case cAlias == "SUS"
		aCposLst	:= {"US_COD","US_LOJA","US_NOME"}
		nOrder		:= 1
		cCpoPesq	:= "US_NOME"
		cRetCpo		:= "US_COD"  
		cTable		:= "SUS001"
EndCase

cRetorno := Ft530F3(cAlias		, cWhere	, aCposLst	, nOrder	,;
					cCpoPesq	, cRetCpo	, cJoin		, cTable	)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPosiciona alias para que a pesquisa do SXB recupere oณ
//ณregistro localizado pelo usuario                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty(cRetorno)
	(cAlias)->(DbSetOrder(1))
	If (cAlias)->(DbSeek(xFilial(cAlias)+cPreProj+cRetorno))
		lRet := .T.
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATA530   บAutor  ณMicrosiga           บ Data ณ  01/31/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft530F3(	cAlias	, cWhere	, aCposLst	, nOrder	,;
					cCpoPesq, cRetCpo 	, cJoin		, cTable	)

Local aArea			:= GetArea()
Local oDlgPsq		:= Nil
Local oOcorr		:= Nil
Local aDados		:= {}
Local nTask			:= 1
Local nPos			:= 0
Local lRet			:= .F.
Local nOcorrencia   := 0
Local cPrefx		:= PrefixoCpo(cAlias)
Local cPesquisa		:= Space(TamSX3(cCpoPesq)[1])
Local cRetorno		:= ""
Local cIteAtu		:= &(ReadVar())
Local cTitle		:= ""  
Local cCposList		:= ""
Local nX			:= 0              
Local nTotReg		:= 0
Local cSep			:= ""  
Local cOrder		:= "" 
Local cTmp			:= ""
Local cTmp2			:= ""
Local cTabName		:= "TMP"
Local bBlockAdd		:= Nil
Local bBlockLine	:= Nil
Local bRet			:= Nil 
Local bNextReg		:= Nil
Local nPRet			:= 0
Local aHeaders		:= {}
Local oLstBx  		:= Nil

Default cWhere		:= ""
Default nOrder		:= 1  
Default cCpoPesq	:= "" 
Default cJoin		:= "" 
Default cTable		:= ""

If !Empty(cTable)
	cTabName	:= cTable
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta lista de camposณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cTmp	:= "{||AAdd(aDados,{"
cTmp2	:= "{||oLstBx:bLine :={|| {"
For nX := 1 to Len(aCposLst)
	aAdd(aHeaders, AllTrim(Capital(FWX3Titulo(aCposLst[nX]))))
	cCposList	+= cSep + aCposLst[nX]
	cTmp		+= cSep + cTabName + "->" + aCposLst[nX]
	cTmp2		+= cSep + "oLstBx:aArray[oLstBx:nAt][" + AllTrim(Str(nX)) + "]"
	cSep		:= ","
Next nX
cTmp	+= cSep + cTabName + "->" + "RECNUM})}"
cTmp2	+= "}}}" 

bBlockAdd	:= &(cTmp)
bBlockLine	:= &(cTmp2)

If !Empty(cTable)
	cCposList+= cSep+"RECNUM"
	aAdd(aCposLst,"RECNUM")
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณOrdem utilizada no SQLณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
(cAlias)->(DbSetOrder(nOrder))

cOrder	:= SqlOrder((cAlias)->(IndexKey()))

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณConta registros da tabelaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea(cAlias)
DbGoTop()
While !Eof() .AND. nTotReg <= NMAXPAGE
	nTotReg++
	DbSkip()
End
DbGoTop()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPesquisa inicialณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Ft530Pesq(	cPesquisa	, @nOcorrencia	, @aDados	, @oLstBx	,;
				@oOcorr		, cAlias		, cPrefx	, cCposList	,;
				cWhere		, cOrder		, cCpoPesq	, bBlockAdd	,;
				bBlockLine	, cJoin			, cTable	)
	RestArea(aArea)
	Return .F.
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณLocaliza a posicao do campo de retornoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nPRet := aScan(aCposLst,{|x|AllTrim(x) == AllTrim(cRetCpo)})

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณNome da pesquisaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cTitle	:= Capital(AllTrim(FWX2Nome(cAlias)))

DEFINE MSDIALOG oDlgPsq TITLE cTitle From 0,0 TO 310,500 OF oMainWnd PIXEL 

bRet	:= {||cRetorno:=oLstBx:aArray[oLstBx:nAt][nPRet],(oDlgPsq:End())}

oLstBx := TWBrowse():New(30,5,240,100,Nil,aHeaders,,oDlgPsq,,,,,,,,,,,,,,.T.)
oLstBx:bLDblClick := bRet
oLstBx:SetArray(aDados) 
Eval(bBlockLine)

oLstBx:GoTop()
oLstBx:Refresh()

If (nTotReg > NMAXPAGE)

   	bNextReg			:= {|a,b,c,d,e|Ft530Pag(@a,b,c,d,e)}
	oLstBx:bGoBottom	:= {||Eval(bNextReg,oLstBx,cTabName,aCposLst,NMAXPAGE),oLstBx:NAT := EVAL( oLstBx:BLOGICLEN ) }    
	oLstBx:bSkip		:= {|NSKIP, NOLD, nMax|nMax:=EVAL( oLstBx:BLOGICLEN ),NOLD := oLstBx:NAT, oLstBx:NAT += NSKIP,;
							oLstBx:NAT := MIN( MAX( oLstBx:NAT, 1 ), nMax ),If(oLstBx:nAt==nMax,Eval(bNextReg,oLstBx,cTabName,aCposLst,NMAXPAGE,cAlias),.F.),;
							oLstBx:NAT - NOLD}

EndIf
  
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se o codigo  ja esta preenchidoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If (cIteAtu <> Nil) .AND. !Empty(cIteAtu) .AND. ((nPos := aScan(aDados,{|x| AllTrim(x[nPRet])==AllTrim(cIteAtu)}))>0)
	oLstBx:nAt	:= nPos   
	oLstBx:Refresh()
EndIf

@ 140,150 Say "" OBJECT oOcorr //Ocorrencias

@ 140,005 Button STR0048 Size 40,10 Action Eval(bRet)						//"&Confirmar"
@ 140,050 Button STR0049 Size 40,10 Action (Close(oDlgPsq),DbCloseArea())	//"&Retonar"
@ 140,095 Button STR0050 Size 40,10 Action Ft530Visua(@oLstBx,cAlias)		//"&Visual."

If !Empty(cCpoPesq)
	@ 003,005 Say STR0051 //"Pesquisa pela descri็ใo:" 
	@ 012,005 Get cPesquisa Picture "@!" Size 160,10 Of oDlgPsq Pixel 
	@ 012,190 Button STR0052 Size 50,10 Action (oLstBx:nAt := 1,; //"&Filtrar"
		Ft530Pesq(	cPesquisa	, @nOcorrencia	, @aDados		, @oLstBx	,;
					@oOcorr		, cAlias		, cPrefx		, cCposList	,;
					cWhere		, cOrder		, cCpoPesq		, bBlockAdd	,;
					bBlockLine	, cJoin			, cTable		),;
		Iif( (nTotReg > NMAXPAGE), CfgPagLbx(@oLstBx,cTabName,aCposLst,cAlias), .F. ))
EndIf

Activate Dialog oDlgPsq Centered     

If !Empty(cTable)
	If Select(cTable) > 0
		(cTable)->(DbCloseArea())
	EndIf
EndIf

RestArea(aArea)

Return cRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530Pesq บAutor  ณVendas Clientes     บ Data ณ  22/11/2007 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria query para que seja feita a pesquisa com a palavra    บฑฑ
ฑฑบ          ณ informada e caso retorno seja verdadeiro mostra as         บฑฑ
ฑฑบ          ณ ocorrencias encontrdas.                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณCall Center                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/            
Static Function Ft530Pesq(	cPesquisa	, nOcorrencia	, aDados	, oLstBx	,;
							oOcorr		, cAlias		, cPrefx	, cCposList	,;
							cWhere		, cOrder		, cCpoPesq	, bBlockAdd	,;
							bBlockLine	, cJoin			, cTable	)

Local aArea		:= GetArea() 
Local aCposInd	:= {}
Local cTabela	:= "TMP" 
Local cFiltro	:= ""
Local nRecAdic	:= 0
Local nX		:= 0
Local lPaginar	:= (cTable <> Nil) .AND. (cTable <> "")

If lPaginar

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณExecuta a pesquisa, se estiver preenchidaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !Empty(cCpoPesq) .AND. !Empty(cPesquisa)
		If !(TCGetDB() $ "DB2|ORACLE")
			cFiltro += " AND LOWER("+cCpoPesq+") LIKE '%"+AllTrim(RetSqlAce(cPesquisa))+"%' "
		Else 
			cFiltro += " AND UPPER("+cCpoPesq+") LIKE '%"+AllTrim(Upper(cPesquisa))+"%' "
		EndIf
	EndIf
	
	cTabela := cTable 
	
	Ft320FilTb(Nil,cAlias,cFiltro,cTabela)  

	DbSelectArea(cTabela)
	DbGoTop()
	
	If (cTabela)->(Eof())
	    If FWIsInCallStack("PA010PSQ") //Caso a consulta F3 tenha partido da rotina de amarra็ใo no PMS
	    	MsgAlert(STR0090 + CRLF + STR0091,STR0054)
	    Else
	    	MsgAlert(STR0053,STR0054) //"Nenhuma Ocorr๊ncia encontrada com a palavra digitada."###"Aten็ใo"
	    EndIf
	    Return(.F.)
	Endif 
	
	//Limpa listbox
	If oLstBx <> Nil
		oLstBx:aArray := {}
	EndIf

	//Carrega a listbox
	aDados := Ft530Pag(@oLstBx,cTabela,StrToKArr(cCposList,","),NMAXPAGE)	
	
Else

	aCposInd := StrToKArr((cAlias)->(IndexKey()),"+")
	
	For nX := 1 to Len(aCposInd)
		If !(AllTrim(aCposInd[nX]) $ cCposList)
			cCposList += "," + aCposInd[nX]
		EndIf
	Next nX
	
	If Select(cTabela) > 0
		(cTabela)->(DbCloseArea())
	EndIf
	
	cQuery := "SELECT " + cCposList + " ,"+cAlias+".R_E_C_N_O_ as RECNUM "
	cQuery += " FROM " + RetSqlName(cAlias) + " " + cAlias
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPermite relacionar tabelasณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !Empty(cJoin)
		cQuery	+= cJoin
	EndIf
	
	cQuery += " WHERE "
	cQuery += cPrefx+"_FILIAL = '" + xFilial(cAlias)	+ "'"
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFiltra pelo projeto (modelo)ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !Empty(cWhere)
		cQuery += " AND " + cWhere
	EndIf
	     
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณRemove deletadosณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If TcSrvType() != "AS/400"
		cQuery	+= " AND " + cAlias + ".D_E_L_E_T_ = ' ' "
	Else
		cQuery	+= " AND " + cAlias + ".@DELETED@ = ' ' "
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณExecuta a pesquisa, se estiver preenchidaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !Empty(cCpoPesq) .AND. !Empty(cPesquisa)
		If !(TCGetDB() $ "DB2|ORACLE")
			cQuery += " AND LOWER("+cCpoPesq+") LIKE '%"+AllTrim(RetSqlAce(cPesquisa))+"%'" 
		Else 
			cQuery += " AND UPPER("+cCpoPesq+") LIKE '%"+AllTrim(Upper(cPesquisa))+"%'"
		EndIf
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณOrdena e executa queryณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cQuery	+= " ORDER BY " + cOrder
	
	cQuery := ChangeQuery( cQuery )
	
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cTabela,.T.,.T.)

	DbSelectArea(cTabela)
	DbGoTop()
	
	If (cTabela)->(Eof())
		If FWIsInCallStack("PA010PSQ") //Caso a consulta F3 tenha partido da rotina de amarra็ใo no PMS
	    	MsgAlert(STR0090 + CRLF + STR0091,STR0054)
	    Else
	    	MsgAlert(STR0053,STR0054) //"Nenhuma Ocorr๊ncia encontrada com a palavra digitada."###"Aten็ใo"
	    EndIf
		DbCloseArea()    
	    Return(.F.)
	Endif 
	
	aDados		:= {}
	nOcorrencia	:= 0
	
	While !(cTabela)->(Eof()) .AND. (nRecAdic <= NMAXPAGE)
		Eval(bBlockAdd)
		nOcorrencia++
		nRecAdic++
		(cTabela)->(DbSkip())
	Enddo
	
EndIf

If oLstBx <> Nil
	oLstBx:nAt	:= 1
	oLstBx:SetArray(aDados)
	Eval(bBlockLine)
   	oLstBx:Refresh()
   	If lPaginar                                                                 
   		oOcorr:cTitle := ""
   	Else
	  	oOcorr:cTitle := Strzero(nOcorrencia,6) + STR0055 //" ocorr๊ncia(s) encontrada(s)"
	EndIf
   	oOcorr:Refresh()
EndIf

RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATA530   บAutor  ณMicrosiga           บ Data ณ  01/17/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GrvItem(oTree,aTree,nOpcX,lExcMult)

Local lRet		:= .T.
Local aArea		:= GetArea()
Local aAreaAF5	:= {}
Local aTrack	:= {}
Local cCargo	:= oTree:GetCargo()
Local cAlias	:= SubStr(cCargo,1,3)
Local cAliasMemo:= ""
Local nRecno	:= Val(SubStr(cCargo,4,12))
Local nX		:= 0
Local bCampo   	:= {|nCPO| Field(nCPO) }
Local nValAnt	:= 0  
Local cPrefX	:= PrefixoCpo(cAlias)
Local nOpc		:= aRotina[nOpcX][4] 
Local lAltBkp	:= ALTERA
Local lIncBkp	:= INCLUI
Local lAltStatus:= .F.
Local nForcPos 	:= aScan(oTree:aCargo,{|x| x[1] == cCargo}) 
Local lModelo	:= IsInCallStack("FATA530A")

If (nOpc <> 5) .AND. (nOpc <> 2) .AND. !lExcMult

	If lRet
	
		ALTERA 	:= .T.
		INCLUI	:= .F.
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณSe a raiz da tree foi selecionada, a tabela associada sera ณ
		//ณa raiz do projeto, AF1                                     ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If Val(oTree:CurrentNodeID) == 1  .OR. nForcPos == 1 
			cAlias	:= "AF1"
			nRecno	:= AF1->(Recno())
		EndIf
		
		DbSelectArea(cAlias)
		DbGoTo(nRecno)
				
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifica se o status do registro foi alteradoณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If cAlias == "AF5"
			lAltStatus	:= (M->AF5_STATUS <> AF5->AF5_STATUS)
		ElseIf cAlias == "AF2"
			lAltStatus	:= (M->AF2_STATUS <> AF2->AF2_STATUS)
		EndIf
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณSe houve alguma alteracao no registroณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If cAlias == "AF2"
			
			If M->AF2_STATUS == "2" .AND. !Ft530VlPre(cAlias,nRecno,@aTree)
				ALTERA 	:= lAltBkp
				INCLUI	:= lIncBkp
				RestArea(aArea)
				Return .F.
			EndIf
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณSe for uma tarefa e esta estiver marcada como 'Utilizada',  ณ
			//ณarmazena o valor anterior da tarefa, para recalculo do totalณ
			//ณdo projeto                                                  ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
			If AF2->AF2_STATUS == "1"
				nValAnt	:= AF2->AF2_QUANT
			EndIf
	
			FTA531Grava(.F.,nRecno)
			
		ElseIf _lAlterou 
	
			If M->AF5_STATUS == "2" .AND. !Ft530VlPre(cAlias,nRecno,@aTree)
				ALTERA 	:= lAltBkp
				INCLUI	:= lIncBkp
				RestArea(aArea)
				Return .F.
			EndIf
		
			Begin Transaction
	
			RecLock(cAlias,.F.)
			
			For nX := 1 TO FCount()
				If "_FILIAL" $ FieldName(nX)
					FieldPut(nX,xFilial(cAlias))
				Else
					FieldPut(nX,M->&(Eval(bCampo,nX)))
				EndIf
			Next nX
			
			If Type("aMemos") == "A"
				For nX := 1 to Len(aMemos)
					cVar := aMemos[nX][1]
					If cPrefX $ cVar
						MSMM((cAlias)->&(aMemos[nX][2]),TamSx3(aMemos[nX][1])[1],,&cVar,1,,,cAlias,aMemos[nX][2])
					EndIf
				Next nX
			EndIf
			
			MsUnLock()
	
			End Transaction
	
		End  
	
		If (cAlias == "AF2") .OR. _lAlterou
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAtualiza descricao da treeณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			oTree:ChangePrompt(AllTrim(Substr((cAlias)->&(PrefixoCpo(cAlias)+"_DESCRI"),1,50)), cCargo)
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณTotaliza as quantidades do projetoณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If aTreeSk(@aTree,cCargo,@aTrack)
			
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณSe o status da EDT foi alterado, todos os filhos devem receberณ
				//ณo mesmo status                                                ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If (cAlias == "AF5") .AND. lAltStatus
					//Desmarca os filhos se o pai for desmarcado
			   		Ft530SetIt(@aTree,aTrack,@oTree,AF5->AF5_STATUS)
			 	ElseIf (cAlias == "AF2") .AND. AF2->AF2_STATUS == "1" .AND. lAltStatus
				 	//Seleciona o pai se nao estiver marcado
					Ft530StPai(@oTree)
				EndIf
				
			EndIf
			
			If cAlias $ "AF5/AF2"
				Ft530ChgIt(@oTree,@aTree,.T.,lExcMult)
			EndIf
		
		EndIf 
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณSe for a tela principal, salva os produtos adicionaisณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If (cAlias == "AF5") .AND. (AllTrim(AF5->AF5_EDT) == AllTrim(M->AF1_ORCAME))
			lRet := Ft530GrPrA()
		EndIf
		
		_lAlterou := .F.
	
		ALTERA 	:= lAltBkp
		INCLUI	:= lIncBkp
		
		RestArea(aArea)
		
    EndIf
    
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATA530   บAutor  ณMicrosiga           บ Data ณ  01/17/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function AtuMemory(cAlias,nRecno)

Local aArea	:= GetArea()
Local nX	:= 0

DbSelectArea(cAlias)

If nRecno <> NIL
	DbGoTo(nRecno)
EndIf

SX3->(DbSetOrder(1))
SX3->(DbSeek(cAlias))
While !SX3->(Eof()) .and. SX3->X3_ARQUIVO == cAlias
	
	If SX3->X3_CONTEXT <> "V"
		cCpo := (cAlias+"->"+Trim(SX3->X3_CAMPO))
		M->&(SX3->X3_CAMPO) := &cCpo
	EndIf

	SX3->(DbSkip())

EndDo

If Type("aMemos") == "A"
	For nX := 1 to Len(aMemos)
		cVar := aMemos[nX][1]
		If (PrefixoCpo(cAlias) $ cVar) .AND. !Empty((cAlias)->&(aMemos[nX][2]))
			M->&(aMemos[nX][1]) := MSMM((cAlias)->&(aMemos[nX][2]),TamSx3(aMemos[nX][1])[1])
		Else
			M->&(aMemos[nX][1]) := ""
		EndIf
	Next nX
EndIf

RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATA530   บAutor  ณMicrosiga           บ Data ณ  01/17/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ft530PutVl(oGet)

oGet:oBox:bWhen	:= {|| _lAlterou := .T.}

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATA530   บAutor  ณMicrosiga           บ Data ณ  01/18/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function aTreeIn(oTree,aTree,cSeekAdd,cCargo)

Local aTrack	:= {}

If aTree <> NIL
	aTreeSk(@aTree,cSeekAdd,@aTrack)
	AddTree(@aTree,cCargo,aTrack,Len(aTrack))
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATA530   บAutor  ณMicrosiga           บ Data ณ  01/18/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AddTree(aTree,cCargo,aTrack,nLenTrack,nPos)

Local nX		:= 0
Default nPos	:= 1

If Len(aTrack) > 0
	For nX := nPos to nLenTrack
		If nX == nLenTrack
			AAdd(aTree[aTrack[nX]][2], {cCargo,{}})
			Exit
		Else
			AddTree(@aTree[aTrack[nX]][2],cCargo,aTrack,nLenTrack,nPos+1)
			Exit
		EndIf
	Next nX
Else
	AAdd(aTree,{cCargo,{}})
EndIf    

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATA530   บAutor  ณMicrosiga           บ Data ณ  01/18/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function aTreeSk(aTree,cSeek,aTrack)

Local nX := 0

Default	aTrack	:= {}

For nX := 1 to Len(aTree)
	If aTree[nX][1] == cSeek
		AAdd(aTrack,nX)
		Return .T.
	Else
		If Len(aTree[nX][2]) > 0
			AAdd(aTrack,nX)
			If aTreeSk(@aTree[nX][2],cSeek,@aTrack)
				Return .T.
			Else
				aDel(aTrack,Len(aTrack))
				aSize(aTrack,Len(aTrack)-1)
			EndIf
		EndIf
	EndIf
Next nX

Return .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATA530   บAutor  ณMicrosiga           บ Data ณ  01/21/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft530AltTT(cAlias,nRecno,lSoma)

Local aArea		:= GetArea()
Local aAreaTmp	:= (cAlias)->(GetArea())
Local aAreaAF5	:= AF5->(GetArea())
Local cFilAF5	:= xFilial("AF5")
Local cPreProj	:= ""
Local cVersao	:= ""
Local cEdtPai	:= ""
Local nQuant	:= 0

DbSelectArea(cAlias)
DbGoTo(nRecno)

cPreProj	:= (cAlias)->&(PrefixoCpo(cAlias)+"_ORCAME")
cVersao 	:= (cAlias)->&(PrefixoCpo(cAlias)+"_VERSAO")
cEdtPai		:= (cAlias)->&(PrefixoCpo(cAlias)+"_EDTPAI")
nQuant		:= (cAlias)->&(PrefixoCpo(cAlias)+"_QUANT")

DbSelectArea("AF5")
DbSetOrder(5) //AF5_FILIAL+AF5_ORCAME+AF5_VERSAO+AF5_EDT

While !Empty(cEdtPai)
	If DbSeek(cFilAF5+cPreProj+cVersao+cEdtPai)	
		RecLock("AF5",.F.)
		If lSoma
			AF5->AF5_QUANT	+= nQuant
		Else
			AF5->AF5_QUANT	-= nQuant
		EndIf
		MsUnLock()
		cEDTPai	:= AF5->AF5_EDTPAI
	EndIf
End

RestArea(aAreaTmp)
RestArea(aAreaAF5)
RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530Prod บAutor  ณVendas Clientes     บ Data ณ  23/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTotaliza os produtos consumidos no projeto, calculando tras-บฑฑ
ฑฑบ          ณlado quando tais campos estiverem preenchidos.              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFata530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft530Prod(aHead,aCols,cProjet,lSomaAdic,cVersao)

Local aArea		:= GetArea()
Local aAreaAF2	:= AF2->(GetArea())
Local aAreaSB1	:= SB1->(GetArea())
Local cSeek		:= ""
Local bWhile	:= Nil 
Local bCond		:= Nil
Local aYesFields:= {"AF3_PRODUT","AF3_DESCRI","AF3_UM","AF3_QUANT","AF3_CUSTD"}
Local nX		:= 0
Local aColsTmp	:= {}
Local nPosProd	:= 0
Local nPosQtd	:= 0
Local nPosDesc	:= 0
Local nPosUm	:= 0
Local nPosCtd	:= 0
Local nPos		:= 0
Local aProds	:= {} 
Local nUsado	:= 0  
Local cFilSB1	:= xFilial("SB1")
Local cQuery	:= ""
Local lOrcSPms	:= SuperGetMV('MV_ORCSPMS',.F.,.F.)

Default aHead		:= {}
Default aCols		:= {}
Default cProjet		:= M->AF1_ORCAME
Default cVersao		:= M->AF1_VERSAO
Default	lSomaAdic	:= .T.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPosiciona a tabela de produtos do pre-projetoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
AF3->(DbSetOrder(5))	//AF3_FILIAL+AF3_ORCAME+ AF3_VERSAO+AF3_TAREFA+AF3_ITEM
AF3->(DbSeek(xFilial("AF3")+cProjet+cVersao))

AF2->(DbSetOrder(5))	//AF2_FILIAL+AF2_ORCAME+AF2_VERSAO+AF2_TAREFA+AF2_ORDEM


If lOrcSPms
	cQuery	:= "SELECT AF3_PRODUT, AF3_QUANT, AF3_CUSTD FROM " + RetSqlName("AF3") + " AF3 "
Else
	cQuery	:= "SELECT AF3_PRODUT,SUM(AF3_QUANT) AF3_QUANT FROM " + RetSqlName("AF3") + " AF3 "
EndIf
cQuery	+= "INNER JOIN " + RetSqlName("AF2") + " AF2 ON "
cQuery	+= "AF3.AF3_FILIAL = AF2.AF2_FILIAL AND AF3.AF3_ORCAME = AF2.AF2_ORCAME AND AF3.AF3_VERSAO = AF2.AF2_VERSAO AND AF3.AF3_TAREFA = AF2.AF2_TAREFA "
cQuery	+= "WHERE AF3.AF3_FILIAL = '" + xFilial("AF3") + "' AND AF3.AF3_ORCAME = '" + cProjet + "' AND AF3.AF3_VERSAO = '" + cVersao + "' "
cQuery	+= "AND AF2.AF2_STATUS = '1' "

If TcSrvType() != "AS/400"
	cQuery	+= "AND AF3.D_E_L_E_T_ = ' ' AND AF2.D_E_L_E_T_ = ' ' "
Else
	cQuery	+= "AND AF3.@DELETED@ = ' ' AND AF2.@DELETED@ = ' ' "
EndIf

If !lOrcSPms
	cQuery	+= "GROUP BY AF3_PRODUT "
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSoma os itens avulsosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lSomaAdic
	cQuery	+= "UNION ALL "
	If lOrcSPms
		cQuery	+= "SELECT AF3_PRODUT, AF3_QUANT, AF3_CUSTD "
	Else
		cQuery	+= "SELECT AF3_PRODUT,SUM(AF3_QUANT) AF3_QUANT "
	EndIf
	cQuery	+= "FROM " + RetSqlName("AF3") + " AF3 WHERE AF3.AF3_ORCAME = '" + cProjet + "' AND AF3.AF3_VERSAO = '" + cVersao + "' "
	cQuery	+= "AND AF3.D_E_L_E_T_ = ' ' AND AF3_TAREFA = ' ' AND AF3_FILIAL = '" + xFilial("AF3") + "' "
	If !lOrcSPms
		cQuery	+= "GROUP BY AF3_PRODUT "
	EndIf
EndIf

If (aHead == NIL) .OR. (Len(aHead) == 0) 
	aHead	:= Ft530Head("AF3",aYesFields)
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCarrega dados da tabela e agrupa quantidadesณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aProds	:= Ft530Cols(1,cSeek,bWhile,bCond,cQuery)

nPosProd	:= aScan(aHead,{|x|AllTrim(x[2]) == "AF3_PRODUT"	})
nPosQtd		:= aScan(aHead,{|x|AllTrim(x[2]) == "AF3_QUANT"	}) 
nPosDesc	:= aScan(aHead,{|x|AllTrim(x[2]) == "AF3_DESCRI"	}) 
nPosUm		:= aScan(aHead,{|x|AllTrim(x[2]) == "AF3_UM"		})
nPosCtd		:= aScan(aHead,{|x|AllTrim(x[2]) == "AF3_CUSTD"		})
nUsado		:= Len(aHead)

DbSelectArea("SB1")
DbSetOrder(1)

For nX := 1 to Len(aProds)
	
	SB1->(DbSeek(cFilSB1+aProds[nX][1]))
	
	Aadd( aColsTmp, Array(nUsado+1) )
	aColsTmp[nX][nPosProd]	:= aProds[nX][1]
	aColsTmp[nX][nPosQtd]	:= aProds[nX][2]
	aColsTmp[nX][nPosDesc]	:= SB1->B1_DESC
	aColsTmp[nX][nPosUm]	:= SB1->B1_UM
	If lOrcSPms
		aColsTmp[nX][nPosCtd]	:= aProds[nX][3]
	EndIf
	aColsTmp[nX][nUsado+1]	:= .F.
	
Next nX                   

aCols	:= aClone(aColsTmp)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAtualiza objetoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RestArea(aAreaAF2)
RestArea(aAreaSB1)
RestArea(aArea) 

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530Head บAutor  ณVendas Clientes     บ Data ณ  23/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria aHeader para o alias indicado no parametro             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ft530Head(cAlias,aCampos)

Local aArea		:= GetArea()
Local aHeader	:= {}
Local lCpoEsp	:= 	aCampos <> Nil

SX3->(dbSetOrder(1))
SX3->(dbSeek(cAlias))

While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cAlias
	
	If ( lCpoEsp .And. Ascan( aCampos,{|x| x==Rtrim(SX3->X3_CAMPO)} ) == 0 )
		SX3->(dbSkip())
		Loop
	EndIf
		
	Aadd( aHeader, {	Rtrim( SX3->(X3Titulo())), ;
						SX3->X3_CAMPO,; 
						SX3->X3_PICTURE,;
						SX3->X3_TAMANHO,;
						SX3->X3_DECIMAL,;
						SX3->X3_VALID, 	;
						SX3->X3_USADO,	;
						SX3->X3_TIPO, 	;
						SX3->X3_F3,;
						SX3->X3_CONTEXT ;
						} )
	
	SX3->(dbSkip())
End

RestArea(aArea)

Return aClone(aHeader)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATA530   บAutor  ณVendas Clientes     บ Data ณ  23/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta o acols contendo os produtos do modelo/proposta       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ft530Cols(nOrder,cSeek,bWhile,bCond,cQuery)

Local cAlias	:= "AF3"
Local aArea		:= GetArea()
Local aAreaSX3	:= SX3->(GetArea())
Local nPos		:= 0
Local aProds	:= {}
Local lOrcSPMS	:= SuperGetMV('MV_ORCSPMS',.F.,.F.)


If !Empty(cQuery)

	cAlias	:= "TMP"
	cQuery 	:= ChangeQuery( cQuery )
	
	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf
	
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias,.T.,.T.)
	DbGoTop()
	
	While !(cAlias)->(Eof())
		If lOrcSPMS
			Aadd( aProds, {(cAlias)->AF3_PRODUT,(cAlias)->AF3_QUANT,(cAlias)->AF3_CUSTD})
		Else
			If (nPos := aScan(aProds,{|x|x[1]== (cAlias)->AF3_PRODUT })) == 0
				Aadd( aProds, {(cAlias)->AF3_PRODUT,(cAlias)->AF3_QUANT})
			Else
				aProds[nPos][2] += (cAlias)->AF3_QUANT
			EndIf
		EndIf
		(cAlias)->(DbSkip())			
	End
	
	(cAlias)->(DbCloseArea())
	
Else  
  	
	(cAlias)->(DbSetOrder(nOrder))
	(cAlias)->(DbSeek(cSeek)) 
	
	While (cAlias)->(!Eof()) .AND. ( (cAlias)->(Eval( bWhile )) == cSeek )
		
		If (bCond <> Nil) .AND. (Eval(bCond))
			(cAlias)->(dbSkip())
			Loop
		EndIf
		
		If (nPos := aScan(aProds,{|x| x[1] == AF3->AF3_PRODUT})) == 0
			Aadd( aProds, {AF3->AF3_PRODUT,AF3->AF3_QUANT})
		Else
			aProds[nPos][2] += AF3->AF3_QUANT
		EndIF
		
		(cAlias)->(dbSkip())
	End


EndIf
 

RestArea(aAreaSX3)
RestArea(aArea)

Return aClone(aProds)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATA530   บAutor  ณMicrosiga           บ Data ณ  01/23/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ft530ChgIt(oTree,aTree,lJaGrav,lExcMult)

Local aArea		:= GetArea()
Local aTrack	:= {}
Local cCargo	:= oTree:GetCargo()
Local cAlias	:= SubStr(cCargo,1,3)
Local nRecno	:= Val(SubStr(cCargo,4,12))
Local nValAnt	:= 0
Local cPrefx	:= PrefixoCpo(cAlias)
Local cStatus	:= ""
Local cBmp		:= ""

Default	lJaGrav	:= .F.
If	!lExcMult

	If !lJaGrav 
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณSomente o duplo clique utiliza a rotina a seguirณ	
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		(cAlias)->(DbGoTo(nRecno))
		cStatus	:= (cAlias)->&(cPrefX+"_STATUS")
		
		RecLock(cAlias,.F.)
	
		Do Case
			Case cStatus == "1" .AND. Ft530VlPre(cAlias,nRecno,@aTree)	
				(cAlias)->&(cPrefX+"_STATUS")	:= "2"
				M->&(cPrefX+"_STATUS")	:= "2"
			Case cStatus == "2"  
				(cAlias)->&(cPrefX+"_STATUS")	:= "3"
				M->&(cPrefX+"_STATUS")	:= "3"
			Case cStatus == "3"
				(cAlias)->&(cPrefX+"_STATUS")	:= "1"
				M->&(cPrefX+"_STATUS")	:= "1"
		EndCase   
		MsUnLock()  
	
		If cAlias == "AF2".AND. AF2->AF2_STATUS == "1"		
			//Seleciona o pai se nao estiver marcado
			Ft530StPai(@oTree)
	 	EndIf
		
	EndIf

	If cAlias <> 'AF2'
		cBmp		:= Ft530Bmp(cAlias)
	Else
			cBmp		:= Ft530Bmp(cAlias)	
	EndIf
	
	oTree:ChangeBmp(cBmp,cBmp,oTree:GetCargo())
	
Endif	

RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATA530   บAutor  ณMicrosiga           บ Data ณ  01/23/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft530Bmp(cAlias)

Local cPrefx		:= PrefixoCpo(cAlias)
Local cRet			:= ""
Local lModelo		:= IsInCallStack("FATA530A")

If cAlias == "AF5"
	If lModelo
		cRet	:= EDT_INSTALADO
	Else
		Do Case
			Case (cAlias)->&(cPrefX+"_STATUS") == "1"
				cRet	:= EDT_INSTALADO
			Case (cAlias)->&(cPrefX+"_STATUS") == "2"
				cRet	:= EDT_NAOINSTAL
			Case (cAlias)->&(cPrefX+"_STATUS") == "3"
				cRet	:= EDT_PREINSTAL		
		EndCase
	EndIf
Else
	If lModelo
		cRet	:= TAR_INSTALADO
	Else
		Do Case
			Case (cAlias)->&(cPrefX+"_STATUS") == "1"
				cRet	:= TAR_INSTALADO
			Case (cAlias)->&(cPrefX+"_STATUS") == "2"
				cRet	:= TAR_NAOINSTAL
			Case (cAlias)->&(cPrefX+"_STATUS") == "3"
				cRet	:= TAR_PREINSTAL		
		EndCase
	EndIf
EndIf

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATA530   บAutor  ณMicrosiga           บ Data ณ  01/24/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ft530Copia(cModelo,cProposta,cNextEdt,cEdtPai,nNivel,cEdtDest,aQlEDT,lCpaPrj,cVerMod,cVersao)

Local aArea			:= GetArea()
Local aAreaAF5		:= AF5->(GetArea())
Local aAreaAF2		:= AF2->(GetArea())
Local aAreaAF3		:= AF3->(GetArea())
Local aAreaAF7		:= AF7->(GetArea())
Local nRecAF5		:= 0
Local nRecRet		:= 0
Local nRecBkp		:= 0   
Local cFilADX		:= xFilial("ADX")
Local cFilAF5		:= xFilial("AF5")
Local cFilAF3		:= xFilial("AF3")
Local cEdtAtu		:= "" 
Local cEdtDstTar	:= ""
Local cSufixo		:= ""
Local cTarBco		:= Space(TamSx3("AF3_TAREFA")[1])
Local cTarOri		:= ""
Local aValores		:= {}
Local nX			:= 0
Local nCont			:= 0
Local nFields		:= 0 
Local cDelim		:= Iif(Empty(AF1->AF1_DELIM),GetMv("MV_AF1DELI",,"."),AllTrim(AF1->AF1_DELIM))
Local aTarDP		:= {}
Local cMemoTxt		:= "" 
Local lExistCpOr	:= AF5->(FieldPos("AF5_MODORI")) > 0
Local cValMod 		:= "OK"
local lContProcesso := .T.
Local nLi			:= 1
Local nPosMdl		:= 0

Default cModelo	:= ""
Default	cEdtPai	:= "" 
Default cEdtDest:= ""
Default nNivel	:= 2
Default aQlEDT	:= {}
Default lCpaPrj	:= .F.

cValMod := ValModel(cFilAF5,cModelo,cNextEdt,cVerMod)

If cValMod == "E"
	Aviso(STR0026, STR0076, {"Ok"}, 2)
ElseIf cValMod == "T"
	Aviso(STR0026, STR0077 + cModelo + STR0078, {"Ok"}, 2)// "Opcao invalida."##"O Tamanho do modelo "##" ้ maior do que o suportado pelo grupo de campos EDT/Tarefa"
EndIf
If cValMod <> "OK"
	Return nRecRet
EndIf

cVerMod := A530ModVer( cModelo )

If Empty (cVerMod)
	cVerMod := " "
Endif 
//AF5_FILIAL+AF5_ORCAME+AF5_VERSAO+AF5_EDTPAI+AF5_ORDEM
If AF5->(DbSeek(cFilAF5+cModelo+cVerMod+cEdtPai))
	
	If IsInCallStack("Ft530VerAF1")
		M->AF5_ORCAME	:= AF1->AF1_ORCAME
		M->AF5_VERSAO	:= AF1->AF1_VERSAO 
	EndIf	
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPercorre EDTsณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤู
	While  AF5->AF5_FILIAL	== cFilAF5	.AND. AF5->AF5_ORCAME	== cModelo .AND. AF5->AF5_VERSAO	== cVerMod .AND. AllTrim(AF5->AF5_EDTPAI) == cEdtPai .AND. !AF5->(Eof())
	
		cEdtOr := AF5->AF5_EDT
	
		nCont++
		     
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCopia da EDTณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤู
		nRecBkp		:= AF5->(Recno())
		aValores	:= {}
		nFields		:= AF5->(FCount())
		
		For nX := 1 to nFields
			AAdd(aValores,{AF5->(FieldName(nX)),AF5->(FieldGet(nX))})
		Next nX
	                                                 
		If (nNivel == 2)
			Ft530CpPrg("2",cModelo,"3",M->AF5_ORCAME,,cNextEdt,.T.,cVerMod,cVersao)
		Else
			Ft530CpPrg("2",cModelo,"3",M->AF5_ORCAME,AF5->AF5_EDT,cNextEdt,.T.,cVerMod,cVersao)
		EndIf
		
		If	Len(aQlEDT) > 0
		
			nPosMdl := Ascan(aQlEDT,Alltrim(AF5->AF5_EDT))
			
			If	nPosMdl > 0
				cCdETD := Alltrim(aQlEDT[nPosMdl])
			Else 
				cCdETD := "**"				
			Endif 		
	
			If	nNivel == 2 .OR. Alltrim(AF5->AF5_EDT) == cCdETD 
				RecLock("AF5",.T.)                          
				
				//Copia campos do registro original
				For nX := 1 to nFields
					Replace AF5->&(aValores[nX][1]) With(aValores[nX][2])
				Next nX	                           
						
				//Altera campos de amarracao da estrutura
				Replace AF5->AF5_ORCAME	With M->AF5_ORCAME
				Replace AF5->AF5_VERSAO	With cVersao
				Replace AF5->AF5_EDT	With cNextEdt
				Replace AF5->AF5_EDTPAI	With cEdtDest
				Replace AF5->AF5_NIVEL	With StrZero(nNivel,TamSX3("AF5_NIVEL")[1])
				
				//Grava codigo do modelo original
				If (nNivel == 2) .AND. lExistCpOr
					Replace AF5->AF5_MODORI	With cModelo
					cModOri		:= cModelo
				Else 
					Replace AF5->AF5_EDTORI	With cEdtOr
				EndIf
					
				MsUnLock()
		
			Else
	
				dbSelectArea("AF5")
				AF5->(DbGoTo(nRecBkp))
				dbSkip()
				Loop
			
			Endif 
			
		Else 
		RecLock("AF5",.T.)
			
			//Copia campos do registro original
			For nX := 1 to nFields
				Replace AF5->&(aValores[nX][1]) With(aValores[nX][2])
			Next nX
				
			//Altera campos de amarracao da estrutura
			Replace AF5->AF5_ORCAME	With M->AF5_ORCAME
			Replace AF5->AF5_VERSAO	With cVersao
			Replace AF5->AF5_EDT	With cNextEdt
			Replace AF5->AF5_EDTPAI	With cEdtDest
			Replace AF5->AF5_NIVEL	With StrZero(nNivel,TamSX3("AF5_NIVEL")[1])
	
			//Grava codigo do modelo original
			If (nNivel == 2) .AND. lExistCpOr
				Replace AF5->AF5_MODORI	With cModelo
				cModOri		:= cModelo			
			Else 
				Replace AF5->AF5_EDTORI	With cEdtOr
			EndIf
			
		MsUnLock()
		
		Endif 
		nRecRet	:= AF5->(Recno())
		AF5->(DbGoTo(nRecBkp))
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCopia EDT's filhas, se encontrarณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cEdtAtu	:= AF5->AF5_EDT
		nRecAF5	:= AF5->(Recno())
		cSufixo	:= cDelim + StrZero(nCont,Val(SubStr(AF1->AF1_MASCAR,nNivel-1,1)))
		
		If	AF5->(DbSeek(cFilAF5+cModelo+cVerMod+cEdtAtu))
	
			Ft530Copia(cModelo,cProposta,cNextEdt+cSufixo,AllTrim(cEdtAtu),nNivel+1,cNextEdt,aQlEDT,,cVerMod,cVersao) 
								
		EndIf
	
		//Retorna ao registro original para leitura
		AF5->(DbGoTo(nRecAF5))
		
		If	Len(aQlEDT) > 0 	
		
			nPosMdl := Ascan(aQlEDT,Alltrim(AF5->AF5_EDT))
		
			If	nPosMdl > 0
				cCdETD := Alltrim(aQlEDT[nPosMdl])
			Else 
				cCdETD := "**"				
			Endif 
	
			If	Alltrim(AF5->AF5_EDT) == cCdETD
				lContProcesso := .T.		
			Else
				lContProcesso := .F.
			Endif 
			
		Else 
			lContProcesso := .T.		
		
		Endif
		
		If	lContProcesso 
		
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณPercorre tarefasณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			AF2->(DbSeek(cFilAF5+cModelo+cVerMod+AF5->AF5_EDT))
			
			//Zera o sufixo para utilizacao nas tarefas
			cSufixo	:= cDelim + StrZero(1,Val(SubStr(AF1->AF1_MASCAR,nNivel-1,1)))
			
			cEDTOAF2 := ""		
			
			While AF2->AF2_FILIAL	== cFilAF5	.AND.;
				AF2->AF2_ORCAME	== cModelo	.AND.;
				AF2->AF2_VERSAO	== cVerMod	.AND.;
				AF2->AF2_EDTPAI	== AF5->AF5_EDT .AND. !AF2->(Eof()) 
				
				
				cEDTOAF2 	:= AF2->AF2_TAREFA
	
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณCopia da tarefaณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				nRecBkp		:= AF2->(Recno())
				aValores	:= {}
				nFields		:= AF2->(FCount())
				cTarOri		:= AF2->AF2_TAREFA
		
				//Armazena codigo novo e antigo da tarefa, para atualizar a tabela de predecessoras
				
				AAdd(aTarDP,{cTarOri,cNextEdt+cSufixo})
			
				For nX := 1 to nFields
					AAdd(aValores,{AF2->(FieldName(nX)),AF2->(FieldGet(nX))})
				Next nX       
				
				Ft530VlTar(@aValores,M->AF5_ORCAME,cVersao)
			
				RecLock("AF2",.T.)
				
					For nX := 1 to nFields
						Replace AF2->&(aValores[nX][1]) With(aValores[nX][2])
					Next nX	
					
					Replace AF2->AF2_MODORI With cModOri
		            Replace AF2->AF2_EDTORI With cEDTOAF2
					Replace AF2->AF2_ORCAME	With M->AF5_ORCAME
					Replace AF2->AF2_VERSAO	With cVersao
					Replace AF2->AF2_TAREFA	With cNextEdt+cSufixo
					Replace AF2->AF2_EDTPAI	With cNextEdt 
					Replace AF2->AF2_NIVEL	With StrZero(nNivel,TamSX3("AF2_NIVEL")[1])
					
				MsUnLock() 
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณIncorpora perguntas do modeloณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				Ft530CpPrg("2",cModelo,"3",M->AF5_ORCAME,cTarOri,AF2->AF2_TAREFA,,cVerMod,cVersao)
		
				AF2->(DbGoTo(nRecBkp))
			
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณCopia produtosณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				AF3->(DbSetOrder(5))//AF3_FILIAL+AF3_ORCAME+AF3_VERSAO+AF3_TAREFA+AF3_ITEM
				AF3->(DbSeek(cFilAF5+cModelo+cVerMod+AF2->AF2_TAREFA))
			
				While AF3->AF3_FILIAL	== cFilAF5	.AND.;
					AF3->AF3_ORCAME	== cModelo	.AND.;
					AF3->AF3_VERSAO	== cVerMod	.AND.;
					AF3->AF3_TAREFA	== AF2->AF2_TAREFA .AND. !AF3->(Eof())
				
					nRecBkp		:= AF3->(Recno())
					aValores	:= {}
					nFields		:= AF3->(FCount())
				
					For nX := 1 to nFields
						AAdd(aValores,{AF3->(FieldName(nX)),AF3->(FieldGet(nX))})
					Next nX  
				
					RecLock("AF3",.T.)
		
						For nX := 1 to nFields
							Replace AF3->&(aValores[nX][1]) With(aValores[nX][2])
						Next nX	
	
						Replace AF3->AF3_ORCAME	With M->AF5_ORCAME
						Replace AF3->AF3_VERSAO	With cVersao
						Replace AF3->AF3_TAREFA	With cNextEdt+cSufixo
					MsUnLock() 
		
					AF3->(DbGoTo(nRecBkp))   			
					AF3->(DbSkip())
				
				End
			                  
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณCopia predecessorasณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
				//AF7_FILIAL+AF7_ORCAME+AF7_VERSAO+AF7_TAREFA+AF7_ITEM
				AF7->(DbSeek(cFilAF5+cModelo+cVerMod+AF2->AF2_TAREFA))
				
				While AF7->AF7_FILIAL	== cFilAF5	.AND.;
					AF7->AF7_ORCAME	== cModelo	.AND.;
					AF7->AF7_VERSAO	== cVerMod	.AND.;
					AF7->AF7_TAREFA	== AF2->AF2_TAREFA .AND. !AF7->(Eof())
					
					nRecBkp		:= AF7->(Recno())
					aValores	:= {}
					nFields		:= AF7->(FCount())
					
					For nX := 1 to nFields
						AAdd(aValores,{AF7->(FieldName(nX)),AF7->(FieldGet(nX))})
					Next nX  
					
					RecLock("AF7",.T.)
		
						For nX := 1 to nFields
							Replace AF7->&(aValores[nX][1]) With(aValores[nX][2])
						Next nX	
		
						Replace AF7->AF7_ORCAME	With M->AF5_ORCAME
						Replace AF7->AF7_VERSAO	With cVersao
						Replace AF7->AF7_TAREFA	With cNextEdt+cSufixo 
						Replace AF7->AF7_PREDEC With SubsTr(cSufixo,2,2)+"."+AF7->AF7_PREDEC
					//Substitui a tarefa predecessora antiga com o valor correto
					//If (nX := aScan(aTarDP,{|x|x[1] == AF7->AF7_PREDEC})) <> 0
						//Replace AF7->AF7_PREDEC With aTarDP[nX][2]
					//EndIf       
					
					MsUnLock() 
			
					AF7->(DbGoTo(nRecBkp))   			
					AF7->(DbSkip())
					
				End
			        
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณCopia componentesณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
				//ADX_FILIAL+ADX_ORCAME+ADX_VERSAO+ADX_TAREFA+ADX_ITEM
				ADX->(DbSetOrder(2))
				ADX->(DbSeek(cFilADX+cModelo+cVerMod+AF2->AF2_TAREFA))
			
				While ADX->ADX_FILIAL	== cFilADX	.AND.;
					ADX->ADX_ORCAME	== cModelo	.AND.;
					ADX->ADX_VERSAO	== cVerMod	.AND.;
					ADX->ADX_TAREFA	== AF2->AF2_TAREFA .AND. !ADX->(Eof())
					
					nRecBkp		:= ADX->(Recno())
					aValores	:= {}
					nFields		:= ADX->(FCount())
					
					//Le o memo, se existir
					cMemoTxt	:= If(Empty(ADX->ADX_CODMEM),"",Msmm(ADX->ADX_CODMEM))
					
					For nX := 1 to nFields
						AAdd(aValores,{ADX->(FieldName(nX)),ADX->(FieldGet(nX))})
					Next nX  
				
					RecLock("ADX",.T.)
						For nX := 1 to nFields
							Replace ADX->&(aValores[nX][1]) With(aValores[nX][2])
						Next nX
						Replace ADX->ADX_QTDORI	With ADX->ADX_QUANT
						Replace ADX->ADX_ORCAME	With M->AF5_ORCAME
						Replace ADX->ADX_VERSAO	With cVersao
						Replace ADX->ADX_TAREFA	With cNextEdt+cSufixo
						Replace ADX->ADX_CODMEM	With ""
						Replace ADX->ADX_PROORI	With cModelo
					MsUnLock()
					
					//Importa o memo  
					If !Empty(cMemoTxt)
						MSMM(ADX->ADX_CODMEM,,,cMemoTxt,1,,,"ADX","ADX_CODMEM")
					EndIf
			
					ADX->(DbGoTo(nRecBkp))   			
					ADX->(DbSkip())
					
				End
	
				nPos := Rat(cDelim,cSufixo) 
				cSufixo	:= If(nPos>0,cDelim,"")+Soma1(SubStr(cSufixo,If(nPos>0,nPos+1,1),Len(cSufixo)))
	
				AF2->(DbSkip())
	
			End
		
	
		Endif 
	         
		nPos := Rat(cDelim,cNextEdt)
		cNextEdt := Iif(nPos>0,(SubStr(cNextEdt,1,nPos-1) + cDelim),"") + Soma1(SubStr(cNextEdt,nPos+1,Len(cNextEdt)))
		
		AF5->(DbSkip())
	
	End
	
	If nNivel == 2 //So executa 1 vez
		
		//Le quantos produtos adicionais ja existem
			nProdAtu := Ft530CntPA(M->AF5_ORCAME,cVersao)
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCopia produtos comuns ao projeto, sem vinculo com tarefasณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		AF3->(DbSetOrder(5))//AF3_FILIAL+AF3_ORCAME+AF3_VERSAO+AF3_TAREFA+AF3_ITEM
		AF3->(DbSeek(cFilAF5+cModelo+cVerMod))
		
		While !AF3->(Eof()) .AND.;
			AF3->AF3_FILIAL	== cFilAF5	.AND.;
			AF3->AF3_ORCAME	== cModelo	.AND.;
			AF3->AF3_VERSAO	== cVerMod	.AND.;
			Empty(AF3->AF3_TAREFA)
			
			aValores	:= {}
			nRecBkp		:= AF3->(Recno())
			nFields		:= AF3->(FCount())
			
			For nX := 1 to nFields
				AAdd(aValores,{AF3->(FieldName(nX)),AF3->(FieldGet(nX))})
			Next nX  
			
			AF3->(DbSetOrder(6)) //AF3_FILIAL+AF3_ORCAME+AF3_VERSAO+AF3_PRODUT+AF3_TAREFA
			If !AF3->(DbSeek(cFilAF3+M->AF5_ORCAME+M->AF5_VERSAO+AF3->AF3_PRODUT+cTarBco))		
				RecLock("AF3",.T.)
					For nX := 1 to nFields
						Replace AF3->&(aValores[nX][1]) With(aValores[nX][2])
					Next nX	
					Replace AF3->AF3_ORCAME	With M->AF5_ORCAME
					Replace AF3->AF3_VERSAO	With cVersao
					Replace AF3->AF3_TAREFA	With ""
					Replace AF3->AF3_ITEM	With StrZero(++nProdAtu,2)
				MsUnLock() 
			Else
				RecLock("AF3",.F.)
					Replace AF3->AF3_QUANT	With AF3->AF3_QUANT + aValores[aScan(aValores,{|x|AllTrim(x[1])=="AF3_QUANT"})][2]
				MsUnLock()
			EndIf
			
			AF3->(DbSetOrder(1))
			AF3->(DbGoTo(nRecBkp))   			
			AF3->(DbSkip())
		
		End
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณIncorpora perguntas do modeloณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Ft530CpPrg("2",cModelo,"3",M->AF5_ORCAME,,,,cVerMod,cVersao)
		
	EndIf
EndIf
RestArea(aAreaAF2)
RestArea(aAreaAF7)
RestArea(aAreaAF3)
RestArea(aAreaAF5) 
RestArea(aArea)

Return nRecRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATA530   บAutor  ณMicrosiga           บ Data ณ  12/18/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ValModel(cFilAF5,cModelo,cNextEdt,cVerMod)
Local aArea		:= GetArea()
Local cQuery	:= ""
Local cExisERR	:= "OK"
Local nTamEDT	:= TAMSX3("AF5_EDT")[1]
Local nTamDEL	:= TAMSX3("AF1_DELIM")[1]


	cQuery := "SELECT COUNT(*) QTDE "
	cQuery += "FROM "+RetSQLName("AF5")+" AF5 "
	cQuery += "WHERE AF5.AF5_FILIAL = '" + cFilAF5 + "'"
	cQuery += "  AND SUBSTRING(AF5.AF5_EDT,1,3) = 'ERR'"
	cQuery += "  AND AF5.AF5_ORCAME = '" + cModelo + "'"
	cQuery += "  AND AF5.AF5_VERSAO = '" + cVerMod + "'"
	cQuery += "  AND AF5.D_E_L_E_T_ = ' '"

	cQuery	:= ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TRBAF5', .F., .T.)

	cExisERR := IIf(TRBAF5->QTDE > 0,"E",cExisERR)
	
	TRBAF5->(dbCloseArea())

	If cExisERR == "OK"
		cQuery := " SELECT AF5_EDT "
		cQuery += "	  FROM "+RetSQLName("AF5")+" AF51 "
		cQuery += " WHERE AF51.D_E_L_E_T_ = ' ' "
		cQuery += "   AND AF5_FILIAL = '" + cFilAF5 + "' "
		cQuery += "   AND AF5_ORCAME = '" + cModelo + "'"
		cQuery += "   AND AF5_VERSAO = '" + cVerMod + "'"
		cQuery += "   AND AF5_NIVEL = (SELECT MAX(AF5_NIVEL) FROM " + RetSQLName("AF5") + " AF52 "
		cQuery += "                     WHERE AF52.D_E_L_E_T_ = ' ' "
		cQuery += "                       AND AF51.AF5_FILIAL = AF52.AF5_FILIAL "
		cQuery += "                       AND AF51.AF5_ORCAME = AF52.AF5_ORCAME "
		cQuery += "                       AND AF51.AF5_VERSAO = AF52.AF5_VERSAO) "
	
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TRBAF5', .F., .T.)
		
		cExisERR := IIF(Len( AllTrim(TRBAF5->AF5_EDT) ) + nTamDEL > nTamEDT,"T",cExisERR)
		
		TRBAF5->(dbCloseArea())
		
	EndIf

RestArea(aArea)
 
Return cExisERR


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATA530   บAutor  ณMicrosiga           บ Data ณ  01/24/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ft530NwEdt()

Local aArea		:= GetArea()
Local aAreaAF5	:= AF5->(GetArea())
Local cFilAF5	:= xFilial("AF5")
Local cEDT		:= "" 
Local cMasc		:= GetMv("MV_AF1MASC",,"2222222222")

If IsInCallStack("Ft530VerAF1")
	DbSelectArea("AF1")
	AF1->(DbSetOrder(8))	//AF5_FILIAL+AF5_ORCAME+AF5_VERSAO+AF5_EDTPAI+AF5_ORDEM
	AF1->(DbSeek(cFilAF5+AF1->AF1_ORCAME+AF1->AF1_VERSAO+AF1->AF1_ORCAME)) 
	M->AF1_ORCAME	:= AF1->AF1_ORCAME
		M->AF1_VERSAO	:= AF1->AF1_VERSAO 
EndIf	

AF5->(DbSetOrder(6))	//AF5_FILIAL+AF5_ORCAME+AF5_VERSAO+AF5_EDTPAI+AF5_ORDEM
AF5->(DbSeek(cFilAF5+M->AF1_ORCAME+M->AF1_VERSAO+M->AF1_ORCAME))

While !AF5->(Eof())	 					.AND.;
	AF5->AF5_FILIAL == cFilAF5 			.AND.;
	AF5->AF5_ORCAME == M->AF1_ORCAME	.AND.;
	AF5->AF5_VERSAO == M->AF1_VERSAO	.AND.;
	(AllTrim(AF5->AF5_EDTPAI) == AllTrim(M->AF1_ORCAME))
	
	If AF5->AF5_EDT > cEDT
		cEDT	:= AllTrim(AF5->AF5_EDT)
	EndIf
	AF5->(DbSkip())
End

If Empty(cEdt)
	If Empty(AF1->AF1_MASCAR)
		cEdt	:= Replicate("0",Val(SubStr(cMasc,0,1)))
	Else
		cEdt	:= Replicate("0",Val(SubStr(AF1->AF1_MASCAR,0,1)))
	EndIf
EndIf

cEDT := Soma1(cEdt)

RestArea(aAreaAF5)
RestArea(aArea)           

Return cEdt

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATA530   บAutor  ณMicrosiga           บ Data ณ  01/25/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ft530ImpMd(oTree,aTree,nOpcX,aLBox)

Local lRet		:= .T.
Local aArea		:= GetArea()
Local aAreaAF1	:= AF1->(GetArea())
Local aDummy	:= {}
Local aCols		:= {}
Local lIncBkp	:= INCLUI
Local lAltBkp	:= ALTERA
Local nX		:= 0 
Local nImportar	:= 0
Local nL		:= 0

Local oPesq
Local cPesq		:= ""

Local oOk		:= LoadBitmap( GetResources(), "LBOK" )
Local oNo		:= LoadBitmap( GetResources(), "LBNO" )
Local oBtnB		:= Nil
Local oBtnP		:= Nil
Local nOpcEsc   := 1
Local aBkpItens :={}
Local lModelo	:= IsInCallStack("FATA530A")

cPesq := Space(TamSx3("AF1_DESCRI")[1])

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Adicionado opcao para que o usuario selecione a forma de carregar o projeto:ณ
//ณ  1 - Completo (projeto inteiro)                                             ณ
//ณ  2 - Manual (pode ser carregado partes do projeto)                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nOpcEsc := Aviso(STR0054,STR0092,{STR0093,STR0094,STR0095}) //"Aten็ใo"###"Selecione a forma desejada para carregar o projeto"###{"Completo","Manual","Cancelar"}

If	nOpcEsc == 1
	For nX := 1 to Len(aLBox)
		If aLBox[nX][1]
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Verifica se o modelo ja foi importado, nao permite duplicar ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			oTree:TreeSeek(aTree[1][1])		//Posiciona a arvore na raiz principal
			If aScan(oTree:aNodes,{|x|AllTrim(Upper(x[4])) == AllTrim(Upper(aLBox[nX][4]))}) <> 0
				MsgAlert(STR0056 + aLBox[nX][4]+ STR0057,STR0054)	//"O Modelo "###" j๏ฟฝ foi importado"###"Aten๏ฟฝ๏ฟฝo"
				lRet := .F.
				Exit
			Else
				nImportar++ 
			EndIf
		EndIf
	Next nX

	If	lRet .AND. (nImportar > 0)
	
		For nX := 1 To Len(aLbox)
			//Realiza a copia   
			If aLBox[nX][1]
				FTA530Tree(@oTree,@aTree,,.F.,,aLBox[nX][2],,,aLBox[nX][3])
			EndIf
		Next nX
	             
	
		//Altera as variaveis de tipo de operacao	
		INCLUI	:= .F.
		ALTERA	:= .T. 	
		
		//Atualiza objeto com produtos adicionais
		FillGetDados(4,"AF3",1,xFilial("AF3")+M->AF1_ORCAME+M->AF1_VERSAO,{||AF3->AF3_FILIAL+AF3->AF3_ORCAME+AF3_VERSAO},;
			{||Empty(AF3->AF3_TAREFA)},{"AF3_FATOR","AF3_COMPOS","AF3_CALCTR","AF3_TURNO"},,,,,,@aDummy,@aCols)	
			
		//Inicializa o campo AF3_ITEM se estiver em branco
		nX	:=  aScan(aDummy,{|x|AllTrim(x[2]) == "AF3_ITEM"})
		If (nX > 0) .AND. (Len(aCols) == 1) .AND. Empty(aCols[1][nX])
			aCols[1][nX]	:= "01"
		EndIf
		
		//Atualiza o objeto
		aObj[3][6]:SetArray(aCols,.T.)
		aObj[3][6]:Refresh()
		
		//Atualiza total de produtos
		aDummy	:= {}  
		aCols	:= {}
		Ft530Prod(aDummy,@aCols)
		aObj[3][5]:SetArray(aCols,.T.)
		aObj[3][5]:Refresh()
		
		//Restaura valores anteriores
		INCLUI	:= lIncBkp
		ALTERA	:= lAltBkp  
	                   
	EndIf
	
ElseIf	nOpcEsc == 2 
									
		aClsMnu := {}
		
		For nL:=1 To Len(aLBox)                     
	
			If	aLBox[nL,1]
				aadd(aClsMnu,{.F.,aLBox[nL,4],aLBox[nL,2],aLBox[nL,3] })
			Endif 
	
		Next nL
		
		aClsItm := {}	
	
		If	Len(aClsMnu) == 1
			aClsMnu[1][1] := .T. 	
			aClsItm := Ft530SlManual(aClsMnu[1][3])
		Else 
			aadd(aClsItm,{.F.,"","","",""})
		Endif 
	
		DEFINE MSDIALOG oDlg TITLE STR0096 FROM 178,181 TO 600,915 PIXEL //"Sele็ใo manual"
		
			// Cria as Groups do Sistema
			@ 002,003 TO 160,315 LABEL STR0064 PIXEL OF oDlg //"Selecione o(s) modelo(s) desejados para inclusใo:"
			@ 165,003 TO 200,315 LABEL STR0065 PIXEL OF oDlg //"Pesquisa pelo nome:"
	
			//	
			@ 012,008 ListBox oClsMnu Fields HEADER "",STR0047; //"Codigo"###"Codigo"
				Size 150,140 Of oDlg Pixel ON;
		 DblClick(aClsMnu[oClsMnu:nAt,1] := !aClsMnu[oClsMnu:nAt,1],aClsItm[oClsItm:nAT,03] == aClsMnu[oClsMnu:nAT,03] , aClsItm := aClone( Ft530SlItens(aClsMnu[oClsMnu:nAT,03],aClsMnu,aClsItm,oClsItm,aBkpItens) ) , oClsItm:Refresh(), oClsItm:SetFocus() )
				
			//	
			@ 012,160 ListBox oClsItm Fields HEADER "",STR0047; //"Codigo"###"Codigo"
				Size 149,140 Of oDlg Pixel ON DblClick(aClsItm[oClsItm:nAt,1] := !aClsItm[oClsItm:nAt,1], Ft530DbClick(aClsItm,oClsItm,aClsItm[oClsItm:nAt,1],aClsItm[oClsItm:nAT,04]), oClsItm:Refresh(), oClsItm:SetFocus() )
				
			oClsMnu:SetArray(aClsMnu)
			oClsMnu:bLine := {||{	Iif(aClsMnu[oClsMnu:nAt,1],oOk,oNo),;
							 		aClsMnu[oClsMnu:nAT,02],;
							 		aClsMnu[oClsMnu:nAT,03] }}
							 		
			If	Len(aClsMnu) == 1
				oClsItm:Refresh()
				oClsItm:SetFocus()
			Endif
									
			oClsItm:SetArray(aClsItm)
			oClsItm:bLine := {||{	Iif(aClsItm[oClsItm:nAt,1],oOk,oNo),;
							 		aClsItm[oClsItm:nAT,02],;
							 		aClsItm[oClsItm:nAT,03]	,;
							 		aClsItm[oClsItm:nAT,04],;
							 		aClsItm[oClsItm:nAT,05] }}
		
			@ 178,008 MsGet oPesq Var cPesq Size 200,009 COLOR CLR_BLACK PIXEL OF oDlg Valid Ft530SkLbx(aClsItm,@oClsItm,cPesq)
		
			DEFINE SBUTTON FROM 005,330 TYPE 1 ENABLE OF oDlg Action (Ft530IpManul(@oTree,@aTree,aClsMnu,aClsItm),oDlg:End())
			DEFINE SBUTTON FROM 022,330 TYPE 2 ENABLE OF oDlg Action oDlg:End()
		
			@ 178,215 Button oBtnB Prompt STR0031 Size 40,10 Pixel Action Ft530SkLbx(aClsItm,@oClsItm,cPesq) Message STR0067 Of oDlg	 //"Pesquisar"###"Pesquisa o texto digitado"
			@ 178,260 Button oBtnB Prompt STR0068 Size 40,10 Pixel Action Ft530SkLbx(aClsItm,@oClsItm,cPesq,@oLBox:nAt) Message STR0067 Of oDlg //"Pr๓ximo"###"Pesquisa o texto digitado"
		
		
		ACTIVATE MSDIALOG oDlg CENTERED 	
Else 
	
	lRet := .T.	

Endif 

RestArea(aAreaAF1)
RestArea(aArea)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATA530   บAutor  ณVendas clientes     บ Data ณ  28/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna os campos a serem exibidos na enchoice de acordo comบฑฑ
ฑฑบ          ณo alias                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft530Field(cAlias,lEnchoice,aFolders)

Local aArea		:= GetArea()					// Armazena o posicionamendo do alias atual
Local aAreaSX3	:= SX3->(GetArea())			// Armazena o posicionamento do SX3
Local aCampos	:= {}							// Lista de campos de retorno
Local cCposNao	:= "_STATUS"					// Sufixo dos campos que nao devem ser exibidos
Local cSufixo	:= ""							// Sufixo do campo
Local lChave	:= .F.							// Campo chave
Local lNAltera	:= .F.							// Campo nao alteravel
Local lObrigat	:= .F.							// Campo obrigatorio
Local lCondicao	:= .T.							// Indica se o campo pode ser incluido na lista de campos
Local lRemove	:= .F.							// Indica se o campo sera removido da lista de campos
Local aCpVisual	:= {}							// Campos que nao podem ser alterados
Local cX3CpTit	:= ""							// Campo do X3_TITULO em Port / Esp / Ing
Local cX3Campo	:= ""							// Campo do SX3

Default lEnchoice	:= .F.
Default aFolders	:= Nil

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRelacao de campos somente visuaisณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
AAdd(aCpVisual,"AF2_QUANT")
AAdd(aCpVisual,"AF5_QUANT")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณLista das pastas para o alias atualณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SXA")
DbSetOrder(1)
If DbSeek(cAlias)
	aFolders := {}
	While (!Eof()) .AND. (SXA->XA_ALIAS == cAlias)
		AAdd(aFolders,Capital(SXA->XA_DESCRIC))
		DbSkip()
	End
Else
	aFolders := Nil
EndIf

DbSelectArea("SX3")
DbSetOrder(4)//X3_ARQUIVO+X3_FOLDER+X3_ORDEM
DbSeek(cAlias)

While !SX3->(Eof()) .AND. SX3->X3_ARQUIVO == cAlias
	
	cSufixo		:= SubStr(SX3->X3_CAMPO,At("_",SX3->X3_CAMPO),10)
	lObrigat	:= VerByte(X3_RESERV,7) .OR. X3Obrigat(SX3->X3_CAMPO)
	lCondicao	:= (cNivel >= X3_NIVEL) .OR. lObrigat
	lRemove		:= IsInCallStack("FATA530A") .AND. (cSufixo $ cCposNao)
	
	If !X3Uso(SX3->X3_USADO) .OR. !lCondicao  .OR. lRemove
		SX3->(DbSkip())
		Loop
	EndIf 
	
	lChave	  := X3Chave(SX3->X3_USADO) 
	lNAltera  := X3Alteravel(SX3->X3_USADO)
	
	If lEnchoice
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณUtilizado para criacao da Enchoiceณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		AAdd(aCampos,SX3->X3_CAMPO)

	Else
		cX3CpTit := X3Titulo()
		cX3Campo := Alltrim(SX3->X3_CAMPO)
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณUtilizado para criacao da MsmGetณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		AAdd(aCampos,{;
			cX3CpTit				,;
			SX3->X3_CAMPO 			,;
			SX3->X3_TIPO   			,;
			SX3->X3_TAMANHO			,;
			SX3->X3_DECIMAL			,;
			SX3->X3_PICTURE			,;
			If(!Empty(SX3->X3_VALID),&("{||"+SX3->X3_VALID+"}"),""),;
			lObrigat	   			,;
			SX3->X3_NIVEL 			,;
			SX3->X3_RELACAO			,;
			SX3->X3_F3	   			,;
			If(!Empty(SX3->X3_WHEN),&("{||"+SX3->X3_WHEN+"}"),""),;
			If(aScan(aCpVisual,AllTrim(SX3->X3_CAMPO))>0,.T.,SX3->X3_VISUAL == "V"),;
			lChave		   			,;
			SX3->X3_CBOX  			,;
			Val(SX3->X3_FOLDER)		,;
			lNAltera	   			,;
			SX3->X3_PICTVAR			,;
			Iif(cX3Campo == "AF2_BDI" .OR. cX3Campo == "AF2_VALBDI","S","N")}) //Indiga se deve disparar o gatilho do campo.
	
	EndIf
	
	SX3->(DbSkip())   
	
End

If Len(aCampos) == 0
	aCampos	:= NIL
EndIf

RestArea(aAreaSX3)
RestArea(aArea)

Return aCampos

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530CountบAutor  ณVendas Clientes     บ Data ณ  28/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ft530Count(cAlias,cChave,nIndex,cWhile)

Local nCont		:= 0
Local aArea		:= GetArea()
Local aAreaAlias:= (cAlias)->(GetArea())
Local nLenChave	:= 0
Local bWhile	:= Nil
Local cQuery	:= ""
Local aCampos	:= Nil  

cChave		:= RTrim(cChave)
nLenChave	:= Len(cChave)

DbSelectArea(cAlias)
DbSetOrder(nIndex)
DbSeek(cChave)


aCampos	:= StrTokArr(cWhile,"+")

cQuery	:= " SELECT COUNT(*) AS TOTREC FROM " + RetSqlName(cAlias)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRemove deletadosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If TcSrvType() != "AS/400"
	cQuery	+= " WHERE D_E_L_E_T_ = ' ' "
Else
	cQuery	+= " WHERE @DELETED@ = ' ' "
EndIf
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFiltro dos camposณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nCont	:= 1 to Len(aCampos)
	aCampos[nCont]	:= SubStr(aCAmpos[nCont],At("->",aCAmpos[nCont])+2,15)
	cQuery	+= " AND " + aCampos[nCont] + " = '" + (cAlias)->&(aCampos[nCont]) + "' "
Next nCont

nCont	:= 0

cQuery := ChangeQuery( cQuery )

If Select("TMPCNT") > 0
	TMPCNT->(DbCloseArea())
EndIf

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TMPCNT",.F.,.T.)

nCont	:= 	TMPCNT->TOTREC

TMPCNT->(DbCloseArea())	

RestArea(aAreaAlias)
RestArea(aArea)
            
Return nCont

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATA530   บAutor  ณMicrosiga           บ Data ณ  01/29/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ft530SetIt(aTree,aTrack,oTree,cStatus,nNivel,aTmp)

Local aArea		:= {}
Local aAreaAF5	:= {}
Local cCargoBk	:= ""
Local cTrk		:= ""
Local nX   		:= 0
Local nLenTrk	:= 0 
Local cAlias	:= ""
Local cBmp		:= ""
Local aTrk		:= {}
Local nTotal	:= 0

Default nNivel	:= 1
Default	aTmp	:= {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAcessa o local alterado da arvoreณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nNivel == 1
	aArea		:= GetArea()
	aAreaAF5	:= AF5->(GetArea())
	nLenTrk		:= Len(aTrack)
	cCargoBk	:= oTree:GetCargo()
	nTotal		:= AF5->AF5_QUANT
	
	For nX := 1 to nLenTrk
		cTrk	:= "["+AllTrim(Str(aTrack[nX]))+"][2]"
		If nX == 1
			Eval(&("{|| aTmp := aTree"+cTrk+"}"))
		Else
			Eval(&("{|| aTmp := aTmp"+cTrk+"}"))
		EndIf
	Next nX  
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAltera os status e bmps dos itens filhos, recursivamenteณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nX := 1 to Len(aTmp)  
	
	cAlias	:= SubStr(aTmp[nX][1],1,3)
	oTree:TreeSeek(aTmp[nX][1])

	DbSelectArea(cAlias)
	DbGoTo(Val(SubStr(aTmp[nX][1],4,12)))
	RecLock(cAlias,.F.)
	(cAlias)->&(PrefixoCpo(cAlias)+"_STATUS") := cStatus
	MsUnLock()

	cBmp := Ft530Bmp(cAlias)
	oTree:ChangeBmp(cBmp,cBmp,oTree:GetCargo())
		
	If Len(aTmp[nX][2]) > 0	
		Ft530SetIt(aTree,aTrack,oTree,cStatus,nNivel+1,@aTmp[nX][2])
	EndIf
	
Next nX

If nNivel == 1  
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTotaliza projetoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	AF5->(DbSetOrder(1))	//AF5_FILIAL+AF5_ORCAME+AF5_EDT
	AF5->(DbGoTo(Val(SubStr(cCargoBk,4,12))))
	nQuant		:= AF5->AF5_QUANT

	RecLock("AF5",.F.)
	AF5->AF5_QUANT	:= 0
	MsUnLock()
	
	While !Empty(AF5->AF5_EDTPAI)
		cEdtPai := AF5->AF5_EDTPAI
		If AF5->(DbSeek(xFilial("AF5")+M->AF1_ORCAME+cEdtPai))
			RecLock("AF5",.F.)
			AF5->AF5_QUANT	-= nQuant
			MsUnLock() 
		EndIf
	End

	oTree:TreeSeek(cCargoBk)
	RestArea(aAreaAF5)
	RestArea(aArea)
	
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATA530   บAutor  ณMicrosiga           บ Data ณ  01/30/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ft530StPai(oTree)

Local aArea		:= GetArea()
Local aAreaAF5	:= AF5->(GetArea()) 
Local cEdtPai	:= ""
Local cCargo	:= oTree:GetCargo()
Local lRestaura	:= .F.

DbSelectArea("AF5")
DbSetOrder(1)
DbSeek(xFilial("AF5")+M->AF1_ORCAME+AF2->AF2_EDTPAI)

While !Empty(AF5->AF5_EDTPAI) .AND. AF5->AF5_STATUS <> "1" 

	RecLock("AF5",.F.)
	AF5->AF5_STATUS := "1"
	MsUnLock()      
	oTree:TreeSeek("AF5"+StrZero(AF5->(Recno()),12))
	cBmp := Ft530Bmp("AF5")
	oTree:ChangeBmp(cBmp,cBmp,oTree:GetCargo())
	cEdtPai := AF5->AF5_EDTPAI
	lRestaura	:= .T.

	AF5->(DbSeek(xFilial("AF5")+M->AF1_ORCAME+cEdtPai))

End	 

If lRestaura
	oTree:TreeSeek(cCargo)
EndIf
RestArea(aAreaAF5)		
RestArea(aArea)
                   
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATA530   บAutor  ณMicrosiga           บ Data ณ  02/05/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ft530Fold(oPanelGD,oDlg,nOpcx)

Local aArea		:= GetArea()
Local aTitles	:= {STR0058,STR0059,STR0060}//"Produtos"###"Predecessoras"###"Componentes"
Local nLeft     := oMainWnd:nLeft+10
Local nRight    := oMainWnd:nRight-10

Local nHResol	:=	oMainWnd:nClientHeight	 //Resolucao vertical do monitor

Local nLargura	:= (nRight-nLeft)/2-150
Local nAltura	:= ((oDlg:nBottom-oDlg:nTop)/2)-If(nHResol<847,220,350)
Local aHeadTmp	:= {}
Local aColsTmp	:= {}
Local nOpc		:= aRotina[nOpcX][4]
Local nGdOpc	:= 0
Local lCria		:= aObj[1][4] == Nil
Local nX		:= 0
Local lIncBk	:= INCLUI
Local lAltBk	:= ALTERA
Local lModelo	:= IsInCallStack("FATA530A")

If lCria
	aObj[1][4] := TFolder():New(If(nHResol<847,115,180),3,aTitles,{},oPanelGD,,,,.T.,.T.,nLargura,nAltura)
	aObj[1][4]:bSetOption:={|nFolder| A530SetOption(nFolder,aObj[1][4]:nOption) }
EndIf

nGdOpc 		:= IIf(INCLUI .OR. ALTERA,GD_INSERT+GD_UPDATE+GD_DELETE,0)

ALTERA	:= .T.
INCLUI	:= .F. 
nOpc	:= 4

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta GetDados dos produtosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cSeek 	:= 	xFilial("AF3")+M->AF2_ORCAME+M->AF2_VERSAO+M->AF2_TAREFA
bWhile	:=	{||AF3->AF3_FILIAL+AF3->AF3_ORCAME+AF3->AF3_VERSAO+AF3->AF3_TAREFA} 
FillGetDados(nOpc,"AF3",5,cSeek,bWhile,,,,,,,,@aHeadTmp,@aColsTmp)

//Inicializa o AF3_ITEM (sequencial da linha)
nX		:=  aScan(aHeadTmp,{|x|AllTrim(x[2]) == "AF3_ITEM"})
If (nX > 0) .AND. (Len(aColsTmp) == 1) .AND. Empty(aColsTmp[1][nX])
	aColsTmp[1][nX]	:= "01"
EndIf

If lCria
	oGd[1] := MsNewGetDados():New(4,4,(aObj[1][4]:nHeight/3)+10,((aObj[1][4]:nWidth/2)-5),nGdOpc,"A531GD1LinOk","A531GD1TudOk","+AF3_ITEM",,,300,,,"Ft530VlPrdSrv",aObj[1][4]:aDialogs[1],aHeadTmp,aColsTmp)
	//Torna o campo AF3_QUANT nao-alteravel
	nX := aScan(oGd[1]:aHeader,{|x|AllTrim(x[2])=="AF3_QUANT"}) 
	oGd[1]:aInfo[nX][5] 	:= "V"
	oGd[1]:aHeader[nX][14]	:= "V"
Else
	oGd[1]:aCols	:= aClone(aColsTmp)
EndIf

oGd[1]:Refresh()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta Getdados das predecessorasณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aHeadTmp	:= {}
aColsTmp	:= {}
cSeek 	:= 	xFilial("AF7")+M->AF2_ORCAME+M->AF2_VERSAO+M->AF2_TAREFA
bWhile	:=	{||AF7->AF7_FILIAL+AF7->AF7_ORCAME+AF7->AF7_VERSAO+AF7->AF7_TAREFA} 
FillGetDados(nOpc,"AF7",3,cSeek,bWhile,,,,,,,,@aHeadTmp,@aColsTmp,{|a,b|FT531AfCo2(a,b)})
nX		:=  aScan(aHeadTmp,{|x|AllTrim(x[2]) == "AF7_ITEM"})
If (nX > 0) .AND. (Len(aColsTmp) == 1) .AND. Empty(aColsTmp[1][nX])
	aColsTmp[1][nX]	:= "01"
EndIf

If lCria
	oGd[2] := MsNewGetDados():New(4,4,(aObj[1][4]:nHeight/3)+10,((aObj[1][4]:nWidth/2)-5),If(lModelo,nGdOpc,0),"A531GD2LinOk","A531GD2TudOK","+AF7_ITEM",,,300,,,,aObj[1][4]:aDialogs[2],aHeadTmp,aColsTmp)
Else
	oGd[2]:aCols	:= aClone(aColsTmp)
EndIf

oGd[2]:Refresh()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta GetDados dos componentesณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aHeadTmp	:= {}
aColsTmp	:= {}
cSeek 	:= 	xFilial("ADX")+M->AF2_ORCAME+M->AF2_VERSAO+M->AF2_TAREFA
bWhile	:=	{||ADX->ADX_FILIAL+ADX->ADX_ORCAME+ADX->ADX_VERSAO+ADX->ADX_TAREFA} 
FillGetDados(nOpc,"ADX",2,cSeek,bWhile,,,,,,,,@aHeadTmp,@aColsTmp,{|a,b|FT531AfCo1(a,b)})

//Inicializa o contador de itens
nX		:=  aScan(aHeadTmp,{|x|AllTrim(x[2]) == "ADX_ITEM"})
If (nX > 0) .AND. (Len(aColsTmp) == 1) .AND. Empty(aColsTmp[1][nX])
	aColsTmp[1][nX]	:= "01"
EndIf

If lCria
	oGd[3] := MsNewGetDados():New(4,4,(aObj[1][4]:nHeight/3)+10,((aObj[1][4]:nWidth/2)-5),nGdOpc,"A531GD3LinOk","A531GD3TudOK","+ADX_ITEM",,,300,"F531GDFOk",,,aObj[1][4]:aDialogs[3],aHeadTmp,aColsTmp)
Else
	oGd[3]:aCols	:= aClone(aColsTmp)
EndIf    

oGd[3]:Refresh()

INCLUI	:= lIncBk
ALTERA	:= lAltBk	
RestArea(aArea)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณA530SetOptionณ Autor ณ Vendas Cliente     ณ Data ณ 08-01-2008 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Funcao que controla a GetDados ativa na visualizacao do      ณฑฑ
ฑฑณ          ณ Folder.                                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ FATA531                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A530SetOption(nFolder,nOldFolder)
                           
Local lRet	:= .T.

lRet := oGd[nOldFolder]:TudoOk()

If nOldFolder == 3
	M->AF2_QUANT := Ft531Soma()
	aObj[1][1]:Refresh()    
	oGd[1]:Refresh()
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530VlPreบAutor  ณVendas Clientes     บ Data ณ  07/02/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidacao das predecessoras antes de executar a exclusao ou บฑฑ
ฑฑบ          ณremocao da tarefa/edt do projeto.                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ft530VlPre(cAlias,nRecAlias,aTree,nNivel,aTreeRef,lRecursivo,lExcMult,lMSG)

Local aArea		:= GetArea()
Local aAreaAF2	:= AF2->(GetArea())
Local aAreaAF5	:= AF2->(GetArea())
Local aAreaTmp	:= (cAlias)->(GetArea())
Local lRet		:= .T.
Local aTrack	:= {}
Local nLen		:= 0 
Local nX		:= 0 
Local cTrk		:= ""
Local cAliasIt	:= ""
Local nRecnoIt	:= 0
Local aTreeTmp	:= {}
Local cRelTar	:= ""

Default aTreeRef	:= {}
Default nNivel 		:= 1   
Default lRecursivo	:= .F.
Default lExcMult	:= .F.
Default lMSG		:= .T.
     
//Caso exclusao do 1o. Nivel
If nNivel == Nil
	Return(.F.)
EndIf  

//Testa se nao eh o 1o. nivel do tree
If ValType(aTree[1][1]) <> "U" .And. AllTrim(aTree[1][1]) == cAlias+StrZero(nRecAlias,12) .And. !lRecursivo
	Return(.F.)
EndIf

DbSelectArea(cAlias)
DbGoTo(nRecAlias)

DbSelectArea("AF7")
DbSetOrder(2) //AF7_FILIAL+AF7_ORCAME+AF7_PREDEC

If cAlias == "AF2"
	
	If AF7->(DbSeek(xFilial("AF7")+M->AF1_ORCAME+AF2->AF2_TAREFA)) 

		AF2->(DbSetOrder(1)) //AF2_FILIAL+AF2_ORCAME+AF2_TAREFA
		AF2->(DbSeek(xFilial("AF2")+M->AF1_ORCAME+AF7->AF7_TAREFA))
		
   		If nNivel <> 1 //Exclusao de um grupo todo
			If !aTreeSk(@aTreeRef,"AF2"+Strzero(AF2->(Recno()),12)) 
				lRet := .F.
			EndIf
		Else
		   	lRet := .F.
		EndIf
		
		If !lRet			
			//"A tarefa nใo pode ser removida neste momento pois a tarefa '"###" ้ dependente deste processo."
			MsgInfo(STR0061 + AllTrim(Capital(AF2->AF2_DESCRI)) + "' ("+AllTrim(AF2->AF2_TAREFA)+")"+STR0062)
		EndIf		
	
	EndIf
	
ElseIf cAlias == "AF5"
	
	If aTreeSk(@aTree,"AF5"+Strzero(nRecAlias,12),@aTrack)

		nLen := Len(aTrack)    			
		For nX := 1 to nLen
			cTrk	:= "["+AllTrim(Str(aTrack[nX]))+"][2]"
			If nX == 1
				Eval(&("{|| aTreeTmp := aTree"+cTrk+"}"))
			Else
				Eval(&("{|| aTreeTmp := aTreeTmp"+cTrk+"}"))
			EndIf
		Next nX 

		If nNivel == 1
			aTreeRef := aClone(aTreeTmp)
		EndIf
		
		nLen	:= Len(aTreeTmp)
		nX		:= 1
 		
 		While (nX <= nLen) .AND. lRet   
 		
			cAliasIt	:= SubStr(aTreeTmp[nX][1],1,3)
			nRecnoIt	:= Val(SubStr(aTreeTmp[nX][1],4,12))
			
			lRet := Ft530VlPre(cAliasIt,nRecnoIt,@aTreeTmp,nNivel+1,aTreeRef,.T.,lExcMult,lMSG)

			nX++ 
 			
		End
		
	Else
		lRet := .F.
	EndIf

EndIf

RestArea(aAreaTmp)
RestArea(aArea)
RestArea(aAreaAF2)
RestArea(aAreaAF5)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณA530PrLok   ณ Autor ณ Vendas Clientes     ณ Data ณ 30-01-2008 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณFuncao de validacao dos produtos adicionais da proposta       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณFata530                                                       ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A530PrLok()
Local lRet 	:= F531ChkCol(@aObj[3][6],{"AF3_QUANT"})
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณA530PrLok   ณ Autor ณ Vendas Clientes     ณ Data ณ 30-01-2008 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณFuncao de validacao dos produtos adicionais da proposta       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณFata530                                                       ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A530PrTok()
Local lRet 	:= A530PrLok()
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFT530GrPrAบAutor  ณVendas Clientes     บ Data ณ  08/02/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGravacao dos produtos adicionais do projeto                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ft530GrPrA()

Local aArea		:= GetArea()
Local lRet		:= .T.
Local nPosRecNo	:= 0
Local nPosProd	:= 0
Local aCols		:= {}
Local aHeader	:= {}
Local nCntFor	:= 0
Local nCntFor2	:= 0  
Local cFilAF3	:= xFilial("AF3")

If ( aObj[3][6] == Nil )
	RestArea(aArea)
	Return .T.
EndIf                    

//Valida a getdados
If ( aObj[3][6]:TudoOk() )

	aCols	:= aObj[3][6]:aCols
	aHeader	:= aObj[3][6]:aHeader

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Grava arquivo AF3 (Produtos)ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea("AF3")
	
	nPosRecNo	:= aScan(aHeader,{|x|AllTrim(x[2])=="AF3_REC_WT"})
	nPosProd	:= aScan(aHeader,{|x|AllTrim(x[2])=="AF3_PRODUT"})
	
	Begin Transaction
	
	For nCntFor := 1 to Len(aCols)
		If !aTail(aCols[nCntFor])
			If !Empty(aCols[nCntFor][nPosProd])
				If aCols[nCntFor][nPosRecNo] > 0
					dbGoto(aCols[nCntFor][nPosRecNo])
					RecLock("AF3",.F.)
				Else
					RecLock("AF3",.T.)
				EndIf
				For nCntFor2 := 1 To Len(aHeader)
					If (aHeader[nCntFor2][10] != "V" )
						AF3->(FieldPut(FieldPos(aHeader[nCntFor2][2]),aCols[nCntFor][nCntFor2]))
					EndIf
				Next nCntFor2
				AF3->AF3_FILIAL	:= cFilAF3
				AF3->AF3_ORCAME	:= M->AF1_ORCAME
				AF3->AF3_VERSAO	:= M->AF1_VERSAO
				AF3->AF3_TAREFA	:= ""
				MsUnlock()

				//Atualiza o aCols para as proximas gravacoes
				aCols[nCntFor][nPosRecNo] := AF3->(Recno())

			EndIf
		Else
			If aCols[nCntFor][nPosRecNo] > 0
			
				dbGoto(aCols[nCntFor][nPosRecNo])
				RecLock("AF3",.F.,.T.)
				dbDelete()
				MsUnlock()        
				
				//Atualiza o aCols para as proximas gravacoes
				aCols[nCntFor][nPosRecNo] := 0
				
			EndIf
		EndIf
	
	Next nCntFor
	
	End Transaction
	
Else
	lRet := .F.
EndIf

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATA530   บAutor  ณMicrosiga           บ Data ณ  02/08/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณFata530                                                       ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A530PrdSet(nFolder,nOldFolder)

Local lRet 		:= .T.
Local aCols		:= {}
Local aHeader	:= {}
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCalcula total da tarefaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nOldFolder == 2 
	If aObj[3][6]:TudoOk()
		Ft530GrPrA()
	   	Ft530Prod(@aHeader,@aCols)
	   	if !Empty(aCols)
	   		aObj[3][5]:SetArray(aCols,.T.)
	   	End if
		aObj[3][5]:Refresh()
	Else
		lRet := .F.
	EndIf
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530CntPAบAutor  ณVendas Clientes     บ Data ณ  19/02/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConta quantos produtos adicionais existem para o projeto    บฑฑ
ฑฑบ          ณrecebido via parametro                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ft530CntPA(cProjeto,cVersao)

Local aArea		:= GetArea()
Local aAreaAF3	:= AF3->(GetArea())
Local cTarBco	:= Space(TamSx3("AF3_TAREFA")[1])
Local cFilAF3	:= xFilial("AF3")
Local nCont		:= 0

DbSelectArea("AF3")
DbSetOrder(5) //AF3_FILIAL+AF3_ORCAME+AF3_VERSAO+AF3_TAREFA
DbSeek(cFilAF3+cProjeto+cVersao+cTarBco)

While !Eof() .AND.;
	AF3->AF3_FILIAL	== cFilAF3	.AND.;
	AF3->AF3_ORCAME	== cProjeto	.AND.;
	AF3->AF3_VERSAO	== cVersao	.AND.;
	AF3->AF3_TAREFA	== cTarBco
	nCont++
	DbSkip()
End

RestArea(aAreaAF3)
RestArea(aArea)

Return nCont

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530Num  บAutor  ณVendas Clientes     บ Data ณ  19/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFornece um numero sequencial valido para cadastros          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ft530Num(cAlias, cCampo, nQualndex)

Local aArea		:= GetArea()
Local aAreaTmp	:= (cAlias)->(GetArea())
Local cProxNum
Local cFilter 	:= (cAlias)->(DbFilter())

Default nQualndex := 1

(cAlias)->(dbClearFilter())
         
cProxNum 	:= GetSxeNum(cAlias, cCampo,, nQualndex)

dbSelectArea(cAlias)
dbSetOrder(nQualndex)
		
While dbSeek( xFilial( cAlias ) + cProxNum )
	ConfirmSX8()
	cProxNum := GetSx8Num(cAlias, cCampo,, nQualndex)
End

If !Empty(cFilter)
	(cAlias)->(DbSetFilter({||&cFilter},cFilter))
Endif

RestArea(aAreaTmp)
RestArea(aArea)

Return(cProxNum)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530TtAF5บAutor  ณVendas Clientes     บ Data ณ  04/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza o total de horas para a EDT passada no parametro   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ft530TtAF5(cOrcam,cEdt,cVersao)  

Local aArea		:= GetArea()
Local aAreaAF5	:= AF5->(GetArea())
Local nTotal	:= Ft530SumHr(cOrcam,cVersao,cEdt) 

DbSelectArea("AF5")
DbSetOrder(5) //AF5_FILIAL+AF5_ORCAME+AF5_VERSAO+AF5_EDT+AF5_ORDEM

If DbSeek(xFilial("AF5")+cOrcam+cVersao+cEdt)
	RecLock("AF5",.F.)
	AF5->AF5_QUANT	:= nTotal
	MsUnLock()
EndIf

RestArea(aAreaAF5)
RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530SumHrบAutor  ณVendas Clientes     บ Data ณ  04/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalculo do total de horas da EDT corrente, somando os totaisบฑฑ
ฑฑบ          ณdas filhas                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ft530SumHr(cOrcam,cVersao,cEdt,nNivel,nTotal)

Local aArea		:= GetArea()
Local aAreaAF5	:= AF5->(GetArea())
Local cQuery	:= ""
Local cFuncNull	:= "" 
Local cDbType	:= TCGetDB()
Local cAliasTrb	:= ""

Default nNivel	:= 1
Default nTotal	:= 0

DbSelectArea("AF5")
DbSetOrder(5) //AF5_FILIAL+AF5_ORCAME+AF5_VERSAO+AF5_EDT+AF5_ORDEM
DbSeek(xFilial("AF5")+cOrcam+cVersao+cEdt)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณNome da funcao do banco de dados que substitui NULL por 0ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Do Case
	Case cDbType $ "DB2/POSTGRES"
		cFuncNull	:= "COALESCE"
	Case "ORACLE" $ cDbType  
  		cFuncNull	:= "NVL"
 	Otherwise
 		cFuncNull	:= "ISNULL"
EndCase

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSoma o total de horas para as tarefas da EDT correnteณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cQuery	:= "SELECT " + cFuncNull + "(SUM(AF2_QUANT),0) QUANT FROM " + RetSqlName("AF2")
cQuery	+= " WHERE AF2_FILIAL = '" + xFilial("AF2") + "'"
cQuery	+= " AND AF2_ORCAME = '" + cOrcam + "' "
cQuery	+= " AND AF2_VERSAO = '" + cVersao + "' "
cQuery	+= " AND AF2_EDTPAI = '" + cEdt + "' "
cQuery	+= " AND AF2_STATUS = '1' "   

If TcSrvType() != "AS/400"
	cQuery	+= " AND D_E_L_E_T_ = ' ' "
Else
	cQuery	+= " AND @DELETED@ = ' ' "
EndIf

If Select("TMP2") > 0
	TMP2->(DbCloseArea())
EndIf

cQuery := ChangeQuery( cQuery )
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TMP2",.T.,.T.)
DbGoTop()

nTotal	+=	TMP2->QUANT

TMP2->(DbCloseArea())

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefine nome da area temporariaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cAliasTrb	:= "TMPX"+AllTrim(Str(nNivel))

If Select(cAliasTrb) > 0
	(cAliasTrb)->(DbCloseArea())
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSoma tambem as EDTs filhasณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cQuery	:= "SELECT AF5_ORCAME,AF5_VERSAO,AF5_EDT"
cQuery	+= " FROM " + RetSqlName("AF5")
cQuery	+= " WHERE AF5_FILIAL = '"+xFilial("AF5")+"'"
cQuery	+= " AND AF5_ORCAME = '" + cOrcam + "' " 
cQuery	+= " AND AF5_VERSAO = '" + cVersao + "' " 
cQuery	+= " AND AF5_EDTPAI = '" + cEdt + "'"
cQuery	+= " AND D_E_L_E_T_ = ' '"  

cQuery := ChangeQuery( cQuery )

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasTrb ,.T.,.T.)
DbGoTop()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAnalisa recursivamente as EDTs filhasณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
While !(cAliasTrb)->(Eof())
	Ft530SumHr((cAliasTrb)->AF5_ORCAME,(cAliasTrb)->AF5_VERSAO,(cAliasTrb)->AF5_EDT,nNivel+1,@nTotal)
	(cAliasTrb)->(DbSkip())
End

(cAliasTrb)->(DbCloseArea())

RestArea(aAreaAF5)
RestArea(aArea)

Return nTotal

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530SelMdบAutor  ณVendas Clientes     บ Data ณ  14/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTela de selecao de modelos, permitindo selecao multipla de  บฑฑ
ฑฑบ          ณmodelos                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ft530SelMd(oTree,aTree,nOpcX)

Local lRet	:= Ft530GrPrA()
Local oDlg
Local oPesq
Local cPesq	:= ""
Local aLBox := {}
Local oLBox	:= Nil  
Local oOk	:= LoadBitmap( GetResources(), "LBOK" )
Local oNo	:= LoadBitmap( GetResources(), "LBNO" )
Local oBtnB	:= Nil
Local oBtnP	:= Nil
Local lFiltro := .F. //Se o filtro foi utilizado e nao encontrou modelos relacionados ao cliente ou prospect.
Local lFT530SEL	:= ExistBlock("FT530SEL") //Ponto de entrada para alterar o filtro de modelos

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe a validacao dos produtos adicionais interrompeu a rotina,ณ
//ณaborta                                                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !lRet
	Return .F.
EndIf

If lFT530SEL
	ExecBlock("FT530SEL",.F.,.F.,{@oTree,@aTree,nOpcX})
	Return .T.
EndIf

cPesq := Space(TamSx3("AF1_DESCRI")[1])

Ft530AbreMd(@aLBox,@lFiltro)

If Len(aLBox) > 0

	DEFINE MSDIALOG oDlg TITLE STR0063 FROM 178,181 TO 600,915 PIXEL //"Sele็ใo de modelos"
	
		// Cria as Groups do Sistema
		@ 002,003 TO 160,315 LABEL STR0064 PIXEL OF oDlg //"Selecione o(s) modelo(s) desejados para inclusใo:"
		@ 165,003 TO 200,315 LABEL STR0065 PIXEL OF oDlg //"Pesquisa pelo nome:"
	
		@ 012,008 ListBox oLBox Fields HEADER "",STR0066,STR0047; //"Codigo"###"Codigo"
			Size 300,140 Of oDlg Pixel ON DblClick( FAT530EMPT(aLbox,oLboX))
				
		oLBox:SetArray(aLBox)
	
		oLBox:bLine := {||{	Iif(aLBox[oLBox:nAt,1],oOk,oNo),;
						 		aLBox[oLBox:nAT,02],;
								aLBox[oLBox:nAT,04]}}   
	
		@ 178,008 MsGet oPesq Var cPesq Size 200,009 COLOR CLR_BLACK PIXEL OF oDlg Valid Ft530SkLbx(aLBox,@oLBox,cPesq)
	
		DEFINE SBUTTON FROM 005,330 TYPE 1 ENABLE OF oDlg Action (If(Ft530ImpMd(@oTree,@aTree,nOpcX,@aLBox),oDlg:End(),.F.))
		DEFINE SBUTTON FROM 022,330 TYPE 2 ENABLE OF oDlg Action oDlg:End() 
	
		@ 178,215 Button oBtnB Prompt STR0031 Size 40,10 Pixel Action Ft530SkLbx(aLBox,@oLBox,cPesq) Message STR0067 Of oDlg	 //"Pesquisar"###"Pesquisa o texto digitado"
		@ 178,260 Button oBtnB Prompt STR0068 Size 40,10 Pixel Action Ft530SkLbx(aLBox,@oLBox,cPesq,@oLBox:nAt) Message STR0067 Of oDlg //"Pr๓ximo"###"Pesquisa o texto digitado"
	
	
	ACTIVATE MSDIALOG oDlg CENTERED 
	
Else
	If lFiltro
		MsgStop(STR0087)//Nใo hแ modelos relacionados aos segmentos.
	Else
		MsgStop(STR0069)//"Nใo hแ modelos cadastrados para importa็ใo"
	EndIf
EndIf

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530SkLbxบAutor  ณVendas Clientes     บ Data ณ  14/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLocaliza um elemento no array do listbox e posiciona o obje-บฑฑ
ฑฑบ          ณto                                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ft530SkLbx(aLBox,oLBox,cPesq,nStart)

Local nPos		:= 0  

If nStart <> Nil
	nStart++
EndIf

cPesq := AllTrim(Upper(cPesq))

If (nPos := aScan(aLBox,{|x|cPesq $ Upper(AllTrim(x[3]))},nStart) )  > 0
	oLBox:nAt := nPos
	oLBox:Refresh()
EndIf

If nPos == 0 .AND. nStart <> Nil
	nStart--
	oLBox:nAt := nStart
	oLBox:Refresh()
EndIf

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530AbreMdบAutor ณMicrosiga           บ Data ณ  04/17/08   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณListagem dos modelos para importacao                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ft530AbreMd(aLista,lFiltro)

Local aArea		:= GetArea()
Local aAreaAF1	:= AF1->(GetArea())
Local cFilAF1	:= xFilial("AF1")
Local cAlias	:= ""
Local lFt530Qry	:= ExistBlock("Ft530Qry")
Local cRetPE	:= ""
Local aSegment  :={}  		// Array com os segmentos de negocios
Local nX        := 0  		// Contador temporario
Local cEntidade	:= ""       // Entidade Cliente ou Prospect
Local cCodEnt	:= ""		// Codigo da Entidade
Local cCodLoj	:= ""      	// Loja da Entidade
Local lHabUsSg	:= SuperGetMV("MV_FATHBSG",,.T.)	//Habilita uso de segmentos de negocio da entidade 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSeleciona os registros mostrados como modelosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Local cQuery	:= "" 	

cAlias 	:= "AF1T"

If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf

cQuery	:= "SELECT AF1_FILIAL,AF1_ORCAME,AF1_VERSAO, AF1_DESCRI, AF1_TIPO"
cQuery	+= " FROM " + RetSqlName("AF1")
cQuery	+= " WHERE AF1_TIPO = '1' "
cQuery	+= " AND AF1_FILIAL = '" + cFilAF1 + "' "
cQuery	+= " AND D_E_L_E_T_ = ' ' " 

If lFt530Qry 
	cRetPE := ExecBlock("FT530QRY",.F.,.F.)
	If ValType(cRetPE) == "C"
		cQuery += cRetPE
	EndIf
EndIf

cQuery	+= " ORDER BY AF1_DESCRI "

cQuery := ChangeQuery( cQuery )

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias,.T.,.T.)
         
DbSelectArea(cAlias)
DbGoTop()
	
             
If (Type("M->ADY_ENTIDA") == "C" ) 
	cEntidade := M->ADY_ENTIDA
	cCodEnt	  := M->ADY_CODIGO
	cCodLoj	  := M->ADY_LOJA
Else
	cEntidade := M->AAT_ENTIDA
	cCodEnt	  := M->AAT_CODENT
	cCodLoj	  := M->AAT_LOJENT
EndIf



//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Filtro na importacao do modelo.     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If	lHabUsSg

	If cEntidade <> Nil //Pois pode ser acessado direto pelo cadastro de modelos 

		If cEntidade == '1'
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Entidade - Cliente   ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			
			DbSelectArea("SA1")
			DbSetOrder(1)
			If DbSeek(xFilial("SA1")+cCodEnt+cCodLoj)
				
				
				If !Empty(SA1->A1_CODSEG)
					aAdd(aSegment,SA1->A1_CODSEG)
				EndIf
				
				DbSelectArea("AOW")
				AOW->(DbSetOrder(1)) //AOW_FILIAL+AOW_CODSEG+AOW_ENTIDA+AOW_CODCNT+AOW_LOJCNT+AOW_SUBSEG
				AOW->(DbSeek(xFilial("AOW")+SA1->A1_CODSEG+'SA1'+cCodEnt+cCodLoj))
		
				While !AOW->( EOF() ) .And. xFilial( "AOW" )== AOW->AOW_FILIAL .And. AOW->AOW_ENTIDA=='SA1' .And.;
		    	  AOW->AOW_CODCNT==cCodEnt .And. AOW->AOW_LOJCNT==cCodLoj .And. AOW->AOW_CODSEG==SA1->A1_CODSEG
				
					aAdd(aSegment,AOW->AOW_SUBSEG)
					AOW->( dbSkip() )
				End
			EndIf
			DbCloseArea()
		Else
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Entidade - Prospect  ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			
			DbSelectArea("SUS")
			DbSetOrder(1)
			If DbSeek(xFilial("SUS")+cCodEnt+cCodLoj)
				
				If !Empty(SUS->US_CODSEG)
					aAdd(aSegment,SUS->US_CODSEG)
				EndIf
				
				DbSelectArea("AOW")
				AOW->(DbSetOrder(1)) //AOW_FILIAL+AOW_CODSEG+AOW_ENTIDA+AOW_CODCNT+AOW_LOJCNT+AOW_SUBSEG
				AOW->(DbSeek(xFilial("AOW")+SUS->US_CODSEG+'SUS'+cCodEnt+cCodLoj))
		
				While !AOW->( EOF() ) .And. xFilial( "AOW" )== AOW->AOW_FILIAL .And. AOW->AOW_ENTIDA=='SUS' .And.;
		    	  AOW->AOW_CODCNT==cCodEnt .And. AOW->AOW_LOJCNT==cCodLoj .And. AOW->AOW_CODSEG==SUS->US_CODSEG
				
					aAdd(aSegment,AOW->AOW_SUBSEG)
					AOW->( dbSkip() )
				End
		
			EndIf
			DbCloseArea()
		EndIf
	EndIf
Endif

If lHabUsSg .and. Len(aSegment) > 0
	If MSGYESNO(STR0086,STR0079) // Deseja filtrar os segmentos de negocios?
		DbSelectArea("AG0")
		DbSetOrder(2)
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณMonta Array filtradoณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		While !(cAlias)->(Eof()) .AND. (cAlias)->AF1_FILIAL == cFilAF1 .AND. (cAlias)->AF1_TIPO == "1"
			For nX := 1 To Len(aSegment)
				If AG0->(DbSeek(xFilial("AG0")+aSegment[nX] + (cAlias)->AF1_ORCAME ))
					Aadd(aLista,{.F.,AllTrim((cAlias)->AF1_ORCAME),Alltrim((cAlias)->AF1_VERSAO),AllTrim(Capital(NoAcento((cAlias)->AF1_DESCRI)))})
					Exit
				EndIf
			Next nX
			(cAlias)->(DbSkip())
		End
		
		If Len(aLista) == 0
			lFiltro := .T.
		EndIf
		
	Else
		//ฺฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณMonta Arrayณ
		//ภฤฤฤฤฤฤฤฤฤฤฤู
		While !(cAlias)->(Eof()) .AND. (cAlias)->AF1_FILIAL == cFilAF1 .AND. (cAlias)->AF1_TIPO == "1"
			Aadd(aLista,{.F.,AllTrim((cAlias)->AF1_ORCAME),Alltrim((cAlias)->AF1_VERSAO),AllTrim(Capital(NoAcento((cAlias)->AF1_DESCRI)))})
			(cAlias)->(DbSkip())
		End
	EndIf
Else
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMonta Arrayณ
	//ภฤฤฤฤฤฤฤฤฤฤฤู
	While !(cAlias)->(Eof()) .AND. (cAlias)->AF1_FILIAL == cFilAF1 .AND. (cAlias)->AF1_TIPO == "1"
		Aadd(aLista,{.F.,AllTrim((cAlias)->AF1_ORCAME),Alltrim((cAlias)->AF1_VERSAO),AllTrim(Capital(NoAcento((cAlias)->AF1_DESCRI)))})
		(cAlias)->(DbSkip())
	End
	
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDesfaz indice temporarioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

(cAlias)->(DbCloseArea())


RestArea(aAreaAF1)
RestArea(aArea)

Return Nil	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530VlTarบAutor  ณVendas Clientes     บ Data ณ  25/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida se a tarefa a ser incluida ja existe no projeto, tra-บฑฑ
ฑฑบ          ณtando o seu status.                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ft530VlTar(aValores,cOrcamento,cVersao)

Local aAreaAF2	:= AF2->(GetArea())
Local nPComp	:= aScan(aValores,{|x| AllTrim(x[1]) == "AF2_COMPOS" })
Local nPStat	:= aScan(aValores,{|x| AllTrim(x[1]) == "AF2_STATUS" })

DbSelectArea("AF2")
DbSetOrder(7)//AF2_FILIAL+AF2_ORCAME+AF2_VERSAO+AF2_COMPOS

If 	((nPComp) > 0 .AND. (nPStat) > 0) .AND. !Empty(aValores[nPComp][2]) .AND.;
	DbSeek(xFilial("AF2")+cOrcamento+cVersao+aValores[nPComp][2])
	
	aValores[nPStat][2] := "3"
	
EndIf

RestArea(aAreaAF2)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณProcurar  บAutor  ณVendas Clientes     บ Data ณ  10/07/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Procurar(oTree, cSearchText, cArquivo)

Local nPos		:= 0
Local cCargo	:= ""

If oTree <> Nil .AND. PMSFindDlg(@cSearchText)
	
	cSearchText := AllTrim(Upper(cSearchText))
	nPos		:= aScan(oTree:aNodes,{|x| cSearchText $ AllTrim(Upper(x[4])) })
	
	If nPos > 0
		cCargo	:= oTree:GetCargo(oTree:aNodes[nPos][2])
		oTree:TreeSeek(cCargo)
	EndIf
	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณProcurarP บAutor  ณVendas Clientes     บ Data ณ  10/07/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ProcurarP(oTree, cSearch, cArquivo)

Local nPos	:= 0
Local nStart:= 0

If oTree <> Nil 
	
	nStart		:= aScan(oTree:aNodes,{|x| cSearch $ AllTrim(Upper(x[4])) })
	nPos		:= aScan(oTree:aNodes,{|x| cSearch $ AllTrim(Upper(x[4])) }, nStart+1 )
	
	If nPos > 0
		cCargo	:= oTree:GetCargo(oTree:aNodes[nPos][2])
		oTree:TreeSeek(cCargo)
	EndIf  
	
EndIf  

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530GrRspบAutor  ณVendas CRM          บ Data ณ  29/07/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava as respostas das perguntas associadas ao projeto      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft530GrRsp(cProjeto,cVersao,aRecAF2,cCodPerg,cLocalAG6)

Local aArea		:= GetArea()
Local aAreaADX	:= ADX->(GetArea())
Local aAreaAF3	:= AF3->(GetArea())
Local aAreaAG6	:= AG6->(GetArea())
Local cFilAG6	:= xFilial("AG6")
Local cFilADX	:= xFilial("ADX") 
Local cFilAF2	:= xFilial("AF2")
Local cFilAF5	:= xFilial("AF5")
Local cFilSKH	:= xFilial("SKH")
Local cFilAF3	:= xFilial("AF3") 
Local nDecs		:= TamSx3("ADX_QUANT")[2]
Local nDecsAF3	:= TamSX3("AF3_QUANT")[2] 
Local aFatores	:= Ft530Fator(cProjeto,cVersao)
Local nX		:= 0
Local nPos		:= 0
Local nValTot	:= 0 
Local nQtdTot	:= 0
Local nItens	:= 0
Local nPesoPrg	:= 0 
Local nPAcProd	:= 0
Local nPAcQtd	:= 0 
Local nPPerg	:= 0
Local nPQuant	:= 0
Local nQuant	:= 0
Local nPosRecno	:= 0
Local aHeadPro	:= {}
Local aColPro	:= {}
Local aColNew	:= {}
Local aDummy	:= {}
Local aItensADX	:= {}
Local cAliasSql	:= "TMP3"
Local cItem		:= Ft531MaxIt(cProjeto,cVersao)
Local lAtuProd	:= .F.
Local lNewRec	:= .T.
Local lSoma		:= .F.
Local cProOrig 	:= ""
Local lExecSk 	:= .F.      
Local nY    
Local nRecAG6            
Local cEDT		:= ""
Local cQuery
Local nValRsp	:= 0
Local nlPe		:= 1
Local aAF2Ater	:= {}
Local nSmTot	:= 0
Local nQtdTAR	:= 0

DbSelectArea("ADX")
DbSetOrder(2) //ADX_FILIAL+ADX_ORCAME+ADX_VERSAO+ADX_TAREFA+ADX_ITEM

DbSelectArea("AF2")
DbSetOrder(6) //AF2_FILIAL+AF2_ORCAME+AF2_VERSAO+AF2_EDTPAI+AF2_ORDEM                                                                                                                      

DbSelectArea("AF5")
DbSetOrder(5) //AF5_FILIAL+AF5_ORCAME+AF2_VERSAO+AF5_EDT+AF5_ORDEM

DbSelectArea("SKH")
DbSetOrder(1) //KH_FILIAL+KH_CODQST+KH_CODALT                                                                                                                                   
DbSelectArea("AF3")
DbSetOrder(1) //AF3_FILIAL+AF3_ORCAME+AF3_VERSAO+AF3_TAREFA+AF3_ITEM

DbSelectArea("AG6")
DbSetOrder(4) //AG6_FILIAL+AG6_TIPO+AG6_CODPRO+AG6_VERSAO+AG6_LOCAL+AG6_CODPER
DbSeek(cFilAG6+"3"+cProjeto+cVersao+cLocalAG6+cCodPerg)

cProOrig := AG6->AG6_PROORI

BEGIN TRANSACTION							

While AG6->AG6_FILIAL == cFilAG6 .And. AG6->AG6_TIPO == "3" .And. AG6->AG6_CODPRO == cProjeto .And.  AG6->AG6_VERSAO == cVersao .AND. AG6->AG6_CODPER == cCodPerg .AND. !AG6->(Eof())

		cProOrig := AG6->AG6_PROORI
	
	While AG6->AG6_CODPRO == cProjeto .And. AG6->AG6_VERSAO == cVersao .And.  AG6->AG6_PROORI == cProOrig .AND. AG6->AG6_CODPER == cCodPerg .AND. !AG6->(Eof())
		
		If Empty(AG6->AG6_LOCAL) .And. !Empty(AG6->AG6_RESP)
			
			//Soma valor da resposta
			nValRsp	:= Ft530ExFor(AG6->AG6_CODPER,AG6->AG6_RESP,cProjeto,cVersao,,,cProOrig)
			
			lAtuProd	:= .T.
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณInclui produtos adicionaisณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			//Carrega os totais para o projeto (sem produtos adicionais)
			Ft530Prod(@aHeadPro,@aColPro,cProjeto,.F.,cVersao)
			nPAcProd	:= aScan(aHeadPro,{|x|AllTrim(x[2]) == "AF3_PRODUT"})
			nPAcQtd		:= aScan(aHeadPro,{|x|AllTrim(x[2]) == "AF3_QUANT" })

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAntes de incluir o registro de adicional verifica se existe umณ
			//ณregistro para cada produto na aba de produtos adicionais      ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			For nX := 1 to Len(aColPro)
				
				//Verifica se ha produtos adicionais cadastrados
				cQuery	:= "SELECT R_E_C_N_O_ AS RECNUM FROM " + RetSqlName("AF3")
				cQuery	+= " WHERE AF3_FILIAL = '" + cFilAF3 + "'"
				cQuery	+= " AND AF3_ORCAME = '" + cProjeto + "' "
				cQuery	+= " AND AF3_VERSAO = '" + cVersao + "' "
				cQuery	+= " AND AF3_PRODUT = '" + aColPro[nX][nPAcProd] + "'"
				cQuery	+= " AND AF3_TAREFA = '' "
				cQuery	+= " AND D_E_L_E_T_ = ' ' "
			
				cQuery	:= ChangeQuery(cQuery)
				
				If Select(cAliasSql) > 0
					(cAliasSql)->(DbCloseArea())
				EndIf
				
				DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasSql,.T.,.T.)
				DbGoTop()
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณSe for um registro ja gravado, armazena o recnoณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If !(cAliasSql)->(Eof())
					lNewRec	:= .F.
					nRecAF3 := (cAliasSql)->RECNUM
				Else
					lNewRec := .T.
				EndIf
				
				(cAliasSql)->(DbCloseArea())
				
				DbSelectArea("AF3")
				
				If !lNewRec
					DbGoTo(nRecAF3)
				EndIf   
						
				//Tratamento do item
				If lNewRec
					cItem := Soma1(cItem)
				EndIf
				
				//Verifica qual o fator do produto
				nPos := aScan(aFatores,{|x|AllTrim(x[1])==AllTrim(aColPro[nX][nPAcProd])})
				If nPos > 0
					nFator	:= aFatores[nPos][2]
				Else
					nFator	:= 1
				EndIf
				
				RecLock("AF3",lNewRec)
				AF3->AF3_FILIAL	:= cFilAF3
				AF3->AF3_ITEM	:= If(lNewRec,cItem,AF3->AF3_ITEM)
				AF3->AF3_ORCAME	:= cProjeto
				AF3->AF3_VERSAO	:= cVersao
				AF3->AF3_TAREFA	:= ""
				AF3->AF3_PRODUT	:= aColPro[nX][nPAcProd]
				AF3->AF3_QUANT	:= (nValRsp*nFator) + Ft530RetAd("T",aColPro[nX][nPAcProd]) + IIF(lNewRec,0,Ft530RetAd("P",aColPro[nX][nPAcProd]))
				AF3->AF3_MOEDA	:= 1
				MsUnLock()
				
				//Adiciona o valor adicional da pergunta ao array de controle 
				Ft530SomAd("P",aColPro[nX][nPAcProd],(nValRsp*nFator))
			        
			Next nX
			
		ElseIf !Empty(AG6->AG6_LOCAL) .And. !Empty(AG6->AG6_RESP)
			
			If AG6->AG6_EDT == 'S'	//EDT
			
				nValRsp	:= Ft530ExFor(AG6->AG6_CODPER,AG6->AG6_RESP,cProjeto,cVersao,AG6->AG6_LOCAL,@lSoma,,AF5->AF5_QUANT)
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Aplica calculo da pergunta na EDT ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				
				cQuery := "SELECT AF2_ORCAME, AF2_VERSAO, AF2_TAREFA, AF2_QUANT "
				cQuery += " FROM " + RetSqlName("AF2") + " AF2 "
				cQuery += " WHERE 	AF2_ORCAME = '"+cProjeto+"' AND"
				cQuery += " 		AF2_VERSAO = '"+cVersao+"' AND"
				cQuery += " 		AF2_EDTPAI = '"+AF5->AF5_EDT +"'AND "
				cQuery += " D_E_L_E_T_=' '"
				
				DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "AF2PER",.T.,.T.)

				DbSelectArea("AF2PER")
				DbGoTop() 
				
				While AF2PER->(!EOF())
					aadd(aAF2Ater,{ AF2PER->AF2_ORCAME, AF2PER->AF2_VERSAO, AF2PER->AF2_TAREFA, AF2PER->AF2_QUANT, nValRsp} )
					dbSkip()
				Enddo
				
				DbSelectArea("SKG")
				DbSetOrder(1)
				If	dbSeek(xFilial("SKG") + cCodPerg)
					cOperacao	:= SKG->KG_OPERA	//"1=Soma;2=Subtracao;3=Multiplicacao;4=Divisao"
				Endif 
				
				If	cOperacao $ "1|2"	//SOMA - SUBTRACAO
					nDifSald	:= (nValRsp/Len(aAF2Ater))
				Endif
				
				If	cOperacao $ "3"
					nDifSald	:= (AF5->AF5_QUANT / nValRsp) * 100
				Endif 					
				
				If	cOperacao $ "4"
					nDifSald	:= (AF5->AF5_QUANT / nValRsp)
				Endif 					
				
				DbSelectArea("ADX")
				DbSetOrder(2) //ADX_FILIAL+ADX_ORCAME+ADX_VERSAO+ADX_TAREFA+ADX_ITEM
				
				For nlPe:=1 To Len(aAF2Ater)

  					nPesoPrg := 0

					If	ADX->(DbSeek(xFilial("ADX")+aAF2Ater[nlPe,1]+aAF2Ater[nlPe,2]+aAF2Ater[nlPe,3]))
					
						If	cOperacao $ "1|2"	//SOMA 
							nPesoPrg := Round( (ADX->ADX_QUANT + nDifSald) , nDecs)
						Endif
						
						If	cOperacao $ "3"
							nPesoPrg := Round( (ADX->ADX_QUANT * nDifSald) , nDecs)
						Endif
						
						If	cOperacao $ "4"
							nPesoPrg := Round( (ADX->ADX_QUANT / nDifSald) , nDecs)
						Endif
						
						RecLock("ADX",.F.)
				
						ADX->ADX_VALPER	:= nPesoPrg
						ADX->ADX_QUANT	:= ADX->ADX_VALPER
				
						MsUnLock()  
						
						dbSelectArea("AF2")
						dbSetOrder(5)
						If	dbSeek(xFilial("AF2")+aAF2Ater[nlPe,1]+aAF2Ater[nlPe,2]+aAF2Ater[nlPe,3])
							RecLock("AF2",.F.)
							AF2_QUANT := nPesoPrg			
							MsUnLock()
						Endif 
						
					Endif 
					
					nSmTot += nPesoPrg
					                                             
					dbSelectArea("AF3")
					dbSetOrder(5)
					If	DbSeek(xFilial("AF3")+aAF2Ater[nlPe,1]+aAF2Ater[nlPe,2]+aAF2Ater[nlPe,3])
					                                               
						While !AF3->(Eof()) 						.AND.;
							AF3->AF3_FILIAL == xFilial("ADX") 		.AND.;
							AF3->AF3_ORCAME	== aAF2Ater[nlPe,1] 	.AND.;
							AF3->AF3_VERSAO	== aAF2Ater[nlPe,2]  	.AND.;
							AF3->AF3_TAREFA	== aAF2Ater[nlPe,3]
		
							nQuant	:= Ft530Qtd(AF3->AF3_ORCAME,AF3->AF3_TAREFA,.F.,,AF3->AF3_VERSAO)
							
							RecLock("AF3",.F.)
							AF3->AF3_QUANT	:= Round(nQuant * AF3->AF3_FATOR,nDecsAF3)
							MsUnLock()					
							AF3->(DbSkip())
						End
					Endif 						

				Next nlPe
				
				AF2PER->(dbCloseArea())
				
				If	nSmTot < 0

					MsgAlert(STR0173,STR0054)	//"EDT terแ sua quantidade NEGATIVA. Reavaliar projeto. Resposta nใo serแ aplicada!"###"Aten็ใo"
					DisarmTransaction()
					RestArea(aArea)
					
					RecLock("AG6",.F.)
					AG6_RESP 	:= ""
					AG6_MARCA 	:= "nochecked"
					MsUnLock()
					
					oGd[4]:Refresh()
					
				Endif                                                                                                     
				
				If	nSmTot == 0
					MsgAlert(STR0174,STR0054)	//"EDT terแ sua quantidade igual a ZERO. Reavaliar projeto, caso necessแrios excluir EDT."###"Aten็ใo"
				Endif 

				If	nSmTot >= 0				
					M->AF5_QUANT := nSmTot
				Endif 					

				aObj[2][1]:Refresh()    

			Else 
			
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Aplica calculo da pergunta na TAREFA ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				nValRsp	:= Ft530ExFor(AG6->AG6_CODPER,AG6->AG6_RESP,cProjeto,cVersao,AG6->AG6_LOCAL,@lSoma)
				
				//Altera os itens de complexidade			
				If	ADX->(DbSeek(cFilADX+cProjeto+cVersao+AG6->AG6_LOCAL)) //ADX_FILIAL+ADX_ORCAME+ADX_TAREFA+ADX_ITEM
				
					aItensADX 	:= {}
					nQtdTot		:= 0
			
					While ADX->ADX_FILIAL == cFilADX .AND. 	ADX->ADX_ORCAME	== cProjeto .AND. ADX->ADX_VERSAO	== cVersao .AND. ADX->ADX_TAREFA	== AG6->AG6_LOCAL .AND. !ADX->(Eof())
					
						AAdd(aItensADX,{ADX->(Recno()),ADX->ADX_QUANT})
						nQtdTot += ADX->ADX_QUANT
				
						ADX->(DbSkip())
					
					End
				
						nItens	:= Len(aItensADX)
						nValTot	:= 0
				
					For nX := 1 to nItens 
				
						ADX->(DbGoTo(aItensADX[nX][1]))
						nPesoPrg	:= Round(nValRsp * (aItensADX[nX][2]/nQtdTot),nDecs)
						nValTot		+= nPesoPrg
					
						//Soma diferencas de decimais
						If nX == nItens
							nPesoPrg += (nValRsp - nValTot)
						EndIf
					
						nSomQu := 0 
						
						RecLock("ADX",.F.)
						ADX->ADX_VALPER	:= nPesoPrg
						If	lSoma
							If	ADX->ADX_QTDORI <> ADX->ADX_QUANT
								nSomQu := ADX->ADX_QUANT
							Else
								nSomQu := ADX->ADX_QTDORI
							Endif 

							ADX->ADX_QUANT	:= nSomQu  + ADX->ADX_VALPER
						Else
							ADX->ADX_QUANT	:= ADX->ADX_VALPER
						EndIf
						
						nQtdTAR := ADX->ADX_QUANT
						
						MsUnLock()  
						If	nQtdTAR >= 0	//ANALISAR FUNCIONAMENTO

						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณAtualiza o item alterado no aColsณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
						If oGd[3] <> Nil
							nPosRecno := aScan(oGd[3]:aHeader,{|x|AllTrim(x[2])=="ADX_REC_WT"	})
							nPQuant	  := aScan(oGd[3]:aHeader,{|x|AllTrim(x[2])=="ADX_QUANT"	})
							nPPerg	  := aScan(oGd[3]:aHeader,{|x|AllTrim(x[2])=="ADX_VALPER"	})
							nPos	  := aScan(oGd[3]:aCols,{|x| x[nPosRecno] == aItensADX[nX][1]})
							If nPos > 0
								oGd[3]:aCols[nPos][nPPerg]  := ADX->ADX_VALPER
								oGd[3]:aCols[nPos][nPQuant] := ADX->ADX_QUANT
							EndIf						
						EndIf 
						
						Endif 
					
					Next nX

					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณAtualiza registros dos produtosณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					AF3->(DbSeek(cFilAF3+cProjeto+cVersao+AG6->AG6_LOCAL))
				                                               
					While !AF3->(Eof()) 				.AND.;
						AF3->AF3_FILIAL == cFilAF3 		.AND.;
						AF3->AF3_ORCAME	== cProjeto 	.AND.;
						AF3->AF3_VERSAO	== cVersao  	.AND.;
						AF3->AF3_TAREFA	== AG6->AG6_LOCAL

						nQuant	:= Ft530Qtd(AF3->AF3_ORCAME,AF3->AF3_TAREFA,.F.,AF3->AF3_VERSAO)
						
						RecLock("AF3",.F.)
						AF3->AF3_QUANT	:= Round(nQuant * AF3->AF3_FATOR,nDecsAF3)
						MsUnLock()					
								
						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณAtualiza o item alterado no aColsณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
						If	oGd[1] <> Nil
							nPosRecno := aScan(oGd[1]:aHeader,{|x|AllTrim(x[2])=="AF3_REC_WT"	})
							nPQuant	  := aScan(oGd[1]:aHeader,{|x|AllTrim(x[2])=="AF3_QUANT"	})
							nPos	  := aScan(oGd[1]:aCols,{|x| x[nPosRecno] == AF3->(Recno()) })
							If nPos > 0
								oGd[1]:aCols[nPos][nPQuant] := ADX->ADX_QUANT						
							EndIf
						EndIf 
						AF3->(DbSkip())
						
					End
	
						If (oGd[1]<> Nil) .AND. (oGd[3] <> Nil)
							oGd[1]:Refresh()
							oGd[3]:Refresh()
					   		Ft531Soma()
					 	EndIf
				
				Endif 
				
				If	nQtdTAR == 0
					MsgAlert(STR0175,STR0054)	//"TAREFA terแ sua quantidade igual a ZERO. Reavaliar projeto, caso necessแrios excluir TAREFA."###"Aten็ใo"
				Endif 
				
				If	nQtdTAR < 0

					MsgAlert(STR0176,STR0054)	//"TAREFA terแ sua quantidade NEGATIVA. Reavaliar projeto. Resposta nใo serแ aplicada!","Aten็ใo"

					DisarmTransaction()
					
					RecLock("AG6",.F.)
					AG6_RESP 	:= ""
					AG6_MARCA 	:= "nochecked"
					MsUnLock()
					
					oGd[4]:Refresh()
					
				Endif                                                                                                     				
				
			Endif 

		EndIf
		
		AG6->(DbSkip())
		lExecSk := .T.
	EndDo

	If lExecSk // Se ja executou dbSkip
		lExecSk := .F.
	Else
		AG6->(DbSkip())
	EndIf
End

If lAtuProd   

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAtualiza a relacao de produtos adicionaisณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    aColNew	:= {}
	FillGetDados(4,"AF3",5,xFilial("AF3")+cProjeto+cVersao,{||AF3->AF3_FILIAL+AF3->AF3_ORCAME+AF3->AF3_VERSAO},;
		{||Empty(AF3->AF3_TAREFA)},{"AF3_FATOR","AF3_COMPOS","AF3_CALCTR","AF3_TURNO"};
		,,,,,,aDummy,@aColNew)
                  
	aObj[3][6]:SetArray(aColNew,.T.)
	aObj[3][6]:Refresh()	

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAtualiza o total de produtosณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aColNew	:= {}
	aDummy 	:= {}
	Ft530Prod(@aDummy,@aColNew)
	aObj[3][5]:SetArray(aColNew,.T.)
	aObj[3][5]:Refresh()
	
EndIf

END TRANSACTION				
RestArea(aAreaAG6)
RestArea(aAreaAF3)
RestArea(aAreaADX)
RestArea(aArea)

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530Pag  บAutor  ณVendas CRM          บ Data ณ  18/09/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPaginacao de registros no RecordSet da tela de consulta     บฑฑ
ฑฑบ          ณcustomizada.                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft530Pag(oLstBx,cAlias,aCampos,nLimite,cAliasOri)

Local aLinha	:= {}
Local nX		:= 0
Local nRegs		:= 0 
Local aDados	:= {}  
Local cChaveInd	:= ""
Local cSep		:= "" 
Local cChave	:= ""

(cAliasOri)->(DbSetOrder(1))

For nX := 1 to (cAlias)->(FCount())
	If Type((cAlias)->(FieldName(nX))) == "C"
		cChaveInd	+= cSep + (cAlias)->(FieldName(nX))
		cSep	:= "+"
	EndIf
Next nX

While !(cAlias)->(Eof()) .AND. nRegs <= nLimite
	
	aLinha := {}
	cChave	:= (cAlias)->&(cChaveInd)

	(cAliasOri)->(DbSeek(xFilial(cAliasOri)+cChave))

	For nX := 1 to Len(aCampos)
		AAdd(aLinha,(cAliasOri)->&(aCampos[nX]))
	Next nX
	AAdd(aLinha,(cAliasOri)->(Recno()))
	
	If oLstBx <> Nil
		AAdd(oLstBx:aArray,aClone(aLinha))
	Else
		Aadd(aDados,aClone(aLinha))
	EndIf

	nRegs++ 
	
	(cAlias)->(DbSkip())
	
End

If oLstBx <> Nil
	Return aClone(oLstBx:aArray)
Else             
	Return aDados
EndIf

Return .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530VisuaบAutor  ณMicrosiga           บ Data ณ  09/23/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ft530Visua(oLstBx,cAlias)
          
Local aArea	:= GetArea()
Local nReg	:= aTail(oLstBx:aArray[oLstBx:nAt])
                     
SaveInter()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCria um aRotina basico para evitar quaisquer problemasณ
//ณcom a rotina diferente deste padrao                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aRotina := {{STR0031,"AxPesqui",0,1} ,;	//"Pesquisar"
			{STR0010,"AxVisual",0,2}}		//"Visualizar"
RecLock(cAlias,.F.)     
DbSelectArea(cAlias)
DbGoTo(nReg)

AxVisual(cAlias,nReg,2)
MsUnlock()
RestInter()

RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530SomAdบAutor  ณVendas CRM          บ Data ณ  02/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณSoma detalhes de produtos adicionais ao array de controle   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 - Define a origem (P-Pergunta,T-Traslado)             บฑฑ
ฑฑบ          ณExpC2 - Codigo do produto                                   บฑฑ
ฑฑบ          ณExpN3 - Valor a adicionar                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft530SomAd(cOrigem,cProd,nValor)

Local nPos	:= 0

nPos := aScan(_aAdic,{|x|x[1] == cOrigem .AND. x[2] == cProd})

If nPos == 0
	AAdd(_aAdic,{cOrigem,cProd,nValor})
Else 
	_aAdic[nPos][3] := nValor
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530RetAdบAutor  ณVendas CRM          บ Data ณ  02/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna total de um item, para pergunta ou traslado         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 - Define a origem (P-Pergunta,T-Traslado)             บฑฑ
ฑฑบ          ณExpC2 - Codigo do produto                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft530RetAd(cOrigem,cProd)

Local nPos	:= 0
Local nValor:= 0

nPos := aScan(_aAdic,{|x|x[1] == cOrigem .AND. x[2] == cProd})

If nPos > 0
	nValor	:= _aAdic[nPos][3]
EndIf

Return nValor

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530SlManualบAutor  ณEduardo Gomes Juniorบ Data ณ  25/05/12   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria ARRAY contendo o projeto selecionado que sera usado 	 บฑฑ
ฑฑบ          ณmanualmente   					                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FATA530                                                    	 บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ft530SlManual(cCodPrjt,aBkpItens)

Local aArea		:= GetArea()
Local cQuery	:= "" 	
Local cCodPrj	:= ""
Local aLista	:= {}
Local nExitProj := 0
Local nLi		:= 1

Default aBkpItens := {}
	
If	Select("AF5MNA") > 0
	(AF5MNA)->(DbCloseArea())
EndIf

cQuery	:= "SELECT AF5_FILIAL,AF5_ORCAME, AF5_DESCRI, AF5_EDT, AF5_NIVEL"
cQuery	+= " FROM " + RetSqlName("AF5")
cQuery	+= " WHERE "
cQuery	+= " AF5_FILIAL = '" + xFilial("AF5") + "' AND "
cQuery	+= " AF5_ORCAME = '" + cCodPrjt + "'"
cQuery	+= " AND D_E_L_E_T_ = ' ' "       
cQuery	+= " ORDER BY AF5_ORCAME, AF5_EDT,AF5_NIVEL "

cQuery := ChangeQuery( cQuery )
	
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "AF5MNA" ,.T.,.T.)
	         
DbSelectArea("AF5MNA")
DbGoTop()

//ฺฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta Arrayณ
//ภฤฤฤฤฤฤฤฤฤฤฤู

If	Len(aBkpItens) > 0
	nExitProj := aScan(aBkpItens, {|x| Alltrim(x[3]) == Alltrim(AF5MNA->AF5_ORCAME) } )
Endif 	

If	nExitProj == 0

	While !EOF()
	
		If	Alltrim(AF5MNA->AF5_EDT) <> Alltrim(AF5MNA->AF5_ORCAME)
			
			If	LEN(ALLTRIM(AF5MNA->AF5_EDT)) == 2
				cAdiEsp := "|------>"		
			Else			
				cAdiEsp := ""
			Endif 
			
			Aadd(aLista,{.F.,cAdiEsp+""+AllTrim(Capital(NoAcento(AF5MNA->AF5_DESCRI))),AF5MNA->AF5_ORCAME, AF5MNA->AF5_EDT, AF5MNA->AF5_NIVEL })
			
		Endif
		
		DbSkip()
		
	End
	
Else 	

	For nLi :=1 To Len(aBkpItens)
		If	Alltrim(aBkpItens[nLi,3]) == Alltrim(AF5MNA->AF5_ORCAME)
			Aadd(aLista,{aBkpItens[nLi,1],aBkpItens[nLi,2],aBkpItens[nLi,3], aBkpItens[nLi,4], aBkpItens[nLi,5] })	
		Endif 			
	Next nLi
	
Endif 	

AF5MNA->(DbCloseArea())

If Empty( aLista ) 
	aLista :=	{{.F.,"","","",""}}
EndIf
RestArea(aArea)

Return(aLista)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530SlItensบAutor  ณEduardo Gomes Juniorบ Data ณ  25/05/12   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria ARRAY contendo os modulos do projeto selecionado que 	บฑฑ
ฑฑบ          ณsera usado manualmente   			                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FATA530                                                    	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ft530SlItens(cCodPrjt,aClsMnu,aClsItm,oClsItm,aBkpItens)

Local nLI 		:= 1
Local aClsAtu   := {}
Local nExitProj := 0

Local oOk		:= LoadBitmap( GetResources(), "LBOK" )
Local oNo		:= LoadBitmap( GetResources(), "LBNO" )

Default aBkpItens	:= {}

If	Len(aClsMnu) > 1

	If	Len(aClsItm) > 0
	
		For nLI := 1 To Len(aClsItm)

			If	!Empty(aClsItm[nLI][3]) 
			
				nExitProj := aScan(aBkpItens, {|x| Alltrim(x[3]+x[4]+x[5]) == Alltrim(aClsItm[nLI][3]+aClsItm[nLI][4]+aClsItm[nLI][5]) } )

				If	nExitProj == 0
				  	aadd(aBkpItens,{aClsItm[nLI][1],aClsItm[nLI][2],aClsItm[nLI][3],aClsItm[nLI][4],aClsItm[nLI][5]})
				Else 
					If aClsItm[nLI][1] <> aBkpItens[nExitProj,1]
						aBkpItens[nExitProj,1] := aClsItm[nLI][1]
					Endif 
				Endif 
								  	
			Endif
		
		Next nLI
	
	Endif 

	If	Len(aBkpItens) > 0
		aDel(aClsItm,Len(aClsItm))
		aSize(aClsItm,Len(aClsItm)-1)	
	Endif 		

	aClsItm := Ft530SlManual(cCodPrjt,aBkpItens)
	
	oClsItm:SetArray(aClsItm)
	oClsItm:bLine := {||{	Iif(aClsItm[oClsItm:nAt,1],oOk,oNo),;
					 		aClsItm[oClsItm:nAT,02],;
					 		aClsItm[oClsItm:nAT,03]	,;
					 		aClsItm[oClsItm:nAT,04],;
					 		aClsItm[oClsItm:nAT,05] }}
	
Endif

If Len(aClsItm) == 0 
	aClsItm :=	{{.F.,"","","",""}}
EndIf
 
Return(aClsItm)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530IpManulบAutor  ณEduardo Gomes Juniorบ Data ณ  25/05/12   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega o projeto/modulo que foi selecionado manualmente	    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FATA530                                                    	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ft530IpManul(oTree,aTree,aClsMnu,aClsItm)

Local nX 	:= 0
Local nY 	:= 0
Local aQETD := {}

//Selecao do modelo
For nX := 1 To Len(aClsMnu)

	If 	aClsMnu[nX][1]

		aadd(aQETD,{aClsMnu[nX][3],{}})
		nLinPos := Len( aQETD )

		For nY := 1 To Len(aClsItm)
			If aClsItm[nY][1] .AND. aClsItm[nY][3] == aQETD[nLinPos][1]
				aadd(aQETD[nLinPos][2],aClsItm[nY][4])
			Endif 				
		Next nY		
		
	EndIf
	
Next nX

If	Len(aQETD) > 0
	FTA530Tree(@oTree,@aTree,,.F.,,"MANUAL",,aQETD)
Endif 

Return 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530DbClickบAutor  ณEduardo Gomes Juniorบ Data ณ  25/05/12   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Opcao de DUPLO CLICK (marca/desmarca) usado na selecao de 	บฑฑ
ฑฑบ          ณmodulos manual												บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FATA530                                                     	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ft530DbClick(aClsItm,oClsItm,lEDTPos,cEDTPos)

Local nL 		:= 1
Local nEdt		:= 1

If	Len(Alltrim(cEDTPos)) == 2

	For nL :=1 To Len(aClsItm)
		If	Substr(aClsItm[nL,4],1,2) == Alltrim(cEDTPos)
			If	lEDTPos
				aClsItm[nL][1]:= .T.
			Else 
				aClsItm[nL][1]:= .F.
			Endif 			
		Endif
	Next nL
	
Else 

	For nEdt:=1 To Len(aClsItm)

		If	Alltrim(SubsTr(cEDTPos,1,Len( Alltrim( aClsItm[nEdt,4] ) ) ) ) $  SubsTr(aClsItm[nEdt,4],1,Len( Alltrim( aClsItm[nEdt,4] ) ) )

			If	lEDTPos
				aClsItm[nEdt][1]:= .T.
			Else 
				aClsItm[nEdt][1]:= .F.
			Endif 			
			
		Endif 			

	Next nEdt 
	
Endif 		

oClsItm:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530CpPRJ บAutor  ณEduardo Gomes Juniorบ Data ณ  29/08/12   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria interface para que seja selecionado o projeto a ser    บฑฑ
ฑฑบ          ณ copiado. Sera copiado para a simulacao atual um projeto ja  บฑฑ
ฑฑบ          ณ existente usado ou nao em outra proposta comercial/simulacaoบฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FATA530                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ft530CpPRJ(oTree,aTree,nOpcX)

Local oDlg
Local aArea			:= GetArea()
Local aAreaAF1		:= AF1->(GetArea())
Local lRet			:= .F.
Local cFilhos 		:= "AF1,AF5,AF2,AF3"
Local lReset 		:= .F.
Local lInsTask		:= .T.
Local lDisplay 		:= .F.
Local aQlEDT 		:= {}
Local oDadosPrj

Private cCodProjeto	:= Space(TamSX3("AF1_ORCAME")[1])
Private cVerprojeto	:= Space(TamSX3("AF1_VERSAO")[1])
Private cDesProjeto	:= Space(TamSX3("AF1_DESCRI")[1])

Private oCodProjeto                                         
Private oVerProjeto
Private oDesProjeto

DEFINE MSDIALOG oDlg TITLE STR0099 FROM 178,181 TO 250,915 PIXEL //"Selecione o projeto a ser copiado"
	
@ 002,003 TO 030,315 LABEL STR0100 PIXEL OF oDlg //"Informe o codigo do projeto:"

@ 013,008 Say STR0102 	COLOR CLR_BLUE PIXEL OF oDlg	//"Projeto:"
@ 011,027 MsGet oCodProjeto Var cCodProjeto F3 "AF1CPY"  Valid ExistCpo("AF1",cCodProjeto)	Size 050,010 COLOR CLR_BLACK PIXEL OF oDlg

@ 013,081 Say "Versใo:" COLOR CLR_BLUE PIXEL OF oDlg
@ 011,100 MsGet oVerProjeto Var cVerProjeto Size 010,010 COLOR CLR_BLACK PIXEL OF oDlg

@ 011,125 MsGet oDesProjeto Var cDesProjeto 			When .F.							Size 185,010 COLOR CLR_BLACK PIXEL OF oDlg
	
DEFINE SBUTTON FROM 005,330 TYPE 1 ENABLE OF oDlg Action Processa({||AuxTree(oTree,aTree,cFilhos,lReset,lInsTask,cCodProjeto,lDisplay,aQlEDT,.T.,,cVerprojeto),oDlg:End() },STR0040)
DEFINE SBUTTON FROM 022,330 TYPE 2 ENABLE OF oDlg Action oDlg:End()
	
ACTIVATE MSDIALOG oDlg CENTERED

RestArea(aArea)
RestArea(aAreaAF1)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530BlqCposบAutor  ณEduardo Gomes Juniorบ Data ณ  05/10/12   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Bloqueia campos do simulador de servico (AF1) quando for	    บฑฑ
ฑฑบ          ณ chamada a rotina atraves da proposta comercial FATA600       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ WHEN dos campos: AF1_ORCAME / AF1_DESCRI                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft530BlqCpos()

Local lHbCpos := .T.

If	IsInCallStack("A600SERVICOS")
	lHbCpos := .F.
Endif 

Return(lHbCpos)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530VlPrdSrvบAutor  ณEduardo Gomes Juniorบ Data ณ  16/10/12   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Nao permite alteracao/exclusao de produtos originados atraves บฑฑ
ฑฑบ          ณdo simulador de servico                                      	 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FATA530 / FATA600											 บฑฑ
ฑฑบ          ณ SX3 (ADZ/ADZ) -> WHEN dos campos 							 บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft530VlPrdSrv(cAlias)

Local aArea			:= GetArea()
Local aAreaAF3		:= AF3->(GetArea())					
Local aAreaAF5		:= AF5->(GetArea())					
Local lRet			:= .T.									
Local lPropServ		:= .F.									
Local nPosPrd		:= 0
Local nPosPMS		:= 0									
Local nPosVPMS		:= 0									
Local cProdAnt		:= Space(TamSX3("ADZ_PRODUT")[1]) 
Local cQuery		:= ""
Local lhVldPrds		:= GetMV("MV_FATALPR",,.T.)

Default cAlias 		:= "AF3"

If	lhVldPrds

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Validacao aplicada quando for o simulador de servicos ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If	cAlias == "AF3"
	
		If	IsInCallStack("A600SERVICOS")
			lPropServ 	:= .T.
			nPosPrd		:= aScan( aHeader , { |x| AllTrim(x[2]) == "AF3_PRODUT" } )
		Endif 
		
		If	lPropServ
		
			If	Empty( Alltrim(M->AF5_MODORI) )
				RegToMemory('AF5', .F. )
			Endif 
	
			cQuery := " SELECT AF5_FILIAL, AF5_ORCAME, AF5_EDT, AF5_MODORI, AF5_EDTPAI "
			cQuery += " FROM " + RetSqlName("AF5")
			cQuery += " WHERE "
			cQuery += "	AF5_FILIAL = '"+xFilial("AF5")+"'  AND AF5_ORCAME = '"+M->AF5_ORCAME+"' AND AF5_EDT = '"+SUBSTR(M->AF5_EDT,1,2)+"'AND AF5_MODORI <> '' AND "
			cQuery += " D_E_L_E_T_ = ' '" 
		           
			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "AF5TPA" ,.T.,.T.)
		
			dbSelectArea("AF3")
			dbSetOrder(2)
			
			If	dbSeek(xFilial("AF3")+Alltrim(AF5TPA->AF5_MODORI)+aCols[n,nPosPrd])
				lRet := .F.
			eNDIF 	
			
			AF5TPA->(dbCloseArea())	
			
		Endif 		
	
	Else 	
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Validacao aplicada quando for proposta comercial    ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		nPosPrd	:= aScan( aHeader, { |x| AllTrim(x[2]) == "ADZ_PRODUT"	})	//Posicao do campo produto na proposta comercial
		nPosPMS := aScan( aHeader, { |x| AllTrim(x[2]) == "ADZ_PMS"	})	//Posicao do campo PMS na proposta comercial
		nPosVPMS:= aScan( aHeader, { |x| AllTrim(x[2]) == "ADZ_PMSVER"	})	//Posicao do campo versao do PMS na proposta comercial
		
		If	!EMPTY(aCols[n,nPosPMS] )
		
			cQuery := " SELECT AF5_FILIAL, AF5_ORCAME, AF5_VERSAO, AF5_MODORI "
			cQuery += " FROM " + RetSqlName("AF5")
			cQuery += " WHERE "
			cQuery += "	AF5_FILIAL = '"+xFilial("AF5")+"'  AND AF5_ORCAME = '"+aCols[n,nPosPMS]+"' AND AF5_VERSAO = '"+aCols[n,nPosVPMS]+"' AND AF5_MODORI <> '' AND "
			cQuery += " D_E_L_E_T_ = ' '" 
			
			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "AF5TPA" ,.T.,.T.)

			dbSelectArea("AF5TPA")
			While !EOF() .AND. lRet
			
				dbSelectArea("AF3")
				dbSetOrder(6)
				If	dbSeek(xFilial("AF3")+Alltrim(AF5TPA->AF5_MODORI)+"001"+aCols[n,nPosPrd])
					lRet := .F.	
				Endif
				
				dbSelectArea("AF5TPA")
				dbSkip()
			
			Enddo
			
			AF5TPA->( dbCloseArea())
			
		Endif	
		
	Endif
	
	If	!lRet
		MsgAlert(STR0103,STR0104) 	//"Altera็ใo/exclusใo de produto nใo permitida! Qualquer duvida entrar em contato com o PMO Corporativo."###"Aten็ใo - Produto referente ao simulador de servi็os"
	Endif 	

Endif 

RestArea(aArea)
RestArea(aAreaAF3)
RestArea(aAreaAF5)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATA530   บAutor  ณEduardo Gomes Juniorบ Data ณ  11/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Interface especifica para o vendedor usar na selecao de    บฑฑ
ฑฑบ          ณprojetos que podem ser usados para copias                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FATA530                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft530FilPrjs()

Local oDlgPRJ
Local oOk		:= LoadBitmap( GetResources(), "LBOK" )
Local oNo		:= LoadBitmap( GetResources(), "LBNO" )
Local oOrdem	
Local aOrdem    := {STR0105,STR0106,STR0107,STR0108,STR0109}	//"1-Orcamento"###"2-Codigo+Loja"###"3-Tp.Ent+Codigo+Loja"###"4-Descricao Entidade"###"5-Nome do Projeto"
Local cOrd  
Local cPesq		:= Space(300)
Local oPesq		:= NIL
Local aBrowse	:= {}
Local oBrowse
Local bAtuPRJ	:= {|| MsgRun(STR0110,STR0111,{|| aBrowse := Ft530MntPrj(cOrd), oBrowse:Refresh() }) }	//"Aguarde carregando projetos..."###"Copia de Projeto"

DEFINE MSDIALOG oDlgPRJ TITLE STR0111 FROM 178,181 TO 600,915 PIXEL //"Copia de Projeto"
	
@ 002,003 TO 160,315 LABEL STR0112 PIXEL OF oDlgPRJ //"Selecione o modelo desejados para realizar a copia:"
@ 165,003 TO 200,315 LABEL STR0113 PIXEL OF oDlgPRJ //"Pesquisa:"
	
@ 012,008 ListBox oBrowse Fields HEADER " ",STR0114,STR0160,STR0115,STR0116,STR0117,STR0118,STR0119,STR0120;
	Size 300,140 Of oDlgPRJ Pixel ON DblClick(aBrowse[oBrowse:nAt,01] := !aBrowse[oBrowse:nAt,01])	//" "###"Orcamento"###"Versใo"###"Descricao"###"Tp Entidade"###"Codigo"###"Loja"###"Descricao Entidade"###"Nome do Projeto"
			
aBrowse := Ft530MntPrj()
			
oBrowse:SetArray(aBrowse)
oBrowse:bLine := {||{	Iif(aBrowse[oBrowse:nAt,01],oOk,oNo) ,;
					aBrowse[oBrowse:nAt,02],;
					aBrowse[oBrowse:nAt,03],;
					aBrowse[oBrowse:nAt,04],;
					aBrowse[oBrowse:nAt,05],;
					aBrowse[oBrowse:nAt,06],;
					aBrowse[oBrowse:nAt,07],;
					aBrowse[oBrowse:nAt,08],;
					aBrowse[oBrowse:nAt,09]	} }

	@ 174,008 COMBOBOX oOrdem VAR cOrd ITEMS aOrdem SIZE 200,10 OF oDlgPRJ PIXEL On Change Eval(bAtuPRJ)
	@ 186,008 MsGet oPesq Var cPesq Size 200,009 COLOR CLR_BLACK PIXEL OF oDlgPRJ 
	
	DEFINE SBUTTON FROM 005,330 TYPE 1 ENABLE OF oDlgPRJ Action If( Ft530VldSel(aBrowse) , (cCodProjeto := aBrowse[oBrowse:nAt,02], cVerprojeto := aBrowse[oBrowse:nAt,03], cDesProjeto := aBrowse[oBrowse:nAt,09], oDlgPRJ:End() ) , )
	DEFINE SBUTTON FROM 022,330 TYPE 2 ENABLE OF oDlgPRJ Action oDlgPRJ:End() 
	
	@ 181,215 Button oBtnB Prompt STR0031 Size 40,10 Pixel Action Ft530SkPrj(aBrowse,@oBrowse,cPesq,cOrd) Message STR0067 Of oDlgPRJ	 //"Pesquisar"###"Pesquisa o texto digitado"
	@ 181,260 Button oBtnB Prompt STR0068 Size 40,10 Pixel Action Ft530SkPrj(aBrowse,@oBrowse,cPesq,cOrd,@oBrowse:nAt) Message STR0067 Of oDlgPRJ //"Pr๓ximo"###"Pesquisa o texto digitado"
	
	
	ACTIVATE MSDIALOG oDlgPRJ CENTERED 
	
Return(.T.)	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530MntPrjบAutor  ณEduardo Gomes Juniorบ Data ณ  13/11/12   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Filtra projetos do EAR que podem ser usandos em copias      บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FATA530                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft530MntPrj(cOrd)

Local cQuery	:= {}
Local aPrjEAR 	:= {}
Local nOrdSel	:= 0
Local cVndWrk	:= aParCrm[01]
Local cOrcCab	:= M->AF1_ORCAME

Default cOrd	:= "1"

nOrdSel := Val(cOrd)

cQuery := "SELECT AF1_ORCAME, AF1_VERSAO, AF1_DESCRI, AF1_ENTIDA, AF1_CODENT, AF1_LOJENT, AF1_NOMPRJ"
cQuery += " FROM " + RetSQLName("AF1") + " AF1 WHERE "
cQuery += " AF1_ORCAME <> '"+cOrcCab+"' AND "
cQuery += " AF1_VEND = '"+Alltrim(cVndWrk)+"'"
cQuery += " AND D_E_L_E_T_ ' ' "

If		nOrdSel == 1
		cQuery += " ORDER BY AF1_ORCAME, AF1_VERSAO"
ElseIf	nOrdSel == 2
		cQuery += " ORDER BY AF1_CODENT, AF1_LOJENT"
ElseIf	nOrdSel == 3
		cQuery += " ORDER BY AF1_ENTIDA, AF1_CODENT, AF1_LOJENT"
ElseIf	nOrdSel == 4
		cQuery += " ORDER BY AF1_NOMPRJ"
Endif 		

TCQUERY cQuery NEW ALIAS "SELPRJ"

dbSelectArea("SELPRJ")

While !EOF()

	AADD(aPrjEAR,{.F., SELPRJ->AF1_ORCAME, SELPRJ->AF1_VERSAO ,SELPRJ->AF1_DESCRI, SELPRJ->AF1_ENTIDAD, SELPRJ->AF1_CODENT, SELPRJ->AF1_LOJENT, SELPRJ->AF1_NOMPRJ })

	dbSelectArea("SELPRJ")
	dbSkip()

Enddo

SELPRJ->(dbCloseArea())

Return(aPrjEAR)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATA530   บAutor  ณEduardo Gomes Juniorบ Data ณ  13/11/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza pesquisa de projetos                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FATA530                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft530SkPrj(aLBox,oLBox,cPesq,cOrd,nStart)

Local nPos		:= 0  
Local cProcura	:= ""
Local nColuna	:= 1

If	Empty(cPesq)
	MsgAlert(STR0123,STR0054)	///###"Aten็ใo"
	Return(.F.)
Endif 

If		Val(cOrd) == 1	//Orcamento
		nColuna	:= 2
ElseIf	Val(cOrd) == 2	//Codigo da entidade 
		nColuna	:= 5
ElseIf	Val(cOrd) == 3	//Entidade
		nColuna	:= 5
ElseIf	Val(cOrd) == 4	//Descricao da entidade 
		nColuna	:= 8
ElseIf	Val(cOrd) == 5	//Nome do projeto
		nColuna	:= 9
Endif
	
If nStart <> Nil
	nStart++
EndIf

cPesq := AllTrim(Upper(cPesq))

If (nPos := aScan(aLBox,{|x|cPesq $ Upper(AllTrim(x[nColuna]))},nStart) )  > 0
	oLBox:nAt := nPos
	oLBox:Refresh()
EndIf

If nPos == 0 .AND. nStart <> Nil
	nStart--
	oLBox:nAt := nStart
	oLBox:Refresh()
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530VldSelบAutor  ณEduardo Gomes Juniorบ Data ณ  13/11/12   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida projeto marcado para copia 						   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FATA530                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft530VldSel(aBrowse)

Local lRet		:= .T. 
Local nL		:= 1
Local nQtSel	:= 0

For nL:=1 To Len(aBrowse)

	If	aBrowse[nL,1] 
		nQtSel ++
	Endif 			

Next nL

If	nQtSel == 0
	MsgInfo(STR0121,STR0054)	//"Nenhum Projeto selecionado para copia !"###"Aten็ใo"
	lRet := .F. 
Endif 

If	nQtSel > 1 
	MsgInfo(STR0122,STR0054)	//"Selecione apenas um projeto para realizar a copia !"##"Aten็ใo"
	lRet := .F. 	
Endif 

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530MenuPOPบAutor  ณEduardo Gomes Juniorบ Data ณ  24/07/13   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria MENU POUP com opcoes disponiveis 						บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FATA530                                                    	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft530MenuPOP(oObj,nX,nY, oTree,aTree,cArquivo,cSearch,lRefresh,aAreaAF1,lXVisual,oDlg,aSVAlias,nBottomEn,nRight,nLeft,nOldEnch,oPanel,nOpcx)

Local lHabOp01 := .T.
Local lHabOp02 := .T.
Local lHabOp03 := .T.
Local lHabOp04 := .T.
Local lHabOp05 := .T.
Local lHabOp06 := .T.
Local lHabOp07 := .T.
Local lHabOp08 := .T.
Local lHabOp09 := .T.
Local lHabOp10 := .T.
Local lHabOp11 := .T.

If	Val(oTree:CURRENTNODEID)== 1
	lHabOp01 := .T.
	lHabOp02 := .T.
	lHabOp03 := .T.
	lHabOp04 := .T.
	lHabOp05 := .T.
	lHabOp06 := .T.
	lHabOp07 := .F.
	lHabOp08 := .T.
	lHabOp09 := .T.
	lHabOp10 := .T.
Else

	cAlias		:= SubStr(oTree:GetCargo(),1,3)

	Do Case

		Case cAlias == "AF5" .And. AF5->AF5_NIVEL=="001"

			lHabOp01 := .T.
			lHabOp02 := .T.
			lHabOp03 := .T.
			lHabOp04 := .T.
			lHabOp05 := .T.
			lHabOp06 := .T.
			lHabOp07 := .F.
			lHabOp08 := .T.
			lHabOp09 := .T.
			lHabOp10 := .T.
		

		Case cAlias == "AF5" .And. AF5->AF5_NIVEL!="001"
			
			lHabOp01 := .T.
			lHabOp02 := .T.
			lHabOp03 := .T.
			lHabOp04 := .T.
			lHabOp05 := .T.
			lHabOp06 := .T.
			lHabOp07 := .T.
			lHabOp08 := .T.
			lHabOp09 := .T.
			lHabOp10 := .T.

		Case cAlias == "AF2"
	
			lHabOp01 := .F.
			lHabOp02 := .F.
			lHabOp03 := .T.
			lHabOp04 := .T.
			lHabOp05 := .T.
			lHabOp06 := .T.
			lHabOp07 := .T.
			lHabOp08 := .F.
			lHabOp09 := .T.
			lHabOp10 := .T.
			
		Otherwise

			lHabOp01 := .F.
			lHabOp02 := .F.
			lHabOp03 := .F.
			lHabOp04 := .F.
			lHabOp05 := .F.
			lHabOp06 := .F.
			lHabOp07 := .F.
			lHabOp08 := .F.
			lHabOp09 := .F.
			lHabOp10 := .F.
	EndCase
	
Endif 	

If !lXVisual

	MENU oMenu POPUP

	MenuAddItem(STR0007	,,,lHabOp01	,{|| MngItem(3,@oTree,@aTree,"1",cArquivo,@lRefresh),RestArea(aAreaAF1), Nil }	,"","PMSEDT3"		) //"Incluir EDT"
	MenuAddItem(STR0008	,,,lHabOp02	,{|| MngItem(3,@oTree,@aTree,"2",cArquivo,@lRefresh),RestArea(aAreaAF1), Nil }	,"","PMSTASK4"		) //"Incluir Tarefa"
	MenuAddItem(STR0009	,,,lHabOp03	,{|| MngItem(4,@oTree,@aTree,,cArquivo,@lRefresh),If(lRefresh,Eval(oTree:bChange),.F.),RestArea(aAreaAF1), Nil }	,"","ALTERA"		) //"Alterar"
	MenuAddItem(STR0010	,,,lHabOp04	,{|| MngItem(2,@oTree,@aTree,,cArquivo) }	,"","VERNOTA"		) //"Visualizar"
	MenuAddItem(STR0151,,,.T.	,{|| Ft530MvItens(@oTree,@aTree,@oDlg) }	,"","TDI_SETA_DOWN_UP"	)	//"Alterar Posi็ใo"

	MENUITEM "_____________________" Disabled

	MenuAddItem(STR0011	,,,lHabOp05	,{|| MngItem(5,@oTree,@aTree,,cArquivo,@lRefresh),RestArea(aAreaAF1) }	,"","EXCLUIR"		) 	//"Excluir"
	MenuAddItem(STR0124	,,,lHabOp06	,{|| MsgRun(STR0152,STR0124,{ || Ft530ExMult(@oTree,@aTree,cArquivo,@lRefresh)} ) }						,"","NOCHECKED"	) 		//"Excluir M๚ltiplos"###"Aguarde habilitando objeto para marcar/desmarcar item"	

	MENUITEM "_____________________" Disabled

	MenuAddItem(STR0012	,,,lHabOp07	,{|| lRefresh := ChangeEDT(@oTree,@aTree,cArquivo),If(lRefresh, (RestArea(aAreaAF1),Eval(bRefresh)),Nil) }	,"","S4WB014B"		) //"Trocar EDT Pai"
	MenuAddItem(STR0013	,,,lHabOp08	,{|| If(FT531CMP(AF1->(RecNo()),@oTree,cArquivo),(RestArea(aAreaAF1)),Nil) }	,"","SDUIMPORT"		) //"Importar Composicao"

	MENUITEM "_____________________" Disabled

	MenuAddItem(STR0014	,,,lHabOp09	,{|| Procurar(@oTree, @cSearch, cArquivo) }	,"","PESQUISA"		) //"Procurar..."
	MenuAddItem(STR0015	,,,lHabOp10	,{|| ProcurarP(@oTree, @cSearch, cArquivo) }	,"","PMSZOOMIN"		) //"Procurar proxima"
	
	MENUITEM "_____________________" Disabled
	
	MenuAddItem(STR0181	,,,lHabOp11	,{|| Ft530Leg() }	,"","PMSCOLOR"		) //"Legenda"
	
	ENDMENU

	If	lExcMult
	
		MENU oMenu POPUP 

		MenuAddItem(STR0125	,,,.T.	,{|| MsgRun(STR0153,STR0124,{ || Ft530MultEs(1,@oTree,@aTree,@oDlg,@aSVAlias,@nBottomEn,@nRight,@nLeft,@nOldEnch,@oPanel,@nOpcx)  } ) } 	,"","OK"   		) 	//"Confirma"###"Aguarde excluindo itens marcados"###"Excluir M๚ltiplos"	
		MENUITEM "_____________________" Disabled		
		MenuAddItem(STR0126	,,,.T.	,{|| MsgRun(STR0154,STR0124,{ || Ft530MultEs(2,@oTree,@aTree,@oDlg,@aSVAlias,@nBottomEn,@nRight,@nLeft,@nOldEnch,@oPanel,@nOpcx) } ) }	,"","CANCEL"	)	//"Cancela"###"Aguarde cancelando exclusใo"###"Excluir M๚ltiplos"
		MENUITEM "_____________________" Disabled
		MenuAddItem(STR0127	,,,.T.	,{|| MsgRun(STR0155,STR0124,{ || Ft530MultEs(3,@oTree,@aTree,@oDlg,@aSVAlias,@nBottomEn,@nRight,@nLeft,@nOldEnch,@oPanel,@nOpcx) } ) }	,"","LBNO"		)	//"Limpar"###"Aguarde limpando itens marcados"###"Excluir M๚ltiplos"

		ENDMENU			
		
	Endif 
		
Else

	MENU oMenu POPUP
	MenuAddItem(STR0010	,,,.T.	,{|| MngItem(2,@oTree,@aTree,,cArquivo) }		,"","VERNOTA"		) //"Visualizar"	
	MENUITEM "_____________________" Disabled		
	MenuAddItem(STR0014	,,,.T.	,{|| Procurar(@oTree, @cSearch, cArquivo) }	,"","PESQUISA"		) //"Procurar..."
	MenuAddItem(STR0015	,,,.T.	,{|| ProcurarP(@oTree, @cSearch, cArquivo) }	,"","PMSZOOMIN"		) //"Procurar proxima"
	MENUITEM "_____________________" Disabled	
	MenuAddItem(STR0181,,,.T.	,{|| Ft530Leg() }									,"","PMSCOLOR"		) //"Legenda"
	ENDMENU
		
EndIf

oMenu:Activate( nX-80, nY-200, oObj )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณFtA530T3  บAutor  ณVendas CRM          บ Data ณ  16/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณSegmentos de Negocios                                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFaturamento                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function FtA530T3(cModelo)

Local oGetT             		 //Objeto Get superior
Local cGetT		:= Space(60)    //Texto da procura
Local oSayT1	                //Objeto com say procura
Local oGroupT           		//Objeto GroupBox superior
Local oGroupC            		//Objeto GroupBox central
Local oSBtnT         	  		//Objeto button superior procurar
Local oSBtnT2                   //Objeto button superior localizar
Local oSBtnB1          			//Objeto button inferior gravar
Local oSBtnB2                   //Objeto button inferior fechar
Local oPanelT           		//Painel superior que contem objetos GroupBox e TWBrowse
Local oTFontT                   //Objeto fonte Arial
Local oTFontT1                  //Objeto fonte Verdana
Local uPar4 	:= .F.          //Compatibilidade do objeto TFont
Local lBold		:= .T.          //Estilo negrito
Local oPanelC           		//Painel central que contem o objeto button
Local oPanelB          			//Painel inferior que contem o objeto button
Local oBrowse    		    	//Objeto oBrowse com conteudo
Static oDlg                     //Objeto oDlg tela principal

DEFINE MSDIALOG oDlg TITLE STR0079 FROM 000, 000  TO 450, 402 PIXEL


oPanelT := TPanel():New(00,00,/*cText*/,oDlg,/*oFont*/,/*lCentered*/,;
/*uParam7*/,/*nClrText*/,/*nClrBack*/,;
205,025,/*lLowered*/,/*lRaised*/)

oPanelC := TPanel():New(00,00,/*cText*/,oDlg,/*oFont*/,/*lCentered*/,;
/*uParam7*/,/*nClrText*/,/*nClrBack*/,;
205,200,/*lLowered*/,/*lRaised*/)

oPanelB := TPanel():New(400,00,/*cText*/,oDlg,/*oFont*/,/*lCentered*/,;
/*uParam7*/,/*nClrText*/,/*nClrBack*/,;
205,015,/*lLowered*/,/*lRaised*/)

oTFontT := TFont():New('Arial',/*uPar2*/,14,uPar4,lBold)
oTFontT1 := TFont():New('Verdana',/*uPar2*/,13,.T.,.T.)

oPanelT:Align := CONTROL_ALIGN_TOP
oPanelC:Align := CONTROL_ALIGN_ALLCLIENT
oPanelB:Align := CONTROL_ALIGN_BOTTOM

oBrowse := FtAT3Brw(oPanelC,cModelo)

@ 001,001 GROUP oGroupT TO 023, 200 PROMPT STR0080 OF oPanelT  PIXEL
@ 010,005 SAY oSayT1 PROMPT STR0081 SIZE 025, 007 OF oPanelT FONT oTFontT PIXEL
@ 009,032 MSGET oGetT VAR cGetT SIZE 93, 008 OF oPanelT PIXEL
@ 009,131 BUTTON oBtnT1 PROMPT STR0082 SIZE 030, 010 OF oPanelT FONT oTFontT1 PIXEL ACTION  If(FtALocSeg(oBrowse,cGetT, .T. ),oGetT:SetColor(CLR_BLACK,CLR_WHITE),oGetT:SetColor(CLR_WHITE,CLR_HRED))
@ 009,167 BUTTON oBtnT2 PROMPT STR0083 SIZE 030, 010 OF oPanelT FONT oTFontT1 PIXEL ACTION 	If(FtALocSeg(oBrowse,cGetT, .F. ),oGetT:SetColor(CLR_BLACK,CLR_WHITE),oGetT:SetColor(CLR_WHITE,CLR_HRED))
@ 002,002 GROUP oGroupC TO 185, 200 PROMPT STR0084 OF oPanelC PIXEL

DEFINE SBUTTON oSBtnB1 FROM 002, 139 TYPE 01 OF oPanelB ENABLE ACTION(If(FtAGrvAG0(cModelo,oBrowse:aArray),oDlg:End(),Nil))
DEFINE SBUTTON oSBtnB2 FROM 002, 171 TYPE 02 OF oPanelB ENABLE ACTION oDlg:End()

ACTIVATE MSDIALOG oDlg CENTERED

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณFtAT3Brw  บAutor  ณVendas CRM          บ Data ณ  16/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBrowse para marcacao dos Segmentos de Negocios.             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFtA530T3                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FtAT3Brw(oPanelC,cModelo)

Local oBrowse   							//Objeto Browse
Local aBrowse  		:= FtAMntT3(cModelo) //Retorna um array com todos os segmentos de negocios e quais deles pertence ao modelo.
Local oOk 	   		:= LoadBitmap( GetResources(), "LBOK")   //Desenho do Checked
Local oNo 	   		:= LoadBitmap( GetResources(), "LBNO")   //Desenho do Not Checked
Local nRow 			:= 10	   		   		//coordenada vertical.
Local nCol      	:= 05 	   		   		//coordenada horizontal.
Local nWidth    	:= 192 	   				//largura em pixels do objeto.
Local nHeight   	:= 170 		  	    	 //altura em pixels do objeto.
Local aHeaders  	:={'',STR0084}  //tํtulo dos campos no cabe็alho.
Local aColSizes 	:={1,30}           // largura das colunas.
Local bLDblClick 	:= {||}				//bloco de c๓digo que serแ executado quando clicar duas vezes no objeto.
Local uParam20 		:= .F.    //Compatibilidade.
Local lPixel    	:=.T.    //considera as coordenadas passadas em pixels.
Local uParam24  	:=.F.    //Compatibilidade.

oBrowse := TWBrowse():New(nRow,nCol,nWidth,nHeight,/*bLine*/,aHeaders,aColSizes,;
oPanelC,/*cField*/,/*uValue1*/,/*uValue2*/,/*bChange*/,bLDblClick,;
/*bRClick*/,/*oFont*/,/*oCursor*/,/*nClrFore*/,/*nClrBack*/,/*cMsg*/,;
uParam20,/*cAlias*/,lPixel,/*bWhen*/,uParam24,/*bValid*/,/*lHScroll*/,/*lVScroll*/)

oBrowse:SetArray(aBrowse)
oBrowse:bLine := {||{If(aBrowse[oBrowse:nAt,01],oOK,oNO),;
aBrowse[oBrowse:nAt,03]}}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Troca a imagem no duplo click do mouse.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oBrowse:bLDblClick := {|| aBrowse[oBrowse:nAt][1] := !aBrowse[oBrowse:nAt][1],;
oBrowse:DrawSelect()}

Return(oBrowse)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณFtAMntT3  บAutor  ณVendas CRM          บ Data ณ  16/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMontagem do array que contem todos os segmentos de negocios บฑฑ
ฑฑบ          ณe quais deles pertencem ao modelo.                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFtA530T3							                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FtAMntT3(cModelo)

Local aTblT3    := {} 		 			// Array que contem chave e segmento.
Local cTabela   := "T3"	    			// Tabela T3 Segmentos
Local cSegment  := " "     				// Segmento
Local bOrdem    := {|x,y| x[3]<y[3]}  // Bloco de codigo que ordena por ordem alfabetica crescente

DbSelectArea("SX5")
DbSetOrder(1)
If DbSeek(xFilial("SX5")+cTabela)
	
	While SX5->(!EOF()) .AND. SX5->X5_TABELA == cTabela
		
		cSegment := ALLTRIM( X5Descri() )
		
		aAdd(aTblT3,{If(FtALocAG0(cModelo,SX5->X5_CHAVE),.T.,.F.),;
		ALLTRIM(SX5->X5_CHAVE),;
		cSegment})
		SX5->(DbSkip())
	End
EndIf

DbCloseArea()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Ordenacao por ordem alfabetica crescente.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ASort (aTblT3,/*nInicio*/,/*nCont*/,bOrdem)

Return(aTblT3)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณFtAGrvAG0 บAutor  ณVendas CRM          บ Data ณ  16/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava os segmentos de negocios selecionados pelo usuario.   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFtA530T3							                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FtAGrvAG0(cModelo,aSegment)

Local nX := 0 		   //Contador
Local lSelect := .F.  //Variavel logica que indica se o item foi selecionado

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica se existe pelo menos um ณ
//ณ segmento de negocio selecionado. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

AEval(aSegment,{|x|,If(x[1] == .T.,lSelect:=.T.,"")})

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se ha segmento de negocio selecionadoณ
//ณ entra e faz a operacao de gravacao.  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lSelect
	
	DbSelectArea("AG0")
	DbSetOrder(1)
	
	For nX := 1 To Len(aSegment)
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Se o segmento de negocio foi selecionado e nao foi ณ
		//ณ localizado na tabela AG0. Faz a gravacao.          ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		
		If aSegment[nX][1]
			If !FtALocAG0(cModelo,aSegment[nX][2])
				RecLock("AG0",.T.)
				AG0_FILIAL := xFilial("AG0")
				AG0_MODELO := cModelo
				AG0_TABELA := aSegment[nX][2]
				MsUnLock()
			EndIf
		Else
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Se nao verifica se o segmento desmarcado existe ณ
			//ณ na tabela AG0 para exclusao.                    ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			
			If DbSeek(xFilial("AG0")+cModelo+aSegment[nX][2])
				RecLock("AG0",.F.)
				DbDelete()
				MsUnLock()
			EndIf
		EndIf
	Next nX
	
Else
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Se nenhum segmento de negocio foi marcado, ณ
	//ณ exclui todos segmentos para este modelo.   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	DbSelectArea("AG0")
	DbSetOrder(1)
	
	If DbSeek(xFilial("AG0")+cModelo)
		While AG0->(!Eof()) .AND. AG0->AG0_FILIAL == xFilial("AG0") .AND. AG0->AG0_MODELO == cModelo
			RecLock("AG0",.F.)
			DbDelete()
			MsUnLock()
			AG0->(DbSkip())
		End
	EndIf
	
EndIf

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณFtALocAG0 บAutor  ณVendas CRM          บ Data ณ  16/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLocaliza os segmentos de negocios do modelo na tabela AG0.  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFtA530T3							                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FtALocAG0(cModelo,cSegment)

Local lAchou := .F.         //Variavel logica indica se localizou o segmento.

DbSelectArea("AG0")
DbSetOrder(1)

If DbSeek(xFilial("AG0")+cModelo+cSegment)
	lAchou := .T.
EndIf

Return(lAchou)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณFtALocSeg บAutor  ณVendas CRM          บ Data ณ  21/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLocaliza os segmentos de negocios no objeto browse          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFtA530T3                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Static Function FtALocSeg(oBrowse,cString,lInicio)

Static nStartLine		// Controle de pr๓xima procura
Static nStartCol		// Coluna inicial
Local nCount 	:= 0	// Contador temporแrio
Local nCount2	:= 0	// Contador temporแrio
Local lAchou	:= .F.	// Se encontrou a informa็ใo desejada

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicializa a variแvel da linha inicial de procura.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If ValType(nStartLine) <> "N"
	nStartLine := 1
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicializa a variแvel da coluna inicial de procura.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If ValType(nStartCol) <> "N"
	nStartCol := 3
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe ้ para procurar desde o inํcio.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lInicio
	nStartLine	:= 1
	nStartCol	:= 3
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณProcura em todas as linhas e colunas pelo conte๚do solicitado.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nCount := nStartLine To Len(oBrowse:aArray)
	For nCount2 := nStartCol To Len(oBrowse:aArray[nCount])
		If ValType(oBrowse:aArray[nCount][nCount2]) == "C"
			If Upper(AllTrim(cString)) $ Upper(AllTrim(oBrowse:aArray[nCount][nCount2]))
				oBrowse:nAt := nCount
				oBrowse:Refresh()
				nStartLine	:= nCount
				nStartCol	:= nCount2 + 1
				lAchou := .T.
				Exit
			EndIf
		EndIf
	Next
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSe jแ encontrou um resultado, saia.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lAchou
		Exit
	Else
		nStartCol := 3
	EndIf
Next
Return lAchou


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATA530   บAutor  ณMicrosiga           บ Data ณ  07/15/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo para setar os valores do listbox para pagina็ใo.     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CfgPagLbx(oLstBx,cTabName,aCposLst,cAlias)

Local bNextReg	:= Nil

bNextReg			:= {|a,b,c,d,e|Ft530Pag(@a,b,c,d,e)}
oLstBx:bGoBottom	:= {||Eval(bNextReg,oLstBx,cTabName,aCposLst,NMAXPAGE),oLstBx:NAT := EVAL( oLstBx:BLOGICLEN ) }    
oLstBx:bSkip		:= {|NSKIP, NOLD, nMax|nMax:=EVAL( oLstBx:BLOGICLEN ),NOLD := oLstBx:NAT, oLstBx:NAT += NSKIP,;
						oLstBx:NAT := MIN( MAX( oLstBx:NAT, 1 ), nMax ),If(oLstBx:nAt==nMax,Eval(bNextReg,oLstBx,cTabName,aCposLst,NMAXPAGE,cAlias),.F.),;
						oLstBx:NAT - NOLD}
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530ExMultบAutor  ณEduardo Gomes Juniorบ Data ณ  24/07/13   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Muda o BITMAP do TREE e tambem muda funcao acionada no clickบฑฑ
ฑฑบ          ณpara tratar a marca/desmarca de itens para exclusao          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FATA530                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft530ExMult(oTree,aTree,cArquivo,lRefresh)

Local aAreaAF1 	:= AF1->(GetArea())
Local aAreaAF2 	:= AF2->(GetArea())
Local aAreaAF3 	:= AF3->(GetArea())
Local aAreaAF5 	:= AF5->(GetArea())
Local aAreaAF7 	:= AF7->(GetArea())
Local nEx	   	:= 1
Local cBmp 		:= oNoPrd
Local cDesID_AF1:= STR0002 +" Id: "

oTree:BeginUpdate()

For nEx:=2 To Len(oTree:aNodes)

	If	oTree:TreeSeek(oTree:aCargo[nEx,1]) .AND. !cDesID_AF1 $ Alltrim(oTree:aNodes[nEx,4]) 

		oTree:aNodes[nEx,5]	:= oNoPrd
		oTree:aNodes[nEx,6]	:= oNoPrd
		
		oTree:ChangeBmp(cBmp,cBmp,oTree:aCargo[nEx,1])
		
	Endif 		
	
Next nEx 

lExcMult := .T.

oTree:bLDblClick:= {|| Ft530MarDes(oTree,aTree) }
oTree:EndUpdate()
oTree:Refresh()

RestArea(aAreaAF1)
RestArea(aAreaAF2)
RestArea(aAreaAF3)
RestArea(aAreaAF5)
RestArea(aAreaAF7)

oTree:TreeSeek(aTree[1][1])	//Posiciona a arvore na raiz principal

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530MultEsบAutor  ณEduardo Gomes Juniorบ Data ณ  24/07/13   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atraves de opcao selecionada no MENU realizada a acao: 	   บฑฑ
ฑฑบ          ณconfirma / cancela / limpar itens marcados para exclusao     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FATA530                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft530MultEs(nOpcMExcl,oTree,aTree,oDlg,aSVAlias,nBottomEn,nRight,nLeft,nOldEnch,oPanel,nOpcx)

Local aAreaAF1 	:= AF1->(GetArea())
Local aAreaAF2 	:= AF2->(GetArea())
Local aAreaAF3 	:= AF3->(GetArea())
Local aAreaAF5 	:= AF5->(GetArea())
Local aAreaAF7 	:= AF7->(GetArea())
Local cAlias 	:= ""
Local nRecno 	:= 0
Local nEx		:= 1
Local cDesID_AF1:= STR0002 +" Id: "

If	nOpcMExcl == 3
	cBmp := oNoPrd
Endif 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Confirma exclusao de multiplos ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If	nOpcMExcl == 1

	aRegsDel := {}
	
	oTree:Disable()
	oTree:TreeSeek(aTree[1][1])	//Posiciona a arvore na raiz principal
	oTree:bChange := {|| NIL }

	For nEx:=1 To Len(oTree:aNodes)
	
		If	oTree:aNodes[nEx,5] == "LBOK"
		
			cAlias		:= SubStr(oTree:aCargo[nEx,1],1,3)
			nRecAlias	:= Val(SubStr(oTree:aCargo[nEx,1],4,12))
			lRefresh	:= .T.
			
			aadd(aRegsDel,{cAlias,nRecAlias})
			
		Endif 

	Next nEx

	oTree:TreeSeek(aTree[1][1])	//Posiciona a arvore na raiz principal
	
	For nEx:= 1 To Len(aRegsDel)
	
		If	oTree:TreeSeek(aRegsDel[nEx,1]+""+STRZERO(aRegsDel[nEx,2],12) )
		
			If 	aRegsDel[nEx,1] == "AF5"
				FTAExcAF5(,,aRegsDel[nEx,2])
  			ElseIf aRegsDel[nEx,1] == "AF2"
				FTAExcAF2(,,aRegsDel[nEx,2])
			EndIf
			
			oTree:DelItem()	
			
		Endif 			
	
	Next nEx 

	oTree:Enable()   	
	oTree:TreeSeek(aTree[1][1])	//Posiciona a arvore na raiz principal
	
	For nEx:=1 To Len(oTree:aCargo)
	                                 
		If	SubsTr(oTree:aCargo[nEx,1],1,3) == "AF5"
		    cBMP := Ft530Bmp("AF5")
		Else
		    cBMP := Ft530Bmp("AF2")		
		Endif 
		
		oTree:aNodes[nEx,5]	:= cBMP
		oTree:aNodes[nEx,6]	:= cBMP
		oTree:ChangeBmp(oTree:aNodes[nEx,5],oTree:aNodes[nEx,6],oTree:aCargo[nEx,1])
	
	Next nEx 	
	
	oTree:TreeSeek(aTree[1][1])	//Posiciona a arvore na raiz principal

	oTree:bLDblClick:= {|| If(SubStr(oTree:GetCargo(),1,3)=="AF2" , Ft530ChgIt(@oTree,@aTree,,lExcMult),Nil)}
	oTree:bChange 	:= {|| FTAView(@oDlg,@oTree,@aSVAlias,{0,0,nBottomEn,(nRight-nLeft)/2-145},@nOldEnch,@oPanel,nOpcx) }
	lExcMult := .F.

Endif 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cancela exclusao de multiplos ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If	nOpcMExcl == 2

	oTree:bChange:={ || NIL }

	oTree:TreeSeek(aTree[1][1])	//Posiciona a arvore na raiz principal

	For nEx:=1 To Len(oTree:aCargo)

		If	SubsTr(oTree:aCargo[nEx,1],1,3) == "AF5"
		    cBMP := Ft530Bmp("AF5")
		Else
		    cBMP := Ft530Bmp("AF2")		
		Endif 
		
		oTree:aNodes[nEx,5]	:= cBMP
		oTree:aNodes[nEx,6]	:= cBMP
		oTree:ChangeBmp(oTree:aNodes[nEx,5],oTree:aNodes[nEx,6],oTree:aCargo[nEx,1])

	Next nEx 

	oTree:Refresh()
	oTree:bLDblClick:= {|| If(SubStr(oTree:GetCargo(),1,3)=="AF2" , Ft530ChgIt(@oTree,@aTree,,lExcMult),Nil)}
	oTree:bChange 	:= {|| FTAView(@oDlg,@oTree,@aSVAlias,{0,0,nBottomEn,(nRight-nLeft)/2-145},@nOldEnch,@oPanel,nOpcx) }	
	
	lExcMult := .F.

Endif 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Limpa (desmarca) todos os registros marcados ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If	nOpcMExcl == 3

	oTree:TreeSeek(aTree[1][1])	//Posiciona a arvore na raiz principal

	For nEx:=2 To Len(oTree:aNodes)

		If	oTree:TreeSeek(oTree:aCargo[nEx,1]) .AND. !cDesID_AF1 $ Alltrim(oTree:aNodes[nEx,4]) 
		
			oTree:aNodes[nEx,5]	:= cBmp
			oTree:aNodes[nEx,6]	:= cBmp
		
			oTree:ChangeBmp(cBmp,cBmp,oTree:aCargo[nEx,1])			
		
		Endif
	
	Next nEx 

	oTree:Refresh()	

Endif 	

oTree:Refresh()
oTree:TreeSeek(aTree[1][1])	//Posiciona a arvore na raiz principal
Eval(oTree:bChange)

RestArea(aAreaAF1)
RestArea(aAreaAF2)
RestArea(aAreaAF3)
RestArea(aAreaAF5)
RestArea(aAreaAF7)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530MarDesบAutor  ณEduardo Gomes Juniorบ Data ณ  24/07/13   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Marca/desmarca item (EDT/TAREFA) para exclusao              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FATA530                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft530MarDes(oTree,aTree)

Local cCargo	:= oTree:GetCargo()
Local nQtdItens	:= Len(oTree:aNodes)
Local cTrBMP	
Local nEx		:= 1
Local nRecno	:= 0 

nPosicao := aScan(oTree:aCargo,{|x| x[1] == cCargo})

oTree:TreeSeek(cCargo) 

If	oTree:aNodes[nPosicao,5] == oNoPrd

	cTrBMP := oOkPrd

	If	SubStr(oTree:aCargo[nPosicao,1],1,3)	== "AF5"
	
		nRecno:= Val( SubStr(oTree:aCargo[nPosicao,1],4,12) )
		
		If	!Ft530vItObr("AF5",nRecNo)
			Return(.F.)		
		Endif 
		
		If	!Ft530VlPre("AF5",nRecno,@aTree,,,,.T.)
			Return(.F.)
		Endif 

		For nEx:=( (nPosicao) + 1 ) To nQtdItens
		
			nRecno:= Val( SubStr(oTree:aCargo[nEx,1],4,12) )
			
			dbSelectArea("AF2")
			dbGoTo(nRecNo)

			If	AF2->AF2_EDTPAI == AF5->AF5_EDT

				oTree:aNodes[nEx,5]	:= cTrBMP
				oTree:aNodes[nEx,6]	:= cTrBMP
		
				oTree:ChangeBmp(cTrBMP,cTrBMP,oTree:aCargo[nEx,1])
				
			Endif 				

		Next nEx

	Endif 
	
Else

	cTrBMP := oNoPrd

	If	SubStr(oTree:aCargo[nPosicao,1],1,3)	== "AF5"
	
		For nEx:=( (nPosicao) + 1 ) To ( oTree:NADDTREE )
		
			nRecno:= Val( SubStr(oTree:aCargo[nEx,1],4,12) )
		
			dbSelectArea("AF2") 
			dbGoTo(nRecNo)

			If	AF2->AF2_EDTPAI == AF5->AF5_EDT

				oTree:aNodes[nEx,5]	:= cTrBMP
				oTree:aNodes[nEx,6]	:= cTrBMP
		
				oTree:ChangeBmp(cTrBMP,cTrBMP,oTree:aCargo[nEx,1])
			Endif 				

		Next nEx

	Endif 	
	
Endif 

If	SubStr(oTree:aCargo[nPosicao,1],1,3)	== "AF2"

	nRecno:= Val( SubStr(oTree:aCargo[nPosicao,1],4,12) )

	If	!Ft530vItObr("AF2",nRecNo)
		Return(.F.)		
	Endif 
	
	If	!Ft530VlPre("AF2",nRecno,@aTree,,,,.T.)
		Return(.F.)
	Endif 

Endif

oTree:ChangeBmp(cTrBMP,cTrBMP,oTree:GetCargo())	
oTree:aNodes[nPosicao,5]	:= cTrBMP
oTree:aNodes[nPosicao,6]	:= cTrBMP

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530vItObrบAutor  ณEduardo Gomes Juniorบ Data ณ  24/07/13   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Aciona as funcoes de validacao de item obrigatorio EDT e    บฑฑ
ฑฑบ          ณ tarefa.                                                     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FATA530                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft530vItObr(cAlias,nRecNo)

Local aArea			:= GetArea()
Local aAreaAF2		:= GetArea()
Local aAreaAF5		:= GetArea()
Local lRet			:= .T.
Local cNrOrcAF5 	:= ""
Local cEdPaiAF5 	:= ""
Local nQtdEDTo  	:= 0

Default lExcMult 	:= .F.

If	cAlias	== "AF2"

	dbSelectArea("AF2")
	dbGoTo(nRecNo)
	If	AF2->AF2_REGOBR == "1"
		MsgAlert(STR0128,STR0054)	//"Tarefa obrigat๓ria. Nใo serแ possํvel excluir!"###"Aten็ใo"
		lRet := .F.
	Else
		dbSelectArea("AF5")
		dbSetOrder(1)
		If	dbSeek(xFilial("AF5")+AF2->AF2_ORCAME+AF2->AF2_EDTPAI) .AND. AF5_REGOBR == "1"
			MsgAlert(STR0129,STR0054)	//"EDT obrigat๓ria no projeto. Nใo serแ possํvel excluir nenhuma tarefa!"###"Aten็ao"
			lRet := .F.
		Endif 
	Endif 		
	
Endif 

If	cAlias	== "AF5"	
	
	dbSelectArea("AF5")
	dbGoTo(nRecNo)
	If	AF5->AF5_REGOBR == "1"
		MsgAlert(STR0130,STR0054)	//"EDT obrigat๓ria no projeto. Nใo serแ possํvel excluir!"###"Aten็ao"
		lRet := .F.
	Else
	
		cNrOrcAF5 := AF5->AF5_ORCAME
		cEdPaiAF5 := AF5->AF5_EDT
		
		Processa({|| lRet := Ft530VlAF5(cNrOrcAF5,cEdPaiAF5) },STR0134)	//"Analisando EDTs"
		
		If	lRet
			Processa({|| lRet := Ft530VlAF2(cNrOrcAF5,cEdPaiAF5) },STR0131)	//"Analisando tarefas"
		Endif 			

	Endif                           
	
Endif 

RestArea(aArea)
RestArea(aAreaAF2)
RestArea(aAreaAF5)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530VlAF5บAutor  ณEduardo Gomes Juniorบ Data ณ  24/07/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida a existencia de EDTS obrigatorias no projeto        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FATA530                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft530VlAF5(cNrOrcAF5,cEdPaiAF5)

Local aArea		:= GetArea()
Local lRet		:= .T.
Local cQuery
Local nSmObrig	:= 0

cQuery	:= "SELECT AF5_ORCAME, AF5_EDT, AF5_REGOBR "
cQuery	+= " FROM " + RetSqlName("AF5")
cQuery	+= " WHERE "
cQuery	+= " AF5_FILIAL = '" + xFilial("AF5") + "' AND "
cQuery	+= " AF5_ORCAME = '" + cNrOrcAF5 + "' AND "
cQuery	+= " AF5_EDTPAI = '" + cEdPaiAF5 + "' AND "
cQuery	+= " D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery( cQuery )
	
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TMP_AF5EDT" ,.T.,.T.)
	         
DbSelectArea("TMP_AF5EDT")
DbGoTop()

ProcRegua(TMP_AF5EDT->(FCount()))

While !EOF()

	If	TMP_AF5EDT->AF5_REGOBR == "1"
		MsgAlert(STR0132+''+STR0135,STR0054)	//"Existe(m)"###" EDT(s) obrigatoria(s). EDT principal nใo pode ser excluํda!"###"Aten็ใo"
		lRet := .F.
		Exit 
	Else
		Processa({|| lRet := Ft530VlAF2(TMP_AF5EDT->AF5_ORCAME,TMP_AF5EDT->AF5_EDT) },STR0131)	//"Analisando tarefas"
	
		If	!lRet
			Exit 
		Endif
		
	Endif
	
	DbSelectArea("TMP_AF5EDT")
	dbSkip() 

Enddo

TMP_AF5EDT->(dbCloseArea())	

RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530VlAF2บAutor  ณEduardo Gomes Juniorบ Data ณ  24/07/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida a existencia de tarefa obrigatorias no projeto	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FATA530                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft530VlAF2(cNrOrcAF5,cEdPaiAF5)

Local aArea		:= GetArea()
Local cQuery
Local lRet		:= .T.

cQuery	:= "SELECT COUNT(*) AS nAF2OBRG "
cQuery	+= " FROM " + RetSqlName("AF2")
cQuery	+= " WHERE "
cQuery	+= " AF2_FILIAL = '" + xFilial("AF2") + "' AND "
cQuery	+= " AF2_ORCAME = '" + cNrOrcAF5 + "' AND "
cQuery	+= " AF2_EDTPAI = '" + cEdPaiAF5 + "' AND "
cQuery	+= " AF2_REGOBR = '1' AND "
cQuery	+= " D_E_L_E_T_ = ' ' "

TCQuery cQuery New Alias "TMP_AF2EDT"

dbSelectArea("TMP_AF2EDT")
dbGotop()	
		
ProcRegua(TMP_AF2EDT->(FCount()))
		
If	TMP_AF2EDT->nAF2OBRG > 0
	MsgAlert(STR0132+' '+STR0133,STR0054)	//"Existe(m)"###" tarefa(s) obrigatoria(s). EDT nใo pode ser excluida!"###"Aten็ใo"
	lRet := .F.		
Endif 			
		
TMP_AF2EDT->(dbCloseArea())	

RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530HabCposบAutor  ณEduardo Gomes Juniorบ Data ณ  24/07/13   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Habilita os campos AF2_REGOBR / AF5_REGOBR quando rotina de	บฑฑ
ฑฑบ          ณservicos nao for acionada dentro da proposta comercial.       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ WHEN dos campos AF2_REGOBR / AF5_REGOBR                     	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft530HabCpos()

Local lRet	:= .T.

If	IsInCallStack("A600SERVICOS")
	lRet := .F.
Endif 	

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530MvItensบAutor  ณEduardo Gomes Juniorบ Data ณ  13/08/13   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Interface com opcao de mover item do projeto(para cima/baixo)บฑฑ
ฑฑบ          ณa exibi็ใo dos itens ocorre de acordo com o tipo de item      บฑฑ
ฑฑบ          ณAF5 (EDT) / AF2 (TAREFA).									    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FATA530                                                     	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft530MvItens(oTree,aTree,oDlg)

Local oDlgDMove
Local aHeaderMv		:=	{}
Local aColsMv		:=	{}
Local nEx			:= 1
Local nOrdem		:= 1
Local cCargo		:= oTree:GetCargo()
Local nPosicao		:= 0
Local cAliasPo		:= ""
Local nRecnoPo		:= 0
Local nIniTree		:= 0
Local cTitMov	

PRIVATE oGetDMove
PRIVATE bRefrMvs	:= {|| oGetDMove:oBrowse:Refresh() }

AADD(aHeaderMv,{"+"			,"UP"			,"@BMP"		,01,,,,"C",,"V"})	//"+"
AADD(aHeaderMv,{"-"			,"DOWN"			,"@BMP"		,01,,,,"C",,"V"})	//"-"
AADD(aHeaderMv,{STR0137		,"TRB_POSICAO"	,"999"		,03,,,,"N",,"V"})	//"Ordem"	
AADD(aHeaderMv,{STR0138 	,"TRB_DESCRI"	,"@!"		,90,,,,"C",,"V"})	//"Decri็ใo"
AADD(aHeaderMv,{STR0139		,"TRB_ORCAME"	,"@!"		,10,,,,"C",,"V"})	//"Or็amento"
AADD(aHeaderMv,{STR0140		,"TRB_EDT"		,"@!"		,20,,,,"C",,"V"})	//"EDT/TAREFA"

nPosicao 	:= aScan(oTree:aCargo,{|x| x[1] == cCargo})
cAliasPo	:= SubStr(oTree:aCargo[nPosicao,1],1,3)
nRecnoPo	:= Val( SubStr(oTree:aCargo[nPosicao,1],4,12) )

If	cAliasPo == "AF5"
                                                    
	cTitMov	:= STR0141	//" <<< Alterar posi็ใo de EDT(s) >>> "
	
	nRecnoPo 	:= Val( SubStr(oTree:aCargo[nPosicao,1],4,12) )
	
	dbSelectArea("AF5")
	dbGoTo( nRecnoPo )

	cEDT_Pri := AF5->AF5_EDT
	nNvlEstr := Val(AF5->AF5_NIVEL)	+1
	
	If	nPosicao == 1
		nNvlEstr	:= 2
	Endif 

	nIniTree := nPosicao
		
	For nEx:= nIniTree To Len(oTree:aCargo)	
	
		nRecnoPo := Val( SubStr(oTree:aCargo[nEx,1],4,12) )
	
		dbSelectArea("AF5")
		dbGoTo( nRecnoPo )
		
		If	nPosicao == 1 .AND. nNvlEstr == 2
			lAplVld		:= Val(AF5->AF5_NIVEL) == nNvlEstr
		Else
			lAplVld		:= Val(AF5->AF5_NIVEL) == nNvlEstr .AND. AF5->AF5_EDTPAI == cEDT_Pri			
		Endif 

		If	SubsTr(oTree:aCargo[nEx,1],1,3) == "AF5" .AND. lAplVld
			AADD(aColsMv,{oSetUP,oSetDown,nOrdem,oTree:aNodes[nEx,4],AF5->AF5_ORCAME,AF5->AF5_EDT,.F.})
			nOrdem +=1
		Endif 			
		
	Next nEx		
		
Endif

If	cAliasPo == "AF2"

	cTitMov	:= STR0142	//" <<< Alterar posi็ใo de TAREFA(s) >>> "
	
	nRecnoPo 	:= Val( SubStr(oTree:aCargo[nPosicao,1],4,12) )
	cEDT_Pri	:= AF2->AF2_EDTPAI

	dbSelectArea("AF2")
	dbGoTo( nRecnoPo )
	nNvlEstr := Val(AF2->AF2_NIVEL)
	
	nIniTree := nPosicao
		
	For nEx:= nIniTree To Len(oTree:aCargo)	
	
		nRecnoPo := Val( SubStr(oTree:aCargo[nEx,1],4,12) )
	
		dbSelectArea("AF2")
		dbGoTo( nRecnoPo )

		If	SubsTr(oTree:aCargo[nEx,1],1,3) == "AF2" .AND. Val(AF2->AF2_NIVEL) == nNvlEstr .AND. AF2->AF2_EDTPAI == cEDT_Pri
			AADD(aColsMv,{oSetUP,oSetDown,nOrdem,oTree:aNodes[nEx,4],AF2->AF2_ORCAME,AF2->AF2_TAREFA,.F.})
			nOrdem +=1
		Endif 			
		
	Next nEx		
		
Endif

DEFINE MSDIALOG oDlgDMove TITLE STR0143 FROM 0,0 TO 461,545 OF oDlgDMove PIXEL	//"Alterar posi็ใo de EDT(s)/TAREFA(s)"

@ 05,05 TO 210,270 Label cTitMov PIXEL OF oDlgDMove

oGetDMove:=	MsNewGetDados():New(015,010,203,263,GD_UPDATE,,"AllwaysTrue()","AllwaysTrue()",{"TRB_UP","TRB_DOWN","TRB_POSICAO","TRB_DESCRI"},000,99,"AllwaysTrue()", "AllwaysTrue()","AllwaysTrue()",oDlgDMove,aHeaderMv,aColsMv)
oGetDMove:oBrowse:bLDblClick := {|uOpc,nCol| Ft530Move(nCol,oGetDMove:oBrowse:bLDblClick) }

oGetDMove:oBrowse:bLine := {||{ Transform(aColsMv[oGetDMove:nAt,03],"999") }}
oGetDMove:oBrowse:bChange := { || Ft530ColMv(oGetDMove) }

@ 215,105 BUTTON STR0144 	SIZE 50,10 PIXEL ACTION MsgRun(STR0145	,cTitMov, 	{|| Ft530ConfMove(@oTree,@aTree,oGetDMove,cAliasPo,"1") , oDlgDMove:End(), { || lConfirma:=.T., oDlg:End() }  } ) WHEN If( Len(aColsMv) > 1 , .T. , .F. )	//"&Salvar"###"Salvando posi็oes no projeto"
@ 215,160 BUTTON STR0146	 	SIZE 50,10 PIXEL ACTION MsgRun(STR0147	,cTitMov,	{|| Ft530ConfMove(@oTree,@aTree,oGetDMove,cAliasPo,"2") , oDlgDMove:End(), { || lConfirma:=.T., oDlg:End() }  } ) WHEN If( Len(aColsMv) > 1 , .T. , .F. )	//"Salvar/&Atualizar"###"Salvando/Atualizando posi็๕es no projeto"
@ 215,215 BUTTON STR0148 	SIZE 50,10 PIXEL ACTION {|| oDlgDMove:End() }	//"C&ancelar"

ACTIVATE MSDIALOG oDlgDMove CENTER

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530Move บAutor  ณEduardo Gomes Juniorบ Data ณ  13/08/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Move o item do projeto de acordo com opcao escolhida		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FATA530                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft530Move(nCol, bBlock )

Local uRet 			:= Nil

Default nCol 		:= 0
Default bBlock		:= Nil

N := oGetDMove:NAT

If nCol == 1

	If n > 1
		aAux 						:= oGetDMove:aCols[n-1]
		oGetDMove:aCols[n-1] 		:= oGetDMove:aCols[n]
		oGetDMove:aCols[n]			:= aAux
		oGetDMove:aCols[n][3]		:= oGetDMove:aCols[n-1][3]
		oGetDMove:aCols[n-1][3]		:= n-1    
	Else
		MsgAlert(STR0149,STR0054)	//"Nใo ้ possํvel mover esse item para cima!"###"Aten็ใo"
	EndIf
	
ElseIf nCol == 2

	If n < len(oGetDMove:aCols)
		aAux 						:= oGetDMove:aCols[n+1]
		oGetDMove:aCols[n+1]		:= oGetDMove:aCols[n]
		oGetDMove:aCols[n]			:= aAux
		oGetDMove:aCols[n][3]		:= oGetDMove:aCols[n+1][3]
		oGetDMove:aCols[n+1][3]		:= n+1
	Else                           
		MsgAlert(STR0150,STR0054)	//"Nใo ้ possํvel mover esse item para baixo!"###"Aten็ใo"
	EndIf
	
EndIf

oGetDMove:Refresh()

Eval(bRefrMvs)

Return uRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530ColMvบAutor  ณEduardo Gomes Juniorบ Data ณ  13/08/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Preenche a primeira e segunda coluna do TREE com os        บฑฑ
ฑฑบ          ณBITMAPS (seta para cima / seta para baixo)                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FATA530                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft530ColMv(oGetDMove) 

Default oGetDMove := Nil

If	oGetDMove <> Nil

	oGetDMove:aCols[oGetDMove:NAT][1] := oSetUP
	oGetDMove:aCols[oGetDMove:NAT][2] := oSetDown

	oGetDMove:Refresh()

Endif 

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530ConfMoveบAutor  ณMicrosiga           บ Data ณ  13/08/13   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza o TREE do projeto com as novas posicoes				 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FATA530                                                     	 บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft530ConfMove(oTree,aTree,oGetDMove,cAliasPo,cTpSalv)

Local nAtOrdem := 1

If	cAliasPo == "AF5"

	dbSelectArea("AF5")
	dbSetOrder(5)

	For nAtOrdem:=1 To Len(oGetDMove:aCols)

		If	dbSeek(xFilial("AF5")+oGetDMove:aCols[nAtOrdem,5]+M->AF1_VERSAO+oGetDMove:aCols[nAtOrdem,6])
			RecLock("AF5",.F.)
			AF5_ORDEM := StrZero(oGetDMove:aCols[nAtOrdem,3],3)
			MsUnLock()
		Endif 

	Next nAtOrdem

Endif 

If	cAliasPo == "AF2"

	dbSelectArea("AF2")
	dbSetOrder(5)

	For nAtOrdem:=1 To Len(oGetDMove:aCols)

		If	dbSeek(xFilial("AF2")+oGetDMove:aCols[nAtOrdem,5]+M->AF1_VERSAO+oGetDMove:aCols[nAtOrdem,6])
			RecLock("AF2",.F.)
			AF2_ORDEM := StrZero(oGetDMove:aCols[nAtOrdem,3],3)
			MsUnLock()
		Endif 

	Next nAtOrdem

Endif 

If	cTpSalv == "2"

	oTree:TreeSeek(aTree[1][1])	//Posiciona a arvore na raiz principal

	AF5->(DbGoTo(Val(SubStr(aTree[1][1],4,12)))) //Posiciona AF5 na raiz 
	AF7->(DbSetOrder(1)) //AF7_FILIAL+AF7_ORCAME+AF7_TAREFA+AF7_ITEM
	AF3->(DbSetOrder(1)) //AF3_FILIAL+AF3_ORCAME+AF3_TAREFA+AF3_ITEM
	AF1->(DbSetOrder(2)) //AF2_FILIAL+AF2_ORCAME+AF2_EDTPAI+AF2_ORDEM
	AF2->(DbSetOrder(2)) //AF2_FILIAL+AF2_ORCAME+AF2_EDTPAI+AF2_ORDEM
	AF5->(DbSetOrder(2)) //AF5_FILIAL+AF5_ORCAME+AF5_EDTPAI+AF5_ORDEM
	
	oTree:BeginUpdate()
	oTree:Reset()

	AddEDT(@oTree,@aTree,AF5->AF5_ORCAME+AF5->AF5_VERSAO+AF5->AF5_EDT,"AF1,AF5,AF2,AF3", 2,"AF5"+StrZero(AF5->(RecNo()),12),.T.)
	
	oTree:EndUpdate()
	oTree:Display()
	
Endif 	

oTree:Refresh()
oTree:TreeSeek(aTree[1][1])	//Posiciona a arvore na raiz principal
Eval(oTree:bChange)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530VerPRJบAutor  ณKaren Potzik        บ Data ณ  15/08/13   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Interface para criar nova versao do simulador ou realizar   บฑฑ
ฑฑบ          ณmanutencao em versao existente                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FATA530                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ft530VerPRJ(cProjeto,cVersPrj)

Local aArea			:= GetArea()
Local oDlgVers
Local oListBox
Local aListBox		:= {}
Local aModOri		:= {}
Local oOkVer    	:= LoadBitMap(GetResources(), "LBOK")
Local oNoVer    	:= LoadBitMap(GetResources(), "LBNO")
Local cQuery
Local aRetVersao			:= {}
Local nl			:= 0 
Local cNextEDT  

DEFAULT cProjeto := ' '
DEFAULT cVersPrj := ' '

//Query para escolha de versoes existentes
cAlias 	:= GetNextAlias()
cAliasB	:= GetNextAlias()
	
If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf
	
cQuery	:= "SELECT AF1.AF1_FILIAL, AF1.AF1_ORCAME,AF1.AF1_VERSAO,(SELECT MAX(AF1X.AF1_VERSAO) FROM " + RetSqlName("AF1") +" AF1X WHERE AF1X.AF1_FILIAL = '"+xFilial("AF1")+"  ' AND AF1X.AF1_ORCAME = '" + cProjeto + "' AND AF1X.D_E_L_E_T_ = ' ')  MAXVER"
cQuery	+= " FROM " + RetSqlName("AF1") +" AF1 "
cQuery	+= " WHERE AF1.AF1_FILIAL = '" + xFilial("AF1") + "' "
cQuery	+= "   AND AF1.AF1_ORCAME = '" + cProjeto + "' "
cQuery	+= "   AND AF1.D_E_L_E_T_ = ' ' "  
cQuery	+= " ORDER BY AF1.AF1_FILIAL,AF1.AF1_ORCAME"
cQuery := ChangeQuery( cQuery )
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias,.T.,.T.)
DbSelectArea(cAlias)
DbGoTop()
	
If !(cAlias)->(Eof())
	While !(cAlias)->(Eof())
		Aadd(aListBox,{.F.,AllTrim((cAlias)->AF1_ORCAME),AllTrim((cAlias)->AF1_VERSAO)})  
		cMaxVer := (cAlias)->MAXVER
		(cAlias)->(DbSkip())
	End
	(cAlias)->(DbCloseArea())
Else	
	(cAlias)->(DbCloseArea())
	Return({.F.,,})
EndIf	
 
//Query para identificar modelos vinculados ao projeto
If Select(cAliasB) > 0
	(cAliasB)->(DbCloseArea())
EndIf
	
cQuery	:= "SELECT AF5.AF5_FILIAL, AF5.AF5_ORCAME,AF5.AF5_VERSAO, AF5.AF5_MODORI"
cQuery	+= " FROM " + RetSqlName("AF5") +" AF5 "
cQuery	+= " WHERE AF5.AF5_FILIAL = '" + xFilial("AF5") + "' "
cQuery	+= "   AND AF5.AF5_ORCAME = '" + cProjeto + "' "
cQuery	+= "   AND AF5.AF5_VERSAO = '001' "
cQuery	+= "   AND AF5.AF5_MODORI  <> ' ' "
cQuery	+= "   AND AF5.D_E_L_E_T_ = ' ' "  
cQuery	+= " ORDER BY AF5.AF5_FILIAL,AF5.AF5_ORCAME"
cQuery := ChangeQuery( cQuery )
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasB,.T.,.T.)
DbSelectArea(cAliasB)
DbGoTop()
If !(cAliasB)->(Eof())
	While !(cAliasB)->(Eof())
		Aadd(aModOri,{AllTrim((cAliasB)->AF5_ORCAME),AllTrim((cAliasB)->AF5_VERSAO),AllTrim((cAliasB)->AF5_MODORI)})  
		(cAliasB)->(DbSkip())
	End
	(cAliasB)->(DbCloseArea())
EndIf	
DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD

DEFINE MSDIALOG oDlgVers TITLE STR0158 + cProjeto FROM  000,000 TO 200,450 PIXEL OF oMainWnd //"Projetos(s) gerado para proposta: "
	
oListBox := TWBrowse():New( 04,02,225,080,,{" ",STR0159,STR0160},,oDlgVers,,,,,,,,,,,,.F.,,.T.,,.F.,,,) //"No.Projeto"###"Versao"
oListBox:SetArray(aListBox)
oListBox:bLDblClick :=  { || aListBox[oListBox:nAt,1] := !aListBox[oListBox:nAt,1],aRetVersao:= FTA530Dlg("AF1",,3,,,,,.T.,,,aListBox[oListBox:nAt,2],aListBox[oListBox:nAt,3],.F.),(oDlgVers:End())}
oListBox:bLine := { || {If(aListBox[oListBox:nAt,1],oOkVer,oNoVer),aListBox[oListBox:nAt,2],aListBox[oListBox:nAt,3]}}
	
@ 086 ,020  BUTTON STR0161 	SIZE 85 ,10  FONT oDlgVers:oFont ACTION Processa({||Ft530VerAF1(aListBox[oListBox:nAt,2],cMaxVer,aModOri),aRetVersao:= FTA530Dlg("AF1",,3,,,,,.T.,,,aListBox[oListBox:nAt,2],Soma1(cMaxVer),.T.),oDlgVers:End()})  OF oDlgVers PIXEL  //"&Nova Versao"
@ 086 ,118  BUTTON STR0162	SIZE 85 ,10  FONT oDlgVers:oFont ACTION (oDlgVers:End())  OF oDlgVers PIXEL 																			//"&Cancelar"

	
ACTIVATE MSDIALOG oDlgVers CENTERED
        
RestArea(aArea)

Return(aRetVersao) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530VerAF1บAutor  ณKaren Potzik        บ Data ณ  15/08/13   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria nova versao do projeto. Sempre usando como partida o   บฑฑ
ฑฑบ          ณprojeto original (modelo usado na primeira versao)           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FATA530                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ft530VerAF1(cProjeto,cVersPrj,aModOri)
               
Local aAreaAF1		:= AF1->(GetArea())
Local cNewVer		:= Soma1(cVersPrj)
Local aStructAF1	:= AF1->(DBStruct())
Local nLenStruct	:= Len( aStructAF1 )
Local nX			:= 0
Local aAF1Data		:= {}
Local cMasc			:= GetMv("MV_AF1MASC",,"2222222222")
Local cDelim		:= GetMv("MV_AF1DELI",,".")

AF1->( DBSetOrder(8) ) //AF1_FILIAL+AF1_ORCAME+AF1_VERSAO                                                                                                                                

If AF1->( DBSeek( xFilial("AF1") + cProjeto + cVersPrj ) )
	
	//Faz copia do AF1 para gerar uma nova versใo.
	For nX := 1 To nLenStruct 
		aAdd( aAF1Data, { aStructAF1[nX][1], AF1->( FieldGet( FieldPos( aStructAF1[nX][1] ) ) ) } )
	Next nX
	
	RecLock("AF1",.T.)
	For nX := 1 To nLenStruct
		Do Case 
			Case aAF1Data[nX][1] == "AF1_VERSAO"
				AF1->AF1_VERSAO	:= cNewVer
			Case aAF1Data[nX][1] == "AF1_DESCRI"
				AF1->AF1_DESCRI	:= STR0002 +" Id: "+ cProjeto + cNewVer
			Case aAF1Data[nX][1] == "AF1_DATA"
				AF1->AF1_DATA		:= dDataBase 
			Case aAF1Data[nX][1] == "AF1_MASCAR"
				AF1->AF1_MASCAR		:= cMasc
			Case aAF1Data[nX][1] == "AF1_DELIM"
				AF1->AF1_DELIM 		:= cDelim
			OtherWise
				AF1->( FieldPut( nX , aAF1Data[nX][2] ) )
		EndCase		
	Next nX
	AF1->( MsUnlock() )	
	
	RecLock("AF5",.T.)
	AF5->AF5_FILIAL	:= xFilial("AF5")
	AF5->AF5_ORCAME	:= AF1->AF1_ORCAME
	AF5->AF5_VERSAO	:= AF1->AF1_VERSAO
	AF5->AF5_EDT		:= AF1->AF1_ORCAME
	AF5->AF5_DESCRI	:= AF1->AF1_DESCRI
	AF5->AF5_NIVEL	:= "001"
	AF5->AF5_STATUS	:= "1"
	AF5->( MsUnlock() )			
	
	AF7->(DbSetOrder(3)) //AF7_FILIAL+AF7_ORCAME+AF7_VERSAO+AF7_TAREFA+AF7_ITEM
	AF3->(DbSetOrder(5)) //AF3_FILIAL+AF3_ORCAME+AF3_VERSAO+AF3_TAREFA+AF3_ITEM
	AF2->(DbSetOrder(6)) //AF2_FILIAL+AF2_ORCAME+AF2_VERSAO+AF2_EDTPAI+AF2_ORDEM
	AF5->(DbSetOrder(6)) //AF5_FILIAL+AF5_ORCAME+AF5_VERSAO+AF5_EDTPAI+AF5_ORDEM
				
	For nX := 1 to Len(aModOri)
		cNextEDT	:= Ft530NwEdt() 
		Ft530Copia(aModOri[nX][3],cProjeto,cNextEDT,,,cProjeto,,.T.,'001',cNewVer) 
	Next
	
EndIf

RestArea(aAreaAF1)
               
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530Prgt บAutor  ณEduardo Gomes Juniorบ Data ณ  18/09/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Habilita objeto para cadastrar/responder perguntas no      บฑฑ
ฑฑบ          ณ modelo/simulacao.                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FATA530                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ft530Prgt(oPanel,oDlg,nOpcx,cAlias, cTipoOp	, cCodProc	, cVersao	, cLocaliz )

Local aArea		:= GetArea()
Local aTitles	:= {STR0166}	//"Pergunta(s)"
Local nHResol	:=	oMainWnd:nClientHeight	 //Resolucao vertical do monitor
Local nIniFol	:= If(nHResol<847,If(cAlias == "AF2",205,125),If(cAlias == "AF2",250,165))	//If(cAlias == "AF2",250,165)
Local nLeft     := oMainWnd:nLeft+10
Local nRight    := oMainWnd:nRight-10
Local nLargura	:= (nRight-nLeft)/2-150
Local nAltura	:= ((oDlg:nBottom-oDlg:nTop)/2)- If(nHResol<847,If(cAlias == "AF2",080,030),If(cAlias == "AF2",280,195)) //If(cAlias == "AF2",280,195)
Local aHeadPer	:= {}
Local aColsPer	:= {}
Local nOpc		:= 0
Local nGdOpc	:= 0
Local nX		:= 0
Local lIncBk	:= INCLUI
Local lAltBk	:= ALTERA
Local lModelo	:= IsInCallStack("FATA530A")
Local aCposNao	:= {}
Local aAlter	:= {}
Local lGrava	:= .F.
Local bAfterCols:= {|aC,aH|Ft530IniCp(aC,aH)}
Local bActResp	:= {||Ft530RsQst()}
Local bSeekFor	:= {||.T.}
Local cFieldOk	:= "" 
Local nOpcGD	:= 0
Local oFoldPg	:= Nil
Local oPerg		:= Nil
Local cQuery

Default cLocaliz	:= ""

If	lModelo
	cTipoOp 	:= "2"
	aCposNao 	:= {"AG6_TIPO","AG6_CODPRO","AG6_LOCAL","AG6_VERSAO","AG6_VERORI","AG6_EDT","AG6_RESP","AG6_MARCA"}
	nOpc		:= aRotina[nOpcX][4]
Else
	cTipoOp 	:= "3"
	aCposNao 	:= {"AG6_TIPO","AG6_CODPRO","AG6_LOCAL","AG6_VERSAO","AG6_VERORI","AG6_EDT"}
	nOpc		:= 4
Endif 

aObj[4][1]:= TFolder():New(nIniFol,3,aTitles,{},oPanel,,,,.T.,.T.,nLargura,nAltura)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณA validacao Ft530RlFOk deve verificar se a pergunta estaณ
//ณse relacionando a uma tarefa ou ao modelo               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If	cAlias == "AF5"
	cFieldOk	:= "Ft530RlFOk(.F.)"
Else
	cFieldOk	:= "Ft530RlFOk(.T.)"
EndIf

DbSelectArea("AG6")
DbSetOrder(4) //AG6_FILIAL+AG6_TIPO+AG6_CODPRO+AG6_VERSAO+AG6_LOCAL+AG6_CODPER

cQuery := "SELECT * FROM " +  RetSqlName("AG6") + " AG6"
cQuery += " WHERE AG6_FILIAL = '"+xFilial("AG6") +"' AND AG6_TIPO = '"+cTipoOp+"' AND AG6_CODPRO = '"+cCodProc+"' AND AG6_VERSAO = '"+cVersao+"' AND AG6_LOCAL = '"+cLocaliz+"' "
cQuery += " AND D_E_L_E_T_ = ' ' "

FillGetDados(nOpc,"AG6",4,,,bSeekFor,aCposNao,,,cQuery,,,@aHeadPer,@aColsPer,bAfterCols)

If	lModelo
	nOpcGD	:= IIF((INCLUI .OR. ALTERA) .AND. lModelo,GD_INSERT+GD_UPDATE+GD_DELETE,0)
Else
	nOpcGD	:= 0
Endif 	

nHRes	:=	oMainWnd:nClientWidth	//Resolucao horizontal do monitor

oGd[4]:= MsNewGetDados():New(4,4,(aObj[4][1]:nHeight/3)+If(cAlias == "AF2",30,58),((aObj[4][1]:nWidth/2)-5),nOpcGD,,,,,,,cFieldOk,,"FT530Delp",aObj[4][1]:ADIALOGS[1],aHeadPer,aColsPer)

If	!lModelo
	oGd[4]:oBrowse:bLDblClick := bActResp
Endif 	

oGd[4]:Refresh()

RestArea(aArea)

Return Nil 
                                                                      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFT530Delp บAutor  ณEduardo Gomes Juniorบ Data ณ  25/09/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao usada para excluir perguntas dentro do modelo       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FATA530                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FT530Delp()

Local lRet		:= .T.
Local nPDel		:= Len(oGd[4]:aHeader)+1
Local lDelet	:= aCols[oGd[4]:nAt][nPDel]
Local nPRecn	:= aScan(oGd[4]:AHEADER,{|x|AllTrim(x[2]) == "AG6_REC_WT"	})
Local lModelo	:= IsInCallStack("FATA530A")

If	lModelo

	aCols[oGd[4]:nAt][nPDel] := !lDelet

	If	aCols[oGd[4]:nAt][nPDel]

		DbSelectArea("AG6")
		DbSetOrder(1)
		If	aCols[oGd[4]:nAt][nPRecn] > 0
			AG6->(DbGoTo(aCols[oGd[4]:nAt][nPRecn]))
			RecLock("AG6",.F.)
			dbDelete()
			MsUnLock()
		EndIf
	
	Else 

		DbSelectArea("AG6")
		DbSetOrder(1)
		If	aCols[oGd[4]:nAt][nPRecn] > 0
			AG6->(DbGoTo(aCols[oGd[4]:nAt][nPRecn]))
			RecLock("AG6",.F.)
			dbRecall()
			MsUnLock()
		EndIf
		
	Endif 		
	
	aCols[oGd[4]:nAt][nPDel] := lDelet
	
Else 

	lRet := .F.	
	
Endif 

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATA530   บAutor  ณKaren Potzik        บ Data ณ  30/09/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Analisa projeto e mostra relacao de componentes duplicados.บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FATA530                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ft530ITDUP(oTree,aTree,nOpcX,cProjeto,cVersPrj)

Local aArea			:= GetArea()
Local oDlgVers
Local oListBox
Local aListBox		:= {}
Local oOk   	 	:= LoadBitMap(GetResources(), "LBOK")
Local oNo	    	:= LoadBitMap(GetResources(), "LBNO")
Local obEDT			:= LoadBitmap( GetResources(), "BPMSEDT3" )
Local obTAREFA		:= LoadBitmap( GetResources(), "PMSTASK4" )
Local cQuery        := ''
Local cQuery1       := ''
Local cQuery2       := ''
Local cQueryN       := '' 
Local cDescF2       := '' 
Local cDescF5       := ''
Local cCpo			:= ''
Local aRet			:= {}
Local n				:= 0 
Local lConfirma		:= .F.
Local cNextEDT  

DEFAULT cProjeto := ' '
DEFAULT cVersPrj := ' '

cAliasN:= GetNextAlias()
cAlias := GetNextAlias()
	
If Select(cAliasN) > 0
	(cAliasN)->(DbCloseArea())
EndIf

cQueryN := "SELECT MAX(AF25.NIVEL) NIVEL FROM "
cQueryN += " (SELECT AF2.AF2_ORCAME, AF2.AF2_VERSAO, AF2.AF2_NIVEL NIVEL FROM " + RetSqlName("AF2") +" AF2 "
cQueryN += " WHERE AF2.AF2_ORCAME = '" + cProjeto + "' AND AF2.AF2_VERSAO = '" + cVersPrj + "' AND AF2.D_E_L_E_T_ = ' '"
cQueryN += "  UNION SELECT AF5.AF5_ORCAME, AF5.AF5_VERSAO, AF5.AF5_NIVEL NIVEL FROM " + RetSqlName("AF5") +" AF5 WHERE AF5.AF5_ORCAME = '" + cProjeto + "' AND AF5.AF5_VERSAO = '" + cVersPrj + "' AND AF5.D_E_L_E_T_ = ' ') AF25"

cQueryN := ChangeQuery( cQueryN )
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQueryN), cAliasN,.T.,.T.)
	         
DbSelectArea(cAliasN)
DbGoTop()

If !(cAliasN)->(Eof())
	cMaiorNiv := (cAliasN)->NIVEL
EndIf		
(cAliasN)->(DbCloseArea())

If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf

cEdtPai1 := "AF2.AF2_EDTPAI"
cEdtPai2 := "AF5.AF5_EDTPAI"
For n=2 to Val(cMaiorNiv)
	cQuery1  += " INNER JOIN "+ RetSqlName("AF5") + " AFA"+ Alltrim(Str(n)) +" ON (AF2.AF2_FILIAL = AFA"+ Alltrim(Str(n)) +".AF5_FILIAL AND AF2.AF2_ORCAME = AFA"+ Alltrim(Str(n)) +".AF5_ORCAME AND AF2.AF2_VERSAO = AFA"+ Alltrim(Str(n)) +".AF5_VERSAO AND " + cEdtPai1 + " = AFA"+ Alltrim(Str(n)) +".AF5_EDT AND AFA"+ Alltrim(Str(n)) +".D_E_L_E_T_ = ' ')"+CRLF
	cQuery2  += " INNER JOIN "+ RetSqlName("AF5") + " AFB"+ Alltrim(Str(n)) +" ON (AF5.AF5_FILIAL = AFB"+ Alltrim(Str(n)) +".AF5_FILIAL AND AF5.AF5_ORCAME = AFB"+ Alltrim(Str(n)) +".AF5_ORCAME AND AF5.AF5_VERSAO = AFB"+ Alltrim(Str(n)) +".AF5_VERSAO AND " + cEdtPai2 + " = AFB"+ Alltrim(Str(n)) +".AF5_EDT AND AFB"+ Alltrim(Str(n)) +".D_E_L_E_T_ = ' ')"+CRLF
	cEdtPai1 := "AFA"+ Alltrim(Str(n)) +".AF5_EDTPAI"
	cEdtPai2 := "AFB"+ Alltrim(Str(n)) +".AF5_EDT"
	cDescF2  += ", AFA"+ Alltrim(Str(n)) +".AF5_DESCRI TAREFA"+ Alltrim(Str(n))
	cDescF5  += ", AFB"+ Alltrim(Str(n)) +".AF5_DESCRI TAREFA"+ Alltrim(Str(n))
	cCpo	 += IIF(n>1,"+' \ '+","")+"Alltrim(TAREFA"+ Alltrim(Str(n))+")"
Next	                                     '

cQuery	:= " SELECT AF2.AF2_ORCAME, AF2.AF2_VERSAO, AF2.AF2_TAREFA CODIGO, AF2.AF2_DESCRI DESCRICAO, AF2.AF2_EDTPAI EDT, AF2.R_E_C_N_O_ REC, 'AF2' TAB" + cDescF2 + " FROM " + RetSqlName("AF2") +" AF2 "+CRLF
cQuery	+= cQuery1
cQuery	+= " WHERE AF2.AF2_FILIAL = '" + xFilial("AF2") + "' "+CRLF
cQuery	+= " AND AF2.AF2_ORCAME = '" + cProjeto + "' "+CRLF
cQuery	+= " AND AF2.AF2_VERSAO = '" + cVersPrj + "' "+CRLF
cQuery	+= " AND AF2.D_E_L_E_T_ = ' ' "+CRLF
cQuery	+= " AND EXISTS (SELECT AF2T.AF2_ORCAME, AF2T.AF2_VERSAO, AF2T.AF2_DESCRI, COUNT(*) TAREFA FROM " + RetSqlName("AF2") +" AF2T "+CRLF
cQuery	+= "               WHERE  AF2T.AF2_FILIAL = '" + xFilial("AF2") + "' "+CRLF
cQuery	+= "               AND AF2T.AF2_ORCAME = '" + cProjeto + "' "+CRLF
cQuery	+= "               AND AF2T.AF2_VERSAO = '" + cVersPrj + "' "+CRLF
cQuery	+= "               AND AF2T.D_E_L_E_T_ = ' ' "+CRLF
cQuery	+= "               AND AF2T.AF2_DESCRI = AF2.AF2_DESCRI "+CRLF
cQuery	+= "               GROUP BY AF2T.AF2_ORCAME, AF2T.AF2_VERSAO, AF2T.AF2_DESCRI "+CRLF
cQuery	+= "               HAVING COUNT(*) > 1 ) "+CRLF
cQuery	+= " UNION "+CRLF
cQuery	+= " SELECT AF5.AF5_ORCAME, AF5.AF5_VERSAO, AF5.AF5_EDT CODIGO, AF5.AF5_DESCRI DESCRICAO, AF5.AF5_EDTPAI EDT, AF5.R_E_C_N_O_ REC, 'AF5' TAB" + cDescF5 + " FROM " + RetSqlName("AF5") +" AF5 "+CRLF
cQuery	+= cQuery2
cQuery	+= " WHERE AF5.AF5_FILIAL = '" + xFilial("AF5") + "' "+CRLF 
cQuery	+= " AND AF5.AF5_ORCAME = '" + cProjeto + "' "+CRLF
cQuery	+= " AND AF5.AF5_VERSAO = '" + cVersPrj + "' "+CRLF
cQuery	+= " AND AF5.D_E_L_E_T_ = ' ' "+CRLF
cQuery	+= " AND EXISTS (SELECT AF5T.AF5_ORCAME, AF5T.AF5_VERSAO, AF5T.AF5_DESCRI, COUNT(*) TAREFA FROM " + RetSqlName("AF5") +" AF5T "+CRLF
cQuery	+= "               WHERE AF5T.AF5_FILIAL = '" + xFilial("AF5") + "' "+CRLF
cQuery	+= "               AND AF5T.AF5_ORCAME = '" + cProjeto + "' "+CRLF
cQuery	+= "               AND AF5T.AF5_VERSAO = '" + cVersPrj + "' "+CRLF
cQuery	+= "               AND AF5T.D_E_L_E_T_ = ' ' "+CRLF
cQuery	+= "               AND AF5T.AF5_DESCRI = AF5.AF5_DESCRI "+CRLF
cQuery	+= "               GROUP BY AF5T.AF5_ORCAME, AF5T.AF5_VERSAO, AF5T.AF5_DESCRI "+CRLF
cQuery	+= "               HAVING COUNT(*) > 1 ) "+CRLF
cQuery	+= " ORDER BY DESCRICAO "+CRLF

cQuery := ChangeQuery( cQuery )
	
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias,.T.,.T.)
	         
DbSelectArea(cAlias)
DbGoTop()
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta Arrayณ
//ภฤฤฤฤฤฤฤฤฤฤฤู           
If !(cAlias)->(Eof())
	While !(cAlias)->(Eof())   
		cBmp	:= Ft530Bmp((cAlias)->TAB)
		Aadd(aListBox,{.F.,	.F.,AllTrim((cAlias)->CODIGO),	AllTrim((cAlias)->DESCRICAO),AllTrim((cAlias)->EDT),(cAlias)->&cCpo,(cAlias)->REC,AllTrim((cAlias)->TAB)})  
		(cAlias)->(DbSkip())
	End
	(cAlias)->(DbCloseArea())
Else	
	(cAlias)->(DbCloseArea())
	MsgStop(STR0172) //"Nใo existem itens duplicados no projeto"
	RestArea(aArea)
	aSize(aArea,0)
	Return()
EndIf	

DEFINE MSDIALOG oDlg TITLE STR0167 FROM 178,181 TO 600,1115 PIXEL //"Itens em duplicidade"
	
// Cria as Groups do Sistema
@ 002,003 TO 210,462 LABEL STR0168 PIXEL OF oDlg //"Selecione o(s) itens que deseja excluir do projeto:"
	
@ 012,008 ListBox oLBox Fields HEADER "","",STR0169,STR0170,STR0171; //"Codigo"###"Descricao"###Origem
	Size 415,190 Of oDlg Pixel ON DblClick(aListBox[oLbox:nAt,1] := !aListBox[oLbox:nAt,1])
			
oLBox:SetArray(aListBox)

oLBox:bLine := {||{	Iif(aListBox[oLBox:nAt,01],oOk,oNo),; 
					Iif(aListBox[oLBox:nAt,08] == "AF5"  ,obEDT,obTAREFA),; 
				 		aListBox[oLBox:nAT,03],;
						aListBox[oLBox:nAT,04],;
						aListBox[oLBox:nAT,06] }}
	
DEFINE SBUTTON FROM 010,430 TYPE 1 ENABLE OF oDlg Action (lConfirma:= Ft530DLDUP(aListBox,@oLBox) ,oDlg:End(),.F.)
DEFINE SBUTTON FROM 027,430 TYPE 2 ENABLE OF oDlg Action oDlg:End() 
	                               
ACTIVATE MSDIALOG oDlg CENTERED 
 
If lConfirma
	
	oTree:TreeSeek(aTree[1][1])	//Posiciona a arvore na raiz principal

	AF5->(DbGoTo(Val(SubStr(aTree[1][1],4,12)))) //Posiciona AF5 na raiz 
	AF7->(DbSetOrder(3)) //AF7_FILIAL+AF7_ORCAME+AF7_VERSAO+AF7_TAREFA+AF7_ITEM
	AF3->(DbSetOrder(5)) //AF3_FILIAL+AF3_ORCAME+AF3_VERSAO+AF3_TAREFA+AF3_ITEM
	AF2->(DbSetOrder(6)) //AF2_FILIAL+AF2_ORCAME+AF2_VERSAO+AF2_EDTPAI+AF2_ORDEM
	AF5->(DbSetOrder(6)) //AF5_FILIAL+AF5_ORCAME+AF5_VERSAO+AF5_EDTPAI+AF5_ORDEM

	oTree:BeginUpdate()
	oTree:Reset()
	
	AddEDT(@oTree,@aTree,AF5->AF5_ORCAME+AF5->AF5_VERSAO+AF5->AF5_EDT,"AF1,AF5,AF2,AF3", 2,"AF5"+StrZero(AF5->(RecNo()),12),.T.)
	
	oTree:EndUpdate()
	oTree:Display()
	oTree:Refresh()
	oTree:TreeSeek(aTree[1][1])	//Posiciona a arvore na raiz principal   
		
	Eval(oTree:bChange)
EndIf

RestArea(aArea)
aSize(aArea,0)
Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATA530   บAutor  ณKaren Potzik        บ Data ณ  30/09/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Analisa projeto e mostra relacao de componentes duplicados.บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FATA530                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ft530DLDUP(aListBox,oLBox)

Local nI	:= 0
Local cRet	:= .F.

For nI:=1 to Len(aListBox)
	If aListBox[nI,01]
		If aListBox[nI,08]=="AF2"
			MsgRun(STR0003,,{||FTAExcAF2(,,aListBox[nI,07])})
		Else	
			MsgRun(STR0003,,{||FTAExcAF5(,,aListBox[nI,07])})
		EndIf	
		cRet := .T.
	EndIf	
Next
Return(cRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} FAT530EMPT(aLbox,oLboX)

Valida se o modelo selecionado na proposta estแ vazio 

@sample     FATISEMPTY()

@param      aLbox  - Arrei de itens selecionados 
             oLbox  - Objeto do Box

@return     Verdadeiro ou Falso

@author     Renato da Cunha
@since      23/02/2016
@version    12.1.7
/*/
//------------------------------------------------------------------------------

Static Function FAT530EMPT(aLbox,oLboX)

Local cOrca	:= aLbox[oLbox:nAt,2]

Default aLbox	:={}
Default oLbox	:= NIL

AF2->(DbSetOrder(1))
If AF2->(DbSeek(xFilial("AF2")+cOrca))
	aLbox[oLbox:nAt,1] := !aLbox[oLbox:nAt,1]
Else
	MsgAlert(STR0180)
EndIf

Return Nil
//------------------------------------------------------------------------------
/*/{Protheus.doc} A530ModVer(cCodOrc)

Retorna a Ultima versใo do modelo selecionado para c๓pia
@param      cCodOrc  - c๓digo do or็amento เ importar

@return    ๚ltima versใo do modelo เ importar

@author     Renato da Cunha
@since      16/05/2016
@version    12.1.7
/*/
//-----------------------------------------------------------------------------

Static Function A530ModVer( cCodOrc )

Local aModArea	:= GetArea()
Local cVersion	:= Space(TamSX3("AF1_VERSAO")[1])
Local cFilAF1	:= xFilial( "AF1" )

Default cCodOrc := Space(TamSX3("AF1_ORCAME")[1])

DbSelectArea( "AF1" )

AF1->(DbSetOrder(1)) //AF1_FILIAL+AF1_ORCAME+AF1_DESCRI

If AF1->(DbSeek(xFilial("AF1")+cCodOrc))
	
	While AF1->(!Eof()) .And. AF1->AF1_FILIAL == cFilAF1 .And. AF1->AF1_ORCAME == cCodOrc
	
		cVersion := AF1->AF1_VERSAO
	
		AF1->( DbSkip() )
	
	EndDo
	
EndIf

RestArea ( aModArea ) 

Return ( cVersion )

/*/{Protheus.doc} Ft530Leg
Legenda

@Param
@Return 

@author William Pianheri
@since 30/07/2018
@version 1.0
/*/

Function Ft530Leg()
Local oBmp
Local oDlg
Local aArea		:= GetArea()

DEFINE MSDIALOG oDlg TITLE STR0181 + "/" + STR0182 OF oMainWnd PIXEL FROM 0,0 TO 200,255 //"Legenda/Status"

@ 2,4 to 80,125 Label STR0181 PIXEL  //"Legenda"
@ 10,10 BITMAP oBmp RESNAME EDT_INSTALADO SIZE 16,16 NOBORDER PIXEL
@ 10,20 SAY STR0183 + " - " + STR0184 of oDlg PIXEL //"EDT - Utilizado"
@ 22,10 BITMAP oBmp RESNAME EDT_NAOINSTAL	SIZE 16,16 NOBORDER PIXEL
@ 22,20 SAY STR0183 + " - " + STR0185 of oDlg PIXEL //"EDT - Nใo Utilizado"
@ 34,10 BITMAP oBmp RESNAME EDT_PREINSTAL SIZE 16,16 NOBORDER PIXEL
@ 34,20 SAY STR0183 + " - " + STR0186 of oDlg PIXEL //"EDT - Preexistente"
@ 46,10 BITMAP oBmp RESNAME TAR_INSTALADO SIZE 16,16 NOBORDER PIXEL
@ 46,20 SAY STR0046 + " - " + STR0184 of oDlg PIXEL //"Tarefa - Utilizado"
@ 58,10 BITMAP oBmp RESNAME TAR_NAOINSTAL SIZE 16,16 NOBORDER PIXEL
@ 58,20 SAY STR0046 + " - " + STR0185 of oDlg PIXEL //"Tarefa - Nใo Utilizado"
@ 70,10 BITMAP oBmp RESNAME TAR_PREINSTAL SIZE 16,16 NOBORDER PIXEL
@ 70,20 SAY STR0046 + " - " + STR0186 of oDlg PIXEL //"Tarefa - Preexistente"
@ 85,80 BUTTON STR0187 SIZE 40 ,9   FONT oDlg:oFont ACTION {||oDlg:End()}  OF oDlg PIXEL //"Fechar"

Activate MSDIALOG oDlg CENTERED

RestArea(aArea) 
Return


//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informa็๕es enviadas, 
    quando a regra de auditoria de rotinas com campos sensํveis ou pessoais estiver habilitada
	Remover essa fun็ใo quando nใo houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que serแ utilizada no log das tabelas
    @param nOpc, Numerico, Op็ใo atribuํda a fun็ใo em execu็ใo - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria nใo esteja aplicada, tamb้m retorna falso.

/*/
//-----------------------------------------------------------------------------
Static Function FATPDLogUser(cFunction, nOpc)

	Local lRet := .F.

	If FATPDActive()
		lRet := FTPDLogUser(cFunction, nOpc)
	EndIf 

Return lRet  

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Fun็ใo que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive
