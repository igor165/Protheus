
#include "PLSMGER.CH"   
#include "COLORS.CH"
#include "PROTHEUS.CH"

Function PLSA232

cMsg := "Esta opcao foi desabilitada em funcao de que a antiga rotina mudanca/retorno de fase por lote e agora "
cMsg += "reprocessamento de guias ter sido reformulada para atender as necessidades que esta rotina fazia antes. "
cMsg += "O sistema vai executar a nova rotina automaticamente."

Aviso( "Atencao!!!", ;
       cMsg,;
       { "Ok" }, 2 ) 	                                                                    

PLSA475() //funcao reprocessamento de guias

Return       

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSCHGPRT
Retorna em F3 selecionável (grid checkbox os graus de parentescos)

@author Renan Martins
@since 07/2016
@version P12
/*/
//-------------------------------------------------------------------
Function PLSCHGPRT(cDado,cCampo)
LOCAL oDlg
LOCAL nOpca     := 0
LOCAL bOK       := { || nOpca := K_OK, oDlg:End() }
LOCAL bCancel   := { || oDlg:End() }
LOCAL oCritica
LOCAL cSQL
LOCAL aCritica  := {}
LOCAL nInd                     
Local nIteMar
Local cBak := cDado
Local lRet := .F.

// variaveis lgpd
local aBls         := {}
local aCampos      := {}
local objCENFUNLGP := CENFUNLGP():New()

DEFAULT cCampo  := ""
                                                                                  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ coloca virgula no comeco (caso tenha inicializador padrao)               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cDado  := AllTrim(cDado)   
if subs(cDado,len(cDado),1) != "," .AND. cDado != ""
	cDado += ","
endif

cSQL := "SELECT BRP_CODIGO, BRP_DESCRI FROM " + RetSQLName("BRP")+" WHERE "
cSQL += "BRP_FILIAL = '"+xFilial("BRP") + "' AND D_E_L_E_T_ = ' ' ORDER BY BRP_FILIAL, BRP_DESCRI"

PLSQuery(cSQL,"TrbBRP")

While ! TRBBRP->(Eof())
	aadd(aCritica,{TRBBRP->BRP_CODIGO,TRBBRP->BRP_DESCRI,If(Alltrim(TRBBRP->BRP_CODIGO)$cDado,.T.,.F.)})
	TRBBRP->(DbSkip())
Enddo

TRBBRP->(DbCloseArea())
DbSelectArea("BRP")


DEFINE MSDIALOG oDlg TITLE "Escolha de Parentesco" FROM ndLinIni,ndColIni TO ndLinFin,ndColFin OF GetWndDefault() //"Escolha de Parentesco"

@ 020,012 SAY oSay PROMPT "Selecione o parentesco" SIZE 100,010 OF oDlg PIXEL COLOR CLR_BLACK //"Selecione o parentesco""

oCritica := TcBrowse():New( 035, 012, 330, 150,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
                                            
oCritica:AddColumn(TcColumn():New(" ",{ || IF(aCritica[oCritica:nAt,3],LoadBitmap( GetResources(), "LBOK" ),LoadBitmap( GetResources(), "LBNO" )) },;
         "@!",nil,nil,nil,015,.T.,.T.,nil,nil,nil,.T.,nil))     

oCritica:AddColumn(TcColumn():New("Código",{ || OemToAnsi(aCritica[oCritica:nAt,1]) },; //"Codigo"
         "@!",nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))     

oCritica:AddColumn(TcColumn():New("Descrição",{ || OemToAnsi(aCritica[oCritica:nAt,2]) },; //"Descricao"
         "@!",nil,nil,nil,200,.F.,.F.,nil,nil,nil,.F.,nil))     

oCritica:SetArray(aCritica)         
oCritica:bLDblClick := { || aCritica[oCritica:nAt,3] := Eval( { || nIteMar := 0, aEval(aCritica, {|x| IIf(x[3], nIteMar++, )}), IIf(nIteMar < 90 .Or. aCritica[oCritica:nAt, 3],IF(aCritica[oCritica:nAt,3],.F.,.T.),.F.) })}

if objCENFUNLGP:isLGPDAt()
   aCampos := {.f., "BRP_CODIGO","BRP_DESCRI"}
   aBls := objCENFUNLGP:getTcBrw(aCampos)

   oCritica:aObfuscatedCols := aBls//{.T., .T., .T., .T., .T., .T., .F., .T.}
endif

ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,{})

If nOpca == K_OK
                  
   cDado := ""
   For nInd := 1 To Len(aCritica)
       If aCritica[nInd,3]
          cDado += aCritica[nInd,1]+","
       Endif 
   Next

Endif
                                  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ tira a virgula do final                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if subs(cDado,len(cDado),1) == ","
	cDado := subs(cDado,1,len(cDado)-1)
endif                

if !empty(cCampo)
	cCampo  := "M->"+cCampo
	&cCampo := cDado 
endif

if ! empty(cDado)
	lRet := .T.
endif

Return(lRet)