#include "PLSMGER2.CH"
#include "PROTHEUS.CH"    
#include "PLSA175.CH"

#define K_RevCP    4
#define K_Fase     5
#define K_RetFas   6
#define K_RevPag   7
#define K_RevCob   8    
#define K_RetCP    9  // Essas numerações e de acordo com chamada no menudef se alterar lá tem que alterar aqui tambem

Static objCENFUNLGP := CENFUNLGP():New()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA175 ³ Autor ³ Tulio Cesar          ³ Data ³ 04.09.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao PEGS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA175
LOCAL bAjustBrw  := {|| oBrw := GetObjBrow()}
LOCAL nOrdPeg    := GETNEWPAR("MV_PLORPEG",3)

PRIVATE aRotina   := MenuDef()

PRIVATE cCadastro := STR0012 //"PEGS - Protocolo de Entrega de Guias"
PRIVATE cAlias    := "BCI"
PRIVATE cFiltro
PRIVATE aCdCores  := {}
PRIVATE aCores    := {}

PLSMCorCM(aCores,aCdCores,"BCI")

cFiltro := "@BCI_FILIAL = '"+xFilial("BCI")+"' AND D_E_L_E_T_ = ' '"
BCI->(DbSetOrder(nOrdPeg))
DbSelectArea("BCI")

If ExistBlock( "PL175FIL" )
	cFiltro := ExecBlock( "PL175FIL", .F., .F., {cFiltro} )
EndIf 

SET FILTER TO &cFiltro
BCI->(MsSeek(xFilial("BCI")))
BCI->(mBrowse(006,001,022,075,cAlias, , , , , nil, aCores, ,,.T. ,bAjustBrw))
BCI->(DbClearFilter())

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA175MOV ³ Autor ³ Tulio Cesar       ³ Data ³ 15.08.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao Movimentacao                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA175MOV(cAlias,nReg,nOpc)
LOCAL nOpcA         := 0
LOCAL nH            := 0
PRIVATE oDlg		:= nil
PRIVATE aTELA[0][0]
PRIVATE aGETS[0]
PRIVATE aChave      := {}   
PRIVATE oEnchoice   := nil
PRIVATE bOK         := {|| nOpca := 1,iIf(Obrigatorio(oEnchoice:aGets,oEnchoice:aTela),oDlg:End(),nOpca:=2),IIF(nOpca==1,oDlg:End(),.F.) }
PRIVATE bCancel  	:= {|| rollBackSX8(),oDlg:End()}
PRIVATE _cAno    	:= ""
PRIVATE _cMes    	:= ""

//Verifica se e o operador de gerenciamento
if (nOpc == K_Excluir .or. nOpc == K_Alterar) .and. !PLSVEROPE()
	return
endIf

//Valida o calendario de pagamento...                                      
If nOpc == K_Incluir

	aRetAux 	:= PLSXVLDCAL(dDataBase,PLSINTPAD())

   	If ! aRetAux[1]            
		Aviso( "U.S Mensais", ;
		       "Nao existem U.S Mensais cadastrada para o Ano/Mes do calendario de pagamento atual",;
		  	   { "Ok" }, 2 ) 	                                                                    
      	Return
   	Else
      	_cAno := aRetAux[4]
      	_cMes := aRetAux[5]
   	Endif
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Testa se a PEG esta cancelada...                                         
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
if nOpc == K_Excluir .and. !empty(BCI->BCI_PROCES)
	aviso( "Atenção",;
	       "Impossível excluir PEG vinculada a um PROCESSO",;
	  	   { "Ok" }, 2 ) 	                                                                    
	return
endIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Testa se a PEG esta cancelada...                                         
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If ( nOpc == K_Alterar .Or. nOpc == K_Excluir ) .And. BCI->BCI_SITUAC == "2" 
   Help("",1,"PLSA175CAN")
   Return
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Testa se a PEG esta BLOQUEADA...                                         
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If ( nOpc == K_Alterar .Or. nOpc == K_Excluir ) .And. BCI->BCI_SITUAC == "3" 
   Help("",1,"PLSA175BLO")
   Return
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ No caso de alteracao de pegs fechadas alertar usuario sobre logs...      
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If ( nOpc == K_Alterar .Or. nOpc == K_Excluir ) .And. BCI->BCI_FASE == "4"
   Help("",1,"PLSA175FEC")
   Return
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ No caso de alteracao de pegs fechadas alertar usuario sobre logs...      
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If ( nOpc == K_Alterar .Or. nOpc == K_Excluir ) .And. BCI->BCI_FASE == "3"
  /*PutHelp("PPLSA175PRO", {"PEG com status diferente de EM DIGITAÇÃO!"},,,.T.)
  PutHelp("SPLSA175PRO", {"A guia selecionada pelo usuário não ", "está no status correto para alteração."},,,.T.)
  Help("",1,"PLSA175PRO")
  Return*/
  
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Nao permite excluir PEG caso haja GUIAS digitadas                        
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If nOpc == K_Excluir       
   cAliasCab := IIf(BCI->BCI_TIPGUI $ "  ,01,02","BD5","BE4")
   &(cAliasCab+"->(DbSetOrder(1))")
   If &(cAliasCab+"->(MsSeek(xFilial(cAliasCab)+BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG)))")
      Aviso("",STR0013,{"Ok"} )  //"PEG não poderá ser excluída pois já possui GUIAS digitadas"
      Return
   EndIf
EndIf

aSize := MsAdvSize()

aObjects := {}       
AAdd( aObjects, { 100, 200, .T., .T., .F. } )

aInfo 	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Inicia a construcao do Dialogo com usuario...                            
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Monta M->????                                                            
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
regToMemory(cAlias,nOpc==K_Incluir)  

If nOpc==K_Incluir .And. Len(aRetAux) > 6
	M->BCI_CODDAT := IIf(Empty(aRetAux[6]),StrZero( 0, TamSx3("BDT_CODDAT")[1] ),aRetAux[6])
	M->BCI_DATPAG := aRetAux[7]
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Monta Enchoice...                                                        
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oEnchoice := MSMGET():New(cAlias,nReg,nOpc,,,,,aPosObj[1],,,,,,oDlg,,.T.)

//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
	objCENFUNLGP:useLogUser()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Ativa o Dialogo...                                                       
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ACTIVATE MSDIALOG oDlg CENTERED ON INIT Eval({|| EnChoiceBar(oDlg,bOK,bCancel,.F.,{}) })
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Tratamento para atualizacoes...                                          
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If nOpcA == K_OK
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Trata a exclusao nao podendo haver modificacoes...
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If ( nOpc == K_Incluir .Or. nOpc == K_Alterar .Or. nOpc == K_Excluir )
	
		if nOpc == K_Incluir
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//³ Abre semaforo
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			nH := PLSAbreSem("PLSPEG.SMF")
				M->BCI_CODPEG := PLSA175COD(M->BCI_CODOPE,M->BCI_CODLDP)
				M->BCI_CODCOR := BCL->(Posicione("BCL",1,xFilial("BCL")+M->BCI_CODOPE+M->BCI_TIPGUI,"BCL_CODCOR"))
				
				If M->BCI_CODRDA != BAU->BAU_CODIGO
					BAU->(dbSetOrder(1))
					If BAU->(MsSeek(xfilial("BAU")+M->BCI_CODRDA))
						M->BCI_DATPAG := PLSCHKNCAL(M->BCI_MES)
					EndIF
				else
					M->BCI_DATPAG := PLSCHKNCAL(M->BCI_MES)
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				//³ Grava dados
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				PLUPTENC("BCI",nOpc)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//³ Fecha semaforo
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			PLSFechaSem(nH,"PLSPEG.SMF")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//³ Infor
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			msgInfo("PEG gerado com o numero: " + M->BCI_CODPEG)
		else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//³ Grava dados
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			PLUPTENC("BCI",nOpc)
		endIf
	EndIf
EndIf	

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA175Cod ³ Autor ³ Tulio Cesar       ³ Data ³ 15.08.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao Retorna o proximo codigo disponivel                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
function PLSA175Cod(cCodOpe,cCodLDP)
local cNumPeg	:= ""

cNumPeg := BCI->( getSX8Num("BCI","BCI_CODPEG",,14) ) 
		
BCI->(dbSetOrder(14)) //BCI_FILIAL + BCI_CODPEG
while BCI->( msSeek( xFilial("BCI") + cNumPeg ) )
	cNumPeg := BCI->( getSX8Num("BCI","BCI_CODPEG",,14) )
endDo
	
BCI->(confirmSX8())
	
return(cNumPeg)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA175PRO ³ Autor ³ Tulio Cesar       ³ Data ³ 15.08.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao Retorna o proximo codigo disponivel                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA175PRO(cCodOpe)
LOCAL nRet    := 0
LOCAL nOrdBCJ := BCJ->(IndexOrd())
LOCAL nTam    := Len(BCJ->BCJ_TIPSER)
LOCAL nReg    := BCJ->(Recno())

BCJ->(DbSetOrder(1))
BCJ->(MsSeek(xFilial("BCJ")+cCodOpe+Replicate("9",nTam),.T.))
BCJ->(DbSkip(-1))
                                                           
If BCJ->(BCJ_FILIAL+BCJ_CODOPE) <> xFilial("BCJ")+cCodOpe
   nRet := StrZero(1,nTam)
Else
   nRet := StrZero(Val(BCJ->BCJ_TIPSER)+1,nTam)
Endif

BCJ->(DbSetOrder(nOrdBCJ))
BCJ->(DbGoTo(nReg))

Return(nRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA175FAS
Mudança de fase por PEG

@author    Tulio Cesar
@version   AP6
@since     15/08/2002
/*/
function PLSA175FAS(cAlias,nReg,nOpc,lFila,lHelp,aFiltro,lAutori,nTotEventos,aThreads,nCont,cNameUser,aPLS475)
local cFase   		:= &(cAlias+"->"+cAlias+"_FASE")
local cSituac 		:= &(cAlias+"->"+cAlias+"_SITUAC") 
local cCodOpe  	    := BCI->BCI_CODOPE
local cCodLDP  	    := BCI->BCI_CODLDP
local cCodPEG  	    := BCI->BCI_CODPEG
local dDatCtbChk    := PLRtDtCTB(cCodOpe, cCodLDP, cCodPEG, , .f.)
local lGloMan		:= getNewPar("MV_PLSCGMA",.f.)
local lRecuGlo		:= getNewPar("MV_PLRECUG",.f.)
local aDadc 		:= {}
local aIglo 		:= {}
local aRet			:= {}
local nBD6	  		:= 0
local ltotaliza 	:= .F.
local aRecBD6Atu 	:= {}
local caliasGui	    := ""
local cChvGui		:= "" 
local oFila			as object
local lGo			:= .T.
local cMsg			as char
local lNewMF 		:= GetNewPar("MV_PLMFBET",.f.)

default nCont       := 0
default nTotEventos := 0
default cNameUser   := ""
default lHelp   	:= .T.
default lAutori 	:= .F.
default aFiltro 	:= {}
default aThreads    := {}                              
default aPLS475     := {.F.,"",""}
default lFila		:= .f.

//alimenta variavel usada na PLSPOSGLO
setCTRVAr("BYPGLOFAS")

if lNewMF
	oFila := filaPContas():New()	
endif

// por algum motivo ta vindo caracter em alguns clientes
if cvaltochar(lFila) <> ".T."
	lFila := .f.
endif

//se a data do sistema esta no periodo bloqueado pela contabilidade, não pode executar a ação
If PLVLDBLQCO(dDatCtbChk, {"PLS005"}, lHelp) 

	//Verifica se e o operador de gerenciamento
	If PLSBCIxBXX()
		return "O arquivo referente à este Protocolo ainda não foi Importado ou sua importação foi incompleta."
	EndIf
	
	//Verifica se e o operador de gerenciamento
	if (lHelp .and. !PLSVEROPE()) .or. (lFila .and. !PLSVEROPE())
		return "PEG sendo gerenciado pelo operador ["+allTrim(usrRetName(BCI->BCI_OPERES))+"]"
	endIf
	
	//Posiciona no tipo de guia...                                             
	BCL->(DbSetOrder(1)	)
	BCL->(MsSeek(xFilial("BCL")+BCI->(BCI_CODOPE+BCI_TIPGUI)))
	
	cAliasGui := BCL->BCL_ALIAS
	
	//posiciona na guia do peg                                             
	(cAliasGui)->( msSeek( xFilial(cAliasGui) + &(cAlias + "-> (" + cAlias + "_CODOPE + "  + cAlias + "_CODLDP + " + cAlias + "_CODPEG) " ) ))
	
	If cFase $ "3" 
		Pl175VerGui(cAliasGui, &(cAlias+"->"+cAlias+"_CODOPE"),&(cAlias+"->"+cAlias+"_CODLDP"),&(cAlias+"->"+cAlias+"_CODPEG"),@cFase) // verifica se mesmo a Peg esteja pronta se há guias em digitaçõa no momento da mudançã de fase 	
	endif
	
	//Veririfica se registro a valida para mudanca de fase...                  
	if ! ( ( cFase $ "1" ) .And. ( cSituac $ "1,3" ) )    
	   
	   if lHelp
	      Help("",1,"PLSA175FAS")
	   endIf   
	   
	   return "Processamento bloqueado para esta guia."
	   
	endIf
	
	if BCL->BCL_MUDFAS == '0'
		cMsg := "Processamento bloqueado para este tipo de guia."
		if lHelp .and. !lFila
	 		msgStop('Mudança de fase bloqueada para este tipo de guia.')
	    endIf
	       
	   	return cMsg
	endIf
	
	//Confirma a mudanca de fase... 	 	   
	if !lFila .and. lHelp
		if !msgYesNo(STR0015) //"Confirma a Mudanca de Fase"
	  		return ""
		endif
	endif
	if oFila != nil	     		   	  
		oFila:setTipGui(BCI->BCI_TIPGUI)
		oFila:setCodLdp(BCI->BCI_CODLDP)
		oFila:setCodPeg(BCI->BCI_CODPEG)
		oFila:setPriority()
		if !oFila:chkfimfila()			   
			cMsg := "O PEG já está na fila de processamento, por favor aguarde!"	        	
		 	lGo := .F.
		endIf 		   
	endif
		
	If lGo
		PLconvRDA7( BCI->BCI_CODOPE, BCI->BCI_CODLDP, BCI->BCI_CODPEG )
		If !lFila
			cHoraIni := TIME()	
			//Se for alteracao habilita botao mudanca de fase...                       
			aRet := PLSXMUDFAS(BCL->BCL_ALIAS,"2",BCL->BCL_CODOPE,BCL->BCL_TIPGUI,date(),lAutori,nil,nil,nil,lHelp,nil,aFiltro,.t.,nil,nil,nil,nil,nTotEventos,aThreads,nCont,cNameUser,,aPLS475)
		
			//Mudo o status da PEG                                                     
			if nReg <> 0
			
				PLSM190Pro(,,,,,,,,,,,.f.,.t.,nReg)
				
				//caso o parâmetro MV_PLSCGMA esteja habilitado deve verificar se teve glosa manual anterior e deve "resgatar"
				//Só irá recuperar caso o parâmetro MV_PLRECUG esteja como .T., caso esteja como .F., a recuperação de glosas automáticas depende de interação do usuário e não contempla a glosa manual.
				
				If lGloMan .and. lRecuGlo 
				
					aDadc := {}
					aDadc := PLSA500CRI(&(cAlias+"->"+cAlias+"_CODOPE"), &(cAlias+"->"+cAlias+"_CODLDP"), &(cAlias+"->"+cAlias+"_CODPEG"), nil, nil, nil, nil, nil, lGloMan, lRecuGlo)
		
					for nCont := 1 to len(aDadc)
		
						BDX->(dbGoTo(aDadc[nCont,36]))
		
						//Irá recuperar as críticas de glosa manual incluídas
						IF BDX->(Deleted())
							BDX->(RecLock("BDX",.F.))
							BDX->(DbRecall())                //restaura os registro removidos
							BDX->BDX_REGREC := ""
							BDX->(MsUnLock())
						endIf
						
						//Adiciona no array críticas de glosa manual para recuperação
						If aScan(aIglo, {|x| x[2] == BDX->(Recno())}) == 0
							aadd(aIglo, {BDX->BDX_CODOPE+BDX->BDX_CODLDP+BDX->BDX_CODPEG+BDX->BDX_NUMERO+BDX->BDX_ORIMOV+BDX->BDX_SEQUEN+BDX->BDX_CODPAD+BDX->BDX_CODPRO, BDX->(Recno())})
						endIf
						
					Next nCont
					
					//Fazer novos cálculos da BD6 e BD7 relacionadas após resgatar a glosa manual
					if len(aIglo) > 0
						
						BD6->(DbSetOrder(1))	//BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN+BD6_CODPAD+BD6_CODPRO
						
						for nBD6 := 1 to len(aIglo)				
							
							if BD6->(MsSeek(xFilial("BD6")+aIglo[nBD6][1]))
							
								If aScan(aRecBD6Atu, BD6->(Recno())) == 0
									Aadd(aRecBD6Atu, BD6->(Recno()))
								endIf
								
								//Atualiza os valores da BD6 e BD7
								PLVLBDXBD7(BD6->(Recno()),.T.,aIglo[nBD6][2])
								
								lTotaliza := .T.
							endIf
							
						next nBD6										
						
					endIf
					
				endIf
				
			endIf	
			cHoraFim := TIME()			
			cElapsed := ElapTime( cHoraIni, cHoraFim ) 		
			msgInfo("Mudanca de Fase concluida com sucesso !!!")
		else			
			addFilaPLS(BCI->BCI_CODPEG, BCI->BCI_CODLDP, BCI->BCI_TIPGUI, , , ,retCodUsr())
			cMsg := "PEG adicionada na fila de processamento, em breve será processada!"
		endIf
	endIf
endIf	

Return cMsg
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA175Leg ³ Autor ³ Eduardo Motta     ³ Data ³ 13.12.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Legenda                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA175Leg()
BrwLegenda(cCadastro,STR0011,aCdCores) //"Legenda"
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSQINSQL  ³ Autor ³                   ³ Data ³            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Transforma selecoes por virgula em IN para SQL/ORACLE      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSQINSQL(cAliasPri,cTipPre)
LOCAL nFor	 := 0
LOCAL cRet 	 := ""                
LOCAL cPrest := ""

for nFor := 1 to len(cTipPre)

    cPrest 	+= "'" + subs(cTipPre,nFor,3) + "',"
    nFor 	:= nFor + 3
    
next      
                                
if len(cPrest) > 0
   cPrest := subs(cPrest,1,len(cPrest)-1)
endIf

cRet := " AND " + cAliasPri + "_TIPPRE IN (" + cPrest + ") "

return(cRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA175RGR ³ Autor ³ Tulio Cesar       ³ Data ³ 20.12.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Reprocessamento generico (retorno de fase ou revalorizacao)³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
function PLSA175RGR(cAlias,nReg,nOpc,lProcessa,lMsg,aFiltro,nTotEventos,aThreads,nCont,cOriMov,cNameUsr,cTipo,nDifUs,nVlrDifUs,aPLS475)
LOCAL cAliasPri	 	:= ""
LOCAL cCodOpe   	:= BCI->BCI_CODOPE
LOCAL cCodLDP   	:= BCI->BCI_CODLDP
LOCAL cCodPEG   	:= BCI->BCI_CODPEG
LOCAL nRecBCL   	:= BCL->(Recno())
LOCAL nOrdBCL   	:= BCL->(IndexOrd())
LOCAL nRecBQC   	:= BQC->(Recno())
LOCAL nOrdBQC   	:= BQC->(IndexOrd())
LOCAL nRecBG9   	:= BG9->(Recno())
LOCAL nOrdBG9   	:= BG9->(IndexOrd())
LOCAL nRecBA3   	:= BA3->(Recno())
LOCAL nOrdBA3   	:= BA3->(IndexOrd())
LOCAL bRest     	:= {|| BCL->(DbGoTo(nRecBCL)), BCL->(DbSetOrder(nOrdBCL)), BQC->(DbGoTo(nRecBQC)), BQC->(DbSetOrder(nOrdBQC)), BG9->(DbGoTo(nRecBG9)), BG9->(DbSetOrder(nOrdBG9)), BA3->(DbGoTo(nRecBA3)), BA3->(DbSetOrder(nOrdBA3)) }
LOCAL lReval    	:= .F.
local nCount		:= 0
local lFirst		:= .t.
LOCAL cCodEmp   	:= ""
LOCAL cConEmp		:= ""
LOCAL cVerCon		:= ""
LOCAL cSubCon		:= ""
LOCAL cVerSub		:= ""
LOCAL cMatric		:= ""
LOCAL cSQL      	:= ""
LOCAL cNamePRI  	:= ""
LOCAL cNameBAU  	:= BAU->(retSQLName("BAU"))
LOCAL cFilBAU   	:= BAU->(xFilial("BAU"))
LOCAL cChaveGui 	:= ""
LOCAL lProcOK   	:= .f.
local lCtb			:= .t.
local lAllPEG		:= .t.
local lProcErro		:= .f.
LOCAl cChaveP		:= ""
LOCAL lExtGRC		:= .F.
LOCAL cMsg			:= ""
LOCAL lPLS175RF     := existBlock("PLS175RF")
Local lretFasCtb	:= .F.
Local dDatCtbChk    := stod('')
Local lOkcalctb	:= .F.

DEFAULT nTotEventos := 0
DEFAULT nCont       := 0
DEFAULT nDifUs    	:= 0
DEFAULT nVlrDifUs 	:= 0
DEFAULT cOriMov 	:= BCL->BCL_CDORIT
DEFAULT cNameUsr 	:= ""
DEFAULT cTipo    	:= ""
DEFAULT lMsg    	:= .t.
DEFAULT aFiltro 	:= {}
DEFAULT aThreads    := {}
DEFAULT aPLS475   	:= {.F.,"",""}
default lProcessa	:= .f.

if !(cTipo $ "1234")
	cTipo := ""
endif

lretFasCtb := cTipo == "1" .OR. PLSRETROT(nOpc) == K_RetFas
dDatCtbChk := PLRtDtCTB(cCodOpe, cCodLDP, cCodPEG, , lretFasCtb)
lOkcalctb := PLVLDBLQCO(dDatCtbChk, {"PLS005"}, lMsg) 

//No retorno de fase, também verifica se o custo já foi contabilizado, pois deve impedir caso tenha sido
If lretFasCtb .AND. lOkcalctb
	dDatCtbChk := PLRtDtCTB(cCodOpe, cCodLDP, cCodPEG, , .F.)
	lOkcalctb := PLVLDBLQCO(dDatCtbChk, {"PLS005"}, lMsg) 
endIf

//se a data do sistema esta no periodo bloqueado pela contabilidade, não pode executar a ação
if lOkcalctb
	
	//Verifica se e o operador de gerenciamento
	if lMsg .and. !PLSVEROPE()
		return
	endIf
	
	//1-Retorno de Fase,2-Revalorizacao Pagto,3-Revalorizacao Cobranca,4-Revalorizacao Pagto e Cobranca
	if empty(cTipo)
		
		if PLSRETROT(nOpc) == K_RetFas
			cTipo := "1"
		elseIf PLSRETROT(nOpc) == K_RevPag
			cTipo := "2"
		elseIf PLSRETROT(nOpc) == K_RevCob
			cTipo := "3"
		elseIf PLSRETROT(nOpc) == K_RevCP .or. PLSRETROT(nOpc) == K_RetCP
			cTipo := "4"
		endif
		
	endIf
	
	//Guia de Reembolso nao permite retorno de fase... 			             
	If BCI->BCI_TIPGUI == '04' .And. BCI->BCI_FASE <> '4'
		
		if lMsg
			Help( ,, 'HELP',,"Nao é permitido retorno de fase de Guia de Reembolso!", 1, 0)
		endIf
			
		Return
		
	Endif
	
	//Veririfica se registro a valida para mudanca de fase...                  
	If cTipo $ "1,2" .and. BCI->BCI_FASE == "4"  
		
		if lMsg	
			Help("",1,"PLSA175FAS")
		endIf	
		
		Return
	
	Endif
	
	//Confirma a mudanca de fase...                                            
	If lMsg
	
		If cTipo == "1"
		
			If ! MsgYesNo(STR0016) //"Confirma o Retorno de Fase"
				Return
			Endif
		
		ElseIf cTipo == "2"
		
			If ! MsgYesNo(STR0017) //"Confirma a Revalorizacao de Pagamento desta PEG?"
				Return
			Endif
		
		ElseIf cTipo == "3"
		
			If ! MsgYesNo(STR0025) //"Confirma a Revalorizacao de Cobranca desta PEG?"
				Return
			Endif
		
		ElseIf cTipo == "4"
		
			If ! MsgYesNo(STR0027) //"Confirma a Revalorizacao de Cobranca e Pagamento desta PEG?"
				Return
			Endif
			
		Endif
		
	Endif
	
	//Busca o alias principal do tipo de guia do PEG atual...                  
	BCL->(DbSetOrder(1))
	BCL->(DbGotop())
	
	If ! BCL->(msSeek(xFilial("BCL")+BCI->(BCI_CODOPE+BCI_TIPGUI)))
		
		If lMSg
			Help("",1,"PLSA498BCL")
		Endif
		
		Eval( bRest)
		Return
		
	Endif
	
	cOriMov 	:= BCL->BCL_CDORIT
	cAliasPri 	:= BCL->BCL_ALIAS
	cNamePRI	:= retSqlName(cAliasPri)
	
	//Navega por todos os itens do PEG...
	cSQL := " SELECT PRI.R_E_C_N_O_ AS REG, " + cAliasPri + "_QTDEVE QTDEVE "
	cSQL += "   FROM " + cNamePRI + " PRI, " + cNameBAU + " BAU " 
	cSQL += "  WHERE " + cAliasPri + "_FILIAL = '" + xFilial(cAliasPri) + "' "
	cSQL += "    AND " + cAliasPri + "_CODOPE = '" + cCodOpe + "' "
	cSQL += "    AND " + cAliasPri + "_CODLDP = '" + cCodLDP + "' "
	cSQL += "    AND " + cAliasPri + "_CODPEG = '" + cCodPeg + "' "
	cSQL += "    AND " + cAliasPri + "_SITUAC = '1' "

	//Verifica data de/ate do evento caso a rotina seja chamada pelo PLSA475   
	if valType(aPLS475) == "A" .and. aPLS475[1]
	    cSQL += "    AND " + cAliasPri + "_DATPRO BETWEEN '" + dtos(aPLS475[2]) + "' AND '" + iIf( ! empty(aPLS475[3]),dtos(aPLS475[3]),replicate('Z',len(dtos(aPLS475[3])))) + "' "
	endIf
	
	//Retorno de Fase
	If cTipo == "1" 
	    
	    cSQL += "    AND " + cAliasPri + "_FASE IN ('3','2') "  
        cSQL += "    AND " + cAliasPri + "_SEQEST = '' "
		cSQL += "    AND " + cAliasPri + "_PODRFS <> '0' "  
	
	//Revalorizacao de Pagto //Revalorizacao de Pagto e Cobranca 
	ElseIf cTipo $ "2|4" 
	
		cSQL += "    AND " + cAliasPri + "_FASE = '3' "
		
	elseIf cTipo == "3" //Revalorizacao de Cobranca
		
		cSQL += "    AND " + cAliasPri + "_FASE IN( '3', '4' ) "

	Endif
	
	If Len(aFiltro) >= 2
		cSQL += "    AND " + cAliasPri + "_CODOPE BETWEEN '" + aFiltro[1] + "' AND '" + aFiltro[2] + "' "
	Endif
	
	If Len(aFiltro) >= 4
		cSQL += "    AND " + cAliasPri + "_CODEMP BETWEEN '" + aFiltro[3] + "' AND '" + aFiltro[4] + "' "
	Endif
	
	If Len(aFiltro) >= 6
		cSQL += "    AND " + cAliasPri + "_CONEMP BETWEEN '" + aFiltro[5] + "' AND '" + aFiltro[6] + "' "
	Endif
	
	If Len(aFiltro) >= 8
		cSQL += "    AND " + cAliasPri + "_SUBCON BETWEEN '" + aFiltro[7] + "' AND '" + aFiltro[8] + "' "
	Endif
	
	If Len(aFiltro) >=14
		cSQL += "    AND " + cAliasPri + "_LOCAL BETWEEN '" + aFiltro[13] + "' AND '" + aFiltro[14] + "' "
	Endif
	
	If Len(aFiltro) >= 15 .And. ! Empty(Alltrim(aFiltro[15]))
		cSQL += PLSQINSQL(cAliasPri,Alltrim(aFiltro[15]))
	Endif
	
	If Len(aFiltro) >= 16 .And. aFiltro[16] == 2
		cSQL += "    AND " + cAliasPri + "_VLRPAG = 0 " 
	Endif
	
	If cTipo <> "2" .and.  (cAliasPri)->&( cAliasPri + "_FASE" ) == "4"
		cSQL += "    AND " + cAliasPri + "_STAFAT <> '0' "
	Endif
	
	//se for branco a ZZZ eu nem entro aqui
	If Len(aFiltro) >= 20 .and. !Empty(aFiltro[20])	.and. (alltrim(aFiltro[19]+aFiltro[20]) <> Replicate("Z",10))
		
		//primeiro caso - NFSS no cabecalho
		cSQL += "(    AND " + cAliasPri + "_SEQNFS BETWEEN '" + aFiltro[19]     + "' AND '" + aFiltro[20] + "' "
		
		//se existe alguma NFSS no BD7
		cSQL += "( EXISTS (SELECT BD7_FILIAL FROM " + retSQLName("BD7") + " BD7E "
		cSQL += "           WHERE BD7_FILIAL = " + cAliasPri + "_FILIAL "
		cSQL += "             AND BD7_CODOPE = " + cAliasPri + "_CODOPE "
		cSQL += "             AND BD7_CODLDP = " + cAliasPri + "_CODLDP "
		cSQL += "             AND BD7_CODPEG = " + cAliasPri + "_CODPEG "
		cSQL += "             AND BD7_ORIMOV = " + cAliasPri + "_ORIMOV "
		cSQL += "             AND BD7_SITUAC = '1' "
		cSQL += "             AND BD7_SEQNFS BETWEEN '" + aFiltro[19] + "' AND '" + aFiltro[20] + "' "
		cSQL += "             AND BD7E.D_E_L_E_T_ = ' '
		cSQL += " ) ) ) "
		
	Endif
	
	cSQL += "   AND PRI.D_E_L_E_T_ = '' "
	
	cSQL += "   AND BAU_FILIAL = '" + cFilBAU + "' "
	cSQL += "   AND BAU_CODIGO = " + cAliasPri + "_CODRDA "
	
	If Len(aFiltro) >= 17
		cSQL += " AND BAU_GRPPAG BETWEEN '" + aFiltro[17] + "' AND '" + aFiltro[18] + "' "
	Endif
	
	cSQL += "  AND BAU.D_E_L_E_T_ = '' "
	cSQL += "ORDER BY " + cAliasPri + "_FILIAL, " + cAliasPri + "_CODOPE, " + cAliasPri + "_CODLDP, " + cAliasPri + "_CODPEG, " + cAliasPri + "_FASE, "

	//	Ordem para processar a Mudança de Fase
	if getNewPar("MV_PLSDTMF", "0") == "1"	
		cSQL += cAliasPri + "_DATPRO, " + cAliasPri + "_NUMERO"	//	Data + Número
	else
		cSQL += cAliasPri + "_NUMERO, " + cAliasPri + "_DATPRO"	//	Número + Data
	endIf

	dbUseArea(.T.,"TOPCONN",tcGenQry(,,changeQuery(cSql)),"TrbRetFas",.F.,.T.)
  	
	//Verifico se existe guia com Redução e aviso o usuário
	cChaveP := &(cAliasPri+"->("+cAliasPri+"_CODOPE+"+cAliasPri+"_CODLDP+"+cAliasPri+"_CODPEG+"+cAliasPri+"_NUMERO)")
	
	If (PLSVRDRPY(cChaveP,"1",IsInCallStack('PLSA175RGR')) .and. cTipo $ '2,4')
	
		cMsg := STR0033 + CRLF
		cMsg += STR0034
		cMsg += STR0035 + CRLF
		cMsg += STR0036
		
		//Atenção! Nesta guia tem procedimentos que estão com Redução de Custo. Ao revalorar, voltarão aos valores padrões e será necessário reaplicar a Redução de Custos. Deseja Continuar?"))
		if ! msgYesNo(cMsg)
			lExtGRC := .T.
			lProcOK := .f.
		endIf
		
	endIf
	
	BG9->(DbSetOrder(1))
	BQC->(DbSetOrder(1))
	BA3->(DbSetOrder(1))
	
	if lProcessa .and. ! TrbRetFas->(eof())
		
		TrbRetFas->( dbEval({|| nCount ++ }) )
		TrbRetFas->( dbGoTop() )
	
		procRegua(nCount)
		
	endIf	
	
	while ! TrbRetFas->(eof()) .and. ! lExtGRC
		
		(cAliasPri)->( dbGoTo(TrbRetFas->REG) )
		
		if lProcessa
			incProc('Protocolo ' + (cAliasPri)->&(cAliasPri + "_CODPEG") + ' Guia ' + (cAliasPri)->&(cAliasPri + "_NUMERO") )
		endIf
		
		cChaveGui  := &(cAliasPri+"->("+cAliasPri+"_CODOPE+"+cAliasPri+"_CODLDP+"+cAliasPri+"_CODPEG+"+cAliasPri+"_NUMERO+"+cAliasPri+"_ORIMOV)")
		
		//Ponto de entrada p bypassar uma nota com base em regra especifica        
		//no processo de mudar a peg de uma PEG/Lote de Pegs                       
		if cTipo == "1"
			
			If lPLS175RF
			
				If ! execBlock("PLS175RF",.F.,.F.,{cAliasPri,cNameUsr})
			
					if len(aThreads) > 0 .And. nCont > 0 .And. nTotEventos > 0
						PLSATUVGL(aThreads,nCont,nTotEventos,"2",&(cAliasPri+"->"+cAliasPri+"_QTDEVE"),"PLS175RF",cAliasPri,cChaveGui)
					endIf
					
					TrbRetFas->(dbSkip())
					
					loop
					
				endIf
				
			endIf
			
		endIf
		
		lReval := .T.
		
		cCodEmp := &(cAliasPri+"->"+cAliasPri+"_CODEMP")
		cConEmp := &(cAliasPri+"->"+cAliasPri+"_CONEMP")
		cVerCon := &(cAliasPri+"->"+cAliasPri+"_VERCON")
		cSubCon := &(cAliasPri+"->"+cAliasPri+"_SUBCON")
		cVerSub := &(cAliasPri+"->"+cAliasPri+"_VERSUB")
		cMatric := &(cAliasPri+"->"+cAliasPri+"_MATRIC")
		
		if len(aFiltro) >= 9
			
			if BG9->(msSeek(xFilial("BG9")+cCodOpe+cCodEmp))
			
				if BG9->BG9_TIPO == "2"
				
					if BQC->( msSeek(xFilial("BQC")+cCodOpe+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub))
						lReval := BQC->BQC_GRPCOB >= aFiltro[9] .And. BQC->BQC_GRPCOB <= aFiltro[10]
					endIf
					
				else
					
					If BA3->(msSeek(xFilial("BA3")+cCodOpe+cCodEmp+cMatric))
						lReval := BA3->BA3_GRPCOB >= aFiltro[9] .And. BA3->BA3_GRPCOB <= aFiltro[10]
					endIf
					
				endIf
				
			endIf
			
		endIf
		
		If cTipo $ "3,4" .AND. PLSVERCCBG(&(cAliasPri+"->"+cAliasPri+"_OPEUSR")+&(cAliasPri+"->"+cAliasPri+"_CODEMP")+&(cAliasPri+"->"+cAliasPri+"_MATRIC")+ &(cAliasPri+"->"+cAliasPri+"_TIPREG"),&(cAliasPri+"->"+cAliasPri+"_ANOPAG"),&(cAliasPri+"->"+cAliasPri+"_MESPAG"),&(cAliasPri+"->"+cAliasPri+"_SEQPF"))
		
			if len(aThreads) > 0 .And. nCont > 0 .And. nTotEventos > 0
				PLSATUVGL(aThreads,nCont,nTotEventos,"2",&(cAliasPri+"->"+cAliasPri+"_QTDEVE"),"COBRANÇA",cAliasPri,cChaveGui)
			endIf
		
			TrbRetFas->(DbSkip())
			
			loop
		endIf
		
		If lReval
			
			(cAliasPri)->(dbGoTo(TrbRetFas->REG))
			
			//Retorno de Fase
			if cTipo == "1" 
				
				lProcOK := PLSA500RFS(cAliasPri,(cAliasPri)->(recno()),0,,lAllPEG,,@lCtb,.f.)
				
			//Revalorizacao de Pagto
			elseIf cTipo == "2" 
				
				lProcOK := PLSA500RPG(cAliasPri,(cAliasPri)->(recno()),0,nil,.f.,nDifUs,nVlrDifUs,lAllPEG,@lCtb)
				
			//Revalorização de Cobranca
			elseIf cTipo == "3" .And. ! PLSVERCCBG(&(cAliasPri+"->"+cAliasPri+"_OPEUSR")+&(cAliasPri+"->"+cAliasPri+"_CODEMP")+&(cAliasPri+"->"+cAliasPri+"_MATRIC")+ &(cAliasPri+"->"+cAliasPri+"_TIPREG"),&(cAliasPri+"->"+cAliasPri+"_ANOPAG"),&(cAliasPri+"->"+cAliasPri+"_MESPAG"), &(cAliasPri+"->"+cAliasPri+"_SEQPF")) 

				lProcOK := PLSA500RCB(cAliasPri,(cAliasPri)->(recno()),0,nil,.f.,,lAllPEG,@lCtb) 
			
			//Revalorização de Cobranca
			elseIf cTipo == "4" .And. ! PLSVERCCBG(&(cAliasPri+"->"+cAliasPri+"_OPEUSR")+&(cAliasPri+"->"+cAliasPri+"_CODEMP")+&(cAliasPri+"->"+cAliasPri+"_MATRIC")+ &(cAliasPri+"->"+cAliasPri+"_TIPREG"),&(cAliasPri+"->"+cAliasPri+"_ANOPAG"),&(cAliasPri+"->"+cAliasPri+"_MESPAG"), &(cAliasPri+"->"+cAliasPri+"_SEQPF")) 
			
				lProcOK := PLSA500RCP(cAliasPri,(cAliasPri)->(recno()),0,nil,.f.,,,lAllPEG,@lCtb)
				
			endIf
			
			(cAliasPri)->( dbGoTo(TrbRetFas->REG) )
			
			if lProcOK 
				
				if len(aThreads) > 0 .And. nCont > 0 .And. nTotEventos > 0
					PLSATUVGL(aThreads,nCont,nTotEventos,"1",&(cAliasPri+"->"+cAliasPri+"_QTDEVE"),"PLSA175 ["+cTipo+"]",cAliasPri,cChaveGui)
				endIf
				
			elseIf len(aThreads) > 0 .and. nCont > 0 .and. nTotEventos > 0
				
				PLSATUVGL(aThreads,nCont,nTotEventos,"2",&(cAliasPri+"->"+cAliasPri+"_QTDEVE"),"PLSA500 ["+cTipo+"]",cAliasPri,cChaveGui)
				
			endIf
			
		else
			
			if len(aThreads) > 0 .And. nCont > 0 .And. nTotEventos > 0
				PLSATUVGL(aThreads,nCont,nTotEventos,"2",&(cAliasPri+"->"+cAliasPri+"_QTDEVE"),"COBRANÇA",cAliasPri,cChaveGui)
			endIf
			
		endIf
		
		if ! lProcOK
			lProcErro := .t.
		endIf	
		
	TrbRetFas->( dbSkip() )
	endDo
	
	TrbRetFas->(dbCloseArea())
	
	dbSelectArea("BA1")
	
	eval(bRest)
	
	//Mudo o status da PEG
	if nReg <> 0
		PLSM190Pro(,,,,,,,,,,,.f.,.t.,nReg)
	endIf
	if lMsg
		//Retorno de Fase
		if cTipo == "1" 

			if lProcErro
				msgInfo("Não foi possível retornar a fase de todas as guias.")
			else
				msgInfo("Retorno de Fase concluida.")
			endIf	

		//Revalorizacao de Pagto		
		elseIf cTipo == "2"

			if lProcErro
				msgInfo("Revalorização de Pagto Interrompida.")
			else	
				msgInfo("Revalorizacao de Pagto concluida.")
			endIf	

		//Revalorizacao de Cobranca
		elseIf cTipo == "3"

			if lProcErro
				msgInfo("Revalorização de Cobranca Interrompida.")
			else
				msgInfo("Revalorizacao de Cobranca concluida.")
			endIf	

		//Revalorizacao de Pagto e Cobranca	
		elseIf cTipo == "4"

			if lProcErro
				msgInfo("Revalorização de Pagto e Cobrança Interrompida.")
			else	
				msgInfo("Revalorizacao de Pagto e Cobranca concluida.")
			endIf	

		endIf
	endIf
endIf

return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcoes   ³ PLSA175RFS,PLSA175RPG,PLSA175RCB e PLSA175RCP              ³±±
±±³Objetivo  ³ As funcoes abaixo foram substituidas por uma funcao unica  ³±±
±±³          ³ chamada PLSA175RGR com um parametro de indicacao de        ³±±
±±³          ³ processo. caso alguma customizacao em campo chame alguma   ³±±
±±³          ³ funcao abaixo sera exibido uma mensagem orientando consu   ³±±
±±³          ³ o dem da funcao PLSA175RGR                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA175RFS()
MsgStop(STR0029+"PLSA175RFS"+STR0030+"PLSA175RGR"+Chr(13)+STR0031)
Return

Function PLSA175RPG()
MsgStop(STR0029+"PLSA175RPG"+STR0030+"PLSA175RGR"+Chr(13)+STR0031)
Return

Function PLSA175RCB()
MsgStop(STR0029+"PLSA175RCB"+STR0030+"PLSA175RGR"+Chr(13)+STR0031)
Return

Function PLSA175RCP()
MsgStop(STR0029+"PLSA175RCP"+STR0030+"PLSA175RGR"+Chr(13)+STR0031)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Darcio R. Sporl       ³ Data ³27/12/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao…o ³ Utilizacao de menu Funcional                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
PRIVATE aRotina := {	{ STR0001	,'PLSA498PES'  , 0 , K_Pesquisar  	, 0, .F.},; //'Pesquisar' //"Pesquisar"
						{ STR0002	,'PLSA175MOV'  , 0 , K_Visualizar 	, 0, Nil},; //'Visualizar' //"Visualizar"
						{ STR0003	,'PLSA175MOV'  , 0 , K_Incluir    	, 0, Nil},; //'Incluir' //"Incluir"
						{ STR0004	,'PLSA175MOV'  , 0 , K_Alterar    	, 0, Nil},; //'Alterar' //"Alterar"
						{ STR0005	,'PLSA175MOV'  , 0 , K_Excluir    	, 0, Nil},; //'Excluir' //"Excluir"
						{ STR0006	,'PLSA175FAS'  , 0 , K_Alterar    	, 0, Nil},; //"Mudanca Fase"
						{ STR0007	,'PLSPROCRGR'  , 0 , K_RetFas     	, 0, Nil},; //"Retorno Fase"
						{ STR0008	,'PLSPROCRGR'  , 0 , K_RevPag		, 0, Nil},; //"Revalor. Pagto"
						{ STR0009	,'PLSPROCRGR'  , 0 , K_RevCob		, 0, Nil},; //"Revalor. Cobr."
						{ STR0010	,'PLSPROCRGR'  , 0 , K_RevCP		, 0, Nil},; //"Rev.Cobr./Pagto"
						{ "Gerenciar Peg",'PLSA498RES',0,0		 		,0,nil},;
						{ STR0011	,'PLSA175LEG'  , 0 , 0   			, 0, .F.} } //"Legenda"

return(aRotina)  

/*/{Protheus.doc} PLSPROCRGR
//Processa Retorno de fase e revaloracao
@author PLSTEAM
@since 25/04/2017
/*/
function PLSPROCRGR(cAlias,nReg,nOpc,cTipo,lMsg)
default cTipo := ""
default lMsg  := .t.

if !(cTipo $ " 1234")//se vier algo estranho é pq veio do menudef
	cTipo := ""
	lMsg  := .t.
endif

processa( {|| PLSA175RGR(cAlias,nReg,nOpc,.t.,lMsg,,,,,,,cTipo) },"Aguarde.....","Processando...",.f.)

return(.t.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLSVDBCI  ³ Autor ³ Totvs			        ³ Data ³27/12/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida a Data de pagamento								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVDBCI()
LOCAL aArea     := GetArea()
LOCAL lRet 	 	:= .T.
LOCAL aRet      := {}

If !Empty(M->BCI_CODDAT)

	If M->BCI_CODDAT <> "000"

		aRet:= PLSXVLDCAL(M->BCI_DATREC,M->BCI_CODOPE,,,,,M->BCI_CODRDA,M->BCI_TIPGUI =="04")

		If Len(aRet) > 6 
			If Empty(aRet[6]) .And. Len(aRet[6]) == 0
				aRet[6] := StrZero( 0, TamSx3("BDT_CODDAT")[1] )
			EndIf
		 	If aRet[6] <> M->BCI_CODDAT
				MsgInfo("Codigo de Data de pagamento Invalido Ou deve selecionar Data especifica para RDA informada!")
				lRet:=.F.
			Else
				M->BCI_DATPAG := aRet[7]
			Endif

		Endif
	Endif
Endif
RestArea(aArea)

Return lRet 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLSVDTRPEG ³ Autor ³ Microsiga          ³ Data ³ 02/02/2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricaoo ³ Validacao Data Recebimento da PEG.				          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVDTRPEG(dDatRec,cCodInt,cCodRda,cTipGuia)
LOCAL aArea        := GetArea()
LOCAL lRet         := .T.
LOCAL cCodDat      := "000"
LOCAL dDatPagto    := cTod("") 
LOCAL aDatPag      :={}
LOCAL lReembolso   := .F.
Default cCodInt    := PLSINTPAD()
Default dDatRec    := dDataBase
Default cCodRda    := ""
Default cTipGuia   := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Verifica a data de recebimento aonde tem que ser menor que a database
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If ReadVar() == "M->BCI_DATREC" .And. !Empty(dDatRec) .And. dDatRec > dDataBase
	lRet:= .F.
	Help( ,, 'HELP',,"Data Recebimento maior que a data atual do sistema!", 1, 0)
	Return lRet
Endif

If !Empty(cTipGuia) .And. cTipGuia == "04"
	lReembolso := .T.
Endif

aDatPag  := PLSXVLDCAL(dDatRec,cCodInt,.T.,"","",NIL,cCodRda,lReembolso) 

If Len(aDatPag) > 6
	cCodDat   := IIf(Empty(aDatPag[6]),cCodDat,aDatPag[6])
	dDatPagto := aDatPag[7]
Endif

If readvar() $ "M->BCI_CODRDA,M->BCI_CGCRDA,M->BCI_DATREC"
	If !Empty(dDatRec)
		M->BCI_CODDAT := cCodDat
		M->BCI_DATPAG := dDatPagto
	Else
		M->BCI_CODDAT := ""
		M->BCI_DATPAG := ""
	Endif       
ElseIf readvar() == "M->B44_DATREC" 
	If !Empty(dDatRec)
		M->B44_CODDAT := cCodDat
		M->B44_DATPAG := dDatPagto
	Else
		M->B44_CODDAT := ""
		M->B44_DATPAG := ""
	Endif       	
Endif

RestArea(aArea)

Return lRet 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLSVAlPAP  ³ Autor ³ Microsiga          ³ Data ³ 02/02/2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao Campo Necessita Papel PEG - BCI_GUIPAP	          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVAlPAP()
LOCAL aArea  := GetArea()
LOCAL cRda   := ""

If ReadVar() == "M->BCI_CGCRDA"
	BAU->(dBSetOrder(4))//BAU_FILIAL, BAU_CPFCGC
	If BAU->(MsSeek(xFilial("BAU")+M->BCI_CGCRDA))
		cRda:= BAU->BAU_CODIGO
	Endif	
Else
	cRda:= M->BCI_CODRDA
Endif 

If PLSRETPAP(M->BCI_OPERDA, cRda, M->BCI_TIPGUI)
	M->BCI_GUIPAP :='1'
Else
	M->BCI_GUIPAP :='0'
Endif

RestArea(aArea)

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLSVAlPAP  ³ Autor ³ Microsiga          ³ Data ³ 02/02/2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao Campo Necessita Papel PEG - BCI_GUIPAP	          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVCGRD(nTp)
LOCAL lRet := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Valida cgc
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Do Case
	Case nTp == 1
		If Empty(AllTrim(M->BCI_CGCRDA))                   
			M->BCI_CODRDA	:= Space(TamSx3("BCI_CODRDA")[1])
			lRet 		  	:= PLSVDTRPEG(M->BCI_DATREC,M->BCI_CODOPE,M->BCI_CODRDA,M->BCI_TIPGUI)
		Else	
			lRet 			:= ( CGC(M->BCI_CGCRDA) .And. ExistCpo("BAU",M->BCI_CGCRDA,4) ) .And. PLSVLDRDG(M->BCI_CGCRDA,.T.) .And. PLSVALPAP()
		EndIf       
	Case nTp == 2
		If Empty(AllTrim(M->BCI_CODRDA))                   
			M->BCI_CGCRDA	:= Space(TamSx3("BCI_CGCRDA")[1])
			lRet 		  	:= PLSVDTRPEG(M->BCI_DATREC,M->BCI_CODOPE,M->BCI_CODRDA,M->BCI_TIPGUI)
		Else	
			lRet 			:= ExistCpo("BAU",M->BCI_CODRDA,1) .And. PLSVLDRDG(M->BCI_CODRDA) .And. PLSVAlPAP()
		EndIf	
EndCase		

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA175   ºAutor  ³Microsiga           º Data ³  03/07/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se altera o status da fatura de cobr. p/ 1-aberto  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Pl175VerGui(cAlias,cCodOpe,cCodLdp,cCodPeg,cFase)
Local lret		:=.F.
Local lAlterBci	:=.F.

(cAlias)->( DbSetOrder(1) ) 
(cAlias)->( DbGotop() ) 

If (cAlias)->( DbSeek(xFilial(cAlias)+cCodOpe+cCodLdp+cCodPeg)) 
   While !(cAlias)->(Eof()) .And. (cAlias)->(&(cAlias+"_FILIAL")+&(cAlias+"_CODOPE")+&(cAlias+"_CODLDP")+&(cAlias+"_CODPEG")) == xFilial(cAlias)+cCodOpe+cCodLdp+cCodPeg
   		If &(cAlias+"->"+cAlias+"_FASE") ="1" .and. &(cAlias+"->"+cAlias+"_SITUAC")<>"2" 
	   		(cAlias)->(RecLock((cAlias),.F.))
	   		&(cAlias+"->"+cAlias+"_STAFAT"):="1"
			(cAlias)->(MsUnlock())
			lAlterBci:=.T.
   		Endif
		(cAlias)->( DbSkip() )   
   Enddo
Endif  

If lAlterBci
	BCI->(RecLock("BCI",.F.))
	BCI->BCI_FASE := "1" 
	If BCI->BCI_STTISS < "2" 	
		BCI->BCI_STTISS := "2"//Recebido
	EndIf
	cFase := "1"
	BCI->(MsUnlock())   
Endif	

Return(cFase)
