#INCLUDE "plsmctmd.ch"
#include "COLORS.CH"
#include "PROTHEUS.CH" 
#include "PLSMGER.CH"
#include "PLSMCCR.CH"
 
#DEFINE __aCdCri032 {"540",STR0169} //"Erro controlado SIGAPLS."
#DEFINE __aCdCri196 {"09M",STR0228}//"Data pagamento não pode ser menor que a data atual do sistema"
#DEFINE __aCdCri223 {"590","Unidade com bloqueio automático pela BD3."}
#DEFINE __cTextoAll STR0229 //"*** Todos ***"

STATIC __aNiveis 	:= {}
STATIC UID_VLDCAL 	:= 'PLSXVLDCAL'
STATIC cconcateZ	:= IIF( AllTrim( TCGetDB() ) $ "ORACLE/DB2/POSTGRES" , '||', '+')
Static lAtuB2K	:= B2K->(FieldPos("B2K_DIAIN2")) > 0 .AND. B2K->(FieldPos("B2K_DIAFI2")) > 0
STATIC lUnimed		:= allTrim(getNewPar("MV_PLSUNI","1")) == "1"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSXMUDFAS ³ Autor ³ Tulio Cesar       ³ Data ³ 22.10.2002 ³±±                    
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina generica para mudanca de fase.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Rotina de movimentacao (Contas Medicas)                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
cAlias    - Alias do Arquivo
cTipo     - "1" - Movimento Simples
            "2" - PEG
cTipoGuia - Tipo de Guia        
/*/
Function PLSXMUDFAS(cAlias, cTipo, cCodOpe, cTipGuia, dDatPro, lAutori, cNextFase, nVlrPAG, nVlrGlo, lHelp, aItensGlo,;
				    aFiltro, lReanaliza, lIntEnv, oBrwIte, lProcRev, nIndRecBD6, nTotEventos, aThreads, nCont, cUserName,;
				    lSolicit, aPLS475, lPagAto, cChaveLib, lNegProPac, lGetCri, lProtoc, lNotUsed, aSequen, isPLSA502)
				    				    
LOCAL lRet     		:= .f.
LOCAL aRet     		:= {}
LOCAL aRetAux  		:= {.F.,"",{}}
LOCAL cMacro        := ""                                                                 
LOCAL cCpoFase 		:= (cAlias)->&(cAlias + "_FASE")
LOCAL cAno			:= BCI->BCI_ANO
LOCAL cMes          := BCI->BCI_MES

DEFAULT lHelp      	:= .t.
DEFAULT aItensGlo  	:= {}
DEFAULT aFiltro    	:= {}
DEFAULT lReanaliza 	:= .T.
DEFAULT lIntEnv    	:= .F.
DEFAULT oBrwIte	   	:= nil
DEFAULT lProcRev   	:= .F.                                          
DEFAULT nIndRecBD6 	:= 0
DEFAULT nTotEventos := 0
DEFAULT aThreads    := {}                              
DEFAULT nCont       := 0                                                     
DEFAULT cUserName   := ""                                                    
DEFAULT lSolicit	:= .f.  
DEFAULT aPLS475     := {.F.,"",""}
DEFAULT lPagAto     := .F.                           
DEFAULT cChaveLib	:= ""
DEFAULT lNegProPac	:= .F.                                        
DEFAULT lGetCri		:= .F.
DEFAULT lProtoc		:= .F.
DEFAULT lNotUsed	:= .F.
DEFAULT aSequen 	:= {}
default isPLSA502	:= .f.

//Estrutura do aRet [1] Alterado a fase sim ou nao (Logico)                
//                  [2] Fase alterada                                      
//                  [3,1] Codigo da Glosa                                  
//                  [3,2] Motivo da Glosa                                  
//                  [3,3] Descricao da Glosa                               
If BCI->BCI_TIPGUI <> BCL->BCL_TIPGUI
	BCL->(DbSetOrder(1))
	BCL->(MsSeek(xFilial("BCL")+BCI->(BCI_CODOPE+BCI_TIPGUI)))
EndIf

// Ponto de Entrada para manipular o status do lAutori. Criado para utilizacao na rotina de importacao    
// Xml para manter a guia em conferencia quando todos os procedimentos forem negados e bloqueados.        
// Retorno: T -> Considera a mudanca de fase como uma Autorizacao (guia ficara Ativa)                     
//          F -> Considera a mudanca de fase como uma guia no Contas Medicas (guia ficara em Conferencia) 
If Existblock("PLNEGMFAS")
   lAutori := Execblock("PLNEGMFAS",.F.,.F.,{lAutori})
EndIf

//Executa funcao de mudanca de fase...                                     
If ! Empty(BCL->BCL_FUNMFS) 

   if BCL->BCL_TIPMFS == "1"                         

      aPar   := {cAlias,;			//01
                 cTipo,;			//02
                 cCodOpe,;			//03
                 cTipGuia,;			//04
                 &cCpoFase,;		//05
                 BCI->BCI_CODLDP,;	//06
                 BCI->BCI_CODPEG,;	//07
                 BCL->BCL_GUIREL,;	//08
                 lAutori,;			//09
                 dDatPro,;			//10
                 lHelp,;			//11
                 cNextFase,;		//12
                 nVlrPAG,;			//13
                 nVlrGlo,;			//14
                 lHelp,;			//15
                 BCL->BCL_ALIAS,;	//16
                 aItensGlo,;		//17
                 aFiltro,;			//18
                 lReanaliza,;		//19
                 lIntEnv,;			//20
                 oBrwIte,;			//21
                 lProcRev,;			//22
                 nIndRecBD6,;		//23
                 nTotEventos,;		//24
                 aThreads,;			//25
                 nCont,;			//26
                 cUserName,;		//27
                 lSolicit,;			//28
                 aPLS475,;			//29
                 lPagAto,;			//30
                 cChaveLib,;		//31
                 lNegProPac,;		//32	
                 lGetCri,;			//33
                 lProtoc,;			//34
                 lNotUsed,;			//35
                 aSequen,;			//36	
                 isPLSA502}			//37
        
        cMacro := ( allTrim(BCL->BCL_FUNMFS) + "(aPar)" )    
		
		if lHelp
			processa( {|| aRetAux := &(cMacro) }, "Aguarde.....", "Processando...",.F.)
		else
			aRetAux := &(cMacro) 
		endIf      
		   
   else

   		aRetAux := execBlock(BCL->BCL_FUNMFS,.F.,.F.,{	cAlias,cTipo,cCodOpe,cTipGuia,&cCpoFase,;
                   	          							BCI->BCI_CODLDP,BCI->BCI_CODPEG,BCL->BCL_GUIREL,lAutori,dDatPro,;
                              							lHelp,cNextFase,nVlrPAG,nVlrGlo,lHelp,BCL->BCL_ALIAS,aItensGlo,aFiltro,;
                              							lReanaliza,lIntEnv,oBrwIte,lRevaloriza,nIndRecBD6,nTotEventos,aThreads,nCont,cUserName,;
                              							lSolicit,aPLS475,lPagAto,cChaveLib}) 

   endIf

endIf

aItensGlo	:= {}

Return(aRetAux)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSXCRIGUI ³ Autor ³ Tulio Cesar       ³ Data ³ 22.10.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe dialogo com criticas de mudanca de fase              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Rotina de movimentacao (Contas Medicas)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Padrao do mBrowse                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSXCRIGUI(aCritica,cTipo,cNivel,cAliasPri,cTitulo)

	Static objCENFUNLGP := CENFUNLGP():New()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL oDlg
LOCAL oGrupoCab
LOCAL oGrupoCri
LOCAL oCritica
LOCAL nOpca     := 0
LOCAL bOK       := { || nOpca := K_OK, oDlg:End() }
LOCAL bCancel   := { || oDlg:End() }
LOCAL nInd
LOCAL nAux
LOCAL aAlias 	:= {}

DEFAULT cTitulo := STR0001 //"Criticas"

AaDd(aAlias, cAliasPri)
objCENFUNLGP:setAlias(aAlias)

DEFINE MSDIALOG oDlg TITLE cTitulo FROM ndLinIni,ndColIni TO ndLinFin,ndColFin OF GetWndDefault()

If cTipo == "1"
   @ 020,005 GROUP oGrupoCab TO 055,350 OF oDlg LABEL STR0002  COLOR CLR_HBLUE, CLR_HRED PIXEL       //" Dados da Guia "

   @ 025,010 SAY oSay PROMPT STR0003   SIZE 220,010 OF oDlg PIXEL  //"Usuario     "
   @ 025,045 SAY oSay PROMPT objCENFUNLGP:verCamNPR((cAliasPri+"_NOMUSR"),&(cAliasPri+"->"+cAliasPri+"_NOMUSR")) SIZE 205,010 OF oDlg PIXEL COLOR CLR_HBLUE

   @ 035,010 SAY oSay PROMPT STR0004   SIZE 220,010 OF oDlg PIXEL  //"Prestador   "
   @ 035,045 SAY oSay PROMPT objCENFUNLGP:verCamNPR((cAliasPri+"_NOMRDA"),&(cAliasPri+"->"+cAliasPri+"_NOMRDA")) SIZE 205,010 OF oDlg PIXEL COLOR CLR_HBLUE

   @ 045,010 SAY oSay PROMPT STR0005   SIZE 220,010 OF oDlg PIXEL  //"Data Evento "
   @ 045,045 SAY oSay PROMPT objCENFUNLGP:verCamNPR((cAliasPri+"_DATPRO"),&(cAliasPri+"->"+cAliasPri+"_DATPRO")) SIZE 205,010 OF oDlg PIXEL COLOR CLR_HBLUE

   @ 025,205 SAY oSay PROMPT STR0006   SIZE 220,010 OF oDlg PIXEL  //"Solicitante "
   @ 025,240 SAY oSay PROMPT objCENFUNLGP:verCamNPR((cAliasPri+"_NOMSOL"),&(cAliasPri+"->"+cAliasPri+"_NOMSOL")) SIZE 205,010 OF oDlg PIXEL COLOR CLR_HBLUE

   @ 035,205 SAY oSay PROMPT STR0007   SIZE 220,010 OF oDlg PIXEL  //"Senha Autor."
   @ 035,240 SAY oSay PROMPT objCENFUNLGP:verCamNPR((cAliasPri+"_SENHA"),&(cAliasPri+"->"+cAliasPri+"_SENHA")) SIZE 205,010 OF oDlg PIXEL COLOR CLR_HBLUE

   @ 045,205 SAY oSay PROMPT STR0008   SIZE 220,010 OF oDlg PIXEL  //"CID         "
   @ 045,220 SAY oSay PROMPT objCENFUNLGP:verCamNPR((cAliasPri+"_CID"),&(cAliasPri+"->"+cAliasPri+"_CID"))     SIZE 205,010 OF oDlg PIXEL COLOR CLR_HBLUE

   @ 045,250 SAY oSay PROMPT STR0009   SIZE 220,010 OF oDlg PIXEL  //"Nivel "
   @ 045,268 SAY oSay PROMPT cNivel+"-"+PLSDesNiv(cNivel) SIZE 205,010 OF oDlg PIXEL COLOR CLR_HBLUE
Else
   @ 015,005 GROUP oGrupoCab TO 055,350 OF oDlg LABEL STR0010  COLOR CLR_HBLUE, CLR_HRED PIXEL            //" Dados do PEG "

   @ 025,010 SAY oSay PROMPT STR0004   SIZE 220,010 OF oDlg PIXEL  //"Prestador   "
   @ 025,044 SAY oSay PROMPT objCENFUNLGP:verCamNPR((cAliasPri+"_NOMRDA"),&(cAliasPri+"->"+cAliasPri+"_NOMRDA")) SIZE 205,010 OF oDlg PIXEL COLOR CLR_HBLUE
Endif

@ 060,005 GROUP oGrupoCri TO 195,350 OF oDlg LABEL STR0011  COLOR CLR_HBLUE, CLR_HRED PIXEL       //" Criticas "

oCritica := TcBrowse():New( 075, 012, 330, 110,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
                                            
oCritica:AddColumn(TcColumn():New(STR0012,{ || aCritica[oCritica:nAt,6]+"-"+aCritica[oCritica:nAt,7] },; //"Procedimento"
         "@C",nil,nil,nil,040,.F.,.F.,nil,nil,nil,.F.,nil))     

oCritica:AddColumn(TcColumn():New(STR0013,{ || aCritica[oCritica:nAt,1] },; //"Codigo"
         "@C",nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))     

oCritica:AddColumn(TcColumn():New(STR0014,{ || aCritica[oCritica:nAt,2] },; //"Critica"
         "@C",nil,nil,nil,200,.F.,.F.,nil,nil,nil,.F.,nil))     

oCritica:AddColumn(TcColumn():New(STR0015,{ || aCritica[oCritica:nAt,3] },; //"Descricao"
         "@C",nil,nil,nil,050,.F.,.F.,nil,nil,nil,.F.,nil))     

//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
	if objCENFUNLGP:isLGPDAt()
		aCampos := {"BD6_CODPAD+BD6_CODPRO","BD6_MOTBPG","BD6_DESBPG", .F.}
		aBls := objCENFUNLGP:getTcBrw(aCampos)

		oCritica:aObfuscatedCols := aBls
	endif

oCritica:SetArray(aCritica)         

ACTIVATE MSDIALOG oDlg 

Return(nOpca)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSXVLDCAL ³ Autor ³ Tulio Cesar       ³ Data ³ 15.08.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida o calendario de pagamento                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSXVLDCAL(dData,cCodOpe,lHelp,cCodPad,cCodPro,lRPC,cCodRDA,lReembolso,lJob)
LOCAL cSQL         	:= ""       
LOCAL aRet         	:= {}
LOCAL aCriticas    	:= {}                 
LOCAL aArea        	:= GetArea()
LOCAL cReembolso   	:= "0"
LOCAL dDataPagto   	:= ctod("")
LOCAL lCalend      	:= .F.
LOCAL cCodPagto    	:= Iif( BDT->(FieldPos("BDT_CODDAT")) > 0,StrZero( 0, TamSx3("BDT_CODDAT")[1] ),'000')
LOCAL lDataProc	   	:= .F.
LOCAL lDtRdaPag	   	:= .T.
LOCAL lDtMenor	   	:= .F.
LOCAL lEntrou	   	:= .F.
LOCAL lMVPLSDTPG   	:= GetNewPar("MV_PLSDTPG",.F.)
LOCAL cNewCALPG    	:= GetNewPar("MV_PLCALPG","1")
Local dDataIni 	   	:= ctod("")
Local dDataFim     	:= ctod("")
Local cMesCal      	:= ""
Local cAnoCal      	:= ""
Local lBau		   	:= .F.
Local cBauFrom		:= ""
Local cBauWhr		:= ""		
Local cCalEspeci	:= ""
Local lRegra1		:= .F.
Local lRegra2		:= .F.
Local lRegra3		:= .F.
Local lRegra4		:= .F.
Local lRegra5		:= .F.
local cHashCHV 		:= ''
local lGHash		:= .f.
local lBDTEoF		:= .T.
Local lNewCalPg		:= cNewCALPG <> '1'
Local dDataIn2		:= StoD("")
Local dDataFi2		:= StoD("")
Local cMesBDt		:= ""
Local cAnoBDt		:= ""
Local lJanela2		:= .F.
Local dDatPreBDt 	:= StoD("")
Local dDatPagBDT 	:= StoD("")

default lReembolso 	:= .F. 
default cCodRDA	   	:= ''
default lHelp 	   	:= .F.                                  
default lRPC       	:= .F. 
default cCodPad		:= '' 
default cCodPro		:= ''
default lJob		:= .f.

If lReembolso
	cReembolso := "1"
EndIf

//Esta glosa nao pode ser desligada...                                     
PLSPOSGLO(PLSINTPAD(),__aCdCri025[1],__aCdCri025[2])

cSQL:= " SELECT	BDT_CODINT, BDT_ANO, BDT_MES, BDT_DATINI, BDT_DATFIN, BDT_DATPRE "

If BDT->( FieldPos("BDT_CODDAT") ) > 0 .And. BDT->( FieldPos("BDT_CODRDA") ) > 0
	cSQL+= ",BDT_REEMB, BDT_CODDAT, BDT_DATPAG, BDT_CODRDA "                                                      
EndIf

cSQL+= " FROM " + RetSQLName("BDT") + " BDT "
cSQL+= " WHERE BDT_FILIAL = '" + xFilial("BDT")	         + "' "
cSQL+= " AND BDT_CODINT	  = '" + cCodOpe 			     + "' "
cSQL += " AND '"+dtos(dData)+"' >= BDT_DATINI AND '"+dtos(dData)+"' <= BDT_DATFIN "

If BDT->( FieldPos("BDT_REEMB") ) > 0       
	If cReembolso == '0'
		cSQL+= " AND ( BDT_REEMB	= '" + cReembolso + "' OR BDT_REEMB	= ' ' )"
	Else
		cSQL+= " AND BDT_REEMB	= '" + cReembolso		   + "' "
	Endif
EndIf

cSQL+= " AND BDT.D_E_L_E_T_	= ' ' "
If BDT->( FieldPos("BDT_CODRDA") ) > 0
	cSQL+= " ORDER BY BDT_CODRDA DESC,BDT_DATINI,BDT_DATFIN"
Endif

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbBDT",.F.,.T.)

lBDTEoF := TrbBDT->(Eof())

If (cNewCALPG $ "1") .OR. !lBDTEoF
			
	If lBDTEoF //Sem alterção, só entra aqui pela regra antiga.
		
		RestArea(aArea)
		aadd(aCriticas,{__aCdCri025[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
		
		// Alias e caminho da critica.
		PLSCOMPCRI(aCriticas,"BDT")   
		
		If !lRPC .And. lHelp
			Help("",1,"PLSXVLDVAL")
		Endif
		
		aRet := {.F.,aCriticas,ctod(""),"","",cCodPagto,ctod("")}
		
	Else
	
		BXU->( DbSetOrder(3) ) //BXU_FILIAL, BXU_CODINT, BXU_DATPAG, BXU_REEMB
		While TrbBDT->( !Eof() )
	
			If ( dtos(dData) >= TrbBDT->BDT_DATINI .And. dtos(dData) <= TrbBDT->BDT_DATFIN ) .Or. lDataProc
				lEntrou := .T.
				
				If lMVPLSDTPG 			//GetNewPar("MV_PLSDTPG",.F.)
					lDataProc := .F. 
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifico se a Data de Pagto ja esta Processada                           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
					If BDT->( FieldPos("BDT_DATPAG") ) > 0 .And. FieldPos("BDT_REEMB") > 0 .And. BXU->( MsSeek( xFilial("BXU") + TrbBDT->(BDT_CODINT+BDT_DATPAG+BDT_REEMB) ) ) .And. !Empty(BXU->BXU_DATPRO)
						lDataProc:= .T.
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
						//³ Se teve calendario fechado para rda 
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
						If BDT->( FieldPos("BDT_CODRDA") ) > 0 .And. TrbBDT->BDT_CODRDA == cCodRDA
							lDtRdaPag 	:= .F.
							dDataPagto 	:= StoD(TrbBDT->BDT_DATPAG)
							lCalend   	:= .T.
							
							If StoD(TrbBDT->BDT_DATPAG) <= dDataBase 
								dDataPagto 	:= ctod("")               
								lCalend		:= .F.
								lDtMenor 	:= .T.
							EndIf
							
							Exit
						EndIf
						
						TrbBDT->( DbSkip() )
						Loop
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Validacao do calendario.						                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If BDT->( FieldPos("BDT_DATPAG") ) > 0 .And. BDT->( FieldPos("BDT_CODRDA") ) > 0
					
						If !lDataProc .And. (Empty(TrbBDT->BDT_CODRDA) .Or. Alltrim(cCodRda) == Alltrim(TrbBDT->BDT_CODRDA)) .And. StoD(TrbBDT->BDT_DATPAG) >= dDataBase
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
							//³ Codigo do pagamento
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
							If lDtRdaPag .And. BDT->(FieldPos("BDT_CODDAT")) > 0
								cCodPagto  := Iif( Empty(TrbBDT->BDT_CODDAT), StrZero( 0, TamSx3("BDT_CODDAT")[1] ), TrbBDT->BDT_CODDAT)
								dDataPagto := StoD(TrbBDT->BDT_DATPAG)
							EndIf
								
							lCalend   := .T.
							Exit
						EndIf
						
					Else
						lCalend   := .T.
						Exit
					EndIf
				Else
					lCalend   := .T.
					Exit
				EndIf
				
			EndIf
			TrbBDT->( DbSkip() )
			
		EndDo
	
		If !lCalend .AND. !lNewCalPg
			
			RestArea(aArea)           
			
			If lEntrou .Or. lDtMenor
	
				PLSPOSGLO(PLSINTPAD(),__aCdCri196[1],__aCdCri196[2])
				aadd(aCriticas,{__aCdCri196[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
			
				// Alias e caminho da critica.
				PLSCOMPCRI(aCriticas,"BDT")
				
				If !lRPC .And. lHelp
					Help( ,, 'HELP',,"Data pagamento não pode ser menor que a data atual do sistema!", 1, 0)
				EndIf
			Else
				aadd(aCriticas,{__aCdCri025[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
	
				// Alias e caminho da critica.
				PLSCOMPCRI(aCriticas,"BDT")   
					
				If !lRPC .And. lHelp
					Help("",1,"PLSXVLDVAL")
				EndIf
			EndIf   	
			
			aRet := {.F.,aCriticas,ctod(""),"",cCodPagto,ctod("")}
	
		Else

			BFM->(DbSetOrder(1))
			If BFM->(MsSeek(xFilial("BFM")+cCodOpe+TrbBDT->BDT_ANO+TrbBDT->BDT_MES)) .And. BFM->BFM_VALRDA > 0 .And. BFM->BFM_VALCOP > 0
				aRet := {.T.,{},TrbBDT->BDT_DATPRE,TrbBDT->BDT_ANO,TrbBDT->BDT_MES,cCodPagto,dDataPagto}
				
				RestArea(aArea)
			Elseif !lNewCalPg
				aadd(aCriticas,{__aCdCri025[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
				
				// Alias e caminho da critica.
				PLSCOMPCRI(aCriticas,"BDT")   
		
				If !lRPC .And. lHelp
					Aviso( STR0016, ; //"U.S Mensais"
							STR0017,; //"Nao existem U.S Mensais cadastrada para o Ano/Mes do calendario de pagamento atual"
							{ "Ok" }, 2 ) 	                                                                    
				Endif
				aRet := {.F.,aCriticas,ctod(""),"","",cCodPagto,ctod("")}
				
				RestArea(aArea)
			Endif
		Endif   
	Endif   

endif

/*
aRet := {.T.,{},TrbBDT->BDT_DATPRE,TrbBDT->BDT_ANO,TrbBDT->BDT_MES,cCodPagto,dDataPagto}
posição - descrição
1 - se achou (.T.) ou não (.F.)
2 - array de críticas
3 - Data de previsão de pagamento (não serve pra muita coisa)
4 - Ano competência
5 - Mês competência
6 - ?
7 - Data de pagamento prevista para a competência
8 - Data início da janela de recebimento de faturas 1 (formato caractere)
9 - Data fim da janela de recebimento de faturas 1 (formato caractere)
10 - lógico indicando se existe segunda janela
11 - Data início da janela de recebimento de faturas 2 (formato caractere)
12 - Data fim da janela de recebimento de faturas 2 (formato caractere)

Observações:
a data 7 leva em conta a competência -> no novo vai usar a PLSCHKNCAL, não essa função. PLSCHKNCAL olha a competência já gravada, por isso não vamos ter problema.
as datas 8, 9, 10 e 11 levam em conta a data atual

Regra final:
O sistema vai buscar a competência no BDT primeiro, usando de base a data informada
Caso encontre competência e data de previsão de pagamento, elas irão valer independente do B2K
Após isso o sistema vai buscar no B2K
Caso não haja informações da BDT, os dados encontrados na B2K irão valer
As janelas sempre vão valer o da B2K, pois somente nela é que é possível fazer o cadastro
*/
If !(cNewCALPG $ "1")
	
	if !empTy(aRet) .AND. aRet[1]
		cMesBDt := aRet[5]
		cAnoBDt := aRet[4]
		dDatPreBDt := StoD(aRet[3])
		dDatPagBDT := aRet[7]
	endif	
	//Tratamento novo Calendario de Pagamento.
	BAU->(dbSetOrder(1)) //BAU_FILIAL+BAU_CODIGO
	if !Empty(cCodRDA)		
		If BAU->( DBSeek( xFilial("BAU") +Alltrim(cCodRDA) ))
			IF !Empty(BAU->BAU_CALPGT)
				cCalEspeci := BAU->BAU_CALPGT
				cBauFrom:=  ","+RetSQLName("BAU") + " BAU "
				cBauWhr := " BAU_FILIAL 	  		= '" + xFilial("BAU") + "' "
				cBauWhr += " AND B2J_COD			= BAU_CALPGT "
				cBauWhr += " AND BAU_CODIGO 	= '" + cCodRDA + "'"
				cBauWhr += " AND BAU.D_E_L_E_T_	= ' '  AND "
			Endif	
		Endif
		lBau := .T.
	Endif	
	cSQL:= " SELECT B2J_CODINT, B2K_ANO, B2K_MES, B2K_DIAINI, B2K_DIAFIM, B2K_DIAPGT, B2K_CODRDA "
	if lAtuB2K
		cSql += ", B2K_DIAIN2, B2K_DIAFI2 "
	endif
	cSQL+= " FROM " + RetSQLName("B2J") + " B2J ," + RetSQLName("B2K") + " B2K  "
	cSQL+= Iif(lBau,cBauFrom,"")
	cSQL+= " WHERE "
	cSQL+= Iif(lBau,cBauWhr,"")
	cSQL+= " B2K_FILIAL = '" + xFilial("B2K") + "' "
	cSQL+= " AND B2J_FILIAL = '" + xFilial("B2J") + "' "
	cSQL+= " AND B2J_CODINT = '" + cCodOpe + "' "
	cSQL+= IIF(EmpTy(cCalEspeci), " AND B2J_CALPAD = '1' ", " AND (B2J_COD = '" + cCalEspeci + "' OR B2J_CALPAD = '1') ")
	cSQL+= " AND B2K_STATUS = '1' "
	cSQL+= " AND B2K_COD = B2J_COD "
	CSQL+= " AND B2K_ANO = '" + alltrim(str(Year(dData))) + "' "	
	cSQL+= " AND B2J.D_E_L_E_T_	= ' ' "
	cSQL+= " AND B2K.D_E_L_E_T_	= ' ' "
	cSQL+= " ORDER BY B2K_ANO, B2K_MES, B2K_CODRDA "
	
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbB2K",.F.,.T.)

	cCodPagto := '000'
	
	If TrbB2K->(Eof())
		TrbB2K->(DbCloseArea())
		RestArea(aArea)
		if empty(aRet) .OR. !aRet[1] //Criar condição extra pra quando vem dos que buscam janelas de envio
										// Verificar pra quando for ter a transição pro novo, já que o MV pode mudar
			aadd(aCriticas,{__aCdCri025[1],PLSBCTDESC(),"","","",cCodPad,cCodPro})
			
			// Inclui nivel e caminho da critica.
			PLSCOMPCRI(aCriticas,"B2K")   
			
			If !lRPC .And. lHelp
				Help("",1,"PLSXVLDVAL")
			Endif
			
			aRet := {.F.,aCriticas,ctod(""),"","",cCodPagto,ctod(""), ctod(""), ctod("")}
		endif
	Else
		
		dDataPagto 	:= ctod("")               
		lCalend		:= .F.
		
		TrbB2K->(DbGoTop())
		While TrbB2K->( !Eof() )
		
			//Validação da regra     
			Do Case 
				Case ( alltrim(str(Year(dData))) = TrbB2K->B2K_ANO .And. alltrim(str(Month(dData))) = alltrim(str(val(TrbB2K->B2K_MES))) .And.  TrbB2K->B2K_CODRDA == cCodRDA ) 
						lJanela2 := .F.
						dDataPagto 	:= strZero(val(TrbB2K->B2K_DIAPGT),2)+"/"+strZero(val(TrbB2K->B2K_MES),2)+"/"+TrbB2K->B2K_ANO
						dDataIni 	:= strZero(val(TrbB2K->B2K_DIAINI),2)+"/"+ iif (Empty(TrbB2K->B2K_MES),alltrim(strZero(Month(dData),2)),strZero(val(TrbB2K->B2K_MES),2))   +"/"+ iif( Empty(TrbB2K->B2K_ANO), alltrim(str(Year(dData))),TrbB2K->B2K_ANO)
						dDataFim 	:= strZero(val(TrbB2K->B2K_DIAFIM),2)+"/"+ iif (Empty(TrbB2K->B2K_MES),alltrim(strZero(Month(dData),2)),strZero(val(TrbB2K->B2K_MES),2))   +"/"+ iif( Empty(TrbB2K->B2K_ANO), alltrim(str(Year(dData))),TrbB2K->B2K_ANO)
						lCalend   	:= .T.
						lDtMenor 	:= .F.
						lRegra1		:= .T.
						if lAtuB2K
							lJanela2 := !empty(TrbB2K->B2K_DIAIN2) .AND. !(empty(TrbB2K->B2K_DIAFI2))
							if lJanela2
								dDataIn2 	:= strZero(val(TrbB2K->B2K_DIAIN2),2)+"/"+ iif (Empty(TrbB2K->B2K_MES),alltrim(strZero(Month(dData),2)),strZero(val(TrbB2K->B2K_MES),2))   +"/"+ iif( Empty(TrbB2K->B2K_ANO), alltrim(str(Year(dData))),TrbB2K->B2K_ANO)
								dDataFi2 	:= strZero(val(TrbB2K->B2K_DIAFI2),2)+"/"+ iif (Empty(TrbB2K->B2K_MES),alltrim(strZero(Month(dData),2)),strZero(val(TrbB2K->B2K_MES),2))   +"/"+ iif( Empty(TrbB2K->B2K_ANO), alltrim(str(Year(dData))),TrbB2K->B2K_ANO)
							endif
						endif
						
				Case (alltrim(str(Month(dData))) = alltrim(str(val(TrbB2K->B2K_MES))) .And.  TrbB2K->B2K_CODRDA == cCodRDA .and. Empty(TrbB2K->B2K_ANO) ) .AND. !lRegra1
						lJanela2 := .F.
						dDataPagto 	:= strZero(val(TrbB2K->B2K_DIAPGT),2)+"/"+strZero(val(TrbB2K->B2K_MES),2)+"/"+ iif( Empty(TrbB2K->B2K_ANO), alltrim(str(Year(dData))),TrbB2K->B2K_ANO)  
						dDataIni 	:= strZero(val(TrbB2K->B2K_DIAINI),2)+"/"+ iif (Empty(TrbB2K->B2K_MES),alltrim(strZero(Month(dData),2)),strZero(val(TrbB2K->B2K_MES),2))+"/"+ iif( Empty(TrbB2K->B2K_ANO), alltrim(str(Year(dData))),TrbB2K->B2K_ANO)
						dDataFim 	:= strZero(val(TrbB2K->B2K_DIAFIM),2)+"/"+ iif (Empty(TrbB2K->B2K_MES),alltrim(strZero(Month(dData),2)),strZero(val(TrbB2K->B2K_MES),2))+"/"+ iif( Empty(TrbB2K->B2K_ANO), alltrim(str(Year(dData))),TrbB2K->B2K_ANO)
						lCalend  	:= .T.
						lRegra2	 	:= .T.
						if lAtuB2K
							lJanela2 := !empty(TrbB2K->B2K_DIAIN2) .AND. !(empty(TrbB2K->B2K_DIAFI2))
							if lJanela2
								dDataIn2 	:= strZero(val(TrbB2K->B2K_DIAIN2),2)+"/"+ iif (Empty(TrbB2K->B2K_MES),alltrim(strZero(Month(dData),2)),strZero(val(TrbB2K->B2K_MES),2))   +"/"+ iif( Empty(TrbB2K->B2K_ANO), alltrim(str(Year(dData))),TrbB2K->B2K_ANO)
								dDataFi2 	:= strZero(val(TrbB2K->B2K_DIAFI2),2)+"/"+ iif (Empty(TrbB2K->B2K_MES),alltrim(strZero(Month(dData),2)),strZero(val(TrbB2K->B2K_MES),2))   +"/"+ iif( Empty(TrbB2K->B2K_ANO), alltrim(str(Year(dData))),TrbB2K->B2K_ANO)
							endif
						endif
						
				Case ( alltrim(str(Year(dData))) = TrbB2K->B2K_ANO .And.  TrbB2K->B2K_CODRDA == cCodRDA .and. Empty(TrbB2K->B2K_MES) ) .AND. !lRegra1 .AND. !lRegra2
						lJanela2 := .F.
						dDataPagto 	:= strZero(val(TrbB2K->B2K_DIAPGT),2)+"/"+strZero(val(TrbB2K->B2K_MES),2)+"/"+TrbB2K->B2K_ANO
						dDataIni 	:= strZero(val(TrbB2K->B2K_DIAINI),2)+"/"+ iif (Empty(TrbB2K->B2K_MES),alltrim(strZero(Month(dData),2)),strZero(val(TrbB2K->B2K_MES),2))   +"/"+ iif( Empty(TrbB2K->B2K_ANO), alltrim(str(Year(dData))),TrbB2K->B2K_ANO)
						dDataFim 	:= strZero(val(TrbB2K->B2K_DIAFIM),2)+"/"+ iif (Empty(TrbB2K->B2K_MES),alltrim(strZero(Month(dData),2)),strZero(val(TrbB2K->B2K_MES),2))   +"/"+ iif( Empty(TrbB2K->B2K_ANO), alltrim(str(Year(dData))),TrbB2K->B2K_ANO)
						lCalend  	:= .T.
						lRegra3  	:= .T.
						if lAtuB2K
							lJanela2 := !empty(TrbB2K->B2K_DIAIN2) .AND. !(empty(TrbB2K->B2K_DIAFI2))
							if lJanela2
								dDataIn2 	:= strZero(val(TrbB2K->B2K_DIAIN2),2)+"/"+ iif (Empty(TrbB2K->B2K_MES),alltrim(strZero(Month(dData),2)),strZero(val(TrbB2K->B2K_MES),2))   +"/"+ iif( Empty(TrbB2K->B2K_ANO), alltrim(str(Year(dData))),TrbB2K->B2K_ANO)
								dDataFi2 	:= strZero(val(TrbB2K->B2K_DIAFI2),2)+"/"+ iif (Empty(TrbB2K->B2K_MES),alltrim(strZero(Month(dData),2)),strZero(val(TrbB2K->B2K_MES),2))   +"/"+ iif( Empty(TrbB2K->B2K_ANO), alltrim(str(Year(dData))),TrbB2K->B2K_ANO)
							endif
						endif
						
				Case ( alltrim(str(Year(dData))) = TrbB2K->B2K_ANO .And. alltrim(str(Month(dData))) = alltrim(str(val(TrbB2K->B2K_MES))) ) .AND. empTy(TrbB2K->B2K_CODRDA) .AND. !lRegra1 .AND. !lRegra2 .AND. !lRegra3
						lJanela2 := .F.
						dDataPagto 	:= strZero(val(TrbB2K->B2K_DIAPGT),2)+"/"+strZero(val(TrbB2K->B2K_MES),2)+"/"+TrbB2K->B2K_ANO
						dDataIni 	:= strZero(val(TrbB2K->B2K_DIAINI),2)+"/"+ iif (Empty(TrbB2K->B2K_MES),alltrim(strZero(Month(dData),2)),strZero(val(TrbB2K->B2K_MES),2))   +"/"+ iif( Empty(TrbB2K->B2K_ANO), alltrim(str(Year(dData))),TrbB2K->B2K_ANO)
						dDataFim 	:= strZero(val(TrbB2K->B2K_DIAFIM),2)+"/"+ iif (Empty(TrbB2K->B2K_MES),alltrim(strZero(Month(dData),2)),strZero(val(TrbB2K->B2K_MES),2))   +"/"+ iif( Empty(TrbB2K->B2K_ANO), alltrim(str(Year(dData))),TrbB2K->B2K_ANO)
						lCalend  	:= .T.
						lRegra4	 	:= .T.
						if lAtuB2K
							lJanela2 := !empty(TrbB2K->B2K_DIAIN2) .AND. !(empty(TrbB2K->B2K_DIAFI2))
							if lJanela2
								dDataIn2 	:= strZero(val(TrbB2K->B2K_DIAIN2),2)+"/"+ iif (Empty(TrbB2K->B2K_MES),alltrim(strZero(Month(dData),2)),strZero(val(TrbB2K->B2K_MES),2))   +"/"+ iif( Empty(TrbB2K->B2K_ANO), alltrim(str(Year(dData))),TrbB2K->B2K_ANO)
								dDataFi2 	:= strZero(val(TrbB2K->B2K_DIAFI2),2)+"/"+ iif (Empty(TrbB2K->B2K_MES),alltrim(strZero(Month(dData),2)),strZero(val(TrbB2K->B2K_MES),2))   +"/"+ iif( Empty(TrbB2K->B2K_ANO), alltrim(str(Year(dData))),TrbB2K->B2K_ANO)
							endif
						endif
							
				Case  alltrim(str(Month(dData))) = alltrim(str(val(TrbB2K->B2K_MES))) .and. Empty(TrbB2K->B2K_ANO) .AND. empTy(TrbB2K->B2K_CODRDA) .AND.  !lRegra1 .AND. !lRegra2 .AND. !lRegra3 .AND. !lRegra4
						lJanela2 := .F.
						dDataPagto 	:= strZero(val(TrbB2K->B2K_DIAPGT),2)+"/"+strZero(val(TrbB2K->B2K_MES),2)+"/"+ iif( Empty(TrbB2K->B2K_ANO), alltrim(str(Year(dData))),TrbB2K->B2K_ANO)
						dDataIni 	:= strZero(val(TrbB2K->B2K_DIAINI),2)+"/"+ iif (Empty(TrbB2K->B2K_MES),alltrim(strZero(Month(dData),2)),strZero(val(TrbB2K->B2K_MES),2))   +"/"+ iif( Empty(TrbB2K->B2K_ANO), alltrim(str(Year(dData))),TrbB2K->B2K_ANO)
						dDataFim 	:= strZero(val(TrbB2K->B2K_DIAFIM),2)+"/"+ iif (Empty(TrbB2K->B2K_MES),alltrim(strZero(Month(dData),2)),strZero(val(TrbB2K->B2K_MES),2))   +"/"+ iif( Empty(TrbB2K->B2K_ANO), alltrim(str(Year(dData))),TrbB2K->B2K_ANO)
						lCalend    	:= .T.
						lRegra5		:= .T.
						if lAtuB2K
							lJanela2 := !empty(TrbB2K->B2K_DIAIN2) .AND. !(empty(TrbB2K->B2K_DIAFI2))
							if lJanela2
								dDataIn2 	:= strZero(val(TrbB2K->B2K_DIAIN2),2)+"/"+ iif (Empty(TrbB2K->B2K_MES),alltrim(strZero(Month(dData),2)),strZero(val(TrbB2K->B2K_MES),2))   +"/"+ iif( Empty(TrbB2K->B2K_ANO), alltrim(str(Year(dData))),TrbB2K->B2K_ANO)
								dDataFi2 	:= strZero(val(TrbB2K->B2K_DIAFI2),2)+"/"+ iif (Empty(TrbB2K->B2K_MES),alltrim(strZero(Month(dData),2)),strZero(val(TrbB2K->B2K_MES),2))   +"/"+ iif( Empty(TrbB2K->B2K_ANO), alltrim(str(Year(dData))),TrbB2K->B2K_ANO)
							endif
						endif
			
				Case ( alltrim(str(Year(dData))) = TrbB2K->B2K_ANO  )  .and.  Empty(TrbB2K->B2K_MES) .AND. empTy(TrbB2K->B2K_CODRDA) .AND. !lRegra1 .AND. !lRegra2 .AND. !lRegra3 .AND. !lRegra4 .AND. !lRegra5
						lJanela2 := .F.
						dDataPagto 	:= strZero(val(TrbB2K->B2K_DIAPGT),2)+"/"+alltrim(strZero(Month(dData),2))+"/"+ iif( Empty(TrbB2K->B2K_ANO), alltrim(str(Year(dData))),TrbB2K->B2K_ANO)
						dDataIni 	:= strZero(val(TrbB2K->B2K_DIAINI),2)+"/"+ iif (Empty(TrbB2K->B2K_MES),alltrim(strZero(Month(dData),2)),strZero(val(TrbB2K->B2K_MES),2))   +"/"+ iif( Empty(TrbB2K->B2K_ANO), alltrim(str(Year(dData))),TrbB2K->B2K_ANO)
						dDataFim 	:= strZero(val(TrbB2K->B2K_DIAFIM),2)+"/"+ iif (Empty(TrbB2K->B2K_MES),alltrim(strZero(Month(dData),2)),strZero(val(TrbB2K->B2K_MES),2))   +"/"+ iif( Empty(TrbB2K->B2K_ANO), alltrim(str(Year(dData))),TrbB2K->B2K_ANO)
						lCalend  	:= .T.
						if lAtuB2K
							lJanela2 := !empty(TrbB2K->B2K_DIAIN2) .AND. !(empty(TrbB2K->B2K_DIAFI2))
							if lJanela2
								dDataIn2 	:= strZero(val(TrbB2K->B2K_DIAIN2),2)+"/"+ iif (Empty(TrbB2K->B2K_MES),alltrim(strZero(Month(dData),2)),strZero(val(TrbB2K->B2K_MES),2))   +"/"+ iif( Empty(TrbB2K->B2K_ANO), alltrim(str(Year(dData))),TrbB2K->B2K_ANO)
								dDataFi2 	:= strZero(val(TrbB2K->B2K_DIAFI2),2)+"/"+ iif (Empty(TrbB2K->B2K_MES),alltrim(strZero(Month(dData),2)),strZero(val(TrbB2K->B2K_MES),2))   +"/"+ iif( Empty(TrbB2K->B2K_ANO), alltrim(str(Year(dData))),TrbB2K->B2K_ANO)
							endif
						endif
					
			Endcase
				
			TrbB2K->( DbSkip() )
			
		EndDo
	
		If !lCalend
			TrbB2K->(DbCloseArea())
			RestArea(aArea)           
			if empty(aRet) .OR. !aRet[1] //Criar condição extra pra quando vem dos que buscam janelas de envio
									// Verificar pra quando for ter a transição pro novo, já que o MV pode mudar
		
				aadd(aCriticas,{__aCdCri025[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro}) 
	
				// Alias e caminho da critica.
				PLSCOMPCRI(aCriticas,"B2K")   
				
				If !lRPC .And. lHelp
					Help("",1,"PLSXVLDVAL")//Não existe calendário de pagamento em aberto para a data do evento.       
				EndIf
				
				aRet := {.F.,aCriticas,ctod(""),"","",cCodPagto,ctod(""), CtoD(""), CtoD("")}
			endif
		
		Else
		
			BFM->(DbSetOrder(1))//Parametros Mensais 
			cAnoCal := iif(empty(TrbB2K->B2K_ANO), alltrim(str(Year(dData))),TrbB2K->B2K_ANO)
			cMesCal := iif(empty(TrbB2K->B2K_MES), alltrim(strZero(Month(dData),2)), strZero(val(TrbB2K->B2K_MES),2))          
			If BFM->(MsSeek( xFilial("BFM")+cCodOpe+cAnoCal+cMesCal)) .And. BFM->BFM_VALRDA > 0 .And. BFM->BFM_VALCOP > 0
				//Aqui o anoCal e mseCal vão ser sobrescritos pelo do BDT, caso tenha sido encontrado lá
				//em teoria não faz diferença alguma pras chamadas que buscam as janelas, mas fica à prova do futuro com isso
				aRet := {.T.,{},IIF( !(empty(dDatPreBDt)), dDatPreBDt,CtoD(dDataPagto)),iif( empty(cAnoBDT), cAnoCal, cAnoBDT), iif(empty(cMesBDt), cMesCal, cMesBDt),cCodPagto, IIF( !(empty(dDatPreBDt)), dDatPreBDt,CtoD(dDataPagto)),dDataIni,dDatafIM,lJanela2,dDataIn2,dDataFi2}
				TrbB2K->(DbCloseArea())
				RestArea(aArea)
			//Else
			elseif empty(aRet) .OR. !aRet[1] 
											
				aadd(aCriticas,{__aCdCri025[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro}) 
				
				// Alias e caminho da critica.
				PLSCOMPCRI(aCriticas,"B2K")   
		
				If !lRPC .And. lHelp 
					Aviso( STR0016, ; //"U.S Mensais"
							STR0017,; //"Nao existem U.S Mensais cadastrada para o Ano/Mes do calendario de pagamento atual"
							{ "Ok" }, 2 ) 	                                                                    
				Endif
				aRet := {.F.,aCriticas,ctod(""),"","",cCodPagto,ctod(""), CtoD(""), CtoD("")}
				TrbB2K->(DbCloseArea())
				RestArea(aArea)
			Endif
		Endif   
	Endif   

Endif

TRBBDT->(dbCloseArea())

Return(aRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSVALCOPA ³ Autor ³ Tulio Cesar       ³ Data ³ 17.07.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o valor de uma co-participaca de um evento         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVALCOPA()
LOCAL nVlrPF
LOCAL nVlrBPF
LOCAL nVlrTPF
LOCAL nVlrTAD
LOCAL nTotSE1 := 0      
LOCAL cPagRDA := ""

If BD5->BD5_GUIACO <> "1"
   nVlrPF  := BD5->BD5_VLRPF
   nVlrBPF := BD5->BD5_VLRBPF
   nVlrTPF := BD5->BD5_VLRTPF
   nVlrTAD := BD5->BD5_VLRTAD
   cPagRDA := BD6->(Posicione("BD6",1,xFilial("BD6")+BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV),"BD6_PAGRDA"))
Else
   If cPaisLoc == "BRA"
      nVlrPF  := BD5->BD5_VALOR
      nVlrBPF := BD5->BD5_VALOR
      nVlrTPF := BD5->BD5_VALOR
      nVlrTAD := 0
      cPagRDA := "0"
   Else
      SE1->(DbSetOrder(1))
      If SE1->(DbSeek(xFilial("SE1")+BEA->(BEA_PREFIX+BEA_NUMTIT+BEA_PARCEL+BEA_TIPTIT)))
         nTotSE1 := SE1->E1_VALOR
      Endif   
      	
      nVlrPF  := nTotSE1
      nVlrBPF := nTotSE1
      nVlrTPF := nTotSE1
      nVlrTAD := 0  
      cPagRDA := "0"
   Endif   
Endif   

Return({nVlrPF,nVlrBPF,(nVlrPF*100/nVlrBPF),nVlrTPF,nVlrTAD,cPagRDA})
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSMOVMC   ³ Autor ³ Tulio Cesar       ³ Data ³ 21.10.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pega uma agenda medica e lanca como movimentacao           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Retorno:

[1] .T. ou .F.    -> Processamento ok ou nao
[2] Se for .T.

			    Numero da guia gerada 16 digitos
			    
	Se For .F.
	
			    "1" - Agenda medica ja virou uma guia em situacao anterior
			    "2" - Procedimento invalido
			    "3" - Usuario invalido
			    "4" - RDA invalida
			    "5" - Calendario de pagamento incompativel...
/*/                                                     
Function PLSMOVMC(nRegBBD,cTipo,cCodPad,cCodPro,lAutori,cCodLoc,cCodEsp)
LOCAL nH
LOCAL aHeader := {}
LOCAL aCols   := {}      
LOCAL aVetTrab:= {}                       
LOCAL aRet    := {.F.,""}
LOCAL aRetGrv := {}
LOCAL aDadBEA := {}
LOCAL lRdaOK  := .F.
LOCAL nI
LOCAL cRet
LOCAL aAlias
LOCAL cChave
LOCAL cChaveAux	                                   
// Variavel define se a guia da marcacao de consultas sera gerada bloqueada ou nao.
LOCAL lBlqMov := (GetNewPar("MV_PLSBGMC","1")=='1')
LOCAL lConsulta 
LOCAL cRecBD5 := ""
LOCAL cRecBEA := ""
PRIVATE aDadUsr := {}     
PRIVATE aDadRda := {}
PRIVATE aRetAux := {}
DEFAULT cCodPad := Subs(AllTrim(GetMv("MV_PLSCDCO")),1,2)
DEFAULT cCodPro := Subs(AllTrim(GetMv("MV_PLSCDCO")),3,16)           
DEFAULT cCodLoc := ""
DEFAULT cCodEsp := ""   

lConsulta := PLSISCON(cCodPad,cCodPro)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada para troca do codigo e tabela do procedimento       	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
If Existblock("PLCODCONS")
   aRetPto := Execblock("PLCODCONS",.F.,.F.,{nRegBBD,cCodPad,cCodPro,cCodLoc,cCodEsp})    
   If ValType(aRetPto) == "A"
      cCodPad := aRetPto[1]
      cCodPro := aRetPto[2]  
   EndIf   
EndIf

		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Produto																	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCodPro := cCodPro+Space(16-Len(cCodPro))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no codigo do procedimento...                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BR8->(DbSetOrder(1))
If ! BR8->(MsSeek(xFilial("BR8")+cCodPad+cCodPro))
   aRet := {.F.,"2"}
   Return(aRet)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ nRegBBD -> Numero do registro no BBD, faco o posicionamento agora...     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BBD->( DbGoTo(nRegBBD) ) 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta dados do usuario...                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aDadUsr := PLSDADUSR(BBD->BBD_CODPAC,"1",.F.,BBD->BBD_DATA,cCodPad,cCodPro)                 

If ! aDadUsr[1]
   aRet := {.F.,"3"}
   Return(aRet)
Endif   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta dados da rda...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aDadRDA := PLSDADRDA(BBD->BBD_CODINT,BBD->BBD_CODIGO,"1",BBD->BBD_DATA,Subs(cCodLoc,1,3),cCodEsp)
   
lRDAOK := aDadRda[1]
   
If ! lRDAOK          
   PLSMOVCRI("3",{},aDadRDA[2])
   aRet := {.F.,"0"}
   Return(aRet)
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta calendario de pagamento...                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRetAux := PLSXVLDCAL(dDataBase,BBD->BBD_CODINT,.T.,"","")
   
If ! aRetAux[1]
   aRet := {.F.,"5"}
   Return(aRet)   
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o aHeader com os dados do item da consulta....                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SX3->(DbSetOrder(2))
SX3->(MsSeek("BE2_CODPAD"))
aadd(aHeader,{trim(X3TITULO()),SX3->X3_CAMPO,;
              SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,;
              SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT})

SX3->(MsSeek("BE2_CODPRO"))
aadd(aHeader,{trim(X3TITULO()),SX3->X3_CAMPO,;
              SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,;
              SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT})

SX3->(MsSeek("BE2_DESPRO"))
aadd(aHeader,{trim(X3TITULO()),SX3->X3_CAMPO,;
              SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,;
              SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT})

SX3->(MsSeek("BE2_QTDPRO"))
aadd(aHeader,{trim(X3TITULO()),SX3->X3_CAMPO,;
              SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,;
              SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT})

SX3->(MsSeek("BE2_SEQUEN"))
aadd(aHeader,{trim(X3TITULO()),SX3->X3_CAMPO,;
              SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,;
              SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT})

SX3->(MsSeek("BE2_STATUS"))
aadd(aHeader,{trim(X3TITULO()),SX3->X3_CAMPO,;
              SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,;
              SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT})

SX3->(MsSeek("BE2_NIVAUT"))
aadd(aHeader,{trim(X3TITULO()),SX3->X3_CAMPO,;
              SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,;
              SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT})

SX3->(MsSeek("BE2_CHVNIV"))
aadd(aHeader,{trim(X3TITULO()),SX3->X3_CAMPO,;
              SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,;
              SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT})

aRetNiv := PLSAUTPDIR(BBD->BBD_CODINT,BBD->BBD_CODPAC,cCodPad,cCodPro,aDadUsr,BBD->BBD_DATA,,,aDadRDA,.F.,,;
			1)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o aCols baseado no aHeader...                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aCols,{cCodPad,cCodPro,BR8->BR8_DESCRI,1,"001","1",aRetNiv[3],aRetNiv[4],.F.})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava demais campos...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipo == "1" 
	aadd(aVetTrab,0)

    aadd(aDadBEA,{"BEA_ORIMOV","1"})
    aadd(aDadBEA,{"BEA_OPEMOV",BBD->BBD_CODINT})
    aadd(aDadBEA,{"BEA_TIPO",If(lConsulta,"1",'2')})
    aadd(aDadBEA,{"BEA_CODLOC",BB8->BB8_CODLOC})
    aadd(aDadBEA,{"BEA_USUOPE",PLSRtCdUsr()})
    aadd(aDadBEA,{"BEA_DESOPE",PLRETOPE()})
    aadd(aDadBEA,{"BEA_LOCAL",BB8->BB8_LOCAL})
    aadd(aDadBEA,{"BEA_DESLOC",BB8->BB8_DESLOC})
    aadd(aDadBEA,{"BEA_ENDLOC",BB8->BB8_END})
    aadd(aDadBEA,{"BEA_CODESP",BBD->BBD_CODESP})
    aadd(aDadBEA,{"BEA_DESESP",BAQ->(Posicione("BAQ",1,xFilial("BAQ")+BBD->(BBD_CODINT+BBD_CODESP),"BAQ_DESCRI"))})
      
    aadd(aDadBEA,{"BEA_DATPRO",BBD->BBD_DATA})
    aadd(aDadBEA,{"BEA_CODRDA",BBD->BBD_CODIGO})
    aadd(aDadBEA,{"BEA_OPERDA",BBD->BBD_CODINT})                        
    aadd(aDadBEA,{"BEA_NOMRDA",aDadRDA[6]})                        
    aadd(aDadBEA,{"BEA_MATANT",aDadUsr[3]})                        
    aadd(aDadBEA,{"BEA_NOMUSR",aDadUsr[6]})                        
    aadd(aDadBEA,{"BEA_TIPCON","1"})                        
    aadd(aDadBEA,{"BEA_TIPSAI","3"})                        
    aadd(aDadBEA,{"BE1_TIPPAC",getNewPar("MV_PLSTPAA","9")})                        
    
    aadd(aDadBEA,{"BEA_OPEUSR",Subs(BBD->BBD_CODPAC,atCodOpe[1],atCodOpe[2])})
    aadd(aDadBEA,{"BEA_CODEMP",Subs(BBD->BBD_CODPAC,atCodEmp[1],atCodEmp[2])})
    aadd(aDadBEA,{"BEA_MATRIC",Subs(BBD->BBD_CODPAC,atMatric[1],atMatric[2])})
    aadd(aDadBEA,{"BEA_TIPREG",Subs(BBD->BBD_CODPAC,atTipReg[1],atTipReg[2])})
    aadd(aDadBEA,{"BEA_DIGITO",Subs(BBD->BBD_CODPAC,atDigito[1],atDigito[2])})
      
    aadd(aDadBEA,{"BEA_CONEMP",if(len(aDadUsr)>=9,aDadUsr[9],"")})
    aadd(aDadBEA,{"BEA_VERCON",if(len(aDadUsr)>=39,aDadUsr[39],"")})
    aadd(aDadBEA,{"BEA_SUBCON",if(len(aDadUsr)>=41,aDadUsr[41],"")})
    aadd(aDadBEA,{"BEA_VERSUB",if(len(aDadUsr)>=42,aDadUsr[42],"")})
    
	aadd(aDadBEA,{"BEA_HORPRO",StrTran(BBD->BBD_HORA,":","") })
    aadd(aDadBEA,{"BEA_HHDIGI",StrTran(Time(),":","")})
    aadd(aDadBEA,{"BEA_OPEINT",""})
    aadd(aDadBEA,{"BEA_NOMTIT",aDadUsr[6]})
    aadd(aDadBEA,{"BEA_ATEAMB","1"})
    aadd(aDadBEA,{"BEA_ANOPAG",aRetAux[4]})
    aadd(aDadBEA,{"BEA_MESPAG",aRetAux[5]})
	If BEA->(FieldPos("BEA_NUMATE")) > 0
	   aadd(aDadBEA, {"BEA_NUMATE",BBD->BBD_NUMATE} )
	EndIf              
	If BEA->(FieldPos("BEA_TIPPRE")) > 0
	   	AaDd(aDadBEA,{"BEA_TIPPRE",Iif(len(aDadRDA) >= 27, aDadRDA[27],'')})
	Endif
    If  existblock("PLMVMBEA")
		aDadBEA := execblock("PLMVMBEA",.F.,.F.,{aDadBEA})
	EndIf	
EndIf	

//cTipo "1" - Inclusao  "0" - Estorno                                      
If cTipo == "1"    
   aRetGrv := PLSA090Grv(aCols,aHeader,aDadBEA,K_Incluir,aVetTrab,{},BBD->BBD_CODPAC,BBD->BBD_DATA,BBD->BBD_HORA,;
   		   			 	 "1",aRetAux[4],aRetAux[5],If(!lConsulta,GetNewPar("MV_PLSTPGS","02"),GetNewPar("MV_PLSTPGC","01")),;
   		   			 	 .F.,nil,nil,nil,.T.,nil,nil,nil,nil,nil,lBlqMov)
Else 

   If !PLSA090MDa(BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT),"1",aHeader,aVetTrab,aCols)
		MsgAlert(STR0187+':'+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)) //'Nao e possivel excluir a movimentacao para a chave BEA'      
      	aRet := {.F.,"0"}
      	Return(aRet)   
   EndIf
   
   PLSA090Grv(aCols,aHeader,{},K_Excluir,aVetTrab,{},"",ctod(""),"","","","",If(!lConsulta,GetNewPar("MV_PLSTPGS","02"),GetNewPar("MV_PLSTPGC","01")),.F.,nil,nil,nil,.T.,BEA->BEA_ORIGEM,BEA->BEA_CODLDP)
   
Endif

//Verifica o processo de gravacao											 
If cTipo == "1"    
	If aRetGrv[1]               
	   BEA->( DbSetOrder(1) )//BEA_FILIAL + BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT + DTOS(BEA_DATPRO) + BEA_HORPRO
	   If !BEA->( MsSeek(xFilial("BEA")+aRetGrv[2]+aRetGrv[3]+aRetGrv[4]+aRetGrv[5]) )
	      MsgAlert( STR0188+':'+aRetGrv[2]+aRetGrv[3]+aRetGrv[4]+aRetGrv[5] )  //'Base inconsistente, favor verificar a chave (BEA)'
	      aRet := {.F.,"0"}
	      Return(aRet)   
	   Else 
		  BD5->( DbSetOrder(1) ) //BD5_FILIAL + BD5_CODOPE + BD5_CODLDP + BD5_CODPEG + BD5_NUMERO + BD5_SITUAC + BD5_FASE + dtos(BD5_DATPRO) + BD5_OPERDA + BD5_CODRDA
		  If !BD5->( MsSeek(xFilial("BD5")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI) ) )
	 	      MsgAlert( STR0189+':'+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI) )//'Base inconsistente, favor verificar a chave (BD5)'
	    	  aRet := {.F.,"0"}
		      Return(aRet)   
		  EndIf    
	   EndIf
	Else
	   aRet := {.F.,"6"}
	   Return(aRet)   
	EndIf
	cRet := BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO)	
EndIf	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz a exclusao ou gravacao da guia de consulta							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cRet := BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO)
cRecBD5 := BD5->(Recno())
cRecBEA := BEA->(Recno())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tipo																	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipo == "0"    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se for para deletar verifica se tem algum encaminhamento e exclui a guia tb³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(BBD->BBD_NUMATE)
		SIX->(DbSetOrder(1))
		If BEA->(FieldPos("BEA_NUMATE")) > 0 .And. SIX->( MsSeek("BEA13") )
		   BEA->( DbSetOrder(13) )	
		   If BEA->( MsSeek(xFilial("BEA")+BBD->BBD_NUMATE) )
		      aAlias := {"BD5","BD6","BD7","BDX","BDU","BE2","BEG"}
		      While !BEA->( Eof() ) .And. BEA->BEA_NUMATE == BBD->BBD_NUMATE 
		          For nI := 1 To Len(aAlias)
		    	      Do Case 
		                 Case aAlias[nI] $ "BD5,BD6,BD7,BDU"
				              cChave := BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI)   
					     Case aAlias[nI] $ "BE2,BEG,BVX"    
				              cChave := BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)   
				      EndCase            
				                                 
				      cChaveAux := cChave
				      
		              &( aAlias[nI]+'->( DbSetOrder(1) )' )
		              If &(aAlias[nI]+'->( MsSeek( xFilial("'+aAlias[nI]+'")+"'+cChave+'") )' )
						  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						  //³ Faz a Exclusao															 ³
						  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				          While !&(aAlias[nI]+'->( Eof() )') .And. cChave == cChaveAux 
							 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							 //³ Excluindo																	³
							 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							 &( aAlias[nI]+'->( RecLock("'+aAlias[nI]+'",.F.) )' )
							    &( aAlias[nI]+'->( DbDelete() )' )
							 &( aAlias[nI]+'->( MsUnLock() )' )   
							 
							 &( aAlias[nI]+'->( DbSkip() )' )          
							 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							 //³ Monta chave de tabelas da matriz										    ³
							 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			       	         Do Case 
				                Case aAlias[nI] $ "BD5,BD6,BD7,BDX,BDU"
							        //XXX_FILIAL + XXX_CODOPE + XXX_CODLDP + XXX_CODPEG + XXX_NUMERO 
							        cChaveAux := &( aAlias[nI]+'->('+aAlias[nI]+'_CODOPE+'+aAlias[nI]+'_CODLDP+'+aAlias[nI]+'_CODPEG+'+aAlias[nI]+'_NUMERO)' ) 
							    Case aAlias[nI] $ "BE2,BEG"   
						            //XXX_FILIAL + XXX_OPEMOV + XXX_ANOAUT + XXX_MESAUT + XXX_NUMAUT
							        cChaveAux :=&(aAlias[nI]+'->('+aAlias[nI]+'_OPEMOV+'+aAlias[nI]+'_ANOAUT+'+aAlias[nI]+'_MESAUT+'+aAlias[nI]+'_NUMAUT)' ) 
						     EndCase 
						  EndDo	 
		              EndIf
		          Next
				  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				  //³ Excluir																	 ³
				  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				  BEA->( RecLock("BEA",.F.) )
				      BEA->( DbDelete() )
				  BEA->( MsUnLock() )
		          BEA->( DbSkip() )
		      EndDo
		   EndIf
		Else
		   MsgAlert(STR0018) //"Favor verificar a base, campos BEA_NUMATE,BE1_NUMMOV e INDICE 13!"
		EndIf                      
	EndIf
EndIf 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ aRet																	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cRecBD5) .And. !Empty(cRecBEA)
	aRet := { .T. , cRet,cRecBD5,cRecBEA }
Else
	aRet := { .T. , cRet }
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(aRet)
    
/*/{Protheus.doc} PLSSTAGUI
Status da guia
novo conceito, a situacao da guia pode estar bloqueada e a autorizaca
@author PLSTEAM
@since 01/06/2016
@version P12
/*/ 
Function PLSSTAGUI(cOpeMov,cAnoAut,cMesAut,cNumAut,cSituac,lAtuOri,cOrigem,lAtuSta,cCid,lAtuCid,cCodExec,lAtuExec,;
				   cSitGui,lAtuSen,cSenhaOpe,nNrSeqTR,cStatus,cAliCab,cAliPro,cAliCri,lAtuBlo,lBtnOn,lLibAud)
				   
LOCAL nOrdBD5 		:= BD5->(IndexOrd())
LOCAL nRecBD5 		:= BD5->(Recno())
LOCAL nOrdBE4 		:= BE4->(IndexOrd())
LOCAL nRecBE4 		:= BE4->(Recno())
LOCAL aComEve			:= {}
LOCAL lBloqUnd		:= .F.
LOCAL lRetAud       := .F.
DEFAULT lAtuOri		:= .F.
DEFAULT lAtuSta		:= .T.
DEFAULT lAtuCid		:= .F.
DEFAULT cCodExec	:= ""
DEFAULT lAtuExec	:= .F.
DEFAULT cSitGui		:= cSituac
DEFAULT cStatus		:= cSituac
DEFAULT lAtuSen		:= .F.
DEFAULT cSenhaOpe	:= ''                              
DEFAULT nNrSeqTR	:= ''
DEFAULT cAliCab     := "BEA"
DEFAULT cAliPro     := "BE2"
DEFAULT cAliCri     := "BEG"
DEFAULT lAtuBlo		:= .F.
DEFAULT lBtnOn		:= .F.
DEFAULT lLibAud     := .F.

If lAtuExec
   BB0->(DbSetOrder(1))
   If ! BB0->(MsSeek(xFilial("BB0")+cCodExec))
      
      FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0019 , 0, 0, {})//"Executante nao encontrado funcao PLSSTAGUI"
      
      lAtuExec := .F.
   Endif             
Endif   

If cOpeMov+cAnoAut+cMesAut+cNumAut <> &(cAliCab+"->"+cAliCab+"_OPEMOV")+&(cAliCab+"->"+cAliCab+"_ANOAUT")+&(cAliCab+"->"+cAliCab+"_MESAUT")+&(cAliCab+"->"+cAliCab+"_NUMAUT")
	
	   DbSelectArea(cAliCab)
	&(cAliCab+"->(DbSetOrder(1))")//BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)   
	
	   If ! MsSeek(xFilial(cAliCab)+cOpeMov+cAnoAut+cMesAut+cNumAut)
	      Return(.F.)
	   Endif   
	   
Endif   

If &(cAliCab+"->(Eof())")
   Return(.F.)
Endif   

&(cAliCab+"->(RecLock('"+cAliCab+"',.F.))")

	If lAtuSta
	   &(cAliCab+"->"+cAliCab+"_STATUS") := cStatus
	EndIf   
	
	If lAtuOri 
	
	   &(cAliCab+"->"+cAliCab+"_ORIGEM") := cOrigem
	
	   If cOrigem == '1'
	   		&(cAliCab+"->"+cAliCab+"_LIBERA") :=  '0'
	   Endif
	
	Endif                 
	
	If lAtuCid
	   &(cAliCab+"->"+cAliCab+"_CID") := cCid
	Endif
	
	If lAtuExec
	   &(cAliCab+"->"+cAliCab+"_CDPFRE") := BB0->BB0_CODIGO
	   &(cAliCab+"->"+cAliCab+"_REGEXE") := BB0->BB0_NUMCR
	   &(cAliCab+"->"+cAliCab+"_SIGEXE") := BB0->BB0_CODSIG
	   &(cAliCab+"->"+cAliCab+"_ESTEXE") := BB0->BB0_ESTADO
	   &(cAliCab+"->"+cAliCab+"_NOMEXE") := BB0->BB0_NOME
	Endif
	
	If lAtuSen
	
	   &(cAliCab+"->"+cAliCab+"_NRAOPE") :=  cSenhaOpe                      
	   
	   If Type(cAliCab+"->"+cAliCab+"_NRTROL") == "C" 
	      &(cAliCab+"->"+cAliCab+"_NRTROL") := nNrSeqTR  
	   EndIf	   
	
	EndIf

&(cAliCab+"->( MsUnlock() )")


If !GetNewPar("MV_PLIBAUD",.F.)
    lRetAud := .T.
else   
    lRetAud:= PLIBAUD(cOpeMov+cAnoAut+cMesAut+cNumAut)
EndIF

 
If lAtuSta .And. !lBtnOn .And. (!lRetAud .Or. lLibAud)
   PLSATUCS(If( cStatus $ "1,2,3,4,5" ,IIF(lLibAud .Or. lRetAud,"1","2"),"2"),cAliCab ) 
EndIf

If lAtuSen

   If &( cAliPro+"->( FieldPos('"+cAliPro+"_NRAOPE"+"') )" ) > 0                                                    

       DbSelectArea(cAliPro)

	   &(cAliPro+"->(DbSetOrder(1))")    //BE2_FILIAL + BE2_OPEMOV + BE2_ANOAUT + BE2_MESAUT + BE2_NUMAUT + BE2_SEQUEN
	   MsSeek( xFilial(cAliPro)+&(cAliCab+"->("+cAliCab+"_OPEMOV+"+cAliCab+"_ANOAUT+"+cAliCab+"_MESAUT+"+cAliCab+"_NUMAUT)"))                    

	   While !&(cAliPro+"->( Eof() )") .And. &(cAliCab+"->("+cAliCab+"_OPEMOV+"+cAliCab+"_ANOAUT+"+cAliCab+"_MESAUT+"+cAliCab+"_NUMAUT)") == ;
	   										  &(cAliPro+"->("+cAliPro+"_OPEMOV+"+cAliPro+"_ANOAUT+"+cAliPro+"_MESAUT+"+cAliPro+"_NUMAUT)")
	   											
	       &(cAliPro+"->(RecLock('"+cAliPro+"',.F.))")
		   &(cAliPro+"->"+cAliPro+"_NRAOPE") := cSenhaOpe
		   &(cAliPro+"->"+cAliPro+"_STATUS") := "1"
	       &(cAliPro+"->( MsUnlock() )")
	   	   &(cAliPro+"->( DbSkip() )")
	   EndDo
       
       DbSelectArea(cAliCri)
	   &(cAliCri+"->(DbSetOrder(1))")    //BEG_FILIAL + BEG_OPEMOV + BEG_ANOAUT + BEG_MESAUT + BEG_NUMAUT + BEG_SEQUEN 
	   MsSeek( xFilial(cAliCri)+&(cAliCab+"->("+cAliCab+"_OPEMOV+"+cAliCab+"_ANOAUT+"+cAliCab+"_MESAUT+"+cAliCab+"_NUMAUT)")) 
	   While !&(cAliCri+"->( Eof() )") .And. &(cAliCri+"->("+cAliCri+"_OPEMOV+"+cAliCri+"_ANOAUT+"+cAliCri+"_MESAUT+"+cAliCri+"_NUMAUT)") == ;
	   										  &(cAliCab+"->("+cAliCab+"_OPEMOV+"+cAliCab+"_ANOAUT+"+cAliCab+"_MESAUT+"+cAliCab+"_NUMAUT)")
           
           &(cAliCri+"->(RecLock('"+cAliCri+"',.F.))")
	       &(cAliCri+"->( DbDelete() )")
           &(cAliCri+"->( MsUnlock() )")
           &(cAliCri+"->( DbSkip() )")
	   EndDo
	   
   EndIf	   
      
EndIf

If lAtuOri .And. cOrigem == '1'
	DbSelectArea(cAliPro)
	&(cAliPro+"->(DbSetOrder(1))") //BE2_FILIAL + BE2_OPEMOV + BE2_ANOAUT + BE2_MESAUT + BE2_NUMAUT + BE2_SEQUEN
	MsSeek( xFilial(cAliPro)+&(cAliCab+"->("+cAliCab+"_OPEMOV+"+cAliCab+"_ANOAUT+"+cAliCab+"_MESAUT+"+cAliCab+"_NUMAUT)"))                    
		   
	While !&(cAliPro+"->( Eof() )") .And.  &(cAliCab+"->("+cAliCab+"_OPEMOV+"+cAliCab+"_ANOAUT+"+cAliCab+"_MESAUT+"+cAliCab+"_NUMAUT)") == ;
											&(cAliPro+"->("+cAliPro+"_OPEMOV+"+cAliPro+"_ANOAUT+"+cAliPro+"_MESAUT+"+cAliPro+"_NUMAUT)") 
	       &(cAliPro+"->(RecLock('"+cAliPro+"',.F.))")
	       		&(cAliPro+"->"+cAliPro+"_LIBERA") := '0'
	       &(cAliPro+"->( MsUnlock() )")
	   	   &(cAliPro+"->( DbSkip() )")
	EndDo
Endif

If &( cAliCab+"->( FieldPos('"+cAliCab+"_TIPGUI"+"') )" ) > 0                                                    
      
	If &(cAliCab+"->"+cAliCab+"_TIPGUI") $ "01,02,04,13"
	   
	   BD5->(DbSetOrder(1))
	   If BD5->(MsSeek(xFilial("BD5")+&(cAliCab+"->("+cAliCab+"_OPEMOV+"+cAliCab+"_CODLDP+"+cAliCab+"_CODPEG+"+cAliCab+"_NUMGUI)")))
	   
	      BD5->(RecLock("BD5",.F.))
	      if cSitGui != cSituac
	      	 BD5->BD5_SITUAC := cSitGui
	      elseIf lAtuSta
	         BD5->BD5_SITUAC := cSituac
	      Endif   
	      
	      If lAtuCid
	         BD5->BD5_CID := cCid
	      Endif
	      
	      If lAtuExec
	         BD5->BD5_CDPFRE := BB0->BB0_CODIGO
	         BD5->BD5_REGEXE := BB0->BB0_NUMCR
	         BD5->BD5_SIGEXE := BB0->BB0_CODSIG
	         BD5->BD5_ESTEXE := BB0->BB0_ESTADO
	      Endif
	      
		  If lAtuSen
		     BD5->BD5_NRAOPE :=  cSenhaOpe                      
	      EndIf
	      
	      If lAtuOri .And. cOrigem == '1'
	   		 BD5->BD5_LIBERA := '0'
	      Endif
	      
	      If lAtuBlo
			BD5->BD5_BLOPAG := '0'
		  Endif
		  
	      BD5->(MsUnLock())
	         
	      BD6->(DbSetOrder(1))
	      If BD6->(MsSeek(xFilial("BD6")+BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)))
	        
	         While ! BD6->(Eof()) .And. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) == ;
	                                      xFilial("BD6")+BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)         
	               
	               BD6->(RecLock("BD6",.F.))
	               
	               If cSitGui != cSituac   
	                  BD6->BD6_SITUAC := cSitGui
	               Elseif lAtuSta
	                  BD6->BD6_SITUAC := cSituac
	               Endif   
	                
	               If lAtuCid
	                  BD6->BD6_CID := cCid
	               Endif
	               
	               If lAtuExec
	                  BD6->BD6_CDPFRE := BB0->BB0_CODIGO
	                  BD6->BD6_REGEXE := BB0->BB0_NUMCR
	                  BD6->BD6_SIGEXE := BB0->BB0_CODSIG
	                  BD6->BD6_ESTEXE := BB0->BB0_ESTADO
	               Endif
	               
				   If lAtuSen
				      BD6->BD6_NRAOPE :=  cSenhaOpe                      
			       EndIf
	               
	               If lAtuOri .And. cOrigem == '1'
			   		  BD6->BD6_LIBERA := '0'
			       Endif
			       
	               If lAtuBlo
	               		
	               		PLBLOPC("BD6", .f., nil, nil, .t., .t., .f.)
						
		  		   Endif
		  		   
	               BD6->(MsUnLock())
	
	               aComEve := PLSCOMEVE(BD6->BD6_CODTAB,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_CODOPE,BD6->BD6_DATPRO)
	                                        
	               BD7->(DbSetOrder(1))
	               If BD7->(MsSeek(xFilial("BD7")+BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)))
	                 
	                  While ! BD7->(Eof()) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV) == ;
	                                              xFilial("BD6")+BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)         
	
	                        BD7->(RecLock("BD7",.F.))
	                        
	                        If cSitGui != cSituac
	                           BD7->BD7_SITUAC := cSitGui
	                        elseif lAtuSta
	                           BD7->BD7_SITUAC := cSituac
	                        Endif   
	                        
	                        If lAtuCid .And. BD7->(FieldPos("BD7_CID")) > 0
	                           BD7->BD7_CID := cCid
	                        Endif
	                        
	                        If lAtuExec
	                            BD7->BD7_CDPFPR := BB0->BB0_CODIGO
	                            BD7->BD7_REGPRE := BB0->BB0_NUMCR
	                            BD7->BD7_SIGLA  := BB0->BB0_CODSIG
	                            BD7->BD7_ESTPRE := BB0->BB0_ESTADO
	                            BD7->BD7_NOMPRE := BB0->BB0_NOME
	                        Endif
	                        
	                        If lAtuBlo
	                    		
	                    		If Len(aComEve) > 0 
					   	  			
					   	  			nPosUnd := Ascan(aComEve,{|x| x[1] == BD7->BD7_CODUNM})
		   			   	  			
		   			   	  			If nPosUnd > 0
					   					lBloqUnd :=  iif(aComEve[nPosUnd,13] == '1',.T.,.F.)				   	
					   	  			Else
					   					lBloqUnd := .F.				   	
					   	  			EndIf
					   	  			
					   			Else
					      			lBloqUnd := .F.
					   			EndIf
					   			
					   			PLSPOSGLO(PLSINTPAD(),__aCdCri223[1],__aCdCri223[2])
					   			
		  		   				PLBLOPC("BD7", iIf(lBloqUnd, .t.,.f.), __aCdCri223[1], PLSBCTDESC())
		  		   				
		  		   			Endif
		  		   			
							//Via de acesso e percentual da via
							if BD6->BD6_CODPRO == BD7->BD7_CODPRO	  		   			
		  		   				BD7->BD7_VIA	 	:= BD6->BD6_VIA
		  		   				BD7->BD7_PERVIA 	:= BD6->BD6_PERVIA
		  		   			endIf	
		  		   			
	                        BD7->(MsUnLock())
	                                        
	                  BD7->(DbSkip())
	                  Enddo           
	               Endif           
	                                        
	         BD6->(DbSkip())
	         Enddo
	      Endif
	   Endif   
	   BD5->(DbSetOrder(nOrdBD5))
	   BD5->(DbGoTo(nRecBD5))
	
	ElseIf &(cAliCab+"->"+cAliCab+"_TIPGUI") == "03" 
	
	   BE4->(DbSetOrder(1))
	   If BE4->(MsSeek(xFilial("BE4")+&(cAliCab+"->("+cAliCab+"_OPEMOV+"+cAliCab+"_CODLDP+"+cAliCab+"_CODPEG+"+cAliCab+"_NUMGUI)")))
	      
	      BE4->(RecLock("BE4",.F.))
	      
	      if cSitGui != cSituac
	         BE4->BE4_SITUAC := cSitGui
	      elseIf lAtuSta
	         BE4->BE4_SITUAC := cSituac
	      Endif   
	      
	      BE4->BE4_STATUS := cStatus
	      
	      If lAtuCid
	         BE4->BE4_CID := cCid
	      Endif
		  
		  If BE4->(FieldPos("BE4_NRAOPE")) > 0 .And. lAtuSen
		     BE4->BE4_NRAOPE :=  cSenhaOpe                      
	      EndIf             
	      
	      If lAtuBlo
		  	BE4->BE4_BLOPAG := '0'
		  Endif
	      
	      BE4->(MsUnLock())
	         
	      BD6->(DbSetOrder(1))
	      If BD6->(MsSeek(xFilial("BD6")+BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_ORIMOV)))
	         
	         While ! BD6->(Eof()) .And. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) == ;
	                                      xFilial("BD6")+BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_ORIMOV)         
	               
	               BD6->(RecLock("BD6",.F.))
	               
	               If  cSitGui != cSituac   
	               	  BD6->BD6_SITUAC := cSitGui
	               elseif lAtuSta
	                  BD6->BD6_SITUAC := cSituac
	               Endif   
	               
	               If lAtuCid
	                  BD6->BD6_CID := cCid
	               Endif
				   
				   If lAtuSen
				      BD6->BD6_NRAOPE :=  cSenhaOpe                      
			       EndIf
	               
	               If lAtuBlo
	               		
	               		PLBLOPC("BD6", .f., nil, nil, .t., .t., .f.)
						
		  		   Endif
		  		   
	               BD6->(MsUnLock())
	               
	               aComEve := PLSCOMEVE(BD6->BD6_CODTAB,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_CODOPE,BD6->BD6_DATPRO)
	                                        
	               BD7->(DbSetOrder(1))
	               If BD7->(MsSeek(xFilial("BD7")+BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_ORIMOV)))
	                  
	                  While ! BD7->(Eof()) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV) == ;
	                                              xFilial("BD7")+BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_ORIMOV)         
	
	                        BD7->(RecLock("BD7",.F.))
	                       
	                        If cSitGui != cSituac
	                           BD7->BD7_SITUAC := cSitGui
	                        elseif lAtuSta
	                           BD7->BD7_SITUAC := cSituac
	                        Endif   
	                    	
	                    	If lAtuBlo 
	                    		
	                    		If Len(aComEve) > 0 
					   	  			nPosUnd := Ascan(aComEve,{|x| x[1] == BD7->BD7_CODUNM})
		   			   	  			If nPosUnd > 0
					   					lBloqUnd :=  iif(aComEve[nPosUnd,13] == '1',.T.,.F.)				   	
					   	  			Else
					   					lBloqUnd := .F.				   	
					   	  			EndIf
					   			Else
					      			lBloqUnd := .F.
					   			EndIf
					  			
					   			PLSPOSGLO(PLSINTPAD(),__aCdCri223[1],__aCdCri223[2])
					   			
		  		   				PLBLOPC("BD7", iIf(lBloqUnd, .t.,.f.), __aCdCri223[1], PLSBCTDESC())
					  			
		  		   			Endif
		  		   			
							//Via de acesso e percentual da via
							if BD6->BD6_CODPRO == BD7->BD7_CODPRO	  		   			
		  		   				BD7->BD7_VIA	 	:= BD6->BD6_VIA
		  		   				BD7->BD7_PERVIA 	:= BD6->BD6_PERVIA
		  		   			endIf	
		  		   			
	                        BD7->(MsUnLock())
	                                        
	                  BD7->(DbSkip())
	                  Enddo           
	                            
	               Endif           
	                                        
	         BD6->(DbSkip())
	         Enddo
	         
	      Endif
	      
	   Endif   
	      
	   BE4->(DbSetOrder(nOrdBE4))
	   BE4->(DbGoTo(nRecBE4))
	Endif
	
Endif	

Return(.t.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSCUSTMOV ³ Autor ³ Tulio Cesar       ³ Data ³ 13.01.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o custo de uma empresa/familia/usuario             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
cTipoCon == "0" - Operadora
            "1" - Operadora + Grupo Empresa
            "2" - Operadora + Grupo Empresa + Numero do Contrato + Versao
            "3" - Operadora + Grupo Empresa + Numero do Contrato + Versao + SubContrato + Versao
            "4" - Operadora + Grupo Empresa + Familia
            "5" - Operadora + Grupo Empresa + Familia + Usuario
/*/
Function PLSCUSTMOV(cTipoCon,cCodOpe,cCodEmp,cNumCon,cVerCon,cSubCon,cVerSub,cMatric,cTipReg,cAnoIni,cMesIni,cAnoFin,cMesFin,lDialogo)

	Local cSQL := ""       
	Local aArea := GetArea()
	Local nValorCusto := 0                  
	Local lBD7_DTDIGI := BD7->(fieldPos("BD7_DTDIGI")) > 0
	Local cOperadorSql := IIf(AllTrim(TCGetDB()) $ "ORACLE|DB2|POSTGRES", "||", "+")

	Default lDialogo 	:= .T.

	If lDialogo

	If ! Pergunte("PLSCUS",.T.)
		Return
	Else
		cTipoCon := strzero(mv_par01,1)
		cCodOpe  := mv_par02
		cCodEmp  := mv_par03
		cNumCon  := mv_par04
		cVerCon  := mv_par05
		cSubCon  := mv_par06
		cVerSub  := mv_par07
		cMatric  := mv_par08
		cTipReg  := mv_par09
		cAnoIni  := mv_par10
		cMesIni  := mv_par11
		cAnoFin  := mv_par12
		cMesFin  := mv_par13
	Endif   
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o inicio da query, identico a qualquer cTipoCon                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSQL := "SELECT SUM(BD7_VLRPAG-BD7_VLRTPF) AS VALORCUSTO FROM "+RetSQLName("BD7")+", "+RetSQLName("BD6")+"  WHERE "
	cSQL += "BD6_FILIAL = '"+xFilial("BD6")+"' AND "
	cSQL += "BD6_OPEUSR = '"+cCodOpe+"' "
	If cTipoCon <> "0"
	cSQL += "AND BD6_CODEMP = '"+cCodEmp+"' "
	Endif   
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se cTipoCon for igual a 2 ou 3 adiciona a query abaixo...                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If     cTipoCon $ "2,3"
		cSQL += "AND BD6_CONEMP = '"+cNumCon+"' AND "
		cSQL += "BD6_VERCON = '"+cVerCon+"'"
		If cTipoCon == "3"
			cSQL += "AND BD6_SUBCON = '"+cSubCon+"' AND "
			cSQL += "BD6_VERSUB = '"+cVerSub+"'"
		Endif   
	ElseIf cTipoCon $ "4,5"
		cSQL += "AND BD6_MATRIC = '"+cMatric+"' "
		If cTipoCon == "5"
			cSQL += "AND BD6_TIPREG = '"+cTipReg+"'"
		Endif   
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o final da query, identico a qualquer cTipoCon                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSQL += "AND BD6_SITUAC = '1' AND "

	cSQL += "BD7_ANOPAG"+cOperadorSql+"BD7_MESPAG >= '"+cAnoIni+cMesIni+"' AND "
	cSQL += "BD7_ANOPAG"+cOperadorSql+"BD7_MESPAG <= '"+cAnoFin+cMesFin+"' AND "

	cSQL += RetSQLName("BD6")+".D_E_L_E_T_ = ' ' AND "
	cSQL += "BD7_FILIAL = '"+xFilial("BD7")+"' AND "
	cSQL += "BD7_CODOPE = BD6_CODOPE AND "
	cSQL += "BD7_CODLDP = BD6_CODLDP AND "
	cSQL += "BD7_CODPEG = BD6_CODPEG AND "
	cSQL += "BD7_NUMERO = BD6_NUMERO AND "
	cSQL += "BD7_ORIMOV = BD6_ORIMOV AND "
	cSQL += "BD7_SEQUEN = BD6_SEQUEN AND "  
	cSQL += "BD7_BLOPAG <> '1'       AND "
	cSQL += RetSQLName("BD7")+".D_E_L_E_T_ = ' '"     

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Insercao de ponto de entrada para modificacao do tratamento de custo³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("PLMCTCUS")
		cSql := ExecBlock("PLMCTCUS",.F.,.F.,{cSql})
		cSQL := ChangeQuery(cSQL)
	EndIf	
	//Retirei ChangeQuery devido a questões de performance.
	//Funções específicas de banco foram tratadas na própria criação da query.
	//cSQL := ChangeQuery(cSQL)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"PLSCUSTMOV",.T.,.F.)
	TcSetField("PLSCUSTMOV", 'VALORCUSTO', 'N', 18, 2)

	If PLSCUSTMOV->(Eof())
	nValorCusto := 0
	Else  
		While PLSCUSTMOV->(!Eof())
			nValorCusto += PLSCUSTMOV->VALORCUSTO
			PLSCUSTMOV->(Dbskip())
		Enddo    	
		IF ValType(nValorCusto) <> "N"
		nValorCusto := 0
	Endif   
	Endif

	PLSCUSTMOV->( DbCloseArea() )
	RestArea(aArea)

	If nValorCusto < 0
	nValorCusto := 0
	Endif   

	If lDialogo
	MsgInfo(STR0170+Str(nValorCusto,17,2)) //"Valor Total do Custo : "
	Endif       

Return( {nValorCusto} )


Function PLSDesNiv(cAlias)
LOCAL aNiveis := {	{"BT8",STR0171},; //"SubContrato X Cobertura"
                    {"BR8",STR0172},; //"Tabela Padrao"
                    {"BT7",STR0173 } } //"SubContrato X Grupo de Cobertura"
LOCAL nPos
LOCAL cRet
nPos := Ascan(aNiveis,{|x| x[1] == cAlias })                    

If nPos == 0                      
   cRet := cAlias
Else
   cRet := aNiveis[nPos,2]
Endif

Return(cRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSGUIAAud ³ Autor ³ Alexander/xxxx    ³ Data ³ 19.09.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica a guia e o procedimento auditado				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSGUIAAud(cGuia,cParecer,cCodPro,cAliasIte,lEvolucao,lInternacao,nRecno,lAudOnline, lProrrog,lEnvTds)
LOCAL nPos
LOCAL nI
LOCAL cSequen	  := ""	                                              
LOCAL lAuditoria  := .F.     
LOCAL nItensAut   := 0
LOCAL nItensNeg   := 0
LOCAL cStatus     := "1"
LOCAL nReg        := &( cAliasIte+"->(Recno())" )
LOCAL nOrd        := &( cAliasIte+"->(IndexOrd())" )
LOCAL nQtdItens   := 0
LOCAL nQtdItensP  := 0
LOCAL nItemLib    := 0
LOCAL aDadProc	  := {}
LOCAL aDadCri	  := {}    
LOCAL aDadRes	  := {}
LOCAL cCodMedGen  := GetNewPar("MV_PLMEDPT","")
LOCAL cCodMatGen  := GetNewPar("MV_PLMATPT","")  
LOCAL cCodTaxGen  := GetNewPar("MV_PLTAXPT","")
LOCAL cCodOpmGen  := GetNewPar("MV_PLOPMPT","")
LOCAL cDesGenPtu  := cCodMedGen+"-"+cCodMatGen+"-"+cCodTaxGen+"-"+cCodOpmGen
LOCAL lAchouBQV   := .F.
LOCAL cMotivo	  :=  Iif(Type("M->BVX_MOTIVO") <> 'U',M->BVX_MOTIVO,Iif(Type("M->B72_MOTIVO") <> "U",M->B72_MOTIVO,""))
LOCAL cDescCrit	  := ""
LOCAL cSeqPTU     := ""

DEFAULT cParecer  := ""                    
DEFAULT cCodPro   := ""                               
DEFAULT lEvolucao := .F.
DEFAULT lInternacao := .F.
DEFAULT nRecno    	:= 0
DEFAULT lAudOnline	:= .F.
DEFAULT lEnvTds   := .F.

cAliasIte := alltrim(cAliasIte)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se for evolucao															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lEvolucao .or. lInternacao .OR. lProrrog
	cChaveIte := cAliasIte+"->( "+cAliasIte+"_CODOPE+"+cAliasIte+"_ANOINT+"+cAliasIte+"_MESINT+"+cAliasIte+"_NUMINT)"
Else
	cChaveIte := cAliasIte+"->( "+cAliasIte+"_OPEMOV+"+cAliasIte+"_ANOAUT+"+cAliasIte+"_MESAUT+"+cAliasIte+"_NUMAUT)"
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se nao existe aborta													 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SIX->(DbSetOrder(1))
If !SIX->(MsSeek("BVX3"))
   Aviso("Indice BVX_FILIAL + BVX_OPEMOV + BVX_ANOAUT + BVX_MESAUT + BVX_NUMAUT + BVX_SEQUEN nao encontrado!")
   Return( {.F.,"",0,aDadProc,aDadCri} )                    
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Itens																	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea( cAliasIte )

&( cAliasIte+"->( DbGoTo("+Str(nRecno)+") )" )
cCodTran := IIf(&(cAliasIte+"->(FieldPos('"+cAliasIte+"_NRTROL'))") > 0,&( cAliasIte+"->"+cAliasIte+"_NRTROL" ),"")

&( cAliasIte+"->( DbClearFilter() )" )
&( cAliasIte+"->( DbSetOrder(1) )" ) //_FILIAL + _OPEMOV + _ANOAUT + _MESAUT + _NUMAUT + _SEQUEN
If &( cAliasIte+"->( MsSeek('"+xFilial(cAliasIte)+cGuia+"') )" )
   While !&( cAliasIte+"->( Eof() )" ) .And. xFilial(cAliasIte)+&( cChaveIte ) == xFilial(cAliasIte)+cGuia
		 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		 //³ Se codigo de transacao diferente pula registro                           ³
		 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         If &(cAliasIte+"->(FieldPos('"+cAliasIte+"_NRTROL'))") > 0 .And. &( cAliasIte+"->"+cAliasIte+"_NRTROL" ) <> cCodTran .And. lAudOnline
		     &( cAliasIte+"->( DbSkip() )" )
	         Loop
	     EndIf	 
  
		 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		 //³ Se for evolucao														  ³
		 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         If lEvolucao                   
             If &( cAliasIte+"->"+cAliasIte+"_OLNAUD" ) <> "1"
		        &( cAliasIte+"->( DbSkip() )" )
	        	Loop
	         EndIf	 
    	 EndIf
		 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		 //³ Verifica auditoria	e busca o codigo de glosa de procedimentos ja negados ³
		 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         If &( cAliasIte+"->"+cAliasIte+"_AUDITO" ) == "1" .And. !lAuditoria 
            lAuditoria := .T.
         Else
             If cAliasIte == "B4C" .And. B4C->B4C_STATUS == "0"     
                 BEG->(DbSetOrder(1))//BEG_FILIAL+BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT+BEG_SEQUEN    
                 If BEG->(DbSeek(xFilial("BEG")+B4C->(B4C_OPEMOV+B4C_ANOAUT+B4C_MESAUT+B4C_NUMAUT+B4C_SEQUEN)))  
                     cChaveBEG := B4C->(B4C_FILIAL+B4C_OPEMOV+B4C_ANOAUT+B4C_MESAUT+B4C_NUMAUT+B4C_SEQUEN)   
                     While xFilial("BEG")+BEG->(BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT+BEG_SEQUEN) == cChaveBEG .And. !BEG->(Eof())
                         If !Empty(BEG->BEG_CODGLO)
                             AaDd( aDadCri,{B4C->B4C_CODPRO+B4C->B4C_SEQUEN,BEG->BEG_CODGLO,BEG->BEG_DESGLO } )
             			 EndIf    
             			 BEG->(DbSkip())
                     EndDo   
                 EndIf             
             ElseIf cAliasIte == "BE2" .And. BE2->BE2_STATUS == "0"     
                 BEG->(DbSetOrder(1))//BEG_FILIAL+BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT+BEG_SEQUEN    
                 If BEG->(DbSeek(xFilial("BEG")+BE2->(BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT+BE2_SEQUEN)))  
                     cChaveBEG := BE2->(BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT+BE2_SEQUEN)     
                     While xFilial("BEG")+BEG->(BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT+BEG_SEQUEN) == cChaveBEG .And. !BEG->(Eof())
                         If !Empty(BEG->BEG_CODGLO)
                             AaDd( aDadCri,{BE2->BE2_CODPRO+BE2->BE2_SEQUEN,BEG->BEG_CODGLO,BEG->BEG_DESGLO } )
             			 EndIf    
             			 BEG->(DbSkip())
                     EndDo   
                 EndIf
             ElseIf cAliasIte == "BQV" .And. BQV->BQV_STATUS == "0"  
                 BQZ->(DbSetOrder(1))//BQZ_FILIAL+BQZ_CODOPE+BQZ_ANOINT+BQZ_MESINT+BQZ_NUMINT+BQZ_SEQUEN
                 If BQZ->(DbSeek(xFilial("BQZ")+BQV->(BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT+BQV_SEQUEN)))  
                     cChaveBQV := BQV->(BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT+BQV_SEQUEN)
                     While xFilial("BQZ")+BQZ->(BQZ_CODOPE+BQZ_ANOINT+BQZ_MESINT+BQZ_NUMINT+BQZ_SEQUEN) == cChaveBQV .And. !BQZ->(Eof()) 
                         If !Empty(BQZ->BQZ_CODGLO)
                             AaDd( aDadCri,{BQV->BQV_CODPRO+BQV->BQV_SEQUEN,BQZ->BQZ_CODGLO,BQZ->BQZ_DESGLO } )
             			 EndIf    
                         BQZ->(DbSkip())
                     EndDo              
                 EndIf    
             EndIf     
         Endif                        
		 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		 //³ Este controle e para o PTU ON-LINE saber se e o ultimo registro da guia  ³
		 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         If &( cAliasIte+"->"+cAliasIte+"_AUDITO" ) == "1"
            nQtdItens ++
         Endif   
		 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		 //³ Se todos estao pendentes liberar para PTU ON-LINE						  ³
		 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		 If &(cAliasIte+"->(FieldPos('"+cAliasIte+"_PENDEN') )") > 0
	         If &( cAliasIte+"->"+cAliasIte+"_PENDEN" ) == "1" 
	            nQtdItensP ++                                 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ajuste pois o procedimento ja pode ter recebido acao do auditor			 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	            If &( cAliasIte+"->"+cAliasIte+"_CODPRO" ) == cCodPro
		           nQtdItensP --
	            EndIf
	         Endif   
	     EndIf    
		 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		 //³ Pega a sequencia e ajusta a quantidade de itens em pendencia			   ³
		 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		 If &( cAliasIte+"->"+cAliasIte+"_CODPRO" ) == cCodPro
			 cSequen := &( cAliasIte+"->"+cAliasIte+"_SEQUEN" )
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³ Ajusta	no caso de pendencia											   ³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	         If cParecer == "3"
	            nQtdItensP ++
	         ElseIf nQtdItensP > 0
	            nQtdItensP --
	         Endif   
		 EndIf	 
		 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		 //³ Para tratamento do PTU-ONLINE "0" E AUTORIZADO							   ³
		 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         If &( cAliasIte+"->"+cAliasIte+"_STATUS" ) == "1" .Or. cParecer == "0"
            nItensAut ++
         Else           
            nItensNeg ++
         Endif   
		 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		 //³ Verifica a quantidade que foi liberada	- PTU ONLINE				       ³
		 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ       
         
         If cAliasIte <> "B45"
         
	         DbSelectArea("BVX")
	         DbSetOrder(3)//BVX_FILIAL + BVX_OPEMOV + BVX_ANOAUT + BVX_MESAUT + BVX_NUMAUT + BVX_SEQUEN
	         If BVX->(DbSeek(xFilial("BVX")+IIF(cAliasIte $ "BQV,BEJ",&( cAliasIte+"->"+cAliasIte+"_CODOPE" ),&( cAliasIte+"->"+cAliasIte+"_OPEMOV" ))+;   
	                                         IIF(cAliasIte $ "BQV,BEJ",&( cAliasIte+"->"+cAliasIte+"_ANOINT" ),&( cAliasIte+"->"+cAliasIte+"_ANOAUT" ))+;
	                                         IIF(cAliasIte $ "BQV,BEJ",&( cAliasIte+"->"+cAliasIte+"_MESINT" ),&( cAliasIte+"->"+cAliasIte+"_MESAUT" ))+;
	                                         IIF(cAliasIte $ "BQV,BEJ",&( cAliasIte+"->"+cAliasIte+"_NUMINT" ),&( cAliasIte+"->"+cAliasIte+"_NUMAUT" ))+; 
	                                         &( cAliasIte+"->"+cAliasIte+"_SEQUEN" )))
	                                         
	             //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			     //³ Se for despesa generica, verifica a descricao para assumir a qtd correta  ³
			     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	             If Alltrim(&( cAliasIte+"->"+cAliasIte+"_CODPRO" )) $ Alltrim(cDesGenPtu)
	
	                 lAchouBQV := .F.
	                 cChaveBVX := BVX->(BVX_FILIAL+BVX_OPEMOV+BVX_CODEMP+BVX_MATRIC+BVX_TIPREG+BVX_NUMAUT+BVX_CODPAD+BVX_CODPRO)
	                 While !BVX->( Eof() ) .And. xFilial("BVX")+BVX->(BVX_OPEMOV+BVX_CODEMP+BVX_MATRIC+BVX_TIPREG+BVX_NUMAUT+BVX_CODPAD+BVX_CODPRO) == cChaveBVX    
	                     If Alltrim(&( cAliasIte+"->"+cAliasIte+"_DESPRO" )) == Alltrim(BVX->BVX_DESPRO)
	                         nItemLib := BVX->BVX_QTDPRO  
	                         lAchouBQV := .T.
	                         Exit
	                     EndIf
	                     BVX->(DbSkip())
	                 EndDo   
	                 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			         //³ Se nao achou no BQV o procedimento, assume que e o ultimo			       ³
			         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	                 If !lAchouBQV .And. TYPE("M->BVX_QTDPRO")  == 'N'
	                     nItemLib := M->BVX_QTDPRO
	                 EndIf
	             //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			     //³ Se for despesa normal, assume quantidade liberada                         ³
			     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	             Else
	                 nItemLib := BVX->BVX_QTDPRO 
	             Endif    
					BCT->(DbSetOrder(1))//BCT_FILIAL + BCT_CODOPE + BCT_PROPRI + BCT_CODGLO
					If BCT->(DbSeek(xFilial("BCT")+PlsIntPad()+cMotivo))
						cDescCrit := Alltrim(BCT->BCT_DESCRI)
					Else
						cDescCrit := ""
					EndIf
	         Else 
					If lEnvTds
						nItemLib := &( cAliasIte+"->"+cAliasIte+"_QTDPRO" )
					ElseIf TYPE("M->BVX_QTDPRO")  == 'N'
						nItemLib := M->BVX_QTDPRO
					EndIf
					BCT->(DbSetOrder(1))//BCT_FILIAL + BCT_CODOPE + BCT_PROPRI + BCT_CODGLO
					If BCT->(DbSeek(xFilial("BCT")+PlsIntPad()+cMotivo))
						cDescCrit := Alltrim(BCT->BCT_DESCRI)
					Else
						cDescCrit := ""
					EndIf
				EndIf
	     EndIf                                

		 If &(cAliasIte+"->(FieldPos('"+cAliasIte+"_SEQPTU'))") > 0
			cSeqPTU := &( cAliasIte+"->"+cAliasIte+"_SEQPTU" )
		 EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Procedimentos														       ³
		 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		 AaDd(aDadProc,{&( cAliasIte+"->"+cAliasIte+"_CODPAD" ),&( cAliasIte+"->"+cAliasIte+"_CODPRO" ),&( cAliasIte+"->"+cAliasIte+"_QTDPRO" ),&( cAliasIte+"->"+cAliasIte+"_SEQUEN" ),&( cAliasIte+"->"+cAliasIte+"_STATUS" ),nItemLib,&(cAliasIte)->( Recno() ),IIf(&(cAliasIte+"->(FieldPos('"+cAliasIte+"_NRTROL'))") > 0,&( cAliasIte+"->"+cAliasIte+"_NRTROL" ),""),&( cAliasIte+"->"+cAliasIte+"_AUDITO" ),&( cAliasIte+"->"+cAliasIte+"_DATPRO" ),Alltrim(cDescCrit), cSeqPTU } )	
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Skip														  		         ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   &( cAliasIte+"->( DbSkip() )" )
   Enddo
Else
	FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "PLSGUIAAUD Chave "+cAliasIte+" ["+cGuia+"] "+STR0174 , 0, 0, {})//"seek nao localizado!" 
Endif              
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Resposta																  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If     ( nItensNeg == 0 .And. nItensAut >= 1 )
       cStatus := "1" //Autorizada
ElseIf ( nItensNeg > 0  .And. nItensAut >= 1 )   
       cStatus := "2" //Autorizada parcialmente
ElseIf ( nItensNeg > 0 .And. nItensAut == 0 )
       cStatus := "3" //nao autorizada
Endif       
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criticas e resultado da auditoria										 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BVX->( DbSetOrder(3) )	//BVX_FILIAL + BVX_OPEMOV + BVX_ANOAUT + BVX_MESAUT + BVX_NUMAUT + BVX_SEQUEN      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Procedimentos da guia PTU ON-LINE										  ³
//³ Lembrando o Ultimo procedimento ainda nao foi tratado (liberado ou negado)³
//³ Atualiza as criticas caso seja o ultimo procedimento					  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( nQtdItens == 1 .Or. nQtdItensP == nQtdItens ) .And. !Empty(cParecer)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Libera para o online													  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    nQtdItens := 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Resposta da auditoria CRITICAS											  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If BVX->( MsSeek( xFilial("BVX")+cGuia ) )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ While																	  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While !BVX->( Eof() ) .And. BVX->( BVX_FILIAL+BVX_OPEMOV+BVX_ANOAUT+BVX_MESAUT+BVX_NUMAUT ) == xFilial("BVX")+cGuia

			If !Empty( BVX->BVX_MOTIVO ) .And. BVX->BVX_PARECE <> "0" 
			    nPos := aScan(aDadCri,{ |x| x[1] == BVX->(BVX_CODPRO+BVX_SEQUEN) } )
			    If nPos == 0
				   AaDd( aDadCri,{BVX->(BVX_CODPRO+BVX_SEQUEN),BVX->BVX_MOTIVO,BVX->BVX_DESMOT+Iif(BVX->BVX_PARECE=="3"," - PENDENTE","")} )
				Else 
				   aDadCri[nPos,2] := BVX->BVX_MOTIVO
				   aDadCri[nPos,3] := BVX->BVX_DESMOT+Iif(BVX->BVX_PARECE=="3"," - PENDENTE","")
				EndIf	
			EndIf            
			
			BVX->( DbSkip() )
		EndDo
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pega o ultimo que ainda nao foi gravado									  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If M->BVX_PARECE <> "0" .And. lAuditoria .And. nQtdItens == 1
	    nPos := aScan(aDadCri,{ |x| x[1] == cCodPro+cSequen } )
	    If nPos == 0
			AaDd( aDadCri,{cCodPro+cSequen,M->BVX_MOTIVO,M->BVX_DESMOT+Iif(M->BVX_PARECE=="3"," - PENDENTE","") } )
		Else      
		   aDadCri[nPos,2] := M->BVX_MOTIVO
		   aDadCri[nPos,3] := M->BVX_DESMOT+Iif(M->BVX_PARECE=="3"," - PENDENTE","")
		EndIf	
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o ultimo procedimento da matriz								  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPos := Ascan( aDadProc, {|x| x[7] == nRecno } )//Ascan( aDadProc, {|x| x[2] == cCodPro } )
	If nPos > 0
		aDadProc[nPos,5] := Iif(cParecer=="0","1","0")
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona																  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
&( cAliasIte+"->( DbGoTo("+Str(nReg)+") )" )
&( cAliasIte+"->( DbSetOrder("+Str(nOrd)+") )" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta a matriz caso seja parecer 3=pendente							  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lAuditoria .And. nQtdItens == 1 .And. cParecer == "3"
	For nI := 1 To Len(aDadProc)
		aDadProc[nI,5] := cParecer //Status
	Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Somente se nao for informado nenhuma critica nova						  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(M->BVX_MOTIVO)
		aDadCri := {}          	
	EndIf	
EndIf	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina															  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return( {lAuditoria,cStatus,nQtdItens,aDadProc,aDadCri} )                    
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSTIPOCOP ³ Autor ³ Tulio Cesar       ³ Data ³ 12.04.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o tipo de um evento                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*
 aRet e definido como

[1]  - BDH_VALOR    - 116 - Ft Moderador/Co-Participacao
[2]  - BDH_VLRCP2   - 127 - Custo Operac. Serv. Acessorios
[3]  - BDH_VLRCP3   - 134 - Custo operacional outros servicos
[4]  - BDH_VALOR1   - 147 - Prod. de Coop./P. F. (CO-P.)
[5]  - BDH_VALOR2   - 148 - Prod. de Coop./P. J. (CO-P.)
[6]  - BDH_VALOR3   - 149 - Serv. Coop.PF Outras Oper.(CO-P.)
[7]  - BDH_VALOR4   - 150 - Serv. Coop.PJ Outras Oper.(CO-P.)
[8]  - BDH_VALOR5   - 151 - Serv. Aux. (SADT) (CO-P.)
[9]  - BDH_VALOR6   - 152 - Serv. SADT outras Oper.(CO-P.)
[10] - BDH_VALOR7   - 153 - Prod. Nao Cooperado (CO-P.)
[11] - BDH_VALOR8   - 154 - Prod. Nao Coop. Outras Oper.(CO-P.)
[12] - BDH_VALOR9   - 155 - Custos em Serv.Propr.(CO-P.)
[13] - BDH_VLRTIM   - 901 - TIMBRE
[14] - BDH_VLRPES   - 902 - PESO

BDH_VLRCOP   - 104 - Custo Operac. Servicos Medicos
BDH_VALOR    - 116 - Ft Moderador/Co-Participacao
BDH_VLRTAX   - 117 - Taxa Administrativa
BDH_VALCPF   - 124 - Co-Partic. Compras a Faturar  
BDH_VALCOF   - 123 - Custo Oper. Compras a Faturar
BDH_VALTCF   - 125 - Taxas Compras a Faturar
BDH_VLRCP2   - 127 - Custo Operac. Serv. Acessorios
BDH_VLRCP3   - 134 - Custo operacional outros servicos
BDH_VLRCP4   - 137 - Prod. de Coop./Pessoa Fisica (C.O.)
BDH_VLRCP5   - 138 - Prod. de Coop./Pessoa Juridica (C.O.)
BDH_VLRCP6   - 139 - Serv. Coop. PF Outras Operadoras (C.O.) 
BDH_VLRCP7   - 140 - Serv. Coop. PJ Outras Operadoras (C.O.)
BDH_VLRCP8   - 141 - Serv. Aux. Diagn. Terapia (SADT) (C.O.)
BDH_VLRCP9   - 142 - Serv. SADT outras Operadoras (C.O.)
BDH_VLRCPA   - 143 - Prod. Nao Cooperado (C.O.)
BDH_VLRCPB   - 144 - Prod. Nao Coop. Outras Operadoras (C.O.)
BDH_VLRCPC   - 145 - Custos em Servicos Proprios (C.O.)
BDH_VALOR1   - 147 - Prod. de Coop./P. F. (CO-P.)
BDH_VALOR2   - 148 - Prod. de Coop./P. J. (CO-P.)
BDH_VALOR3   - 149 - Serv. Coop.PF Outras Oper.(CO-P.)
BDH_VALOR4   - 150 - Serv. Coop.PJ Outras Oper.(CO-P.)
BDH_VALOR5   - 151 - Serv. Aux. (SADT) (CO-P.)
BDH_VALOR6   - 152 - Serv. SADT outras Oper.(CO-P.)
BDH_VALOR7   - 153 - Prod. Nao Cooperado (CO-P.)
BDH_VALOR8   - 154 - Prod. Nao Coop. Outras Oper.(CO-P.)
BDH_VALOR9   - 155 - Custos em Serv.Propr.(CO-P.)
BDH_VLRTIM   - 901 - TIMBRE
BDH_VLRPES   - 902 - PESO
*/

/*
cTipoVlr:
 1 = Custo Operacional 
 2 = Co-Participacao   
*/                    
Function PLSTIPOCOP(cTipoVLR)
LOCAL aRet     	 := iiF(cPaisLoc == "URU",{0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0}) 
LOCAL nOrdBD7    := BD7->(IndexOrd())
LOCAL nRecBD7  	 := BD7->(Recno())
LOCAL nOrdBAU  	 := BAU->(IndexOrd())
LOCAL nRecBAU  	 := BAU->(Recno())
LOCAL nOrdBR8 	 := BR8->(IndexOrd())
LOCAL nRecBR8	 := BR8->(Recno())  
LOCAL xFilialBD7 := xFilial("BD7")	
LOCAL xFilialBAU := xFilial("BAU")
local aMatTOTBD7 := {}	

LOCAL bRest    	:= { || BD7->(DbSetOrder(nOrdBD7)), BD7->(DbGoTo(nRecBD7)),;
					   	BAU->(DbSetOrder(nOrdBAU)), BAU->(DbGoTo(nRecBAU)),;
					   	BR8->(DbSetOrder(nOrdBR8)), BAU->(DbGoTo(nRecBR8)) }
LOCAL nPercen  	:= 0
LOCAL nDif		:= 0
LOCAL cAto     	:= ''
LOCAL aAux	   	:= {}
LOCAL lTpAto   	:= existblock("PLTIPATO")
LOCAL lBXZ     	:= BXZ->( MsSeek( xFilial("BXZ") ) )//se existe o alias e existe conteudo nele

DEFAULT cTipoVlr := '1'

BD7->(DbSetOrder(1))
BAU->(DbSetOrder(1))
If BD7->(MsSeek(xFilialBD7+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))

	While ! BD7->(Eof()) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
   								xFilialBD7+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
		
		//066 - Evento de alto custo. O valor a ser cobrado/pago deve ser analisado.
		//067 - Evento de alto custo. NF de Entrada nao foi localizada. O valor a ser cobrado/pago deve ser atualizado manualmente.     
		//068 - Evento de alto custo. Valor ja foi pago atraves da NF de Entrada.                                                       
       	If  ( BD7->BD7_BLOPAG == '1' .and. !BD6->BD6_MOTBPG $ '066/067/068' ) .or. (  BD7->BD7_VLRTPF == 0 .and. BD7->BD7_VLRPAG == 0 )
           BD7->(dbSkip())
           loop
       	Endif
             
		nPercen += BD7->BD7_PERCEN
		
		BAU->(MsSeek(xFilialBAU  +BD7->BD7_CODRDA))
		
		//Cooperado, e um servico medico...
		If BAU->BAU_COPCRE == "1" 
		    cAto := "1"
		    
		//Nao e cooperado, e um servico acessorio... 
		Else
	        cAto := "0"
	        
		Endif

        If lBXZ
		
			//passo a aRet para a função e com base no cadastro BXZ eu alimento o ARRAY
			PlTrtLan(aRet,cTipoVLR,;
						BD6->BD6_CODOPE,;
						BD6->BD6_LOCAL,;
						BD6->BD6_CODPAD,;
						BD6->BD6_CODPRO,;
						BD6->BD6_CODPLA,;
						'001',;//alterar isso futuramente
						BD6->BD6_SUBCON,;
						BD6->BD6_VERSUB,;
						BD6->BD6_CONEMP,;
						BD6->BD6_VERCON,;
						BD6->BD6_CODEMP)
        ElseIf lTpAto
        
            aAux := execblock("PLTIPATO",.F.,.F.,{cAto, BD7->BD7_CODPAD, BD7->BD7_CODPRO,aRet,0,BD7->BD7_PERCEN, BD6->BD6_DATPRO, cTipoVlr})
            
            If aAux[3]
	            aRet := Aclone(aAux[2])
	        Else
	        
	        	If BD7->BD7_CODUNM = "TIM" .and. cPaisLoc == "URU"                       
        	
	        		aRet[13] += BD7->BD7_VLRBPF - BD7->BD7_VLRTAD        	
	        		
	        	ElseIf BD7->BD7_CODUNM = "PES" .AND. cPaisLoc == "URU"
	        	
	        		aRet[14] += BD7->BD7_VLRBPF - BD7->BD7_VLRTAD        	
	        		
	        	ElseIf cTipoVlr == '1'
	        	
		            If aAux[1] == "1"
				
						aRet[1] += BD7->BD7_VLRBPF
					       
        		    Elseif aAux[1] == "0"
        		    
						aRet[2] += BD7->BD7_VLRBPF
						
	            	Endif
	            		        
	           	Else
		           	aRet[1] += BD7->BD7_VLRTPF - BD7->BD7_VLRTAD
		       	Endif
		       	
	        Endif
	        
        Else
        
        	If BD7->BD7_CODUNM = "TIM" .and. cPaisLoc == "URU"                       
        	
        		aRet[13] += BD7->BD7_VLRBPF - BD7->BD7_VLRTAD        	
        		
        	ElseIf BD7->BD7_CODUNM = "PES" .and. cPaisLoc == "URU"
        	
        		aRet[14] += BD7->BD7_VLRBPF - BD7->BD7_VLRTAD        	
        		  
 			//1 = Custo Operacional   
        	ElseIf cTipoVlr == '1'
        	
	            If cAto == "1"
	            
					aRet[1] += BD7->BD7_VLRBPF
				       
        	    Elseif cAto == "0"
        	    
					aRet[2] += BD7->BD7_VLRBPF
					
	            Endif

	        //2 = Co-Participacao
	        Else
		        aRet[1] += BD7->BD7_VLRTPF - BD7->BD7_VLRTAD
	        Endif
	        
        Endif
		
	BD7->(DbSkip())
	Enddo
	
Endif

Return(aRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PlTrtLan   ³ Autor ³ Daher             ³ Data ³ 14.09.2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Trata o cadastro de regra de coparticipaçao                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PlTrtLan(aRet, cTipoVLR,cCodOpe,cCodLoc,cCodPad,cCodPsa,cCodPro,cVerPro,cSubCon,cVerSub,cConEmp,cVerCon,cCodEmp)
LOCAL cLanc    := ""
LOCAL nPos     := 0      
LOCAL aLancFt  := {}
LOCAL n

If cTipoVLR == '1'
	aLancFt  := LancFtCpo(1)           
	cLanc    := GetNewPar("MV_PLSCPCP",'116') //conteudo padrao co-part
Elseif cTipoVLR == '2'
	aLancFt  := LancFtCpo(3)
	cLanc    := GetNewPar("MV_PLSCPCO",'104') //conteudo padrao para custo
Endif

__aLanFil := PlRtLBXZ()
xTexto := ''

Do case       

	 //LOCAL E PROCEDIMENTO E PRODUTO E SUBCONTRATO
     case   (nPos := ascan(__aLanFil, { |x| x[1] 		== cCodOpe .and. ;
						     			    x[3] 		== cCodLoc .and. ;
						                    x[4]+x[5] 	== cCodPad+cCodPsa .and. ;
						     		        x[6]+x[7] 	== cCodPro+cVerPro .and. ;
						     		        x[8] 		== cCodOpe+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub .and.;
						     		        x[11] 		== cTipoVLR})) > 0
				
				cLanc := __aLanFil[nPos][2]	     
     
     //LOCAL E PROCEDIMENTO E PRODUTO
     case   (nPos := ascan(__aLanFil, { |x| x[1] 		== cCodOpe .and. ;
								     		x[3] 		== cCodLoc .and. ;
								     		x[4]+x[5] 	== cCodPad+cCodPsa .and. ;
								     		x[6]+x[7] 	== cCodPro+cVerPro .and. Empty(x[8]) .and.;
						     		        x[11] 		== cTipoVLR})) > 0
                
                cLanc := __aLanFil[nPos][2]
                                     
     //LOCAL E PROCEDIMENTO E SUBCONTRATO
     case   (nPos := ascan(__aLanFil, { |x| x[1] 		== cCodOpe .and. ;
								     		x[3] 		== cCodLoc .and. ;
								     		x[4]+x[5] 	== cCodPad+cCodPsa .and. ;
								     		x[8] 		== cCodOpe+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub .and. Empty(x[6]) .and.;
						     		        x[11] 		== cTipoVLR})) > 0
                
     			cLanc := __aLanFil[nPos][2]
     			
     //LOCAL E SUBCONTRATO E PRODUTO
     case   (nPos := ascan(__aLanFil, { |x| x[1] 		== cCodOpe .and. ;
								     		x[3] 		== cCodLoc .and. ;
								     		x[6]+x[7] 	== cCodPro+cVerPro .and. ;
								     		x[8]		== cCodOpe+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub .and. Empty(x[5]) .and.;
						     		        x[11] 		== cTipoVLR})) > 0
                
                cLanc := __aLanFil[nPos][2]
                                         
     //PROCEDIMENTO E PRODUTO E SUBCONTRATO
     case   (nPos := ascan(__aLanFil, { |x| x[1] 		== cCodOpe .and. ;
								     		x[4]+x[5] 	== cCodPad+cCodPsa .and. ;
								     		x[6]+x[7] 	== cCodPro+cVerPro .and. ;
								     		x[8] 		== cCodOpe+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub .and. Empty(x[3]) .and.;
						     		        x[11] 		== cTipoVLR})) > 0
								       
                cLanc := __aLanFil[nPos][2]
                           
     //LOCAL E PROCEDIMENTO
     case   (nPos := ascan(__aLanFil, { |x| x[1] 		== cCodOpe .and. ;
								     		x[3] 		== cCodLoc .and. ;
								     		x[4]+x[5] 	== cCodPad+cCodPsa .and. Empty(x[6])  .and. Empty(x[8]) .and.;
						     		        x[11] 		== cTipoVLR})) > 0
                
                cLanc := __aLanFil[nPos][2]          
                
     //LOCAL E PRODUTO
     case   (nPos := ascan(__aLanFil, { |x| x[1] 		== cCodOpe .and. ;
								     		x[3] 		== cCodLoc .and. ;
								     		x[6]+x[7] 	== cCodPro+cVerPro .and. Empty(x[5])  .and. Empty(x[8]) .and.;
						     		        x[11] 		== cTipoVLR})) > 0
                
                cLanc := __aLanFil[nPos][2]
                                 
     //LOCAL E SUBCONTRATO
     case   (nPos := ascan(__aLanFil, { |x| x[1] 	== cCodOpe .and. ;
								     		x[3] 	== cCodLoc .and. ;
								     		x[8] 	== cCodOpe+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub .and. Empty(x[5])  .and. Empty(x[6]) .and.;
						     		        x[11] 	== cTipoVLR})) > 0
     		    
     		    cLanc := __aLanFil[nPos][2]
     		                 
     //PROCEDIMENTO E PRODUTO 
     case   (nPos := ascan(__aLanFil, { |x| x[1] 		== cCodOpe .and. ;
								     		x[4]+x[5] 	== cCodPad+cCodPsa .and. ;
								     		x[6]+x[7] 	== cCodPro+cVerPro .and. Empty(x[3])  .and. Empty(x[8]) .and.;
						     		        x[11] 		== cTipoVLR})) > 0
				
				cLanc := __aLanFil[nPos][2]
								     
     //PROCEDIMENTO E SUBCONTRATO
     case   (nPos := ascan(__aLanFil, { |x| x[1] 		== cCodOpe .and. ;
								     		x[4]+x[5] 	== cCodPad+cCodPsa .and. ;
								     		x[8] 		== cCodOpe+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub .and. Empty(x[3])  .and. Empty(x[6]) .and.;
						     		        x[11] 		== cTipoVLR})) > 0
				
				cLanc := __aLanFil[nPos][2]
								     
     //SUBCONTRATO E PRODUTO
     case   (nPos := ascan(__aLanFil, { |x| x[1] 		== cCodOpe .and. ;
								     		x[6]+x[7] 	== cCodPro+cVerPro .and. ;
								     		x[8] 		== cCodOpe+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub .and. Empty(x[3])  .and. Empty(x[5]) .and.;
						     		        x[11] 		== cTipoVLR})) > 0
				
				cLanc := __aLanFil[nPos][2]
								     
     //LOCAL
     case   (nPos := ascan(__aLanFil, { |x| x[1] 	== cCodOpe .and. ;
								     		x[3] 	== cCodLoc  .and. Empty(x[5])  .and. Empty(x[6])  .and. Empty(x[8]) .and.;
						     		        x[11] 	== cTipoVLR})) > 0
                
            cLanc := __aLanFil[nPos][2]
            
     //PROCEDIMENTO
     case   (nPos := ascan(__aLanFil, { |x| x[1] 		== cCodOpe .and. ;
								     		x[4]+x[5] 	== cCodPad+cCodPsa .and. Empty(x[3])  .and. Empty(x[6])  .and. Empty(x[8]) .and.;
						     		        x[11] 		== cTipoVLR})) > 0
						     		        
            cLanc := __aLanFil[nPos][2]
                   
     //PRODUTO
     case   (nPos := ascan(__aLanFil, { |x| x[1] 		== cCodOpe .and. ;
								     		x[6]+x[7] 	== cCodPro+cVerPro .and. Empty(x[3])  .and. Empty(x[5])  .and. Empty(x[8]) .and.;
						     		        x[11] 		== cTipoVLR})) > 0
			
			cLanc := __aLanFil[nPos][2]
								              
     //SUBCONTRATO
     case   (nPos := ascan(__aLanFil, { |x| x[1] 	== cCodOpe .and. ;
								     		x[8] 	== cCodOpe+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub .and. Empty(x[3])  .and. Empty(x[5])  .and. Empty(x[6]) .and.;
						     		        x[11]	== cTipoVLR})) > 0
     	    
     	    cLanc := __aLanFil[nPos][2]	
    
    // Apenas lancamento de faturamento - GENERICO. 	    
	case   (nPos := ascan(__aLanFil, { |x| x[1] 	== cCodOpe .AND.;   
											Empty(x[3]) .and.;
											Empty(x[5]) .and.;
											Empty(x[6]) .and.;
											Empty(x[8]) .and.;
						     		        x[11] 	== cTipoVLR})) > 0     

//		MsgStop("Encontrou a regra generica: "+__aLanFil[nPos][2])
		cLanc := __aLanFil[nPos][2]	
End Case

If ((nPos2 := Ascan(aLancFt, {|x| x[2] == cLanc})) > 0)                       
	If cTipoVLR == '1'
		aRet[aLancFt[nPos2][3]] += BD7->BD7_VLRTPF
	Elseif cTipoVLR == '2'
		aRet[aLancFt[nPos2][3]] += BD7->BD7_VLRBPF - BD7->BD7_VLRTAD 
    Endif
Endif 

Return 


Function PLSPRRDAP(cCodRda,cOpeRda,cCodLoc,cCodEsp,cCodPla,cCodPad,cCodPro)       
LOCAL lPagar := .T.                                                       
DEFAULT cCodPad := ""
DEFAULT cCodPro := ""

BBI->(DbSetOrder(1))
If BBI->(MsSeek(xFilial("BBI")+cCodRda+cOpeRda+Subs(cCodLoc,1,3)+cCodEsp+cCodPla)) .And. ;
   BBI->(FieldPos("BBI_BLOPAG")) > 0 .And. BBI->BBI_BLOPAG == "1"                                       
   lPagar := .F.
Endif

If lPagar
   BE9->(DbSetOrder(1))
   If BE9->(FieldPos("BE9_BLOPAG")) > 0                                                                  
   
      If ! BE9->(MsSeek(xFilial("BE9")+cCodRda+cOpeRda+Subs(cCodLoc,1,3)+cCodEsp+cCodPla+cCodPad+cCodPro))
         If ExistBlock("PLSBE9SK")
            ExecBlock("PLSBE9SK",.F.,.F.,{cCodRda,cOpeRda,cCodLoc,cCodEsp,cCodPLa,cCodPad,cCodPro,1})
         Endif
      Endif   

      If BE9->(Found()) .And. ;
         BE9->BE9_BLOPAG == "1"
         lPagar := .F.
      Endif
   Endif   
Endif   

Return(lPagar)



Function PLSVERCCBG(cMatricUsr,cAnoPag,cMesPag,cSeqPF,cTipoRet)
LOCAL lCobrada := .F.
LOCAL nOrdBDH  := BDH->(IndexOrd())
LOCAL nRecBDH  := BDH->(Recno())
LOCAL bRest    := { || BDH->(DbSetOrder(nOrdBDH)), BDH->(DbGoTo(nRecBDH)) }
LOCAL cNumSE1  := ""
DEFAULT cTipoRet := "1"

BDH->(DbSetOrder(3))
If BDH->(MsSeek(xFilial("BDH")+cMatricUsr+cAnoPag+cMesPag+cSeqPF))
   If BDH->BDH_STATUS == "0"
      If cTipoRet == "1"
         lCobrada := .T.
      Else
         cNumSE1 := BDH->(BDH_PREFIX+BDH_NUMTIT+BDH_PARCEL+BDH_TIPTIT)
      Endif   
   Endif   
Endif

Eval(bRest)

Return(If(cTipoRet=="1",lCobrada,cNumSE1))
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSVLDRDG  ³ Autor ³ Totvs             ³ Data ³ 14.09.2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ VldRDG													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVLDRDG(cCodRda,lCnpj)
LOCAL aArea     := GetArea()
LOCAL lRet      := .t.
LOCAL cMVPLSRDAG:= GetNewPar("MV_PLSRDAG","999999")
LOCAL lDatPag   := GetNewPar("MV_PLSDTPG",.F.)
LOCAL aRetBAW	:= {}
LOCAL cCampo    := readVar()
DEFAULT lCnpj 	:= .f.

If !lCnpj

	If cMVPLSRDAG == cCodRda

	   lRet := .F.

	   Aviso( STR0020, ; //"Rede de Atendimento Generica"
	          STR0021,; //"Informe uma Rede de Atendimento Valida."
	          { STR0022 }, 2 ) //"Ok"
	EndIf
	                
EndIf

BAU->( DbSetOrder( Iif( lCnpj,4,1) ) )//BAU_FILIAL + BAU_CODIGO   //BAU_FILIAL + BAU_CPFCGC
If BAU->(msSeek( xFilial("BAU") + cCodRda ) )

    aRetBAW := PLSVldBAW(PLSINTPAD(),nil,nil,nil,nil,nil,nil,cCodRDA)
    
    If ! aRetBAW[1]
    
	   Aviso( STR0021, ; //"Informe uma Rede de Atendimento Valida."
	          aRetBAW[2,1,1] + aRetBAW[2,1,2],; //
	          { STR0022 }, 2 ) //"Ok"

       Return(.f.)
       
    Endif   
    
	If cCampo == "M->BCI_DATREC"
	    
	    lRet := A360CHEBLO(cCodRda,&(cCampo)) 
	    
	    If lDatPag .and. lRet
			lRet := PLSVDTRPEG(M->BCI_DATREC,M->BCI_OPERDA,cCodRda,M->BCI_TIPGUI)
		Endif
		
	EndIf

	//Bloqueio para evitar que a data de atendimento seja alterada para maior que a data dos procedimentos
	If cCampo == "M->BD5_DATPRO"  //Só verifico as datas caso o valid seja acionado pelo campo de data de atendimento

		BD6->(DbSetOrder(1))		
		If BD6->(MsSeek(  xfilial("BD6") + BCI->BCI_CODOPE + BCI->BCI_CODLDP + BCI->BCI_CODPEG + M->BD5_NUMERO))
			While !(BD6->(EoF())) .AND. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO) == xfilial("BD6")+BCI->BCI_CODOPE+BCI->BCI_CODLDP+BCI->BCI_CODPEG+M->BD5_NUMERO
				If BD6->BD6_DATPRO < M->BD5_DATPRO //Percorro todos os procedimentos para comparar datas
					lRet := .f.
					cDataMsg := dtoc(BD6->BD6_DATPRO)
					msgInfo( STR0242 + BD6->BD6_SEQUEN + " - " + STR0005 + cDataMsg + ".") //Não é possível alterar a data de atendimento para uma maior que a data de um procedimentos da guia. Procedimento: xxx - Data dd/mm/aaaa
					Exit
				Endif
				BD6->(DbSkip())
			Enddo
		Endif

	Endif	
	
	If lCnpj                 
		cCodRda := BAU->BAU_CODIGO
	EndIf	                      

EndIf

restArea(aArea)

Return(lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSVLRTREM ³ Autor ³ Tulio Cesar       ³ Data ³ 31.05.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o valor de um evento de reembolso.                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVLRTREM(cCodInt,cCodTab,cMatricUsr,dDatPro,cHorPro,cCodPad,cCodPro,nQtdPro,nUS)
LOCAL aValor                          
LOCAL cMes    := PLSSTRMES(dDatPro)
LOCAL cAno    := PLSSTRANO(dDatPro,.T.)
LOCAL aRetFun
LOCAL aDadUsr
LOCAL lRet    := .T.
LOCAL nRet    := 0

aRetFun := PLSDADUSR(cMatricUsr,"1",.F.,dDatPro,cCodPad,cCodPro)

If ! aRetFun[1]
   lRet := .F.
Else
   aDadUsr := PLSGETUSR()   
Endif   

If lRet

   aValor :=  PLSCALCEVE(cCodPad,cCodPro,cMes,cAno,cCodInt,"","","","",nQtdPro,dDatPro,"",;
                          "","",0,aDadUsr,"",nil,cCodTab,"BA0",nUS,"BFM",cHorPro,{},.F.,;
                          "",0,nil,.T.)
   nRet   := aValor[2]
Endif

Return(nRet)




Function PLSCONRDA(cProduto, cVersao, lFiltRDA)
LOCAL cCodOpe                    
LOCAL bOK     := { || oDlg:End() }
LOCAL bCancel := { || oDlg:End() }

LOCAL oMemo
LOCAL cMemo := ""

LOCAL oEstado
LOCAL aEstado
LOCAL cEstado

LOCAL oEspec
LOCAL aEspec   := {__cTextoAll}
LOCAL cEspec   := __cTextoAll
LOCAL bEsp     := { || aEspec := PLSLESP(cCodOpe,cEstado), oEspec:aItems := aClone(aEspec), cEspec := aEspec[1], Eval(bMun), Eval(bBairro), oEspec:Refresh()}

LOCAL oMun
LOCAL aMun     := {__cTextoAll}
LOCAL cMun     := __cTextoAll
LOCAL bMun     := { || aMun := PLSLISMUN(cCodOpe,Subs(cEspec,1,7),cEstado,""), oMun:aItems := aClone(aMun), cMun := aMun[1], Eval(bBairro), oMun:Refresh()  }

LOCAL oBairro
LOCAL aBairro  := {__cTextoAll}
LOCAL cBairro  := __cTextoAll
LOCAL bBairro  := { || aBairro := PLSLISBAI(cCodOpe,Subs(cEspec,1,7),cEstado,Subs(cMun,1,7)), oBairro:aItems := aClone(aBairro), cBairro := aBairro[1], oBairro:Refresh() }

LOCAL oRDA
LOCAL aRDA     := {}
LOCAL cRDA     := ""         
LOCAL bRDA     := { || aRDA := PLSLISRDA(cCodOpe,Subs(cEspec,1,7),cEstado,Subs(cMun,1,7),cBairro), oRDA:aItems := aClone(aRDA), cRDA := aRda[1], oRDA:Refresh() }

DEFAULT cProduto := ""
DEFAULT cVersao  := ""
DEFAULT lFiltRDA := .F.

DEFINE FONT oFontePLS NAME "Courier New" SIZE 000,-010

cCodOpe  := PLSINTPAD()

aEstado  := PLSLISEST(cCodOpe)
cEstado  := aEstado[1]

DEFINE MSDIALOG oDlg TITLE STR0023 FROM 008.2,010.3 TO 031.5,100.3  //"Consultar Rede de Atendimento (Rdas)"

TGroup():New(030,012,170,177,STR0024,, , ,.T.)  //"Parametros de Pesquisa"
TGroup():New(030,181,170,347,STR0025,, , ,.T.)  //"Rede(s) de Atendimento(s)"

@ 038,020 SAY oSay PROMPT STR0026  SIZE 220,010 OF oDlg PIXEL  //"Estado(s)"
@ 048,020 COMBOBOX oEstado  Var cEstado ITEMS aEstado  SIZE 050,010 OF oDlg PIXEL 

@ 063,020 SAY oSay PROMPT STR0027  SIZE 220,010 OF oDlg PIXEL  //"Especialidade(s)"
@ 073,020 COMBOBOX oEspec   Var cEspec  ITEMS aEspec   SIZE 150,010 OF oDlg PIXEL 
oEspec:bGotFocus := bEsp

@ 088,020 SAY oSay PROMPT STR0028  SIZE 220,010 OF oDlg PIXEL  //"Muncipio(s)"
@ 098,020 COMBOBOX oMun     Var cMun    ITEMS aMun     SIZE 150,010 OF oDlg PIXEL 
oMun:bGotFocus := bMun

@ 113,020 SAY oSay PROMPT STR0029  SIZE 220,010 OF oDlg PIXEL  //"Bairro(s)"
@ 123,020 COMBOBOX oBairro  Var cBairro ITEMS aBairro  SIZE 150,010 OF oDlg PIXEL 
oBairro:bGotFocus := bBairro

@ 153,020 BUTTON STR0030 ACTION Eval( { || aRdas := PLSLISRDA(cCodOpe,Subs(cEspec,1,3),cEstado,Subs(cMun,1,7),cBairro, cProduto, cVersao, lFiltRDA), PintaRDA(aRdas,oMemo,cBairro,cCodOpe,@cMemo) }) SIZE 45, 11 OF oDlg PIXEL //"&Consultar Rdas"

@ 040,190 GET oMemo  VAR cMemo MEMO SIZE 145,120 OF oDlg PIXEL FONT oFontePLS
oMemo:lReadOnly := .T.

ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,{}) Center

Return


Static Function PintaRDA(aRdas,oDlg,cBairro,cCodOpe,cMemo)
LOCAL nFor
LOCAL cCodRda  
LOCAL cCodLoc
LOCAL cCodEsp
Local aCab := {STR0031,STR0032,STR0033,STR0034,STR0035,STR0036,STR0037,STR0038,STR0039} //"Codigo da RDA  : "###"Nome da RDA    : "###"Local de Atend.: "###"Endereco       : "###"Bairro         : "###"Municipio      : "###"Estado         : "###"Telefone       : "###"Especialidade  : "
Local aIte := {"BAU->BAU_CODIGO","AllTrim(BAU->BAU_NOME)","BB8->BB8_CODLOC+'-'+AllTrim(BB8->BB8_DESLOC)","ALLTRIM(BB8->BB8_END)+SPACE(02)+AllTrim(BB8->BB8_NR_END)","BB8->BB8_BAIRRO","BB8->BB8_MUN","BB8->BB8_EST","BB8->BB8_TEL","AllTrim(BAQ->BAQ_DESCRI)"}
Local nJ
LOCAL nSize
LOCAL nSpace

cMemo := ""

For nFor := 1 To Len(aRdas)
    cCodRda := aRdas[nFor,1]
    cCodLoc := aRdas[nFor,3]
    cCodEsp := aRdas[nFor,4]

    BAU->(DbSetOrder(1))                                                                                                      
    BAU->(MsSeek(xFilial("BAU")+cCodRDA))
    
    BB8->(DbSetOrder(1))
    BB8->(MsSeek(xFilial("BB8")+cCodRda+cCodOpe+cCodLoc))
    
    BAX->(DbSetOrder(1))
    BAX->(MsSeek(xFilial("BAX")+cCodRda+cCodOpe+cCodLoc+cCodEsp))
    
    BAQ->(DbSetOrder(1))
    BAQ->(MsSeek(xFilial("BAQ")+cCodOpe+cCodEsp))
    
    For nJ := 1 to Len(aCab)
       cMemo += aCab[nJ]
       
       nSize := Len(aCab[nJ])
       nSpace:= 17-nSize
       
       cMemo += Space(nSpace)
       cMemo += &(aIte[nJ])
       cMemo += chr(13)+chr(10)
    Next
    
    If nFor+1 <= Len(aRdas)
       cMemo   += ""+Replicate("-",49)+chr(13)+chr(10)
    Endif   

Next

oDlg:Refresh()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Objeto     ³ PLSALTUEVE ³ Autor ³ Tulio Cesar          ³ Data ³ 09.09.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o  ³ Alteracao de usuarios de intercambio eventual.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Advanced Protheus                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³             ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSALTUEVE()
LOCAL cGrpEmpInt  := GetNewPar("MV_PLSGEIN","0050")
LOCAL cCodOpe     := PLSINTPAD()
PRIVATE cCadastro := Fundesc() //"Alteracao de Dados de Usuarios de Intercambio Eventual"
PRIVATE aRotina   := {  { STR0041      ,'AxPesqui'    , 0 , K_Pesquisar  },; //"Pesquisar"
                        { STR0042      ,'AxVisual'    , 0 , K_Visualizar },; //"Visualizar"
                        { STR0044      ,'PLSA066'     , 0 , K_Incluir    },; //"Incluir"
                        { STR0043      ,'PLSALTUEVA'  , 0 , K_Alterar    }}  //"Alterar"

DbSelectArea("BA1")
cFiltro := "@BA1_CODINT = '"+cCodOpe+"' AND BA1_CODEMP = '"+cGrpEmpInt+"' AND D_E_L_E_T_ = ' '"
SET FILTER TO &cFiltro
BA1->(mBrowse(06,01,22,75,"BA1",nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,.T.,nil))

Return

Function PLSALTUEVA
Local I__f := 0
LOCAL oDlg
LOCAL aCamposEdt := {}
LOCAL aCampos    := {}
LOCAL oEnchoice       
LOCAL cTitulo    := STR0040 //"Alteracao de Dados de Usuarios de Intercambio Eventual"
LOCAL bOK        := { || nOpca := 1, oDlg:End() }
LOCAL bCancel    := { || nOpca := 1, oDlg:End() }
LOCAL nOpca      := 0
Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := {}
Local aInfo     := {}
PRIVATE Inclui  
PRIVATE lJuridico
PRIVATE lPrim260 := .F.
PRIVATE aRotina  := {	{	STR0041 , '' , 0 ,K_Pesquisar  },; //"Pesquisar"
                        { 	STR0042, '' , 0 ,K_Visualizar },; //"Visualizar"
         				{ 	STR0044 	, '' , 0 ,K_Incluir    },; //"Incluir"
						{ 	STR0043	, '' , 0 ,K_Alterar    },; //"Alterar"
						{ 	STR0045	, '' , 0 ,K_Excluir    }}  //"Excluir"

//aCamposEdt := {"BA1_DATNAS","BA1_DATINC"}
//aCampos    := {"BA1_DATNAS","BA1_DATINC","BA1_NOMUSR"}

aCamposEdt := nil
aCampos    := nil

BA3->(DbSetOrder(1))
BA3->(MsSeek(xFilial()+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))

Inclui := .F.

If !Empty(BA3->BA3_CONEMP)
   lJuridico := .T.
   BQC->(DbSetOrder(1))
   BQC->(MsSeek(xFilial("BQC")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB)))
Else
   lJuridico := .F.
Endif   

Copy "BA1" TO MEMORY
Copy "BA3" TO MEMORY

aSize := MsAdvSize()
aObjects := {}       
AAdd( aObjects, { 1,  1, .T., .T., .F. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

DEFINE MSDIALOG oDlg TITLE cTitulo FROM aSize[7],0 To aSize[6],aSize[5] OF GetWndDefault() Pixel

oEnchice := MSMGet():New("BA1",BA1->(Recno()),K_Alterar,,,,aCampos,aPosObj[1],aCamposEdt,,,,,oDlg,,,.F.)

ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCancel)

If nOpca == K_OK
   PLUPTENC("BA1",K_Alterar)
Endif

Return

/*/{Protheus.doc} PLSUSRINTE
Retorna se um usuario estava ou esta internado em um periodo
@type function
@author TOTVS
@since 21/03/2012
@version 1.0
/*/
function PLSUSRINTE(cMatricUsr,dDataAnalise,cHorPro,lCampos,lConFor,cAlias,lRetCamp,lNerRes,lHorPro,cNumGui,cNumSen,lNaoAuto)
local aArea 	:= getArea()
local xInternado:= .f.                    
local cSQL      := ""                
local cOpeUsr 	:= ""
local cCodEmp 	:= ""
local cMatric 	:= ""
local cTipReg	:= ""     
local aRetCam	:= {}
local cNumguiInt:= ""
local cTipGui	:= ""
local lGuiInt   := .F.

default cHorPro := ""
default lCampos := .f.
default lConFor := .f.
default cAlias  := ""
default lRetCamp:= .f. // retorna o array com os conteudos do campos mesmo que seja regfor = 1 para não oacionar error.log
default lNerRes := .f.
default lHorPro := .t.
default cNumGui := ""
default cNumSen := ""
default lNaoAuto:= .F.

cTipGui := iif(empty(cAlias),"", BD6->BD6_TIPGUI)

if empty(dDataAnalise)
   dDataAnalise := dDataBase
endIf   

cOpeUsr := subs(cMatricUsr,atCodOpe[1],atCodOpe[2])
cCodEmp := subs(cMatricUsr,atCodEmp[1],atCodEmp[2])
cMatric := subs(cMatricUsr,atMatric[1],atMatric[2])
cTipReg := subs(cMatricUsr,atTipReg[1],atTipReg[2])

if existBlock("PLSUSRIN")

   xInternado := execBlock("PLSUSRIN",.F.,.F.,{cTipGui,cMatricUsr,dDataAnalise,cHorPro,lCampos,lConFor,cAlias,cOpeUsr,cCodEmp,cMatric,cTipReg})
   
   If valType(xInternado) == "A" .AND. Len(xInternado) >= 7
   		aRetCam := aClone(xInternado)
	elseif valType(xInternado) == "L"
		aRetCam := { xInternado,"","","","","","" }
	else
		aRetCam := { .F.,"","","","","","" }
	endIf
	
   return(aRetCam)
   
endIf	  

if !empty(cAlias) .and. &( cAlias + "->(fieldPos('" + cAlias + "_REGFOR' ) ) " ) > 0
	
	if ! empty( &( cAlias + "->" + cAlias + "_REGFOR" ) )
	
		if lRetCamp
		
			If cAlias == "BD5"
				cNumguiInt := BD5->BD5_GUIINT
			elseIf cAlias == "BE4"
				cNumguiInt := BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)
			EndIf
			
			aRetCam := {.t., (cAlias)->&( cAlias + "_CODOPE" ), (cAlias)->&( cAlias + "_CODLDP" ), (cAlias)->&( cAlias + "_CODPEG" ),;
							 (cAlias)->&( cAlias + "_NUMERO" ), (cAlias)->&( cAlias + "_PADINT" ),;
							 cNumguiInt }
							 
		else	
			
			aRetCam := { ( &(cAlias+"->"+cAlias+"_REGFOR") == "1" ), (cAlias)->&( cAlias + "_CODOPE" ), (cAlias)->&( cAlias + "_CODLDP" ), (cAlias)->&( cAlias + "_CODPEG" ),;
						 (cAlias)->&( cAlias + "_NUMERO" ), (cAlias)->&( cAlias + "_PADINT" ),;
						 cNumguiInt }

		endIf
		
		return(aRetCam)
			
	endIf
	
endIf
	
If lConFor 

	If !empty(cAlias) .and. &(cAlias+"->(FieldPos('"+cAlias+"_REGATE'))") > 0
	 	
		if ! empty( &(cAlias+"->"+cAlias+"_REGATE") )
			
			If cAlias == "BD5"
				cNumguiInt := BD5->BD5_GUIINT
			elseIf cAlias == "BE4"
				cNumguiInt := BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)
			EndIf
						
			aRetCam := { ( &(cAlias+"->"+cAlias+"_REGATE") == "1" ), (cAlias)->&( cAlias + "_CODOPE" ), (cAlias)->&( cAlias + "_CODLDP" ), (cAlias)->&( cAlias + "_CODPEG" ),;
						 (cAlias)->&( cAlias + "_NUMERO" ), (cAlias)->&( cAlias + "_PADINT" ),;
						 cNumguiInt }
			
			return(aRetCam)	
			
		endIf
				
	endIf
	
endIf

if(!empty(allTrim(cNumGui)))
	BE4->(dbSetOrder(2))
	if BE4->( msSeek( xFilial("BE4") + cNumGui ))
		cNumguiInt := BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO)
		lGuiInt := .T.
	endif
elseif (!Empty(AllTrim(cNumSen)))
	BE4->(dbSetOrder(7))
	if BE4->( msSeek( xFilial("BE4") + cNumSen ))
		cNumguiInt := BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO)
		lGuiInt := .T.
	endif
endif

if empty(allTrim(cHorPro)) .and. lHorPro
	cHorPro := time()
endIf

//Caso for informada, a consulta deve considerar a Hora
if ! empty(cHorPro) .and. lHorPro
	cHorPro := strTran(cHorPro,":","")
endIf

cSQL := " SELECT BE4_DATPRO, BE4_HORPRO, BE4_DTALTA, BE4_HRALTA, "
cSQL += "        BE4_CODOPE, BE4_CODLDP, BE4_CODPEG, BE4_NUMERO, BE4_PADINT, BE4_CODOPE, BE4_ANOINT, BE4_MESINT, BE4_NUMINT "  
cSQL += "   FROM " + retSQLName("BE4")
cSQL += "  WHERE BE4_FILIAL = '" + xFilial("BE4") + "' "
cSQL += "    AND BE4_OPEUSR = '" + cOpeUsr + "' "
cSQL += "    AND BE4_CODEMP = '" + cCodEmp + "' "
cSQL += "    AND BE4_MATRIC = '" + cMatric + "'"
cSQL += "    AND BE4_TIPREG = '" + cTipReg + "' "
cSQL += "    AND BE4_TIPGUI = '03' "
cSQL += "    AND BE4_CANCEL <> '1' "
cSQL += "    AND BE4_SITUAC <> '2' "
cSQL += "    AND BE4_DATPRO <> '        ' "

if lNaoAuto
	cSQL += "    AND BE4_STATUS <> '3' "
EndIf

if lHorPro
	cSQL += "    AND BE4_DATPRO" + cconcateZ + "BE4_HORPRO <= '" + dtos(dDataAnalise) + cHorPro + "' "
	cSQL += "    AND ( BE4_DTALTA" + cconcateZ + "BE4_HRALTA >= '" + dtos(dDataAnalise) + cHorPro + "' OR BE4_DTALTA = '        ' )"
else
	cSQL += "    AND BE4_DATPRO <= '" + dtos(dDataAnalise) + "' "
	cSQL += "    AND ( BE4_DTALTA >= '" + dtos(dDataAnalise) + "' OR BE4_DTALTA = '        ' )"
endif
cSQL += "    AND D_E_L_E_T_ = ' ' "

if !lNerRes
	cSQL += "    AND ( EXISTS ( SELECT R_E_C_N_O_ "
	cSQL += "                       FROM " + retSQLName("BE4")
	cSQL += "                      WHERE BE4_FILIAL = '" + xFilial("BE4") + "' "
	cSQL += "                        AND BE4_OPEUSR = '" + cOpeUsr + "' "
	cSQL += "                        AND BE4_CODEMP = '" + cCodEmp + "' "
	cSQL += "                        AND BE4_MATRIC = '" + cMatric + "'"
	cSQL += "                        AND BE4_TIPREG = '" + cTipReg + "' "
	cSQL += "                        AND BE4_TIPGUI = '05' "
	cSQL += "                        AND BE4_CANCEL <> '1' "
	cSQL += "                        AND BE4_SITUAC <> '2' "
	cSQL += "                        AND BE4_TIPFAT IN ('4','T') "
	cSQL += "                        AND ( BE4_DTALTA" + cconcateZ + "BE4_HRALTA = '            ' "
	if lHorPro
		cSQL += "                    OR BE4_DTALTA" + cconcateZ + "BE4_HRALTA >= '" + dtos(dDataAnalise) + left(cHorPro,4) + "' )"
	else
		cSQL += "                    OR BE4_DTALTA >= '" + dtos(dDataAnalise) + "' )"
	endif
	cSQL += "                        AND D_E_L_E_T_ = ' ' ) "
	cSQL += "    OR NOT EXISTS ( SELECT R_E_C_N_O_ "
	cSQL += "                        FROM " + retSQLName("BE4")
	cSQL += "                        WHERE BE4_FILIAL = '" + xFilial("BE4") + "' "
	cSQL += "                        AND BE4_OPEUSR = '" + cOpeUsr + "' "
	cSQL += "                        AND BE4_CODEMP = '" + cCodEmp + "' "
	cSQL += "                        AND BE4_MATRIC = '" + cMatric + "' "
	cSQL += "                        AND BE4_TIPREG = '" + cTipReg + "' "
	cSQL += "                        AND BE4_TIPGUI = '05' "
	cSQL += "                        AND BE4_CANCEL <> '1' "
	cSQL += "                        AND BE4_SITUAC <> '2' "
	cSQL += "                        AND BE4_TIPFAT IN ('4','T') "
	if lGuiInt
		cSQL += "                    AND BE4_GUIINT = '" + cNumguiInt + "' "
	endif
	cSQL += "                        AND D_E_L_E_T_ = ' ' ) )"
endif

dbUseArea(.T.,"TOPCONN",tcGenQry(,,cSql),"PLSUSRINTE",.F.,.T.)

if ! PLSUSRINTE->(eof())
	 
	xInternado 	:= .t.

    aRetCam := {xInternado, PLSUSRINTE->BE4_CODOPE, PLSUSRINTE->BE4_CODLDP, PLSUSRINTE->BE4_CODPEG, PLSUSRINTE->BE4_NUMERO, PLSUSRINTE->BE4_PADINT, PLSUSRINTE->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)}

else

    aRetCam := { xInternado,"","","","","","" }

endIf    

PLSUSRINTE->(dbCloseArea())

restArea(aArea)

return(aRetCam)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Objeto     ³ PLSGrvIEOL ³ Autor ³ Tulio Cesar          ³ Data ³ 01.10.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o  ³                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Advanced Protheus                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³             ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSGrvIEOL(aCab,aIte,cNumSeq,cOpeSol)
LOCAL nFor                       
LOCAL nInd
LOCAL aAux  
LOCAL cndConteu
LOCAL cType
DEFAULT cOpeSol := PlsIntPad()

   BSA->( DbSetOrder(1) )//BSA_FILIAL + BSA_NUMSEQ + BSA_IDENT
   If !BSA->( MsSeek(xFilial("BSA")+cNumSeq+Space(len(BSA->BSA_NUMSEQ)-len(cNumSeq))+cOpeSol) )
   
   For nFor := 1 To Len(aCab)
       BSA->(RecLock("BSA",.T.))
	       BSA->BSA_FILIAL := xFilial("BSA")
	       BSA->BSA_NUMSEQ := cNumSeq	
	       BSA->BSA_IDENT  := "CAB"
	       BSA->BSA_VARIAV := aCab[nFor,1]
	       cType := ValType(aCab[nFor,2])
	       Do Case
	          Case cType == 'C' 
	          		cndConteu := aCab[nFor,2]
	          Case cType == 'D'
	          		cndConteu := DToC(aCab[nFor,2])
	          Case cType == 'N'
	          		cndConteu := AllTrim(Str(aCab[nFor,2]))
	          Case cType == 'L'
	                Iif(aCab[nFor,2],cndConteu := ".T.",cndConteu := ".F.")		
		   EndCase
		   BSA->BSA_CONTEU := cndConteu
       	   If BSA->(FieldPos("BSA_OPESOL")) > 0 .And. !Empty(cOpeSol)
		       BSA->BSA_OPESOL := cOpeSol	
		   EndIf 		
       BSA->(MsUnLock())
   Next    

   For nFor := 1 To Len(aIte)
       aAux := aClone(aIte[nFor])
       For nInd := 1 To Len(aAux)
           BSA->(RecLock("BSA",.T.))
	           BSA->BSA_FILIAL := xFilial("BSA")
	           BSA->BSA_NUMSEQ := cNumSeq	
	           BSA->BSA_IDENT  := StrZero(nFor,3)
	           BSA->BSA_VARIAV := aAux[nInd,1]
		       cType := ValType(aAux[nInd,2])
		       Do Case
		          Case cType == 'C' 
		          		cndConteu := aAux[nInd,2]
		          Case cType == 'D'
		          		cndConteu := DToC(aAux[nInd,2])
		          Case cType == 'N'
		          		cndConteu := AllTrim(Str(aAux[nInd,2]))
		          Case cType == 'L'
	                    Iif(aAux[nFor,2],cndConteu := ".T.",cndConteu := ".F.")		
			   EndCase
			   BSA->BSA_CONTEU := cndConteu
         	   If BSA->(FieldPos("BSA_OPESOL")) > 0 .And. !Empty(cOpeSol)
		           BSA->BSA_OPESOL := cOpeSol	
 			   EndIf     	
           BSA->(MsUnLock())
       Next    
   Next    
   
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Objeto     ³ PLSVLDNIMP ³ Autor ³ Tulio Cesar          ³ Data ³ 13.01.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o  ³ Valida a existencia de um numero de impresso.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Advanced Protheus                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³             ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVLDNIMP(cNumImp,cCodRda)
LOCAL lRet		:= .T.
LOCAL cSql
LOCAL cOpeMov 
LOCAL cOpeUsr
Local aArea  	:= GetArea()
Local lMatAnt   := GetNewPar("MV_PLVAIMP","0") == "0"
Local nX
Default cCodRda := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para validacao especifica do cliente                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  existblock("PLSVLDIM")
    lRet := execblock("PLSVLDIM",.F.,.F.,{cNumImp,cCodRda})
    Return(lRet)
Endif                     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se nao tiver nenhum dado retorna .T.                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cNumImp)
   Return(.T.)
Endif                     

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se tiver caractere invalido retorna .F.                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len(AllTrim(cNumImp))

	If (!IsAlpha(SubStr(AllTrim(cNumImp),nX,1))) .And. (!IsDigit(SubStr(AllTrim(cNumImp),nX,1)))
		Alert(STR0231 + ': "' + SubStr(AllTrim(cNumImp),nX,1) + '".')
		Return .F.	
	EndIf

Next nX
  
If  ! Empty(BA1->BA1_MATANT)     
    If !lMatAnt
        cOpeUsr := BA1->BA1_CODINT
    Else    
       	If  Len(alltrim(BA1->BA1_MATANT)) < 17
	        cOpeUsr := '0' + Substr(BA1->BA1_MATANT,1,3)
	    Else  
	        cOpeUsr := Substr(BA1->BA1_MATANT,1,4)
	    EndIf  
	EndIf
Else 
	cOpeUsr := BA1->BA1_CODINT
EndIf	      
// nao tirar esse plsintpad daqui. Daher(22/12/2005)        
If Empty(cOpeUsr)
	cOpeUsr := PlsIntPad()   
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida no BD5...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSql := "SELECT BD5_OPEUSR,BD5_MATANT,BD5_SITUAC FROM " + RetSqlName("BD5")
cSql += " WHERE BD5_FILIAL = '" + xFilial("BD5") + "' "
cSql += "   AND BD5_NUMIMP = '" + cNumImp        + "' "
cSql += "   AND D_E_L_E_T_ = ' ' "

dbUseArea(.T.,"TOPCONN",tcGenQry(,,cSql),"TRB1",.F.,.T.)

While ! TRB1->(eof()) 

   If  ! Empty(TRB1->BD5_MATANT)    

       If !lMatAnt
           cOpeMov := TRB1->BD5_OPEUSR
       Else    
  	       If  Len(ALLTRIM(TRB1->BD5_MATANT)) < 17
	    	   cOpeMov := '0' + Substr(TRB1->BD5_MATANT,1,3)
           Else  
               cOpeMov := Substr(TRB1->BD5_MATANT,1,4)
           EndIf  
       EndIf
   Else 
       cOpeMov := TRB1->BD5_OPEUSR
   EndIf	
   If  cOpeMov == cOpeUsr
       If  TRB1->BD5_SITUAC == "2" .AND. lRet //1=Ativa;2=Cancelada;3=Bloqueada
		   lRet := .T.
       Else           
		   lRet := .F.
       EndIf   
   EndIf    
   TRB1->(DbSkip())
EndDo    
TRB1->(dbCloseArea())
RestArea(aArea)
   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida no BE4...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
   cSql := "SELECT BE4_OPEUSR,BE4_MATANT,BE4_SITUAC FROM " + RetSqlName("BE4")
   cSql += " WHERE BE4_FILIAL = '" + xFilial("BE4") + "' "
   cSql += "   AND BE4_NUMIMP = '" + cNumImp        + "' "
   cSql += "   AND D_E_L_E_T_ = ' ' "

   dbUseArea(.T.,"TOPCONN",tcGenQry(,,cSql),"TRB1",.F.,.T.) 

   While ! TRB1->(eof()) 
      If  ! Empty(TRB1->BE4_MATANT)   
          If !lMatAnt
              cOpeMov := TRB1->BE4_OPEUSR
          Else
	  	      If  Len(ALLTRIM(TRB1->BE4_MATANT)) < 17
		          cOpeMov := '0' + Substr(TRB1->BE4_MATANT,1,3)
		      Else  
		    	  cOpeMov := Substr(TRB1->BE4_MATANT,1,4)
		      EndIf  
		  EndIf
	  Else 
	      cOpeMov := TRB1->BE4_OPEUSR
	  EndIf	
      If  cOpeMov == cOpeUsr
	      If  BE4->BE4_SITUAC == "2" .AND. lRet //1=Ativa;2=Cancelada;3=Bloqueada
	          lRet := .T.
	      Else
		      lRet := .F.
		  EndIf			  		     
      EndIf
      TRB1->(DbSkip())
   EndDo    
   TRB1->(dbCloseArea())
   RestArea(aArea)
   
Endif   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida no BEA...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
   cSql := "SELECT BEA_OPEUSR,BEA_MATANT,BEA_NUMIMP FROM " + RetSqlName("BEA")
   cSql += " WHERE BEA_FILIAL = '" + xFilial("BEA") + "' "
   cSql += "   AND BEA_NUMIMP = '" + cNumImp        + "' "
   cSql += "   AND D_E_L_E_T_ = ' ' "
   
   dbUseArea(.T.,"TOPCONN",tcGenQry(,,cSql),"TRB1",.F.,.T.)
   
   While ! TRB1->(eof()) 
      If  ! Empty(TRB1->BEA_MATANT)  
          If !lMatAnt
              cOpeMov := TRB1->BEA_OPEUSR
          Else
		      If  Len(ALLTRIM(TRB1->BEA_MATANT)) < 17
		    	  cOpeMov := '0' + Substr(TRB1->BEA_MATANT,1,3)
              Else  
		 	      cOpeMov := Substr(TRB1->BEA_MATANT,1,4)
    		  EndIf    
		  EndIf
      Else 
		  cOpeMov := TRB1->BEA_OPEUSR
      EndIf	
      If  cOpeMov == cOpeUsr
          lRet := .F.
          Exit
	  EndIf
	  TRB1->(DbSkip())
   EndDo    
   TRB1->(dbCloseArea())
   RestArea(aArea)
   
Endif

If ! lRet
   Help("",1,"EXISTCHAV")
Endif           
   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Objeto     ³ PLSPROXIMP ³ Autor ³ Tulio Cesar          ³ Data ³ 10.03.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o  ³ Retorna proximo numero do impresso.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Advanced Protheus                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³             ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSPROXIMP()
LOCAL cImpresso
LOCAL nOrdBEA := BEA->(IndexOrd())
LOCAL nRecBEA := BEA->(Recno())
LOCAL cFilBEA := xFilial("BEA")
LOCAL nLenNum := Len(BEA->BEA_NUMIMP)

BEA->(DbSetOrder(9))
BEA->(MsSeek(cFilBEA+Replicate("9",nLenNum),.T.))
BEA->(DbSkip(-1))
                                                           
If BEA->(Eof())
   cImpresso := StrZero(1,nLenNum)
Else
   cImpresso := StrZero(Val(BEA->BEA_NUMIMP)+1,nLenNum)
Endif

BEA->(DbSetOrder(nOrdBEA))
BEA->(DbGoTo(nRecBEA))                         

Return(cImpresso)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Objeto     ³ PLSRTCRDAO ³ Autor ³ Tulio Cesar          ³ Data ³ 01.04.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o  ³ Retorna a partir de uma operadora destino seu codigo como RDA ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Advanced Protheus                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³             ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSRTCRDAO(cOpeDes,cCodProf)
LOCAL cMsg    	 := ""
LOCAL cCodRda 	 := ""
LOCAL cCodLoc 	 := ""
LOCAL cCodEsp 	 := ""
LOCAL cCodSol 	 := ""
LOCAL cTipPre  	 := ""
LOCAL cTipRda 	 := ""
LOCAL lOK     	 := .F.
LOCAL bRet    	 := { || {lOK,cMsg,cCodRda,cCodLoc,cCodEsp,cCodSol,cTipPre,cTipRda} }
DEFAULT cCodProf := "999999"

BAU->( DbSetOrder(7) )//BAU_FILIAL + BAU_CODOPE
If BAU->( MsSeek(xFilial("BAU")+cOpeDes) )
   cCodRda := BAU->BAU_CODIGO
   cTipPre := BAU->BAU_TIPPRE 
   cTipRda := BAU->BAU_TIPPE
   BB8->( DbSetOrder(1) )//BB8_FILIAL + BB8_CODIGO + BB8_CODINT + BB8_CODLOC + BB8_LOCAL
   If BB8->( MsSeek(xFilial("BB8")+BAU->BAU_CODIGO) )
      cCodLoc := BB8->BB8_CODLOC
      BAX->( DbSetOrder(1) )//BAX_FILIAL + BAX_CODIGO + BAX_CODINT + BAX_CODLOC + BAX_CODESP + BAX_CODSUB
      If BAX->( MsSeek(xFilial("BAX")+BAU->BAU_CODIGO+BB8->BB8_CODINT+BB8->BB8_CODLOC) )
         cCodEsp := BAX->BAX_CODESP
         
	     BB0->( DbSetOrder(5) ) //BB0_FILIAL + BB0_CODORI
         If !Empty(cCodProf) .And. Val(cCodProf) <> 0
	         If BB0->( MsSeek(xFilial("BB0")+cCodProf) )
	            lOK     := .T.
	         	cCodSol := BB0->BB0_CODIGO
	         EndIf	
		 EndIf 
	         
         If !lOK 
         		If BB0->( MsSeek(xFilial("BB0")+cOpeDes+"999999") )
	            lOK     := .T.
         		  cCodSol := BB0->BB0_CODIGO
              Else                                                                     
                 cMsg := STR0046+cOpeDes+STR0047 //"Unimed Destino ["###"] sem solicitante padrao cadastrado."
         	   EndIf
         EndIf	 
      Else                                                                                
         cMsg := STR0046+cOpeDes+STR0049 //"Unimed Destino ["###"] cadastrada como RDA sem especialidade."
      Endif   
   Else
      cMsg := STR0046+cOpeDes+STR0050 //"Unimed Destino ["###"] cadastrada como RDA sem local de atendimento."
   Endif      
Else
   cMsg    := STR0046+cOpeDes+STR0051 //"Unimed Destino ["###"] nao cadastrada como RDA."
Endif   
   
Return(Eval(bRet))

Function PLSGTESPP(cCodRda)
LOCAL nOrdBBF := BBF->(IndexOrd())
LOCAL nRecBBF := BBF->(Recno())
LOCAL nOrdBAQ := BAQ->(IndexOrd())
LOCAL nRecBAQ := BAQ->(Recno())
LOCAL cCodEsp := ""
LOCAL cNomEsp := ""

BBF->(DbSetOrder(1))
If BBF->(DbSeek(xFilial("BBF")+cCodRda))
   cCodEsp := BBF->BBF_CDESP
   BAQ->(DbSetOrder(1))
   If BAQ->(DbSeek(xFilial("BAQ")+PLSINTPAD()+cCodEsp))
      cNomEsp := BAQ->BAQ_DESCRI
   Endif   
Endif          

BBF->(DbSetOrder(nOrdBBF))
BBF->(DbGoTo(nRecBBF))

BAQ->(DbSetOrder(nOrdBAQ))
BAQ->(DbGoTo(nRecBAQ))

Return({cCodEsp,cNomEsp})


Function PLSPosGOpe(cGruOpe,dDatPro)
LOCAL lRet := .F.
BGH->(DbSetOrder(1))
If BGH->(MsSeek(xFilial("BGH")+cGruOpe))
   While ! BGH->(Eof()) .And. BGH->(BGH_FILIAL+BGH_GRUOPE) == xFilial("BGH")+cGruOpe
   
         If ( dtos(dDatPro) >= dtos(BGH->BGH_DATINI) ) .And. ;
            ( dtos(dDatPro) <= dtos(BGH->BGH_DATFIN) .Or. Empty(BGH->BGH_DATFIN) )
            lRet := .T.
            Exit
         Endif
               
   BGH->(DbSkip())
   Enddo
Endif                                   
Return(lRet)


Function PLSEXCPEG(bBlock)
LOCAL cAliasPri
LOCAL cSQL                
LOCAL cChaveGuia   
LOCAL lExcPEG := .T.
Local aArea := GetArea()
DEFAULT bBlock := { || .T. }

If BCI->BCI_FASE == "4" 
   Return
Endif   

BCL->(DbSetOrder(1))
BCL->(MsSeek(xFilial("BCL")+BCI->(BCI_CODOPE+BCI_TIPGUI)))
cAliasPri := BCL->BCL_ALIAS

cSQL := "SELECT R_E_C_N_O_ AS REG FROM "+RetSQLName(cAliasPri)+" WHERE "
cSQL += cAliasPri+"_FILIAL = '"+xFilial(cAliasPri)+"' AND "
cSQL += cAliasPri+"_CODOPE = '"+BCI->BCI_CODOPE+"' AND "
cSQL += cAliasPri+"_CODLDP = '"+BCI->BCI_CODLDP+"' AND "
cSQL += cAliasPri+"_CODPEG = '"+BCI->BCI_CODPEG+"' AND "
cSQL += "D_E_L_E_T_ = ' ' "
cSQL += "ORDER BY "+cAliasPri+"_FILIAL, "+cAliasPri+"_CODOPE, "+cAliasPri+"_CODLDP, "+cAliasPri+"_CODPEG, "+cAliasPri+"_FASE"
       
dbUseArea(.T.,"TOPCONN",tcGenQry(,,cSql),"TrbFase",.F.,.T.)

While ! TrbFase->(Eof())

      DbSelectArea(cAliasPri)
      DbGoTo(TrbFase->REG)
      
      If ! Empty(bBlock)
         If ! Eval(bBlock)
            TrbFase->(DbSkip())
            lExcPEG := .F.
            Loop
         Endif
      Endif      
      
      cChaveGuia := &(cAliasPri+"->"+cAliasPri+"_CODOPE")+&(cAliasPri+"->"+cAliasPri+"_CODLDP")+;
                    &(cAliasPri+"->"+cAliasPri+"_CODPEG")+&(cAliasPri+"->"+cAliasPri+"_NUMERO")+&(cAliasPri+"->"+cAliasPri+"_ORIMOV")
                    
      BD6->(DbSetOrder(1))
      While BD6->(DbSeek(xFilial("BD6")+cChaveGuia))
            BD6->(RecLock("BD6",.F.))
            BD6->(DbDelete())
            BD6->(MsUnLock())
      Enddo      
          
      BD7->(DbSetOrder(1))
      While BD7->(DbSeek(xFilial("BD7")+cChaveGuia))
            BD7->(RecLock("BD7",.F.))
            BD7->(DbDelete())
            BD7->(MsUnLock())
      Enddo      

      BDU->(DbSetOrder(2))                                                                               	
      While BDU->(MsSeek(xFilial("BDU")+cChaveGuia))
            BDU->(RecLock("BDU",.F.))
            BDU->(DbDelete())
            BDU->(MsUnLock())
      Enddo
       
      BDX->(DbSetOrder(3))                   
      While BDX->(MsSeek(xFilial("BDX")+cChaveGuia))
            BDX->(RecLock("BDX",.F.))
            BDX->(DbDelete())
            BDX->(MsUnLock())
      Enddo
      
      &(cAliasPri)->(RecLock(cAliasPri,.F.))
      &(cAliasPri)->(DbDelete())
      &(cAliasPri)->(MsUnLock())

TrbFase->(DbSkip())
Enddo    

TrbFase->(DbCloseArea())
RestArea(aArea)

If lExcPEG
   BCI->(RecLock("BCI",.F.))
   BCI->(DbDelete())
   BCI->(MsUnLock())
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Objeto     ³ PLSRTCCOMP ³ Autor ³ Tulio Cesar          ³ Data ³ 09.05.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o  ³ Retorna a camera de compensacao padrao EDI de uma operadora   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Advanced Protheus                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³             ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSRTCCOMP(cOpeOri)
LOCAL nOrdBA0    := BA0->(IndexOrd())
LOCAL nRecBA0    := BA0->(Recno())
LOCAL nOrdBA2    := BA2->(IndexOrd())
LOCAL nRecBA2    := BA2->(Recno())
LOCAL cCamComCad := Space(03)
LOCAL cCamComEDI := Space(03)

BA0->(DbSetOrder(1))
If BA0->(DbSeek(xFilial("BA0")+cOpeOri))
   If     BA0->(FieldPos("BA0_CAMCOM")) > 0 .And. ! Empty(BA0->BA0_CAMCOM)
          cCamComCad := BA0->BA0_CAMCOM
   ElseIf ! Empty(BA0->BA0_GRUOPE) 
          BA2->(DbSetOrder(1))    
          If BA2->(DbSeek(xFilial("BA2")+BA0->BA0_GRUOPE)) .And. BA2->(FieldPos("BA2_CAMCOM")) > 0 .And. ! Empty(BA2->BA2_CAMCOM)
             cCamComCad := BA2->BA2_CAMCOM
          Endif
   Endif   
Endif

If ! Empty(cCamComCad)
   BUO->(DbSetOrder(1))
   If BUO->(DbSeek(xFilial("BUO")+cCamComCad)) .And. BUO->(FieldPos("BUO_CODEDI")) > 0 .And. ! Empty(BUO->BUO_CODEDI)
      cCamComEDI := BUO->BUO_CODEDI
   Endif
Endif

BA0->(DbSetOrder(nOrdBA0))
BA0->(DbGoTo(nRecBA0))
BA2->(DbSetOrder(nOrdBA2))
BA2->(DbGoTo(nRecBA2))

Return(cCamComEDI)

/*/{Protheus.doc} PLSNOTXBDH
Atualiza dados da nota a partir de um determinado BDH
O BDH DEVE ESTAR POSICIONADO!!!
@author  PLS TEAM
@version P12
@since   12.10.2005
/*/
function PLSNOTXBDH(cStatus,cOpeFat,cNumFat,aNumSE1,lInterc,lAtuBDH,cTipCob,nPosIntTit)

Local aAreaBD6 :=  BD6->(GetArea())
Local aAreaBD5 :=  BD5->(GetArea())
Local aAreaBE4 :=  BE4->(GetArea())
Local aAreaBEA :=  BEA->(GetArea())

local aCabUpt 	 := {}
local nPos		 := 0
local nFor		 := 0
local cPrefixo	 := aNumSe1[1]
local cTitulo	 := aNumSe1[2]
local cParcela	 := aNumSe1[3]
local cTipoTit	 := aNumSe1[4]
local cKeyBDH 	 := ""
local cKeyBD6 	 := ""
local cUpStatem	 := ""
local cBanco	 := allTrim( TCGetDB() )
local nOrdem	 := 12
local lFieldsNDC := BD6->(fieldPos("BD6_PRENDC")) > 0 .and. BD6->(fieldPos("BD6_NUMNDC")) > 0  .and.; 
					BD6->(fieldPos("BD6_TIPNDC")) > 0 .and. BD6->(fieldPos("BD6_PARNDC")) > 0  .and.; 
					BD5->(fieldPos("BD5_PRENDC")) > 0 .and. BD5->(fieldPos("BD5_NUMNDC")) > 0  .and.; 
					BD5->(fieldPos("BD5_TIPNDC")) > 0 .and. BD5->(fieldPos("BD5_PARNDC")) > 0  .and.;
					BE4->(fieldPos("BE4_PRENDC")) > 0 .and. BE4->(fieldPos("BE4_NUMNDC")) > 0  .and.; 
					BE4->(fieldPos("BE4_TIPNDC")) > 0 .and. BE4->(fieldPos("BE4_PARNDC")) > 0  .and.; 
					BDH->(fieldPos("BDH_PRENDC")) > 0 .and. BDH->(fieldPos("BDH_NUMNDC")) > 0  .and.; 
					BDH->(fieldPos("BDH_TIPNDC")) > 0 .and. BDH->(fieldPos("BDH_PARNDC")) > 0  .and.;
					BEA->(fieldPos("BEA_PRENDC")) > 0 .and. BEA->(fieldPos("BEA_NUMNDC")) > 0  .and.; 
					BEA->(fieldPos("BEA_TIPNDC")) > 0 .and. BEA->(fieldPos("BEA_PARNDC")) > 0 

default lAtuBDH 	:= .t.
default cTipCob 	:= ''
default nPosIntTit 	:= 0

if lAtuBDH

	BDH->(recLock("BDH", .f.))
		BDH->BDH_STATUS := cStatus
		BDH->BDH_OPEFAT := cOpeFat
		BDH->BDH_NUMFAT := cNumFat

		if ((cTipCob == '3' .And. nPosIntTit == 1) .Or. (cTipCob == '1'))  .And. lFieldsNDC
			BDH->BDH_PRENDC := cPrefixo
			BDH->BDH_NUMNDC := cTitulo
			BDH->BDH_PARNDC := cParcela
			BDH->BDH_TIPNDC := cTipoTit     
		else
			BDH->BDH_PREFIX := cPrefixo
			BDH->BDH_NUMTIT := cTitulo
			BDH->BDH_PARCEL := cParcela
			BDH->BDH_TIPTIT := cTipoTit  
		endIf	
	BDH->(msUnLock())

endIf

//Atualiza dados de todos os BD6s relacionados a este BDH... (inclusive seu cabecalho que pode ser BD5 ou BE4) 
SIX->( dbSetorder(01) )
if cPaisLOC <> "BRA" .And. SIX->( dbSeek("BD6L") )
	cKeyBDH := BDH->(BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG+BDH_ANOFT+BDH_MESFT+BDH_LANCF+BDH_SEQPF)
	cKeyBD6 := "BD6->(BD6_FILIAL+BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG+BD6_ANOPAG+BD6_MESPAG+BD6_LANCF+BD6_SEQPF)" 
	nOrdem  := 21 
else
	cKeyBDH := BDH->(BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG+BDH_ANOFT+BDH_MESFT+BDH_SEQPF)
	cKeyBD6 := "BD6->(BD6_FILIAL+BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG+BD6_ANOPAG+BD6_MESPAG+BD6_SEQPF)"
	nOrdem  := 12
endIf

BD6->( dbSetOrder(nOrdem) )
if BD6->( msSeek( xFilial("BD6") + cKeyBDH ) )

	while ! BD6->( eof() ) .and. &cKeyBD6 == xFilial("BD6") + cKeyBDH .and. BD6->BD6_SITUAC <> "3"
		
		BD6->(recLock("BD6", .f.))
			BD6->BD6_STAFAT := cStatus
			BD6->BD6_OPEFAT := cOpeFat
			BD6->BD6_NUMFAT := cNumFat
			
			if (( cTipCob == '3' .and. nPosIntTit == 1 ) .or. (cTipCob == '1'))  .and. lFieldsNDC  
				
				BD6->BD6_PRENDC := cPrefixo
				BD6->BD6_NUMNDC := cTitulo
				BD6->BD6_PARNDC := cParcela
				BD6->BD6_TIPNDC := cTipoTit

			else	
				
				BD6->BD6_PREFIX := cPrefixo
				BD6->BD6_NUMTIT := cTitulo
				BD6->BD6_PARCEL := cParcela
				BD6->BD6_TIPTIT := cTipoTit

			endIf	
		BD6->( msUnLock() )

		//verificar se a guia tem lote de aviso e atualiza o lote de intercambio(titulo) e o valor cobrado
		PLSBDHB6S( BD6->( BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO + BD6_SEQUEN), cPrefixo, cTitulo, cParcela, cTipoTit)

		nPos := aScan(aCabUpt,{|x| x[1] == BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV)})
		
		if nPos == 0
			AaDd(aCabUpt,{BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV),BD6->BD6_ORIMOV,BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)})
		endIf

		cUpStatem := " UPDATE " + RetSQLName("BEA")
		
		if ((cTipCob == '3' .and. nPosIntTit == 1) .or. (cTipCob == '1'))  .and. lFieldsNDC 
			cUpStatem += " SET	BEA_PRENDC = '" + cPrefixo	+ "',"
			cUpStatem += "		BEA_NUMNDC = '" + cTitulo 	+ "',"
			cUpStatem += "		BEA_PARNDC = '" + cParcela	+ "',"
			cUpStatem += "		BEA_TIPNDC = '" + cTipoTit	+ "'"  
		else 
			cUpStatem += " SET	BEA_PREFIX = '" + cPrefixo	+ "',"
			cUpStatem += "		BEA_NUMTIT = '" + cTitulo 	+ "',"
			cUpStatem += "		BEA_PARCEL = '" + cParcela	+ "',"
			cUpStatem += "		BEA_TIPTIT = '" + cTipoTit	+ "'"  
		endIf	
		
		cUpStatem += " WHERE BEA_FILIAL = '" + xFilial("BEA")  + "' And "
		cUpStatem += "       BEA_OPEUSR = '" + BD6->BD6_OPEUSR + "' And "
		cUpStatem += "       BEA_CODEMP = '" + BD6->BD6_CODEMP + "' And "
		cUpStatem += "       BEA_MATRIC = '" + BD6->BD6_MATRIC + "' And "
		cUpStatem += "       BEA_TIPREG = '" + BD6->BD6_TIPREG + "' And "
		cUpStatem += "       BEA_ANOAUT = '" + BD6->BD6_ANOPAG + "' And "
		cUpStatem += "       BEA_MESAUT = '" + BD6->BD6_MESPAG + "' And "
		cUpStatem += "       BEA_NUMGUI = '" + BD6->BD6_NUMERO + "' And "
		cUpStatem += "       BEA_DATPRO = '" + DTOS(BD6->BD6_DATPRO) + "' And "
		cUpStatem += "       BEA_HORPRO = '" + BD6->BD6_HORPRO + "' And "
		cUpStatem += "       D_E_L_E_T_ = ' ' "
		
		if TCSQLExec(cUpStatem) < 0
    		FWLogMsg('ERROR',, 'SIGAPLS', funName(), '', '01', "TCSQLError() " + TCSQLError() , 0, 0, {})
		elseIf cBanco == "ORACLE"
			TCSQLExec("COMMIT")
		endIf
		
		BD6->(DbSkip())

	endDo

endif

//Atualiza os cabecalhos...                                                                                    ³
for nFor := 1 to Len(aCabUpt)
	
	//Guia de consulta ou servico ou sejas BD5
	if aCabUpt[nFor,2] == "1" 

		BD5->( dbSetOrder(1) )
		If BD5->( msSeek( xFilial("BD5") + aCabUpt[nFor,3] ) )

			BD5->(recLock("BD5",.F.))
				BD5->BD5_STAFAT := cStatus
				BD5->BD5_OPEFAT := cOpeFat
				BD5->BD5_NUMFAT := cNumFat

				if (( cTipCob == '3' .and. nPosIntTit == 1) .or. (cTipCob == '1'))  .and. lFieldsNDC  
					BD5->BD5_PRENDC := cPrefixo
					BD5->BD5_NUMNDC := cTitulo
					BD5->BD5_PARNDC := cParcela
					BD5->BD5_TIPNDC := cTipoTit
				else
					BD5->BD5_PREFIX := cPrefixo
					BD5->BD5_NUMTIT := cTitulo
					BD5->BD5_PARCEL := cParcela
					BD5->BD5_TIPTIT := cTipoTit
				endIf
			BD5->(MsUnLock())

		else
			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "PLSNOTXBDH - "+STR0175+" ["+aCabUpt[nFor,1]+"]" , 0, 0, {})//"Falha ao localizar cabecalho da guia do BD5 chave do BD6"	
		endIf

	else
		
		BE4->( dbSetOrder(1) )
		if BE4->( msSeek( xFilial("BE4") + aCabUpt[nFor,3] ) )

			BE4->(recLock("BE4", .f.))
				BE4->BE4_STAFAT := cStatus
				BE4->BE4_OPEFAT := cOpeFat
				BE4->BE4_NUMFAT := cNumFat

				if ((cTipCob == '3' .And. nPosIntTit == 1) .Or. (cTipCob == '1'))  .And. lFieldsNDC  
					BE4->BE4_PRENDC := cPrefixo
					BE4->BE4_NUMNDC := cTitulo
					BE4->BE4_PARNDC := cParcela
					BE4->BE4_TIPNDC := cTipoTit	
				else
					BE4->BE4_PREFIX := cPrefixo
					BE4->BE4_NUMTIT := cTitulo
					BE4->BE4_PARCEL := cParcela
					BE4->BE4_TIPTIT := cTipoTit		 
				endIf
			BE4->(msUnLock())

		else
			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "PLSNOTXBDH - " + STR0176 + " [" + aCabUpt[nFor,1] + "]", 0, 0, {})//"Falha ao localizar cabecalho da guia do BE4 chave do BD6"
		endIf

	endIf

next

if existBlock("PLSPTXDH")
	execBlock("PLSPTXDH", .f., .f., { cStatus, cOpeFat, cNumFat, cPrefixo + cTitulo + cParcela + cTipoTit, lInterc, lAtuBDH, aCabUpt } )
endif

RestArea(aAreaBD6)
RestArea(aAreaBD5)
RestArea(aAreaBE4)
RestArea(aAreaBEA)

return

/*/{Protheus.doc} PLSBDHB6S
Grava chave de ligacao BDH x B6S
@author  PLS TEAM
@version P12
@since   23.03.20
/*/
function PLSBDHB6S(cChave, cPrefixo, cTitulo, cParcela, cTipoTit, dDtEmissao)
local dDtEmissao 	:=  ctod('')
local lB6S_DTEMIS 	:= B6S->(fieldPos("B6S_DTEMIS")) > 0

if lB6S_DTEMIS
	
	SE1->(dbSetOrder(1))
	if SE1->( msSeek( xFilial("SE1") + cPrefixo + cTitulo + cParcela + cTipoTit ) )
		dDtEmissao := SE1->E1_EMISSAO
	endIf

endIf

B6S->(dbSetOrder(3))//B6S_FILIAL+B6S_CODOPE+B6S_CODLDP+B6S_CODPEG+B6S_NUMERO+B6S_SEQUEN                                                                                               
if B6S->( msSeek( xFilial('B6S') + cChave ) )

	B6S->(recLock('B6S', .f.))
		B6S->B6S_V500TX := BD6->BD6_VLRTAD
		B6S->B6S_V500PF := BD6->(BD6_VLRPF + BD6_VLRTAD)
		B6S->B6S_PREFIX := cPrefixo
		B6S->B6S_NUMTIT := cTitulo
		B6S->B6S_PARCEL := cParcela
		B6S->B6S_TIPTIT := cTipoTit

		if lB6S_DTEMIS
			B6S->B6S_DTEMIS	:= dDtEmissao
		endIf

		B6S->B6S_MATRIC := BD6->(BD6_OPEUSR + BD6_CODEMP + BD6_MATRIC + BD6_TIPREG + BD6_DIGITO)
	B6S->(msUnLock())
	
endIf

return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao     ³ PLSATUFATA ³ Autor ³ Tulio Cesar          ³ Data ³ 13.10.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o  ³ Atualiza faturas ja geradas com novo conceito de apontar nas  ³±±
±±³            ³ guias dados da fatura que antes somente existiam no BDH       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Programa batch para ser executado                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³             ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSATUFATA
LOCAL aSays     := {}
LOCAL aButtons  := {}
LOCAL cCadastro := STR0052 //"Atualizacao em faturas geradas de dados faturados nas guias e eventos"

aadd(aButtons, { 1,.T.,{|| MsAguarde({|| ProcBDHNota() }, cCadastro, "", .T.) , FechaBatch() }} )
aadd(aButtons, { 2,.T.,{|| FechaBatch() }} )

aadd(aSays,STR0053) //"Este programa processa faturas geradas e atualiza nas guias e eventos"
aadd(aSays,STR0054) //"dados que eram somente atualizados no arquivo BDH."
aadd(aSays,"")
aadd(aSays,STR0055) //"Somente deve ser executado uma unica vez e preferencialmente"
aadd(aSays,STR0056) //"ao final do expediente."

FormBatch( cCadastro, aSays, aButtons,, 200 )

Return

Static Function ProcBDHNota()
LOCAL nUltimo := BDH->(RecCount())

BDH->(DbSetOrder(0))
BDH->(DbGoBottom())
While ! BDH->(Eof())
   
      MsProcTXT(STR0057+AllTrim(Str(BDH->(Recno()),6))+" / "+AllTrim(Str(nUltimo,6))) //"Analisando registro "
         
      If BDH->BDH_STATUS == "0" //Foi faturada...
         PLSNOTXBDH(BDH->BDH_STATUS,BDH->BDH_OPEFAT,BDH->BDH_NUMFAT,{BDH->BDH_PREFIX,BDH->BDH_NUMTIT,BDH->BDH_PARCEL,BDH->BDH_TIPTIT},If(BDH->BDH_INTERC=="1",.T.,.F.),.F.)
      Endif   
   
BDH->(DbSkip())
Enddo 

MsgStop(STR0058) //"Processamento concluido."


Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao     ³ PLSAnaCM   ³ Autor ³ Tulio Cesar          ³ Data ³ 16.12.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o  ³ Analisa uma guia medica e procura por inconsistencias         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSAnaCM(aSuperRecno,lLerGuia,lPosicione,cChaveGuia,cOriMov,aCriticas,lCorrigir,cTipoGuia)
LOCAL nForItem
LOCAL nForSubItem
LOCAL cFase
LOCAL cSituac                     
LOCAL cChavePeg
LOCAL cMatricUsr
LOCAL cNumFat
LOCAL cNumSe1
LOCAL cTipPre
LOCAL cSeqPF
LOCAL cCodEsp
LOCAL cCodOpe
LOCAL cANOMES
LOCAL nOrdBD5        := BD5->(IndexOrd())
LOCAL nRecBD5        := BD5->(Recno())
LOCAL nOrdBE4        := BE4->(IndexOrd())
LOCAL nRecBE4        := BE4->(Recno())
LOCAL nOrdBD6        := BD6->(IndexOrd())
LOCAL nRecBD6        := BD6->(Recno())
LOCAL nOrdBD7        := BD7->(IndexOrd())
LOCAL nRecBD7        := BD7->(Recno())
LOCAL nOrdBCI        := BCI->(IndexOrd())
LOCAL nRecBCI        := BCI->(Recno())
LOCAL nOrdBAG        := BAG->(IndexOrd())
LOCAL nRecBAG        := BAG->(Recno())
LOCAL nOrdBDH        := BDH->(IndexOrd())
LOCAL nRecBDH        := BDH->(Recno())
LOCAL nOrdBI3        := BI3->(IndexOrd())
LOCAL nRecBI3        := BI3->(Recno())
LOCAL nOrdBA0        := BA0->(IndexOrd())
LOCAL nRecBA0        := BA0->(Recno())
LOCAL cDigito        := ""

LOCAL cClaINS

LOCAL cAliasCab        
LOCAL aRetAnalise    := {}
LOCAL bRest          := {|| BD5->(DbGoTo(nRecBD5)), BD5->(DbSetOrder(nOrdBD5)), BE4->(DbGoTo(nRecBE4)), BE4->(DbSetOrder(nOrdBE4)), ;
                           	BD6->(DbGoTo(nRecBD6)), BD6->(DbSetOrder(nOrdBD6)), BD7->(DbGoTo(nRecBD7)), BD7->(DbSetOrder(nOrdBD7)) ,;
                           	BCI->(DbGoTo(nRecBCI)), BCI->(DbSetOrder(nOrdBCI)), BAG->(DbGoTo(nRecBAG)), BAG->(DbSetOrder(nOrdBAG)) ,;                           
                           	BDH->(DbGoTo(nRecBDH)), BDH->(DbSetOrder(nOrdBDH)), BI3->(DbGoTo(nRecBI3)), BI3->(DbSetOrder(nOrdBI3)) ,;                           
                           	BA0->(DbGoTo(nRecBA0)), BA0->(DbSetOrder(nOrdBA0)) }
                           
LOCAL lChkData      := .F.                           
LOCAL cArqLog    	:= "PLSLGMF.LOG"
LOCAL lBQC_CLAINS 	:= BQC->(FieldPos("BQC_CLAINS")) > 0
LOCAL lBD7_CLAINS 	:= BD7->(FieldPos("BD7_CLAINS")) > 0
LOCAL lValPerm	  	:= .T.
local lReapre       := iif(lUnimed,PlVerReap(BCI->BCI_CODOPE,RIGHT(BCI->BCI_LOTEDI,8)),.f.) //Verifica se é uma reapresentação

DEFAULT aSuperRecno  := {}                           
DEFAULT lLerGuia     := .T.                 
DEFAULT lPosicione   := .F.
DEFAULT aCriticas    := {}
DEFAULT lCorrigir    := .F.
DEFAULT cTipoGuia	 := ""

BDH->(DbSetOrder(3))
BI3->(DbSetOrder(1))
BA0->(DbSetOrder(1))
BAQ->(DbSetOrder(1))
BCI->(DbSetOrder(1))
BD6->(DbSetOrder(1))
BD7->(DbSetOrder(1))

//Caso tenha que ler a guia e monta a SuperRecnos... aconselhavel para programa bath da base toda              
//No caso da mudanca de fase o aSuperRecno  ja vai vir com os dados para ganhar performance...                 
//Analisa tipo de guia que pode ser consulta/servico ou GIH                                                    
If cOriMov $ "1,3,5" 
	
	If cTipoGuia <> "05"
       cAliasCab := "BD5"
       lChkData  := .T.
	Else
		cAliasCab := "BE4"
	EndIf
	
ElseIf cOriMov == "2"
       cAliasCab := "BE4"
       lChkData  := .F.
Else
   //³ Guia invalida!!!                                                                                             
   IncluiCritica(aCriticas,lLerGuia,STR0059,"","","","") //"O campo ORIMOV nao esta com o conteudo valido que seria 1 ou 2"
   
   Return(aCriticas)   
Endif   

If lLerGuia
   
   //Posiciona ou nao na guia...                                                                                  
   If lPosicione
      &(cAliasCab)->(dbSetOrder(1))
      lGuiaFound := &(cAliasCab)->(DbSeek(xFilial(cAliasCab)+cChaveGuia+cOriMov)) 
   Else
      lGuiaFound := .T.
      cChaveGuia := &(cAliasCab+"->"+cAliasCab+"_CODOPE")+&(cAliasCab+"->"+cAliasCab+"_CODLDP")+&(cAliasCab+"->"+cAliasCab+"_CODPEG")+&(cAliasCab+"->"+cAliasCab+"_NUMERO")
   Endif   

   //³ Se achou monta os dados...                                                                                   
   If lGuiaFound

      aSuperRecno := {cAliasCab,&(cAliasCab)->(Recno()),{},{}}

      If BD6->(DbSeek(xFilial("BD6")+cChaveGuia+cOriMov))
      
         While ! BD6->(Eof()) .And. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) == xFilial("BD6")+cChaveGuia+cOriMov
                                        
               aadd(aSuperRecno[3],BD6->(Recno()))
               
               If BD7->(DbSeek(xFilial("BD7")+cChaveGuia+cOriMov+BD6->BD6_SEQUEN))
               
                  While ! BD7->(Eof()) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == xFilial("BD7")+cChaveGuia+cOriMov+BD6->BD6_SEQUEN
                                              
                        AaDd(aSuperRecno[4],BD7->(Recno()))
                                                 
                  BD7->(DbSkip())
                  Enddo                            
               Else
                  //³ Nao existem subitens para o evento da guia...                                                                ³
                  IncluiCritica(aCriticas,lLerGuia,STR0060,"","","","") //"SubItens (BD7) nao encontratos para o evento "
               Endif                      
                                        
         BD6->(DbSkip())
         Enddo
      Else
         //³ Nao existem eventos para a guia                                                                              ³
         IncluiCritica(aCriticas,lLerGuia,STR0061,"","","","") //"Eventos (BD6) nao encontratos para a guia "
      Endif
   Else
      //³ Guia invalida!!!                                                                                             ³
      IncluiCritica(aCriticas,lLerGuia,STR0062+STR0063,"","","","") //"Guia"###" invalida"
   Endif                                     
Endif

DbSelectArea(aSuperRecno[1])
DbGoTo(aSuperRecno[2])

If ( cOriMov == "1" ) .Or. (cOriMov == "3") .or. ( cOriMov == "2" .And. &(cAliasCab+"->"+cAliasCab+"_FASE") == "3" .and. &(cAliasCab+"->"+cAliasCab+"_SITUAC") == "1" )
   
   If Empty(&(cAliasCab+"->"+cAliasCab+"_DATPRO"))                                     
      IncluiCritica(aCriticas,lLerGuia,STR0064,"","","","") //"Data em branco na guia"
   Endif
      
Endif   

If Empty(&(cAliasCab+"->"+cAliasCab+"_ANOPAG"))                                     
   IncluiCritica(aCriticas,lLerGuia,STR0065,"","","","") //"ANOPAG em branco na guia"
Endif   

If Empty(&(cAliasCab+"->"+cAliasCab+"_MESPAG"))                                     
   IncluiCritica(aCriticas,lLerGuia,STR0066,"","","","") //"MESPAG em branco na guia"
Endif   

If ! &(cAliasCab+"->"+cAliasCab+"_TIPGUI") $ "01,02,03,04,05,06,10,13"                                   
   IncluiCritica(aCriticas,lLerGuia,STR0067+&(cAliasCab+"->"+cAliasCab+"_TIPGUI")+"]","","","","")           //"TIPGUI invalido na guia ["
Endif   

cCodOpe := &(cAliasCab+"->"+cAliasCab+"_CODOPE")
cFase   := &(cAliasCab+"->"+cAliasCab+"_FASE")
cSituac := &(cAliasCab+"->"+cAliasCab+"_SITUAC")                                         
cTipPre := &(cAliasCab+"->"+cAliasCab+"_TIPPRE")                                         
cSeqPF  := &(cAliasCab+"->"+cAliasCab+"_SEQPF")                                         
cCodEsp := &(cAliasCab+"->"+cAliasCab+"_CODESP")                                         

If cFase == "5"
	lValPerm := .F.
EndIf

If ! BAQ->(DbSeek(xFilial("BAQ")+cCodOpe+cCodEsp)) .AND. &(cAliasCab+"->"+cAliasCab+"_TIPGUI") <>"05" 
   IncluiCritica(aCriticas,lLerGuia,STR0068+cCodEsp+"]","","","","")               //"Especialidade da guia nao encontrada ["
Endif   

cMatricUsr 	:= &(cAliasCab+"->"+cAliasCab+"_OPEUSR")+&(cAliasCab+"->"+cAliasCab+"_CODEMP")+&(cAliasCab+"->"+cAliasCab+"_MATRIC")+&(cAliasCab+"->"+cAliasCab+"_TIPREG")
cDigito    	:= &(cAliasCab+"->"+cAliasCab+"_DIGITO")

cNumFat 	:= "" //NUMFAT
cNumSe1 	:= "" //NUMSE1

cANOMES 	:= &(cAliasCab+"->"+cAliasCab+"_ANOPAG")+&(cAliasCab+"->"+cAliasCab+"_MESPAG")
cChavePeg 	:= &(cAliasCab+"->"+cAliasCab+"_CODOPE")+&(cAliasCab+"->"+cAliasCab+"_CODLDP")+&(cAliasCab+"->"+cAliasCab+"_CODPEG")

If ! BCI->(DbSeek(xFilial("BCI")+cChavePeg))
   IncluiCritica(aCriticas,lLerGuia,STR0069,"","","","")               //"PEG nao existente para a guia"
Endif

If ! cFase $ "1,2,3,4,5"
   IncluiCritica(aCriticas,lLerGuia,STR0070+cFase+"]","","","","")              //"FASE invalido na guia ["
Endif
   
If ! cSituac $ "1,2,3,4"
   IncluiCritica(aCriticas,lLerGuia,STR0071+cSituac+"]","","","","")              //"SITUAC invalido na guia ["
Endif

For nForItem := 1 To Len(aSuperRecno[3])
    
    BD6->( dbGoTo(aSuperRecno[3,nForItem]) )                                                       
    
    If cSeqPF <> BD6->BD6_SEQPF
       IncluiCritica(aCriticas,lLerGuia,STR0073,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,"")     //"BD6_SEQPF diferente entre cabecalho e evento"
    Endif   

    If cANOMES <> BD6->(BD6_ANOPAG+BD6_MESPAG)
       IncluiCritica(aCriticas,lLerGuia,STR0075,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,"")         //"BD6_ANOPAG+BD6_MESPAG diferente entre cabecalho e evento"
    Endif

    If ! Empty(BD6->BD6_SEQPF) .AND. !lReapre
       
       If ! BDH->(DbSeek(xFilial("BDH")+BD6->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG+BD6_ANOPAG+BD6_MESPAG+BD6_SEQPF)))
          IncluiCritica(aCriticas,lLerGuia,STR0076,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,"")            //"Evento consolidado com BDH nao existente "
       Endif  
        
    Endif
    
    If ! BD6->BD6_INTERC $ "1,0"
       IncluiCritica(aCriticas,lLerGuia,STR0077+BD6->BD6_INTERC+"]",BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,"")            //"BD6_INTERC invalido ["
    Endif    

    If ! BD6->BD6_TIPUSR $ "1,2,3"
       IncluiCritica(aCriticas,lLerGuia,STR0078+BD6->BD6_TIPUSR+"]",BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,"")            //"BD6_TIPUSR invalido ["
    Endif    

    If ! BD6->BD6_MODCOB $ "1,2,9"
       IncluiCritica(aCriticas,lLerGuia,STR0079+BD6->BD6_MODCOB+"]",BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,"")            //"BD6_MODCOB invalido ["
    Endif    

    If ! BD6->BD6_TPPF $ " 1,2"
       IncluiCritica(aCriticas,lLerGuia,STR0080+BD6->BD6_TPPF+"]",BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,"")            //"BD6_TPPF invalido ["
    Endif    

    If cMatricUsr <> BD6->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG)
       IncluiCritica(aCriticas,lLerGuia,STR0081,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,"")     //"Matricula do usuario da guia diferente do evento"
    Endif   
    
    If cDigito <> BD6->BD6_DIGITO
       IncluiCritica(aCriticas,lLerGuia,STR0082,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,"")     //"Digito verificador (???_DIGITO) diferente entre cabecalho e evento"
    Endif   

	if xFilial("BI3") + BD6->(BD6_CODOPE+BD6_CODPLA) <>  BI3->(BI3_FILIAL+BI3_CODINT+BI3_CODIGO)
    	
    	If ! BI3->( msSeek( xFilial("BI3") + BD6->(BD6_CODOPE+BD6_CODPLA) ) )
       		IncluiCritica(aCriticas,lLerGuia,STR0083+BD6->BD6_CODPLA+"]",BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,"")            //"BD6_CODPLA invalido ["
    	Endif
    	
    endIf
    	   
	if !Empty(BD6->BD6_OPEORI) .AND. xFilial("BA0") + BD6->BD6_OPEORI <> BA0->(BA0_FILIAL+BA0_CODIDE+BA0_CODINT)
		
		If ! BA0->(msSeek(xFilial("BA0")+BD6->BD6_OPEORI))
       		IncluiCritica(aCriticas,lLerGuia,STR0084+BD6->BD6_OPEORI+"]",BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,"")            //"BD6_OPEORI invalido ["
    	Endif
    	   
	endIf 

    If cSituac <> BD6->BD6_SITUAC                                                                            
       IncluiCritica(aCriticas,lLerGuia,STR0085,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,"") //"BD6_SITUAC do evento diferente do evento"
    Endif   
    
    If ! BD6->BD6_FASE $ "1,2,3,4"                                                                                     
       IncluiCritica(aCriticas,lLerGuia,STR0086+BD6->BD6_FASE+"]",BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,"") //"BD6_FASE invalido ["
    Endif

    If ! BD6->BD6_SITUAC $ "1,2,3"                                                                                     
       IncluiCritica(aCriticas,lLerGuia,STR0087+BD6->BD6_SITUAC+"]",BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,"") //"BD6_SITUAC invalido ["
    Endif

    If ! BD6->BD6_TIPGUI $ "01,02,03,04,05,06,10,13"
       IncluiCritica(aCriticas,lLerGuia,STR0088+BD6->BD6_TIPGUI+"]",BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,"") //"BD6_TIPGUI em branco ou invalido ["
    Endif
    
    If ( cOriMov == "1" ) .Or. ( cOriMov == "3" ) .or. ( cOriMov == "2" .And. BD6->BD6_FASE == "3" .and. BD6->BD6_SITUAC == "1" )
       
       If Empty(BD6->BD6_DATPRO)
          IncluiCritica(aCriticas,lLerGuia,STR0089,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,"") //"BD6_DATPRO em branco"
       Endif  
        
    Endif
    
    If Empty(BD6->BD6_ANOPAG)                                         
       IncluiCritica(aCriticas,lLerGuia,STR0090,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,"") //"BD6_ANOPAG em branco"
    Endif

    If Empty(BD6->BD6_MESPAG)                                         
       IncluiCritica(aCriticas,lLerGuia,STR0091,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,"") //"BD6_MESPAG em branco"
    Endif

    If lBQC_CLAINS .And. lBD7_CLAINS .and. FindFunction("PLSCLAINS")
       cClaINS := PLSCLAINS(.t.)
    Else
       cClaINS := ""
    Endif   

Next

For nForSubItem := 1 To Len(aSuperRecno[4])

	BD7->(dbGoTo(aSuperRecno[4,nForSubItem]))
	
	//A critica acima sera reestabelecida apos uma analise melhor dos pontos que atualizam o BD7_VLRGLO   

	If cANOMES <> BD7->(BD7_ANOPAG+BD7_MESPAG)
		IncluiCritica(aCriticas,lLerGuia,"BD7_ANOPAG+BD7_MESPAG diferente entre cabecalho e evento",BD7->BD7_CODPAD,BD7->BD7_CODPRO,BD7->BD7_SEQUEN,BD7->BD7_CODUNM)        
	Endif

	If ! BD7->BD7_INTERC $ "1,0"
		IncluiCritica(aCriticas,lLerGuia,STR0094+BD7->BD7_INTERC+"]",BD7->BD7_CODPAD,BD7->BD7_CODPRO,BD7->BD7_SEQUEN,BD7->BD7_CODUNM)            //"BD7_INTERC invalido ["
	Endif    

	If ! BD7->BD7_TIPUSR $ "1,2,3"
		IncluiCritica(aCriticas,lLerGuia,STR0095+BD7->BD7_TIPUSR+"]",BD7->BD7_CODPAD,BD7->BD7_CODPRO,BD7->BD7_SEQUEN,BD7->BD7_CODUNM)            //"BD7_TIPUSR invalido ["
	Endif    

	If ! BD7->BD7_MODCOB $ "1,2,9"
		IncluiCritica(aCriticas,lLerGuia,STR0096+BD7->BD7_MODCOB+"]",BD7->BD7_CODPAD,BD7->BD7_CODPRO,BD7->BD7_SEQUEN,BD7->BD7_CODUNM)            //"BD7_MODCOB invalido ["
	Endif    

	If cMatricUsr <> BD7->(BD7_OPEUSR+BD7_CODEMP+BD7_MATRIC+BD7_TIPREG)
		IncluiCritica(aCriticas,lLerGuia,STR0081,BD7->BD7_CODPAD,BD7->BD7_CODPRO,BD7->BD7_SEQUEN,BD7->BD7_CODUNM)     //"Matricula do usuario da guia diferente do evento"
	Endif

	If cSituac <> BD7->BD7_SITUAC                                                                            
		IncluiCritica(aCriticas,lLerGuia,STR0098,BD7->BD7_CODPAD,BD7->BD7_CODPRO,BD7->BD7_SEQUEN,BD7->BD7_CODUNM) //"BD7_SITUAC do evento diferente do evento"
	Endif   

	If ! BD7->BD7_FASE $ "1,2,3,4"                                                                                     
		IncluiCritica(aCriticas,lLerGuia,STR0099+BD7->BD7_FASE+"]",BD7->BD7_CODPAD,BD7->BD7_CODPRO,BD7->BD7_SEQUEN,BD7->BD7_CODUNM) //"BD7_FASE invalido ["
	Endif

	If ! BD7->BD7_SITUAC $ "1,2,3"                                                                                     
		IncluiCritica(aCriticas,lLerGuia,STR0100+BD7->BD7_SITUAC+"]",BD7->BD7_CODPAD,BD7->BD7_CODPRO,BD7->BD7_SEQUEN,BD7->BD7_CODUNM) //"BD7_SITUAC invalido ["
	Endif

	If ! BD7->BD7_TIPGUI $ "01,02,03,04,05,06,10,13"                                                                                     
		IncluiCritica(aCriticas,lLerGuia,STR0101+BD7->BD7_TIPGUI+"]",BD7->BD7_CODPAD,BD7->BD7_CODPRO,BD7->BD7_SEQUEN,BD7->BD7_CODUNM) //"BD7_TIPGUI em branco ou invalido ["
	Endif

	If ( cOriMov == "1" ) .Or. ( cOriMov == "3" ) .OR. ( cOriMov == "2" .And. BD7->BD7_FASE == "3" .And. BD7->BD7_SITUAC == "1" )
		
		If Empty(BD7->BD7_DATPRO)
			IncluiCritica(aCriticas,lLerGuia,STR0102,BD7->BD7_CODPAD,BD7->BD7_CODPRO,BD7->BD7_SEQUEN,BD7->BD7_CODUNM) //"BD7_DATPRO em branco"
		Endif 
		  
	Endif

	If Empty(BD7->BD7_ANOPAG)                                         
		IncluiCritica(aCriticas,lLerGuia,STR0103,BD7->BD7_CODPAD,BD7->BD7_CODPRO,BD7->BD7_SEQUEN,BD7->BD7_CODUNM) //"BD7_ANOPAG em branco"
	Endif

	If Empty(BD7->BD7_MESPAG)                                         
		IncluiCritica(aCriticas,lLerGuia,STR0104,BD7->BD7_CODPAD,BD7->BD7_CODPRO,BD7->BD7_SEQUEN,BD7->BD7_CODUNM) //"BD7_MESPAG em branco"
	Endif

Next

eval(bRest)

return(aCriticas)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao     ³ IncluiCritica³ Autor ³ Totvs              ³ Data ³ 14.07.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o  ³ Inclui critica												   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function IncluiCritica(aCriticas,lLerGuia,cMsg,cCodPad,cCodPro,cSequen,cUnidade)
DEFAULT cUnidade := ""                                                    

cMsg 	 := Subs(AllTrim(cMsg)+Space(090),1,60)
cUnidade := Subs(AllTrim(cUnidade)+Space(3),1,3)
cCodPro  := Subs(AllTrim(cCodPro)+Space(8),1,8)                      
cCodPad  := Subs(AllTrim(cCodPad)+Space(2),1,2)                      
cSequen  := Subs(AllTrim(cSequen)+Space(3),1,3)                      

PLSPOSGLO(PLSINTPAD(),__aCdCri032[1],__aCdCri032[2],"1")
aadd(aCriticas,{{__aCdCri032[1],cMsg,"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro,cSequen,cUnidade}})
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao     ³ PLSCLAINS    ³ Autor ³ Totvs              ³ Data ³ 14.07.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o  ³ Considera o BD6 posicionado!!!								   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSCLAINS(lField)
local cRet      := BD6->BD6_TIPUSR
local lFoundBQC := .f.

default lField  := BQC->(FieldPos("BQC_CLAINS")) > 0 .and. BD7->(FieldPos("BD7_CLAINS")) > 0 

//Somente PJ que tem a regra...

If lField .and. cRet == "2" 

   If BQC->(BQC_CODIGO+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB) <> BD6->(BD6_OPEUSR+BD6_CODEMP+BD6_CONEMP+BD6_VERCON+BD6_SUBCON+BD6_VERSUB)

      BQC->(dbSetOrder(1))
      lFoundBQC := BQC->(msSeek(xFilial("BQC")+BD6->(BD6_OPEUSR+BD6_CODEMP+BD6_CONEMP+BD6_VERCON+BD6_SUBCON+BD6_VERSUB)))
      
   else
   
      lFoundBQC := .T.
      
   endIf   
   
   if lFoundBQC
   
      if ! empty(BQC->BQC_CLAINS)
         cRet := BQC->BQC_CLAINS
      endIf
      
   else
   
		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0105 + BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO) + "]"  , 0, 0, {})//"SIGAPLS - Nao foi possivel obter subcontrato do evento ["
   
   endIf
      
endIf

return(cRet)

/*/{Protheus.doc} PLSRETNCRI
caminho da critica
@type function
@author TOTVS
@since 04.02.2012
@version 1.0
/*/
Function PLSRETNCRI(cNivCri, cChaveNiv, cNivAut)
local nPos		:= ""
local cRet 		:= ""
local cAliasCri	:= ""

default cNivCri 	:= ""
default cChaveNiv 	:= ""
default cNivAut 	:= ""

if ! empty(cNivCri)
	cAliasCri := cNivCri
elseIf ! empty(cNivAut)
	cAliasCri := cNivAut
else
	return(cRet)
Endif

// Somente busca nivel autorizacao/critica para niveis validos como tabelas do PLS - bops 95827
if subStr(cAliasCri, 1, 1) <> 'B' .And. cAliasCri <> "FOR" .And. cAliasCri <> "URG" .AND. cAliasCri <> "JUR" 
	return(cRet)
endIf

if ! empty(cAliasCri)
	
	if len(__aNiveis) == 0
	
		aAdd(__aNiveis, {"FOR", STR0195 }) //"Procedimento forçado."
		aAdd(__aNiveis, {"BA0", STR0106 }) //"Atualizacoes / Operadora / Operadora de Saude"
		aAdd(__aNiveis, {"BAQ", STR0107 }) //"Atualizacoes / Procedimento / Especialidade Med."
		aAdd(__aNiveis, {"BAU", STR0215 }) //"Atualizacoes / Rede Atendimento"
		aAdd(__aNiveis, {"BAX", STR0108 }) //"Atualizacoes / Rede Atendimento / R.D.A - Cadastro --> Folder Especialidades"
		aAdd(__aNiveis, {"BBF", "Atualizacoes / Rede Atendimento / R.D.A - Cadastro --> Folder Especialidades" }) //"Atualizacoes / Rede Atendimento / R.D.A - Cadastro --> Folder Especialidades"
		aAdd(__aNiveis, {"BB8", STR0109 }) //"Atualizacoes / Rede Atendimento / R.D.A - Cadastro --> Folder Local de Atendimento"
		aAdd(__aNiveis, {"BBI", STR0110 }) //"Atualizacoes / Rede Atendimento / R.D.A - Cadastro --> Folder Especialidades / Planos / Planos"
		aAdd(__aNiveis, {"BBM", STR0111 }) //"Atualizacoes / Procedimentos / Especialidade Med. --> Folder Tabela Padrao / Especialidade x Tabela Padrao"
		aAdd(__aNiveis, {"BC0", STR0108 }) //"Atualizacoes / Rede Atendimento / R.D.A - Cadastro --> Folder Especialidades / Procedimentos Autorizados"
		aAdd(__aNiveis, {"BC5", STR0112 }) //"Atualizacoes / Rede Atendimento / Rda x Tab. Preco"
		aAdd(__aNiveis, {"BC6", STR0113 }) //"Atualizacoes / Rede Atendimento / Rda x Tab. Preco --> Opcao Procedimentos"
		aAdd(__aNiveis, {"BCK", STR0114 }) //"Atualizacoes / Rede Atendimento / R.D.A - Cadastro --> Folder Local de Atendimento / Diferenciacao da Ref./U.S.por Unidade"
		aAdd(__aNiveis, {"BCW", STR0115 }) //"Atualizacoes / Produto Saude / Produto Saude --> Folder Cobertura/Carencias / Tipo de Prestador"
		aAdd(__aNiveis, {"BD4", STR0116 }) //"Atualizacoes / Procedimento / Tb Dinamica Evento --> Folder Unidade de Saude"
		aAdd(__aNiveis, {"BE9", STR0117 }) //"Atualizacoes / Rede Atendimento / R.D.A - Cadastro --> Folder Especialidades / Planos / Procedimentos"
		aAdd(__aNiveis, {"BF5", STR0118 }) //"Atualizacoes / Produto Saude / Dif.vlr.filme.prod"
		aAdd(__aNiveis, {"BFC", STR0119 }) //"Atualizacoes / Contrato/Familia / Familia/Usuario --> Folder Familia / Cobertura / Grupos de Cobertura"
		aAdd(__aNiveis, {"BFE", STR0120 }) //"Atualizacoes / Contrato/Familia / Familia/Usuario --> Folder Usuario(s) / Cobertura / Grupos Determinados"
		aAdd(__aNiveis, {"BFM", STR0121 }) //"Atualizacoes / Pagamento da R.D.A. / Parametros do US"
		aAdd(__aNiveis, {"BG6", STR0122 }) //"Atualizacoes / Contrato/Familia / Grupo/Empresa --> Opcao Contrato / SubContrato --> Folder Diferenciacao do Valor do Filme"
		aAdd(__aNiveis, {"BGD", STR0123 }) //"Atualizacoes / Produto Saude / Produto Saude --> Folder Cobertura/Carencias / Municipio de Atendimento"
		aAdd(__aNiveis, {"BGH", STR0124 }) //"Atualizacoes / Operadora / Grupo de Operadora --> Opcao Vigencias"
		aAdd(__aNiveis, {"BGI", STR0125 }) //"Atualizacoes / Operadora / Grupo de Operadora --> Opcao Vigencias / Selecionar"
		aAdd(__aNiveis, {"BGL", STR0126 }) //"Atualizacoes / Contrato/Familia / Grupo/Empresa --> Opcao Contrato / SubContrato --> Folder Produtos / Municipio de Atendimento --> Botao Co-Participacao"
		aAdd(__aNiveis, {"BGS", STR0127 }) //"Atualizacoes / Contrato/Familia / Grupo/Empresa --> Opcao Contrato / SubContrato --> Folder Produtos / Tipo Prestador --> Botao Co-Participacao"
		aAdd(__aNiveis, {"BH0", STR0128 }) //"Atualizacoes / Operadora / Operadora de Saude --> Opcao Complemento --> Tabelas de Pagamento e Recebimento"
		aAdd(__aNiveis, {"BHC", STR0129 }) //"Atualizacoes / Procedimento / Tabela Padrao --> Botao Co-Participacao"
		aAdd(__aNiveis, {"BHD", STR0130 }) //"Atualizacoes / Produto Saude / Produto Saude --> Folder Cobertura/Carencias / Procedimentos / Co-Participacao"
		aAdd(__aNiveis, {"BHE", STR0131 }) //"Atualizacoes / Contrato/Familia / Grupo/Empresa --> Opcao Contrato / SubContrato --> Folder Produtos / Coberturas / Procedimentos --> Botao Co-Participacao"
		aAdd(__aNiveis, {"BHF", STR0132 }) //"Atualizacoes / Contrato/Familia / Grupo/Empresa --> Opcao Contrato / SubContrato --> Folder Produtos / Coberturas / Grupos Determinados --> Botao Co-Participacao"
		aAdd(__aNiveis, {"BHG", STR0133 }) //"Atualizacoes / Contrato/Familia / Grupo/Empresa --> Opcao Contrato / SubContrato --> Folder Produtos / Co-Participacao"
		aAdd(__aNiveis, {"BHI", STR0134 }) //"Atualizacoes / Produto Saude / Produto Saude --> Folder Cobertura/Carencias / Grupos Determinados "
		aAdd(__aNiveis, {"BHJ", STR0135 }) //"Atualizacoes / Produto Saude / Produto Saude --> Folder Cobertura/Carencias / Co-Participacao"
		aAdd(__aNiveis, {"BKF", STR0136 }) //"Atualizacoes / Procedimento / Porte Anestesico"
		aAdd(__aNiveis, {"BLW", STR0137 }) //"Atualizacoes / Contrato/Familia / Grupo/Empresa --> Opcao Contrato / SubContrato --> Folder Produtos / Coberturas / Procedimentos --> Botao CID"
		aAdd(__aNiveis, {"BLX", STR0138 }) //"Atualizacoes / Contrato/Familia / Grupo/Empresa --> Opcao Contrato / SubContrato --> Folder Produtos / Coberturas / Procedimentos --> Botao Especialidade"
		aAdd(__aNiveis, {"BMB", STR0139 }) //"Atualizacoes / Operadora / Operadora de Saude --> Opcao Complemento --> Parametros para Pagamento"
		aAdd(__aNiveis, {"BMC", STR0139 }) //"Atualizacoes / Operadora / Operadora de Saude --> Opcao Complemento --> Parametros para Pagamento"
		aAdd(__aNiveis, {"BMD", STR0140 }) //"Atualizacoes / Produto Saude / Produto Saude --> Folder Parametros Pagamento Rede Atendimento"
		aAdd(__aNiveis, {"BME", STR0140 }) //"Atualizacoes / Produto Saude / Produto Saude --> Folder Parametros Pagamento Rede Atendimento"
		aAdd(__aNiveis, {"BMF", STR0141 }) //"Atualizacoes / Contrato/Familia / Grupo/Empresa --> Opcao Contrato / SubContrato --> Folder Parametro Pagamento Tipo Prestador"
		aAdd(__aNiveis, {"BMG", STR0141 }) //"Atualizacoes / Contrato/Familia / Grupo/Empresa --> Opcao Contrato / SubContrato --> Folder Parametro Pagamento Tipo Prestador"
		aAdd(__aNiveis, {"BMH", STR0142 }) //"Atualizacoes / Contrato/Familia / Grupo/Empresa --> Opcao Contrato / SubContrato --> Folder Parametro Pagamento Prestador"
		aAdd(__aNiveis, {"BMI", STR0142 }) //"Atualizacoes / Contrato/Familia / Grupo/Empresa --> Opcao Contrato / SubContrato --> Folder Parametro Pagamento Prestador"
		aAdd(__aNiveis, {"BML", STR0143 }) //"Atualizacoes / Contrato/Familia / Grupo/Empresa --> Opcao Contrato / SubContrato --> Folder Parametro Pagamento Especialidade"
		aAdd(__aNiveis, {"BMM", STR0143 }) //"Atualizacoes / Contrato/Familia / Grupo/Empresa --> Opcao Contrato / SubContrato --> Folder Parametro Pagamento Especialidade"
		aAdd(__aNiveis, {"BMQ", STR0144 }) //"Atualizacoes / Operadora / Grupo de Operadora --> Opcao Vigencias / Selecionar / Dif.p/unidade"
		aAdd(__aNiveis, {"BMT", STR0145 }) //"Atualizacoes / Operadora / Grupo de Operadora --> Opcao Vigencias / Selecionar / Dif.p/espec."
		aAdd(__aNiveis, {"BNZ", STR0146 }) //"Atualizacoes / Contrato/Familia / Subcontxco-part/Hr --> Folder Horarios x Co-Participacao"
		aAdd(__aNiveis, {"BP1", STR0147 }) //"Atualizacoes / Procedimento / Auxiliares"
		aAdd(__aNiveis, {"BP8", STR0148 }) //"Atualizacoes / Procedimento / Filme"
		aAdd(__aNiveis, {"BPI", STR0149 }) //"Atualizacoes / Rede Atendimento / R.D.A - Cadastro --> Folder Local de Atendimento / Filme"
		aAdd(__aNiveis, {"BR8", STR0150 }) //"Atualizacoes / Procedimento / Tabela Padrao"
		aAdd(__aNiveis, {"BRV", STR0134 }) //"Atualizacoes / Produto Saude / Produto Saude --> Folder Cobertura/Carencias / Grupos Determinados "
		aAdd(__aNiveis, {"BS0", STR0151 }) //"Atualizacoes / Produto Saude / Prodxdif.u.s Und. --> Folder Gerais"
		aAdd(__aNiveis, {"BS9", STR0152 }) //"Atualizacoes / Contrato/Familia / Subcontxdif.u.s"
		aAdd(__aNiveis, {"BSM", STR0153 }) //"Atualizacoes / Operadora / Grupo de Operadora --> Opcao Vigencias / Selecionar / Dif.p/produto"
		aAdd(__aNiveis, {"BSX", STR0154 }) //"Atualizacoes / Operadora / Grupo de Operadora --> Opcao Vigencias / Selecionar / Dif.p/produto / Dif.unidade"
		aAdd(__aNiveis, {"B7U", "Atualizacoes / Operadora / Grupo de Operadora --> Opcao Vigencias / Selecionar / Dif.p/Nivel Hosp" }) //"Atualizacoes / Operadora / Grupo de Operadora --> Opcao Vigencias / Selecionar / Dif.p/nivel hosp"
		aAdd(__aNiveis, {"BSY", STR0155 }) //"Atualizacoes / Localidade / Local Atendimento --> Folder Co-Participacao"
		aAdd(__aNiveis, {"BTM", STR0156 }) //"Atualizacoes / Procedimento / Tempo Cirurgico"
		aAdd(__aNiveis, {"BT7", STR0157 }) //"Atualizacoes / Contrato/Familia / Grupo/Empresa --> Opcao Contrato / SubContrato --> Folder Produtos / Coberturas / Grupos Determinados"
		aAdd(__aNiveis, {"BVC", STR0158 }) //"Atualizacoes / Contrato/Familia / Familia/Usuario --> Folder Familia / Cobertura / Grupos de Cobertura / Co-Participacao: "
		aAdd(__aNiveis, {"BVJ", STR0159 }) //"Atualizacoes / Contrato/Familia / Familia/Usuario --> Folder Usuarios / Grupos Determinados / Co-Participacao: "
		aAdd(__aNiveis, {"BW5", STR0160 }) //"Atualizacoes / Contrato/Familia / Grupo/Empresa --> Opcao Contrato / SubContrato --> Folder Produtos / Coberturas / Grupo de Quantidades"
		aAdd(__aNiveis, {"BW7", STR0161 }) //"Atualizacoes / Contrato/Familia / Familia/Usuario --> Folder Familia / Cobertura / Grupos de Quantidade"
		aAdd(__aNiveis, {"BW9", STR0162 }) //"Atualizacoes / Contrato/Familia / Familia/Usuario --> Folder Usuarios / Grupos de Quantidades: "
		aAdd(__aNiveis, {"BWW", STR0163 }) //"Atualizacoes / Operadora / Oper.vlr.co-part."
		aAdd(__aNiveis, {"BYK", STR0164 }) //"Atualizacoes / Produto Saude / Produto Saude --> Folder Cobertura/Carencias / Propriedades por Tipo de Internacao"
		aAdd(__aNiveis, {"BB2", STR0165 }) //"Atualizacoes / Produto Saude / Produto Saude --> Folder Cobertura/Procedimentos"
		aAdd(__aNiveis, {"BI3", STR0166 }) //"Atualizacoes / Produto Saude / Produto Saude --> Folder Produto Saude - Alterar"
		aAdd(__aNiveis, {"BBN", STR0167 }) //"Atualizacoes / Rede Atendimento / R.D.A - Cadastro --> Opcao Complemento --> Folder Especialidades / Procedimentos nao Autorizados"
		aAdd(__aNiveis, {"BT8", STR0168 }) //"Atualizacoes / Contrato/Familia / Grupo/Empresa --> Opcao Contrato / SubContrato --> Folder Produtos / Coberturas / Procedimentos"
		aAdd(__aNiveis, {"BYO", STR0190 })
		aAdd(__aNiveis, {"BFG", STR0191 })
		aAdd(__aNiveis, {"BFD", STR0192 })//"Atualizacoes / Contrato/Familia / Familia/Usuario --> Folder Familia / Cobertura / Procedimentos"
		aAdd(__aNiveis, {"B05", STR0193 })//"Atualizacoes / Tabela Padrao --> Botao Odonto"
		aAdd(__aNiveis, {"BYL", STR0194 })//"Atualizacoes / Tabela Padrao --> Botao Odonto / Botao Period/Qtd"
		aAdd(__aNiveis, {"BHK", STR0196 })//"Atualizacoes / Produto Saude / Grupo de Cobertura / Procedimentos -> Botao Co-participacao"
		aAdd(__aNiveis, {"BVF", STR0197 })//"Atualizacoes / Contrato/Familia / Familia/Usuario --> Folder Familia/Cobertura/Procedimentos/Co-Participação"
		aAdd(__aNiveis, {"BQC", STR0202 }) //"Atualizacoes / Contrato - Familia / Grupo - Empresa / Contrato / Sub-Contraro ----> Folder Dados do Sub Contrato - Alterar"
		aAdd(__aNiveis, {"B26", STR0203 }) //"Atualizacoes / Rede Atendimento / Folder Procedimentos Incompativeis
		aAdd(__aNiveis, {"BFP", STR0204 })//"Atualizacoes / Procedimento / Sub-Especialidade --> Botao Sub-especialidades / Folder Itens"
		aAdd(__aNiveis, {"B24", STR0206 })//"Atualizacoes / Rede Atendimento / Tabela de Preço --> Vinculado em Atualizacoes / Rede Atendimento / R.D.A - Cadastro --> Opcao Complemento --> Folder Local de Atendimento / Tabela de Preco"
		aAdd(__aNiveis, {"B30", STR0207 })//"Atualizacoes / Rede Atendimento / Tabela de Preço --> Vinculado em Atualizacoes / Rede Atendimento / R.D.A - Cadastro --> Opcao Complemento --> Folder RDA x Planos" 
		aAdd(__aNiveis, {"B13", STR0208 })//"Atualizacoes / Localidade / Estados X TDE" 
		aAdd(__aNiveis, {"B12", STR0208 })//"Atualizacoes / Localidade / Estados X TDE" 
		aAdd(__aNiveis, {"B29", STR0209 })//"Atualizacoes / Rede Atendimento / Tabela de Preço --> Vinculado em Atualizacoes / Rede Atendimento / R.D.A - Cadastro --> Opcao Alterar --> Folder Tab. Preço " 
		aAdd(__aNiveis, {"B85", STR0210 })//"Atualizacoes / Classe - Associação / Classe X Associação --> Vinculado em Atualizacoes / Rede Atendimento / R.D.A - Cadastro --> Opcao Alterar --> Folder Associação " 	
		aAdd(__aNiveis, {"BVM", STR0211 })//"Atualizacoes / Contrato/Familia / Familia/Usuario --> Folder Usuário / Cobertura / Procedimentos / Co-Participacao: "
		aAdd(__aNiveis, {"BOR", STR0212 })//"Atualizacoes / Contrato/Familia / Grupo/Empresa --> Opcao Contrato / SubContrato --> Folder Produto / Folder Rede Referenciada."
		aAdd(__aNiveis, {"B86", STR0213 })//"Atualizacoes / Produto Saúde / Produto Saúde --> Opcao Alterar/Incluir / Folder Folder Rede Referenciada --> Folder Rede Ref X Co-Part."})
		aAdd(__aNiveis, {"B51", STR0214 })//"Atualizacoes / Procedimento / Regra Sit. Adversas --> Opcao Alterar/Incluir / Folder Situação Adversa."
		aAdd(__aNiveis, {"BEA", STR0216 })
		aAdd(__aNiveis, {"BD6", STR0217})
		aAdd(__aNiveis, {"BD7", STR0218})
		aAdd(__aNiveis, {"BE4", STR0219})	
		aAdd(__aNiveis, {"B44", STR0220})
		aAdd(__aNiveis, {"BT4", STR0221})
		aAdd(__aNiveis, {"BJ4", STR0222})	
		aAdd(__aNiveis, {"BA9", STR0223})
		aAdd(__aNiveis, {"BF7", STR0224})                                                                  
		aAdd(__aNiveis, {"BIA", STR0225})
		aAdd(__aNiveis, {"BA1", STR0226})
		aAdd(__aNiveis, {"BDT", STR0227})	  
		aAdd(__aNiveis, {"URG", STR0230})//"Atendimento de Urgência e Emergência"
		aAdd(__aNiveis, {"JUR", STR0234})//"Atendimento liberado por meio de Guia Juridica. Os dados a respeito do processo judicial deverão ser anotados no cabeçalho da guia."
		aAdd(__aNiveis, {"B08", STR0235})//"Atualizações / Procedimento / Tabela Padrão / Dente-Região / Proc. Incomp X Dente"
		aAdd(__aNiveis, {"B3Z", STR0236})//"Atualizações / Produto Saude / Produto Saude --> Exceções rede a400"
		aAdd(__aNiveis, {"B0G", STR0237})//"Atualizações / Rede Atendimento --> Rd. Atend."
		aAdd(__aNiveis, {"BA3", STR0240})//"Atualizacoes / Contrato/Familia / Grupo Familiar/Beneficiários"
		aAdd(__aNiveis, {"BKV", STR0241})//"Atualizacoes / Procedimento / Tabela Padrao / Refeic. Acompanhantes"
	
	endIf
		
	nPos := aScan(__aNiveis,{ |x| x[1] == cAliasCri })
	
	if nPos > 0
		cRet := __aNiveis[nPos, 2] + iIf( empty(cChaveNiv), "", chr(13) )
	else

		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0179 + cAliasCri  , 0, 0, {})//"SIGAPLS - PLSRETNCRI nao suportada retorno "
		
	endIf
	
endIf

cRet := PadR(cRet, 240)

return(cRet)
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsRestOp ºAutor  ³Eduardo Motta       º Data ³  01/04/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     | Rotina para retornar filtro de acordo com operador         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLS                                                        º±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/        
Function PlsRestOp(cTipo,lSql)
Local cFiltro   := ""
Local cOperad   := PLSRtCdUsr()
Local cIntPad   := PlsIntPad()
Local aEmpPls 	:= {}
Local nI		:= 0
Local nJ        := 0
Local nLoop     := 0
Local nL        := 0
Local cAlias    := ""                                                                                                            
Local cSinal 	:= "="
Local cAceEmp 	:= "0"
Local cOr 		:= "or"
Local cAnd 		:= "and"
Local aPLEMPFIL := {}  
Local lPLEMPFIL := existBlock("PLEMPFIL")  
DEFAULT lSql 	:= .T.

If !lSql
   cOr  := ".or."
   cAnd := ".and."
EndIf

If cTipo == "A" // Auditoria
   cAlias := "BE2"
ElseIf cTipo == "L" // Liberacao/Autoriza SADT
   cAlias := "BEA"
ElseIf cTipo == "I" // Internacao
   cAlias := "BE4"
ElseIf cTipo == "U" // Usuario
   cAlias := "BA1"
ElseIf cTipo == "QR" // Anexos quimio radio opme
   cAlias := "B4A"
ElseIf cTipo == "PI" // Prorrogação de internação
   cAlias := "B4Q"
EndIf

BX4->(DbSetOrder(1))       
If !BX4->( MsSeek(xFilial("BX4")+cOperad+cIntPad) )
   Return cFiltro
EndIf

If !Empty(BX4->BX4_ACEEMP)

  aEmpPls := {}

  BXR->( dbSetOrder(1) )       
  BXR->( msSeek( xFilial('BXR') + BX4->(BX4_CODOPE+BX4_CODINT) ) )
  
  While !BXR->(Eof()) .and. xFilial("BXR")+BX4->BX4_CODOPE+BX4->BX4_CODINT == BXR->BXR_FILIAL+BXR->BXR_CODOPE+BXR->BXR_CODINT
  
		aadd(aEmpPls,{BXR->BXR_CODEMP,BXR->BXR_CONEMP,BXR->BXR_VERCON,BXR->BXR_SUBCON,BXR->BXR_VERSUB,BXR->BXR_ACEEMP })
		
		If lPLEMPFIL
		
			// campos a adicionar 
			aPLEMPFIL := ExecBlock("PLEMPFIL",.F.,.F.,{cTipo, cAlias})  
	
			If Valtype(aPLEMPFIL) == "A"  .And. Len(aPlEmpFil[1]) > 0
	
				For nLoop := 1 to Len(aPlEmpFil[1][1])
					aadd(aEmpPls[1], BXR->&(aPlEmpFil[1][1][nLoop]))
				Next
				
			EndIF
		else
			exit	
		EndIf
		
  BXR->(DbSkip())
  EndDo
      
EndIf

If BX4->(FieldPos("BX4_ACEEMP")) > 0 .and. !Empty(BX4->BX4_ACEEMP)

   If BX4->BX4_ACEEMP == "1"  // Operador tem acesso a todas as empresas, entao verifica restricoes
      cSinal  := "<>"
      cAceEmp := "0"
   Else
      cSinal 	:= "="
      cAceEmp 	:= "1"
   EndIf
   
EndIf

If BX4->(FieldPos("BX4_ACEEMP")) > 0 .and. !Empty(BX4->BX4_ACEEMP)

   For nI := 1 to Len(aEmpPls)

      If aEmpPls[nI,6] == cAceEmp

         If ! Empty(cFiltro)  .and. BX4->BX4_ACEEMP == "1"
            cFiltro+=" "+cAnd+" "
         ElseIf ! Empty(cFiltro)  .and. BX4->BX4_ACEEMP == "0"
            cFiltro+=" "+cOr+" "
         Else   
            cFiltro += " ("   
         EndIf
         
		 If 'MSSQL' $ AllTrim(TcGetDB())

	         If !Empty(aEmpPls[nI,5])
				cFiltro+= " ("+cAlias+"_CODEMP +"+cAlias+"_CONEMP +"+cAlias+"_VERCON +"+cAlias+"_SUBCON +"+cAlias+"_VERSUB "+cSinal+" '"+aEmpPls[nI,1]+aEmpPls[nI,2]+aEmpPls[nI,3]+aEmpPls[nI,4]+aEmpPls[nI,5]+"'"
	         ElseIf !Empty(aEmpPls[nI,4])
	            cFiltro+= " ("+cAlias+"_CODEMP +"+cAlias+"_CONEMP +"+cAlias+"_VERCON +"+cAlias+"_SUBCON "+cSinal+" '"+aEmpPls[nI,1]+aEmpPls[nI,2]+aEmpPls[nI,3]+aEmpPls[nI,4]+"'"
	   		 ElseIf !Empty(aEmpPls[nI,3])
	            cFiltro+= " ("+cAlias+"_CODEMP +"+cAlias+"_CONEMP +"+cAlias+"_VERCON "+cSinal+" '"+aEmpPls[nI,1]+aEmpPls[nI,2]+aEmpPls[nI,3]+"'"
	         ElseIf !Empty(aEmpPls[nI,2])
	            cFiltro+= " ("+cAlias+"_CODEMP +"+cAlias+"_CONEMP "+cSinal+" '"+aEmpPls[nI,1]+aEmpPls[nI,2]+"'"
	 		 ElseIf !Empty(aEmpPls[nI,1])
	    	    cFiltro+= " ("+cAlias+"_CODEMP "+cSinal+" '"+aEmpPls[nI,1]+"'"
	         EndIf        
	         
		Else         
	         If !Empty(aEmpPls[nI,5])
				cFiltro+= " ("+cAlias+"_CODEMP ||"+cAlias+"_CONEMP ||"+cAlias+"_VERCON ||"+cAlias+"_SUBCON ||"+cAlias+"_VERSUB "+cSinal+" '"+aEmpPls[nI,1]+aEmpPls[nI,2]+aEmpPls[nI,3]+aEmpPls[nI,4]+aEmpPls[nI,5]+"'"
	         ElseIf !Empty(aEmpPls[nI,4])
	            cFiltro+= " ("+cAlias+"_CODEMP ||"+cAlias+"_CONEMP ||"+cAlias+"_VERCON ||"+cAlias+"_SUBCON "+cSinal+" '"+aEmpPls[nI,1]+aEmpPls[nI,2]+aEmpPls[nI,3]+aEmpPls[nI,4]+"'"
	   		 ElseIf !Empty(aEmpPls[nI,3])
	            cFiltro+= " ("+cAlias+"_CODEMP ||"+cAlias+"_CONEMP ||"+cAlias+"_VERCON "+cSinal+" '"+aEmpPls[nI,1]+aEmpPls[nI,2]+aEmpPls[nI,3]+"'"
	         ElseIf !Empty(aEmpPls[nI,2])
	            cFiltro+= " ("+cAlias+"_CODEMP ||"+cAlias+"_CONEMP "+cSinal+" '"+aEmpPls[nI,1]+aEmpPls[nI,2]+"'"
	 		 ElseIf !Empty(aEmpPls[nI,1])
	    	    cFiltro+= " ("+cAlias+"_CODEMP "+cSinal+" '"+aEmpPls[nI,1]+"'"
	         EndIf        
		         
		EndIf
	         	
		 If lPLEMPFIL  
		 
		   	If len(aPLEmpFil[2]) > 0
		   		
				For	nJ := 1 to Len(aPLEmpFil[2][1])
			   		cFiltro += " "+cAnd+" "+aPLEmpFil[2][1][nJ]+cSinal+" '"+aEmpPls[nI,6+nJ]+"'"   
		   		Next
		   		
		   	Endif
		   	
			If len(aPLEmpFil[3]) > 0
			
			   For	nL := 1 to Len(aPLEmpFil[3][1])
					cFiltro += aPlEmpFil[3][1][nL] 
			   Next
			   
			EndIf
			
		 Endif
		 
         cFiltro += ")"
         
      EndIf

   Next
   
   If !Empty(cFiltro)
      cFiltro += ")"
   EndIf   
   
EndIf

Return cFiltro
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RetCodEdi ºAutor  ³Alexander           º Data ³  20-09-06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     | Retorna o codigo edi da critica							  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLS                                                        º±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/        
Function RetCodEdi(cCod)
LOCAL cRet    := "0000"
LOCAL cCodOpe := PlsIntPad()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Testa																	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cCod)
   Return cRet
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pega o codigo no BCT													 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BCT->( DbSetOrder(1) ) //BCT_FILIAL + BCT_CODOPE + BCT_PROPRI + BCT_CODGLO
If BCT->( MsSeek( xFilial()+cCodOpe+cCod ) ) .And. !Empty(BCT->BCT_CODED2)
   cRet := BCT->BCT_CODED2
EndIf                          
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VldVlApr ºAutor  ³Helio F. R. Lecchi  º Data ³  26-12-06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     | Verifica para nao deixar informar valor apresentado no BD6 º±±
±±º		 	 ³	 e no BD7 simultaneamente							      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLS                                                        º±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/        
Function VldVlApr()
Local lRet		:= .T.
LOCAL nI 		
LOCAL nJ
LOCAL cCampo 	:= ""
Local lVBD6BD7 := GetNewPar("MV_PLVBD7", .T.)
Local cErro		:= ""

//Validacao dos campos, caso nao existam sera apresentada mensagem na tela 
If oBrwBD6:FieldPos("BD6_VLRAPR") == 0
    If SX3->(DbSeek("BD6_VLRAPR"))
	   cCampo := Trim(X3TITULO())
    Else
		cCampo := ""
    Endif   
	cErro += cCampo + "(BD6_VLRAPR),"
Endif

If oBrwBD6:FieldPos("BD6_SEQUEN") == 0
    If SX3->(DbSeek("BD6_SEQUEN"))
	   cCampo := Trim(X3TITULO())
    Else
		cCampo := ""
    Endif   
	cErro += cCampo + "(BD6_SEQUEN),"
Endif

If oBrwBD6:FieldPos("BD6_CODPRO") == 0
    If SX3->(DbSeek("BD6_CODPRO"))
	   cCampo := Trim(X3TITULO())
    Else
		cCampo := ""
    Endif   
	cErro += cCampo + "(BD6_CODPRO),"
Endif

If oBrwBD7:FieldPos("BD7_VLRAPR") == 0
    If SX3->(DbSeek("BD7_VLRAPR"))
	   cCampo := Trim(X3TITULO())
    Else
		cCampo := ""
    Endif   
	cErro += cCampo + "(BD7_VLRAPR),"
Endif

If oBrwBD7:FieldPos("BD7_SEQUEN") == 0
    If SX3->(DbSeek("BD7_SEQUEN"))
	   cCampo := Trim(X3TITULO())
    Else
		cCampo := ""
    Endif   
	cErro += cCampo + "(BD7_SEQUEN),"
Endif

If oBrwBD7:FieldPos("BD7_CODUNM") == 0
    If SX3->(DbSeek("BD7_CODUNM"))
	   cCampo := Trim(X3TITULO())
    Else
		cCampo := ""
    Endif   
	cErro += cCampo + "(BD7_CODUNM),"
Endif

If Alltrim(cCampo) <> ""
	lRet := .F.
	MsgAlert(STR0180 + cErro + chr(13) +  STR0181 ,STR0182)  //"Campos necessarios a esta rotina não encontrados: "###"Eles devem ser adicionados no layout para este tipo de guia atraves do cadastro tipos de guias (PLSA496)."###"Campos inexistentes."
Endif

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CheckBEAInºAutor  ³PLS-Team            º Data ³  16-11-10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     | Verifica a existencia de um determinado indice no BEA.     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLS                                                        º±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/        
Function CheckBEAIndex(cIndex)
	Local lExite :=	.F.

	SIX->(dbSetOrder(1))
	If SIX->(dbSeek(cIndex))
		lExite :=	.T.
	Else
		MsgInfo(STR0201,"" )
	EndIf
	
Return lExite
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLPTGRVREN³ Autor ³ Microsiga             ³ Data ³ 26.10.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava montagem de uma transacao Ptu Online para            ³±±
±±³          ³ posterior  reenvio                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PLS                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/  
Function PLPTGRVREN(aCab,aIte,cNumSeq,cTpTran,cOpeSol,cOpeDes,cEnvRec,cNomUsr,aQuimio,aRadio)   
LOCAL nFor                       
LOCAL nInd
LOCAL aAux  
LOCAL cndConteu
LOCAL cType 
LOCAL cNumArq  := "1"
LOCAL cDesTran := ""    
LOCAL cChave   := ""
DEFAULT aCab   := {}
DEFAULT aIte   := {}      
DEFAULT aQuimio:= {}
DEFAULT aRadio := {}
           
cOpeSol := Strzero(Val(cOpeSol),4)  
cOpeDes := Strzero(Val(cOpeDes),4)  
           
If PLSALIASEX("B0S") .And. PLSALIASEX("B0T")
	DbSelectArea("B0S")
	DbSelectArea("B0T")
	B0S->(DbSetOrder(1))//B0T_FILIAL+B0T_NUMSEQ+B0T_TIPTRA+B0T_OPESOL+B0T_IDENT+B0T_VARIAV
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se existir registro para mesmo Cod Trans, Tipo Trans e Operadora nao grava ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do Case
      	 Case cTpTran == "00600" 
	        cDesTran := "PEDIDO AUTORIZACAO"    
	    Case cTpTran == "00605" 
	        cDesTran := "COMPLEMENTO AUTORIZ" 
	    Case cTpTran == "00311"        
	        cDesTran := "CANCELAMENTO"
	    Case cTpTran == "00302"        
	        cDesTran := "PEDIDO INSISTENCIA"        
	    Case cTpTran == "00404"        
	        cDesTran := "RESPOSTA AUDITORIA"     
	    Case cTpTran == "00606"       
	        cDesTran := "ORDEM DE SERVICO"      
      	Case cTpTran == "00806"       
	        cDesTran := "ORDEM DE SERVICO"   
        Case cTpTran == "00807"       
	        cDesTran := "RESP DE ORDEM DE SERVICO"
        Case cTpTran == "00804"
	        cDesTran := "AUTOR DE ORDEM DE SERVICO"
		Case cTpTran == "00700"
	        cDesTran := "COMUN DE DECURSO DE PRAZO"
	   	Case cTpTran == "00750"
	        cDesTran := "COMUN DE INTERNACAO OU ALTA"    
    EndCase
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   	//³ Verifica a numeracao do arquivo a ser gravado                              ³
   	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	If !B0S->(DbSeek(xFilial("B0S")+cNumSeq+Space( TamSX3("B0S_NUMSEQ")[1]-Len(cNumSeq) )+cTpTran+cOpeSol)) .And. B0S->(FieldPos("B0S_NUMARQ")) > 0
	    cNumArq := "1"
	Else
	    cChave := B0S->(B0S_FILIAL+B0S_NUMSEQ+B0S_TIPTRA+B0S_OPESOL+B0S_ENVREC)
	    While B0S->(B0S_FILIAL+B0S_NUMSEQ+B0S_TIPTRA+B0S_OPESOL+B0S_ENVREC) == cChave .And. !B0S->(Eof())
	    	If Val(B0S->B0S_NUMARQ) > Val(cNumArq)
	    	    cNumArq := B0S->B0S_NUMARQ 
	    	EndIf
	    	B0S->(DbSkip())
	    EndDo 
	    cNumArq := cValToChar(Val(cNumArq) + 1)      	
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava cabecalho para posterior pesquisa									 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	B0S->(RecLock("B0S",.T.))
	B0S->B0S_FILIAL := xFilial("B0S")
	B0S->B0S_TIPTRA := cTpTran   
	B0S->B0S_DESTRA := cDesTran
	B0S->B0S_NUMSEQ := cNumSeq
	B0S->B0S_OPESOL := cOpeSol
	B0S->B0S_OPEDES := cOpeDes
	B0S->B0S_ENVREC := cEnvRec
	B0S->B0S_NOMUSR := cNomUsr
	B0S->B0S_DATPRO := dDataBase
	B0S->B0S_HORPRO := Substr(Left(Time(),5),1,2)+Substr(Left(Time(),5),4,2)    
    If B0S->(FieldPos("B0S_NUMARQ")) > 0
    	B0S->B0S_NUMARQ := cNumArq
    EndIf	
	B0S->(MsUnLock())
	
	B0T->(DbSetOrder(1))//B0T_FILIAL+B0T_NUMSEQ+B0T_TIPTRA+B0T_OPESOL+B0T_IDENT+B0T_VARIAV+B0T_NUMARQ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava itens                          									 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nFor := 1 To Len(aCab)        
		If B0T->(MsSeek(xFilial("B0T")+cNumSeq+cTpTran+cOpeSol+"CAB"+aCab[nFor,1]+Space(TamSX3("B0T_VARIAV")[1]-len(aCab[nFor,1]))+cNumArq))
	       	B0T->(RecLock("B0T",.F.))  
        	cType := ValType(aCab[nFor,2])
			Do Case
				Case cType == 'C'
					cndConteu := aCab[nFor,2]
				Case cType == 'D'
					cndConteu := DToC(aCab[nFor,2])
				Case cType == 'N'
					cndConteu := AllTrim(Str(aCab[nFor,2]))       
				Case cType == 'L'
				    IIf(aCab[nFor,2], cndConteu := ".T.",cndConteu := ".F.")
			EndCase
			B0T->B0T_CONTEU := cndConteu  
        	B0T->(MsUnLock())
  		Else		
			B0T->(RecLock("B0T",.T.))
			B0T->B0T_FILIAL := xFilial("B0T")
			B0T->B0T_TIPTRA := cTpTran
			B0T->B0T_NUMSEQ := cNumSeq
			B0T->B0T_OPESOL := cOpeSol
			B0T->B0T_OPEDES := cOpeDes
			B0T->B0T_IDENT  := "CAB"
			B0T->B0T_VARIAV := aCab[nFor,1]
			cType := ValType(aCab[nFor,2])
			Do Case
				Case cType == 'C'
					cndConteu := aCab[nFor,2]
				Case cType == 'D'
					cndConteu := DToC(aCab[nFor,2])
				Case cType == 'N'
					cndConteu := AllTrim(Str(aCab[nFor,2]))       
				Case cType == 'L'
				    IIf(aCab[nFor,2], cndConteu := ".T.",cndConteu := ".F.")
			EndCase
			B0T->B0T_CONTEU := cndConteu  
			If B0T->(FieldPos("B0T_NUMARQ")) > 0
				B0T->B0T_NUMARQ := cNumArq  
			EndIf	
			B0T->(MsUnLock())
		EndIf	
	Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava registro de Quimio               									 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nFor := 1 To Len(aQuimio)   
		If B0T->(MsSeek(xFilial("B0T")+cNumSeq+cTpTran+cOpeSol+"QUI"+aQuimio[nFor,1]+Space(TamSX3("B0T_VARIAV")[1]-len(aQuimio[nFor,1]))+cNumArq))
	       	B0T->(RecLock("B0T",.F.))  
        	cType := ValType(aQuimio[nFor,2])
			Do Case
				Case cType == 'C'
					cndConteu := aQuimio[nFor,2]
				Case cType == 'D'
					cndConteu := DToC(aQuimio[nFor,2])
				Case cType == 'N'
					cndConteu := AllTrim(Str(aQuimio[nFor,2]))       
				Case cType == 'L'
				    IIf(aQuimio[nFor,2], cndConteu := ".T.",cndConteu := ".F.")
			EndCase
			B0T->B0T_CONTEU := cndConteu  
        	B0T->(MsUnLock())
		Else
			B0T->(RecLock("B0T",.T.))
			B0T->B0T_FILIAL := xFilial("B0T")
			B0T->B0T_TIPTRA := cTpTran
			B0T->B0T_NUMSEQ := cNumSeq
			B0T->B0T_OPESOL := cOpeSol
			B0T->B0T_OPEDES := cOpeDes
			B0T->B0T_IDENT  := "QUI"
			B0T->B0T_VARIAV := aQuimio[nFor,1]
			cType := ValType(aQuimio[nFor,2])
			Do Case
				Case cType == 'C'
					cndConteu := aQuimio[nFor,2]
				Case cType == 'D'
					cndConteu := DToC(aQuimio[nFor,2])
				Case cType == 'N'
					cndConteu := AllTrim(Str(aQuimio[nFor,2]))       
				Case cType == 'L'
				    IIf(aQuimio[nFor,2], cndConteu := ".T.",cndConteu := ".F.")
			EndCase
			B0T->B0T_CONTEU := cndConteu  
			If B0T->(FieldPos("B0T_NUMARQ")) > 0
				B0T->B0T_NUMARQ := cNumArq  
			EndIf	
		EndIf
		B0T->(MsUnLock())
	Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava registro de Radio                									 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nFor := 1 To Len(aRadio)   
		If B0T->(MsSeek(xFilial("B0T")+cNumSeq+cTpTran+cOpeSol+"RAD"+aRadio[nFor,1]+Space(TamSX3("B0T_VARIAV")[1]-len(aRadio[nFor,1]))+cNumArq))	
			B0T->(RecLock("B0T",.F.))  
        	cType := ValType(aRadio[nFor,2])
			Do Case
				Case cType == 'C'
					cndConteu := aRadio[nFor,2]
				Case cType == 'D'
					cndConteu := DToC(aRadio[nFor,2])
				Case cType == 'N'
					cndConteu := AllTrim(Str(aRadio[nFor,2]))       
				Case cType == 'L'
				    IIf(aRadio[nFor,2], cndConteu := ".T.",cndConteu := ".F.")
			EndCase
			B0T->B0T_CONTEU := cndConteu  
        	B0T->(MsUnLock())
		Else
			B0T->(RecLock("B0T",.T.))
			B0T->B0T_FILIAL := xFilial("B0T")
			B0T->B0T_TIPTRA := cTpTran
			B0T->B0T_NUMSEQ := cNumSeq
			B0T->B0T_OPESOL := cOpeSol
			B0T->B0T_OPEDES := cOpeDes
			B0T->B0T_IDENT  := "RAD"
			B0T->B0T_VARIAV := aRadio[nFor,1]
			cType := ValType(aRadio[nFor,2])
			Do Case
				Case cType == 'C'
					cndConteu := aRadio[nFor,2]
				Case cType == 'D'
					cndConteu := DToC(aRadio[nFor,2])
				Case cType == 'N'
					cndConteu := AllTrim(Str(aRadio[nFor,2]))       
				Case cType == 'L'
				    IIf(aRadio[nFor,2], cndConteu := ".T.",cndConteu := ".F.")
			EndCase
			B0T->B0T_CONTEU := cndConteu  
			If B0T->(FieldPos("B0T_NUMARQ")) > 0
				B0T->B0T_NUMARQ := cNumArq  
			EndIf	
			B0T->(MsUnLock())
		EndIf
	Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava eventos                       									 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	B0T->(DbSetOrder(1))//B0T_FILIAL+B0T_NUMSEQ+B0T_TIPTRA+B0T_OPESOL+B0T_IDENT+B0T_VARIAV+B0T_NUMARQ
	For nFor := 1 To Len(aIte)
		aAux := aClone(aIte[nFor])
		For nInd := 1 To Len(aAux)     
			If B0T->(MsSeek(xFilial("B0T")+cNumSeq+cTpTran+cOpeSol+StrZero(nFor,3)+aAux[nInd,1]+Space(TamSX3("B0T_VARIAV")[1]-len(aAux[nInd,1]))+cNumArq))	
			 	B0T->(RecLock("B0T",.F.))  
			 	cType := ValType(aAux[nInd,2])
				Do Case
					Case cType == 'C'
						cndConteu := aAux[nInd,2]
					Case cType == 'D'
						cndConteu := DToC(aAux[nInd,2])
					Case cType == 'N'
						cndConteu := AllTrim(Str(aAux[nInd,2]))
				EndCase
				B0T->B0T_CONTEU := cndConteu  
  				B0T->(MsUnLock())
			Else
				B0T->(RecLock("B0T",.T.))
				B0T->B0T_FILIAL := xFilial("B0T")
				B0T->B0T_NUMSEQ := cNumSeq
				B0T->B0T_OPESOL := cOpeSol
				B0T->B0T_OPEDES := cOpeDes
				B0T->B0T_IDENT  := StrZero(nFor,3)
				B0T->B0T_VARIAV := aAux[nInd,1]
				B0T->B0T_TIPTRA := cTpTran
				
				cType := ValType(aAux[nInd,2])
				Do Case
					Case cType == 'C'
						cndConteu := aAux[nInd,2]
					Case cType == 'D'
						cndConteu := DToC(aAux[nInd,2])
					Case cType == 'N'
						cndConteu := AllTrim(Str(aAux[nInd,2]))
				EndCase
				B0T->B0T_CONTEU := cndConteu  
				If B0T->(FieldPos("B0T_NUMARQ")) > 0
					B0T->B0T_NUMARQ := cNumArq  
				EndIf	
				B0T->(MsUnLock())
        	EndIf
		Next
	Next
EndIf

Return              
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³PlsGetB0T ³ Autor ³ Microsiga             ³ Data ³ 26/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Carrega aCab e aIte de acordo com B0T					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ PlsGetB0T(cNumSeq,cCodTra,cOpeInt,nInd)					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parƒmetros³ cNumSeq - Numero da requisicao                             ³±±     
±±³          ³ cCodTra - Codigo da transacao                              ³±±   
±±³          ³ cOpeInt - Operadora                                        ³±±  
±±³          ³ nInd - Indice utilizado                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PlsGetB0T(cNumSeq,cCodTra,cOpeInt,nInd,cNumArq)     
Local aCab   := {}
Local aIte   := {}
Local aItem  := {}
Local aQuimio:= {}
Local aRadio := {}
Local cItem  := ""     
Local nTam   := TamSX3("B0T_NUMSEQ")[1]  
Local cField := ""
DEFAULT nInd := 1

If Len(cNumSeq) < nTam
	cNumSeq := cNumSeq + Space( nTam - Len(cNumSeq) )
EndIf          

Iif(nInd == 1,cField := "B0T_OPESOL",cField := "B0T_OPEDES")

B0T->(DbSetOrder(nInd))

B0T->(MsSeek(xFilial()+cNumSeq+cCODTRA+cOpeInt+"CAB"))
While !B0T->(Eof()) .and. xFilial("B0T")+cNumSeq+"CAB"+cCODTRA+cOpeInt == B0T->(B0T_FILIAL+B0T_NUMSEQ+B0T_IDENT+B0T_TIPTRA+&(cField))
	If Alltrim(B0T->B0T_NUMARQ) == Alltrim(cNumArq)         
	    If Alltrim(B0T->B0T_CONTEU) == ".T."
	        aadd(aCab,{B0T->B0T_VARIAV,.T.}) 
	    ElseIf Alltrim(B0T->B0T_CONTEU) == ".F." 
	  		aadd(aCab,{B0T->B0T_VARIAV,.F.}) 
	    Else
	    	aadd(aCab,{B0T->B0T_VARIAV,RTrim(B0T->B0T_CONTEU)}) 
	    Endif
	EndIf
	B0T->(DbSkip())
EndDo

B0T->(MsSeek(xFilial()+cNumSeq+cCODTRA+cOpeInt+"QUI"))
While !B0T->(Eof()) .and. xFilial("B0T")+cNumSeq+"QUI"+cCODTRA+cOpeInt == B0T->(B0T_FILIAL+B0T_NUMSEQ+B0T_IDENT+B0T_TIPTRA+&(cField))
	If Alltrim(B0T->B0T_NUMARQ) == Alltrim(cNumArq)         
	    If Alltrim(B0T->B0T_CONTEU) == ".T."
	        aadd(aQuimio,{B0T->B0T_VARIAV,.T.}) 
	    ElseIf Alltrim(B0T->B0T_CONTEU) == ".F." 
	  		aadd(aQuimio,{B0T->B0T_VARIAV,.F.}) 
	    Else
	    	aadd(aQuimio,{B0T->B0T_VARIAV,RTrim(B0T->B0T_CONTEU)}) 
	    Endif
	EndIf
	B0T->(DbSkip())
EndDo      

B0T->(MsSeek(xFilial()+cNumSeq+cCODTRA+cOpeInt+"RAD"))
While !B0T->(Eof()) .and. xFilial("B0T")+cNumSeq+"RAD"+cCODTRA+cOpeInt == B0T->(B0T_FILIAL+B0T_NUMSEQ+B0T_IDENT+B0T_TIPTRA+&(cField))
	If Alltrim(B0T->B0T_NUMARQ) == Alltrim(cNumArq)         
	    If Alltrim(B0T->B0T_CONTEU) == ".T."
	        aadd(aRadio,{B0T->B0T_VARIAV,.T.}) 
	    ElseIf Alltrim(B0T->B0T_CONTEU) == ".F." 
	  		aadd(aRadio,{B0T->B0T_VARIAV,.F.}) 
	    Else
	    	aadd(aRadio,{B0T->B0T_VARIAV,RTrim(B0T->B0T_CONTEU)}) 
	    Endif
	EndIf
	B0T->(DbSkip())
EndDo
B0T->(MsSeek(xFilial()+cNumSeq+cCODTRA+cOpeInt))
While !B0T->(Eof()) .and. xFilial("B0T")+cNumSeq+cCODTRA+cOpeInt == B0T->(B0T_FILIAL+B0T_NUMSEQ+B0T_TIPTRA+&(cField))
	If !B0T->B0T_IDENT$"CAB-QUI-RAD"
		cItem := B0T->B0T_IDENT
		aItem := {}
		B0T->(MsSeek(xFilial()+cNumSeq+cCODTRA+cOpeInt+cItem))
		While !B0T->(Eof()) .and. xFilial("B0T")+cNumSeq+cItem+cCODTRA+cOpeInt == B0T->(B0T_FILIAL+B0T_NUMSEQ+B0T_IDENT+B0T_TIPTRA+&(cField))
			If Alltrim(B0T->B0T_NUMARQ) == Alltrim(cNumArq)
				aadd(aItem,{B0T->B0T_VARIAV,RTrim(B0T->B0T_CONTEU)})  
			EndIf	
			B0T->(DbSkip())
		EndDo
		If Len(aItem) > 0
			aadd(aIte,aClone(aItem))
		EndIf
	Else
		B0T->(DbSkip())
	EndIf
EndDo

Return {aCab,aIte,aQuimio,aRadio} 
