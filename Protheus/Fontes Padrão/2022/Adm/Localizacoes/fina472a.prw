#INCLUDE "fina472a.ch"
#INCLUDE "protheus.ch"
#INCLUDE "FWMVCDEF.CH"
/*-*/
#DEFINE _CMOVCONC		"3"		//conciliado
#DEFINE _CMOVNCONC		"2"		//nao conciliadol
#DEFINE _CMOVINCON		"1"		//inconsistente
/* estado do extrato */
#DEFINE _CEXTPCONC		"9"		//parcialmente conciliado
#DEFINE _CEXTENCER		"4"		//encerrado
#DEFINE _CEXTCONC		"3"		//conciliado
#DEFINE _CEXTNCONC		"2"		//nao conciliado
#DEFINE _CEXTINCON		"1"		//inconsistente
/* forma de ingresso */
#DEFINE _CINGMANUAL		"1"		//inclusao manual
#DEFINE _CINGAUTOM		"2"		//inclusao automatica (importado)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF472AEXT  บAutor  ณMicrosiga           บFecha ณ 12/09/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472AIncExt()
Local nRet		   		:= 0

Private lIncExtrato		:= .T.
Private lIncAutomatica	:= .F.
Private lProcImportacao	:= .F.

If SEE->(DbSeek(xFilial("SEE") + SA6->A6_COD + SA6->A6_AGENCIA + SA6->A6_NUMCON))
	If SEE->EE_FORMING == "2"
		lIncAutomatica	:= .T.
	Else
		lIncAutomatica	:= .F.
	Endif
Endif
nRet := FWExecView(STR0012,'FINA472A',MODEL_OPERATION_INSERT,,{ || .T.},,20) //'Inclusใo'
Return((nRet == 0))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF472AEXT  บAutor  ณMicrosiga           บFecha ณ 12/09/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472AVisExt()
Local nRet				:= 0

Private lIncExtrato		:= .F.
Private lIncAutomatica	:= .F.
Private lProcImportacao	:= .F.

nRet := FWExecView(STR0013,'FINA472A',MODEL_OPERATION_VIEW,,{ || .T.},,20) //'Visualiza็ใo'
Return((nRet == 0))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF472AEXT  บAutor  ณMicrosiga           บFecha ณ 12/09/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472AAltExt()
Local nRet				:= 0
Local cEstado			:= ""

Private lIncExtrato		:= .F.
Private lIncAutomatica	:= .F.
Private lProcImportacao	:= .F.
          
//MsgRun("Verificando os movimentos do extrato.","Extratos bancแrios",{|| cEstado := F472AVerExt()})
Processa({|| cEstado := F472AVerExt()},STR0001,STR0002) //"Extratos bancแrios"###"Verificando os movimentos do extrato."
If cEstado == _CEXTCONC
	Help(,,STR0014,,STR0015,1,0) //'Extrato conciliado'###'O extrato jแ estแ conciliado. Serแ permitida sua visualiza็ใo.'
	nRet := 1
Else
	If cEstado == _CEXTENCER
		Help(,,STR0016,,STR0017,1,0) //'Extrato encerrado.'###'O extrato estแ encerrado. Serแ permitida sua visualiza็ใo.'
		nRet := 1
	Endif
Endif
If nRet == 0
	If FJE->FJE_FORING == "2"
		MsgInfo(STR0003,STR0001) //"Extrato incluํdo automticamente, pela importa็ใo de arquivos magn้ticos. Nใo ้ permitida a exclusใo de seus movimentos ou a inclusใo de novos."###"Extratos bancแrios"
		lIncAutomatica	:= .T.
	Else
		lIncAutomatica	:= .F.
	Endif
	nRet := FWExecView(STR0018,'FINA472A',MODEL_OPERATION_UPDATE,,{ || .T.},,20) //'Altera็ใo'
Else
	F472AVisExt()
	nRet := 1
Endif
Return((nRet == 0))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF472AEXT  บAutor  ณMicrosiga           บFecha ณ 12/09/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472AExcExt()
Local nRet				:= 0
Local cEstado			:= ""

Private lIncExtrato		:= .F.
Private lIncAutomatica	:= .F.
Private lProcImportacao	:= .F.
          
//MsgRun("Verificando os movimentos do extrato.","Extratos bancแrios",{|| cEstado := F472AVerExt()})
Processa({|| cEstado := F472AVerExt()},STR0001,STR0002)		//"Extratos bancแrios"	"Verificando os movimentos do extrato."
Do Case
	Case cEstado == _CEXTCONC
		Help(,,STR0014,,STR0015,1,0)		//'Extrato conciliado'		'O extrato jแ estแ conciliado. Serแ permitida sua visualiza็ใo.'
		nRet := 1
	Case cEstado == _CEXTENCER
		Help(,,STR0016,,STR0017,1,0) //'Extrato encerrado.'###'O extrato estแ encerrado. Serแ permitida sua visualiza็ใo.'
		nRet := 1
	Case cEstado == _CEXTPCONC
		Help(,,STR0014,,STR0015,1,0)		//'Extrato conciliado'		'O extrato jแ estแ conciliado. Serแ permitida sua visualiza็ใo.'
		nRet := 1
EndCase
If nRet == 0
	nRet := FWExecView(STR0019,'FINA472A',MODEL_OPERATION_DELETE,,{ || .T.},,20) //'Exclusใo'
Else
	F472AVisExt()
	nRet := 1
Endif
Return((nRet == 0))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA999   บAutor  ณMicrosiga           บFecha ณ 12/09/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ModelDef()
Local nCpo		:= 0
Local aCpos		:= {}
Local oStruFJF
Local oStruFJE
Local oModel    
Local lAutomato := IsBlind() // para ejecuci๓n de scripts automatizados

If lAutomato
   lIncAutomatica := .F.
Endif

oStruFJE := FWFormStruct(1,"FJE")
oStruFJE:SetProperty("FJE_CODEXT",MODEL_FIELD_OBRIGAT,.F.)
oStruFJE:SetProperty("FJE_CODEXT",MODEL_FIELD_WHEN,{|| .F.})
oStruFJE:SetProperty("FJE_CODEXT",MODEL_FIELD_NOUPD,.T.)
/*-*/
oStruFJE:SetProperty("FJE_DTCONC",MODEL_FIELD_OBRIGAT,.F.)
oStruFJE:SetProperty("FJE_DTCONC",MODEL_FIELD_WHEN,{|| .F.})
oStruFJE:SetProperty("FJE_DTCONC",MODEL_FIELD_NOUPD,.T.)
/*-*/
oStruFJF := FWFormStruct(1,"FJF")
/*-*/
oStruFJF:SetProperty("FJF_CODCON",MODEL_FIELD_VALID, {|oModel| F472AValCpo(oModel,"FJF_CODCON",.T.,.T.)})
oStruFJF:SetProperty("FJF_DATMOV",MODEL_FIELD_VALID, {|oModel| F472AValCpo(oModel,"FJF_DATMOV",.T.,.T.)})
oStruFJF:SetProperty("FJF_VALOR",MODEL_FIELD_VALID, {|oModel| F472AValCpo(oModel,"FJF_VALOR",.T.,.T.)})
oStruFJF:SetProperty("FJF_DESCON",MODEL_FIELD_VALID, {|oModel| F472AValCpo(oModel,"FJF_DESCON",.T.,.T.)})
/* adiciona campos virtuais */
oStruFJF:AddField(AllTrim(SX3->(RetTitle("FJF_ESTMOV"))),"","FJFESTMOV","C",10,0,{|| .T.},NIL,{},NIL,FwBuildFeature(STRUCT_FEATURE_INIPAD,"F472AEstMov(FJF->FJF_ESTMOV)"),NIL,NIL,.T.)
oStruFJF:AddField(AllTrim(SX3->(RetTitle("FJF_ESTMOV"))),"","FJFOBSMOV","C",TamSX3("FJF_OBSMOV")[1],0,{|| .F.},{|| .T.},{},NIL,FwBuildFeature(STRUCT_FEATURE_INIPAD,"FJF->FJF_OBSMOV"),NIL,NIL,.T.)
/*
bloqueia a edicao de movimentos conciliados */
aCpos := oStruFJF:GetFields()
For nCpo := 1 To Len(aCpos)
	oStruFJF:SetProperty(aCpos[nCpo,3],MODEL_FIELD_WHEN,{|| F472ValEdi()})
Next
/*-*/
oModel := MPFormModel():New('MOVEXTBANC',,,{|oModelGrid, nLine, cAction, cField| F472AGrvExt(oModelGrid, nLine, cAction, cField)})
	oModel:AddFields('FJEEXT',/*cOwner*/,oStruFJE,/*Pre-Validacao*/,{|oMod| F472AValSCab(oMod)},/*Carga*/)
	/*-*/
	oModel:AddGrid('FJFMOV','FJEEXT',oStruFJF,,,)
	/*-*/
	oModel:GetModel('FJEEXT'):SetDescription(STR0024)	//'Movimenta็ใo'
	oModel:GetModel('FJFMOV'):SetDescription(STR0024)
	/*
	Se inclusao automatica (importacao), nao permite a exclusao nem a inclusao de linhas, apenas a alteracao das que forma importadas.*/
	oModel:GetModel('FJFMOV'):SetNoInsertLine(lIncAutomatica)
	oModel:GetModel('FJFMOV'):SetNoDeleteLine(lIncAutomatica)
	/*-*/
	oModel:SetRelation('FJFMOV',{{'FJF_FILIAL','xFilial( "FJF" )'},{'FJF_CODEXT','FJE_CODEXT'}},FJF->(IndexKey(2)))
	oModel:SetDescription('Extrato bancแrio')
	oModel:SetPrimaryKey({"FJE_FILIAL","FJE_CODEXT"})
Return(oModel)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA999   บAutor  ณMicrosiga           บFecha ณ 12/09/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ViewDef()
Local aAux		:= {}
Local oModel
Local oStruFJF
Local oStruFJE
Local oView

oModel := FWLoadModel('FINA472A')
/*-*/
oStruFJE := FWFormStruct(2,"FJE")
	oStruFJE:RemoveField('FJE_BCOCOD')
	oStruFJE:RemoveField('FJE_BCOAGE')
	oStruFJE:RemoveField('FJE_BCOCTA')
	oStruFJE:RemoveField('FJE_ESTEXT')
	oStruFJE:RemoveField('FJE_FORING')
	/*-*/
	If lIncExtrato
		oStruFJE:RemoveField('FJE_CODEXT')
		oStruFJE:RemoveField('FJE_DTCONC')
	Endif
oStruFJF := FWFormStruct(2,'FJF')
	oStruFJF:RemoveField('FJF_CODEXT')
	oStruFJF:RemoveField('FJF_ESTMOV')
	oStruFJF:RemoveField('FJF_OBSMOV')
	oStruFJF:SetProperty("FJF_SEQEXT",MVC_VIEW_CANCHANGE,.F.)
	/* adiciona campos virtuais */
	oStruFJF:AddField('FJFESTMOV','01',AllTrim(SX3->(RetTitle("FJF_ESTMOV")))," ",{},'C','@BMP',NIL,'',.F.,NIL,NIL,{},NIL,'{|| F472AEstMov(FJF->FJF_ESTMOV)}',.T.,NIL)
	oStruFJF:AddField('FJFOBSMOV','02',AllTrim(SX3->(RetTitle("FJF_OBSMOV")))," ",{},'C','',NIL,'',.T.,NIL,NIL,{},NIL,'{|| FJF->FJF_OBSMOV}',.T.,NIL)
/*-*/
oView := FWFormView():New()
	oView:SetModel(oModel)
	/*-*/
	If lIncAutomatica .And. lIncExtrato
		oView:AddUserButton(STR0020,'',{|oView| F472AImpExt(oView)}) //'Importacao'
	Endif
	oView:AddUserButton(STR0044,'',{|oView| F472ALegenda(oView)}) 	//"Legenda"
	/*-*/
	/* adiciona os dados do banco */
	oView:CreateHorizontalBox('BANCO',5)
	oView:AddOtherObject("oPnlBco", {|oPanel| F472AObjs(oPanel)})
	oView:SetOwnerView('oPnlBco','BANCO')
	/*-*/
	oView:AddField('VIEW_FJE',oStruFJE,'FJEEXT')
	oView:CreateHorizontalBox('EXTRATO',If(lIncExtrato,15,23))
	oView:SetOwnerView('VIEW_FJE','EXTRATO')
	/*-*/
	oView:AddGrid('VIEW_FJF',oStruFJF,'FJFMOV')
	oView:AddIncrementField('VIEW_FJF','FJF_SEQEXT')
	oView:CreateHorizontalBox('MOVIMENTOS',If(lIncExtrato,80,72))
	oView:SetOwnerView('VIEW_FJF','MOVIMENTOS')
	/*-*/
	oView:SetFieldAction("FJFOBSMOV",{|oView,cView,cIDCpo,xVal| F472AAcaoCpo(oView,cView,cIDCpo,xVal)})
	/*-*/
Return(oView)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF472AEXT  บAutor  ณMicrosiga           บFecha ณ 12/09/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472AObjs(oPanel)
Local cBanco	:= ""
Local oPnlBco
Local oPnlSep1
Local oPnlSep2
Local oFonte
/*
Painel com os dados do banco: banco, agencia etc */
oFonte := TFont():New(,10,16,,.T.,,,)
cBanco := AllTrim(SA6->A6_COD) + "/" + AllTrim(SA6->A6_AGENCIA) + "/" + AllTrim(SA6->A6_NUMCON) + " - " + AllTrim(SA6->A6_NOME)
oPnlSep1 := TPanel():New(0,0,"",oPanel,,,,,,100,100,,)
	oPnlSep1:Align := CONTROL_ALIGN_TOP
	oPnlSep1:nHeight := 3
oPnlBco := TPanel():New(0,0," " + cBanco,oPanel,oFonte,,,,,100,100,,)
	oPnlBco:Align := CONTROL_ALIGN_TOP
oPnlSep2 := TPanel():New(0,0,"",oPanel,,,,,RGB(0,0,0),100,100,,)
	oPnlSep2:Align := CONTROL_ALIGN_BOTTOM
	oPnlSep2:nHeight := 1
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA472A  บAutor  ณMicrosiga           บFecha ณ 05/10/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472ValEdi()
Local lRet      := .T.
Local cEstado   := ""
Local oView
Local lAutomato := IsBlind() // para ejecuci๓n de scripts automatizados
oView := FWViewActive()
If !lAutomato
	cEstado := oView:GetValue("FJFMOV","FJF_ESTMOV")
	lRet := (cEstado <> _CMOVCONC)
Endif
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA472A  บAutor  ณMicrosiga           บFecha ณ 21/09/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472AValCpo(oModel,cCpo,lAtuEst,lMsg,cMsg)
Local lRet		:= .T.
Local cTexto	:= ""

Default cCpo	:= ""
Default lAtuEst	:= .F.
Default lMsg	:= .F.

cMsg := ""

Do Case
	Case cCpo == "FJF_VALOR"
		nVal := oModel:GetValue("FJF_VALOR")
		If Empty(nVal)
			lRet := .F.
			cMsg := STR0004 //"Valor do movimento nใo informado."
		Endif
	Case cCpo == "FJF_DATMOV"
		dData := oModel:GetValue("FJF_DATMOV")
		If Empty(dData)
			lRet := .F.
			cMsg := STR0005 //"Data do movimento nใo informada."
		Else
			oModObj := oModel:GetModel()
			If dData > oModObj:GetValue("FJEEXT","FJE_DTEXT")
				lRet := .F.
				If Empty(cCpo) .Or. cCpo == "FJF_DATMOV"
					cMsg := STR0006 //"A data do movimento ้ superior a data de corte."
				Endif
			Endif
		Endif
	Case cCpo == "FJF_CODCON"
		cTexto := oModel:GetValue("FJF_CODCON")
		If !Empty(cTexto)
			If !(SEJ->(DbSeek(xFilial("SEJ") + SA6->A6_COD + cTexto)))
				lRet := .F.
				cMsg := STR0007 //"O c๓digo de conceito nใo existe na tabela de ocorr๊ncias bancแrias."
			Else
				oModel:LoadValue('FJF_DESCON',SEJ->EJ_DESCR) 
			Endif
		Else
			cTexto := oModel:GetValue("FJF_DESCON")
			If Empty(cTexto)
				lRet := .F.
				cMsg := STR0008 //"Conceito e descri็ใo do movimento nใo informados."
			Endif
		Endif
	Case cCpo == "FJF_DESCON"
		cTexto := oModel:GetValue("FJF_DESCON")
		If Empty(cTexto)
			lRet := .F.
			cMsg := STR0009 //"Descri็ใo do movimento nใo informada."
		Endif
EndCase
/*-*/
If lRet
	If lAtuEst
		oModel:LoadValue('FJF_ESTMOV',_CMOVNCONC)
		oModel:LoadValue('FJFESTMOV',F472AEstMov(_CMOVNCONC))
		oModel:LoadValue('FJFOBSMOV',' ')
		oModel:LoadValue('FJF_OBSMOV',' ')
	Endif
Else
	If lAtuEst
		oModel:LoadValue('FJF_ESTMOV',_CMOVINCON)
		oModel:LoadValue('FJFESTMOV',F472AEstMov(_CMOVINCON))
		oModel:LoadValue('FJFOBSMOV',Substr(cMsg,1,Len(FJF->FJF_OBSMOV)))
		oModel:LoadValue('FJF_OBSMOV',Substr(cMsg,1,Len(FJF->FJF_OBSMOV)))
	Endif
	If lMsg .And. !lProcImportacao
		MsgAlert(cMsg,STR0010 + " - " + AllTrim(SX3->(RetTitle("FJF_SEQEXT"))) + " " + oModel:GetValue("FJF_SEQEXT")) //"Inconsist๊ncias"
	Endif
	lRet := (lProcImportacao .Or. lRet)
Endif
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF472AEXT  บAutor  ณMicrosiga           บFecha ณ 13/09/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472AValLin(oModel,aTexto)
Local lRet		:= .T.
Local cTexto	:= ""

aTexto := {}
/*
validacao do valor do movimento */
F472AValCpo(oModel,"FJF_VALOR",.F.,.F.,@cTexto)
If !Empty(cTexto)
	Aadd(aTexto,cTexto)
Endif
/* 
validacao da data do movimento */
F472AValCpo(oModel,"FJF_DATMOV",.F.,.F.,@cTexto)
If !Empty(cTexto)
	Aadd(aTexto,cTexto)
Endif
/*
validacao do codigo de conceito */
F472AValCpo(oModel,"FJF_CODCON",.F.,.F.,@cTexto)
If !Empty(cTexto)
	Aadd(aTexto,cTexto)
Endif
/* 
validacao da descricao do conceito */
F472AValCpo(oModel,"FJF_DESCON",.F.,.F.,@cTexto)
If !Empty(cTexto)
	Aadd(aTexto,cTexto)
Endif
/*-*/
If Empty(aTexto)
	oModel:LoadValue('FJF_ESTMOV',_CMOVNCONC)
	oModel:LoadValue('FJFESTMOV',F472AEstMov(_CMOVNCONC))
	oModel:LoadValue('FJFOBSMOV',' ')
	oModel:LoadValue('FJF_OBSMOV',' ')
	lRet := .T.
Else
	oModel:LoadValue('FJF_ESTMOV',_CMOVINCON)
	oModel:LoadValue('FJFESTMOV',F472AEstMov(_CMOVINCON))
	If Len(aTexto) > 1
		oModel:LoadValue('FJFOBSMOV','...')
		oModel:LoadValue('FJF_OBSMOV','...')
	Else
		oModel:LoadValue('FJFOBSMOV',Substr(aTexto[1],1,TamSX3("FJF_OBSMOV")[1]))
		oModel:LoadValue('FJF_OBSMOV',Substr(aTexto[1],1,TamSX3("FJF_OBSMOV")[1]))
	Endif
	lRet := (lProcImportacao .Or. lRet)
Endif
Return(lRet) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA472A  บAutor  ณMicrosiga           บFecha ณ 20/09/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472AAcaoCpo(oView,cView,cIDCpo,xVal)
Local nTexto	:= 0
Local lMsg 		:= .F.
Local aTexto	:= {}
Local cTexto	:= ""
Local oMod

oMod := oView:GetModel("FJFMOV")
Do Case
	Case cIDCpo == "FJF_CODCON"
		SEJ->(DbSeek(xFilial("SEJ") + SA6->A6_COD + xVal))
		oMod:LoadValue('FJF_DESCON',SEJ->EJ_DESCR) 
		lMsg := .F.
	Case cIDCpo == "FJFOBSMOV"
		lMsg := !(F472AValLin(oMod,@aTexto))
		lMsg := .T.
EndCase
If lMsg
	If !Empty(aTexto)
		cTexto := ""
		For nTexto := 1 To Len(aTexto)
			cTexto += aTexto[nTexto]
			cTexto += CRLF
		Next
	Else
		cTexto := STR0011 //"Nใo hแ inconsist๊ncias para este movimento."
	Endif
	MsgAlert(cTexto,STR0010 + " - " + AllTrim(SX3->(RetTitle("FJF_SEQEXT"))) + " " + oMod:GetValue("FJF_SEQEXT"))		//"Inconsist๊ncias"
Endif
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF472AEXT  บAutor  ณMicrosiga           บFecha ณ 13/09/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472AValSCab(oModel)
Local lRet		:= .T.
Local nVal		:= 0
Local dData		:= Ctod("//")

/*
validacao do saldo do extrato */
nVal := oModel:GetValue("FJE_SLDEXT")
If Empty(nVal)
	Help( ,, 'Help',, STR0027, 1, 0 )			//"Informe o saldo do banco para o extrato."
	lRet := .F.
Endif
/* 
validacao da data do movimento */
If lRet
	dData := oModel:GetValue("FJE_DTEXT")
	If Empty(dData)
		Help( ,, 'Help',,STR0028, 1, 0 )		// 'Informe data de corte do extrato.'
		lRet := .F.
	Endif
Endif
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF472AEXT   บAutor  ณMicrosiga           บFecha ณ 13/09/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
*/
Function F472AGrvExt(oModel)
Local nLin		:= 0
Local nTamGrd	:= 0
Local lOk		:= .T.
Local cExtrato	:= "" 
Local oFJFMov
Local lAutomato := IsBlind() // para ejecuci๓n de scripts automatizados

If lAutomato
   lIncAutomatica := .F.
Endif

If oModel:GetOperation() == MODEL_OPERATION_INSERT
	cExtrato := GetSXENum("FJE","FJE_CODEXT")
	/*
	autualiza os dados do banco no cadastro de extratos */
	oModel:LoadValue('FJEEXT','FJE_CODEXT',cExtrato)
	oModel:LoadValue('FJEEXT','FJE_BCOCOD',SA6->A6_COD)
	oModel:LoadValue('FJEEXT','FJE_BCOAGE',SA6->A6_AGENCIA)
	oModel:LoadValue('FJEEXT','FJE_BCOCTA',SA6->A6_NUMCON)
	If lIncAutomatica
		oModel:LoadValue('FJEEXT','FJE_FORING',_CINGAUTOM)
	Else
		oModel:LoadValue('FJEEXT','FJE_FORING',_CINGMANUAL)
	Endif
Endif
/*
Verifica se ha movimentos inconsistentes e atualiza o estado do extrato */
If oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE
	oFJFMov := oModel:GetModel("FJFMOV")
	nTamGrd := oFJFMov:Length()
	nLin := 0
	While lOk .And. (nLin < nTamGrd)
		nLin++
		oFJFMov:GoLine(nLin)
		If !oFJFMov:IsDeleted()
			lOk := (oFJFMov:GetValue("FJF_ESTMOV") <> _CMOVINCON)
		Endif
	Enddo
	If !lOk
		oModel:LoadValue("FJEEXT","FJE_ESTEXT",_CEXTINCON)
	Else
		oModel:LoadValue("FJEEXT","FJE_ESTEXT",_CEXTNCONC)
	Endif
Endif
/*-*/
FWFormCommit(oModel)
If oModel:GetOperation() == MODEL_OPERATION_INSERT
	ConFirmSX8()
Endif
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF472AEXT  บAutor  ณMicrosiga           บFecha ณ 13/09/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472AEstMov(cEstMov,aEst)
Local cEstado		:= ""
Local cTitulo       := ""

Default cEstMov		:= ""
Default aEst        := {}

aEst := {}
Do Case 
	Case cEstMov == _CMOVINCON		//inconsistente
		cEstado := "DISABLE"
		cTitulo := STR0041			//"Inconsistente"
	Case cEstMov == _CMOVNCONC		//nao conciliado
		cEstado := "BR_AMARELO"
		cTitulo := STR0042			//"Nใo conciliado"
	Case cEstMov == _CMOVCONC		//conciliado
		cEstado := "BR_VERDE"
		cTitulo := STR0043			//"Conciliado"
	OtherWise
		cEstado := "LBNO"
		cTitulo := " "
EndCase
aEst := {cEstado,cTitulo}
Return(cEstado)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF472AEXT  บAutor  ณMicrosiga           บFecha ณ 14/09/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472AVerExt()
Local cQuery	:= ""
Local cAliasFJF	:= ""
Local cEstado	:= "" 
Local nMovim	:= 0
Local nNaoConc	:= 0
Local nConcil	:= 0
Local aArea		:= {}

If FJE->FJE_ESTEXT == _CEXTENCER
	cEstado := _CEXTENCER
Else
	aArea := GetArea()
	ProcRegua(7)
	/* verifica os movimentos*/
	cQuery := "select count(*) NMOVIMENTOS from " + RetSqlName("FJF")
	cQuery += " where FJF_FILIAL = '" + xFilial("FJF") + "'"
	cQuery += " and FJF_CODEXT = '" + FJE->FJE_CODEXT + "'"
	cQuery += " and D_E_L_E_T_= ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasFJF := GetNextAlias()
	IncProc()
	DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasFJF,.F.,.T.)
	(cALiasFJF)->(DbGoTop())
	IncProc()
	nMovim := (cAliasFJF)->NMOVIMENTOS
	DbSelectArea(cAliasFJF)
	DbCloseArea()
	IncProc()
	/* verifica os movimentos conciliados */
	cQuery := "select count(*) NMOVIMENTOS from " + RetSqlName("FJF")
	cQuery += " where FJF_FILIAL = '" + xFilial("FJF") + "'"
	cQuery += " and FJF_CODEXT = '" + FJE->FJE_CODEXT + "'"
	cQuery += " and FJF_ESTMOV = '" + _CMOVCONC + "'"
	cQuery += " and D_E_L_E_T_= ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasFJF := GetNextAlia()
	IncProc()
	DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasFJF,.F.,.T.)
	(cALiasFJF)->(DbGoTop())
	IncProc()
	nConcil := (cAliasFJF)->NMOVIMENTOS
	DbSelectArea(cAliasFJF)
	DbCloseArea()
	IncProc()
	RestArea(aArea)
	/*-*/
	nNaoConc := nMovim - nConcil
	If nNaoConc == 0		//nao ha movimentos nao conciliados, logo o extrato esta totalmente conciliado
		cEstado := _CEXTCONC
	Else
		If nConcil > 0		//ha alguns movimentos conciliados, entao o extrato esta parcialmente conciliado
			cEstado := _CEXTPCONC
		Endif
	Endif
	IncProc()
Endif
Return(cEstado)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA472A  บAutor  ณMicrosiga           บFecha ณ 21/09/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472AImpExt(oView)
Local nLin		:= 0
Local nLinhas	:= 0
Local lProc		:= .F.
Local aCposCab	:= {}
Local aValCab	:= {}
Local oEstrFJE
Local oFJF
Local oFJE
Local oModel

oFJE := oView:GetModel("FJEEXT")
If F472AValSCab(oFJE)
	oFJF := oView:GetModel("FJFMOV")
	nLinhas := oFJF:Length()
	If nLinhas > 0
		oFJF:SetNoInsertLine(.F.)
		oFJF:SetNoDeleteLine(.F.)
		oFJF := oView:GetModel("FJFMOV")
		For nLin := 1 To nLinhas
			oFJF:GoLine(nLin)
			oFJF:DeleteLine()
		Next
		/*-*/
		oEstrFJE := oFJE:GetStruct()
		aCposCab := oEstrFJE:GetFields()
		aValCab := {}
		For nLin := 1 To Len(aCposCab)
			Aadd(aValCab,oFJE:GetValue(aCposCab[nLin,3]))
		Next
		oModel := oView:GetModel()
		oModel:DeActivate()
		oModel:Activate()
		For nLin := 1 To Len(aCposCab)
			oFJE:LoadValue(aCposCab[nLin,3],aValCab[nLin])
		Next
		lProc := .T.
	Else
		lProc := .T.
	Endif
	If lProc
		oFJF:SetNoInsertLine(.F.)
		oFJF:SetNoDeleteLine(.F.)
		lProcImportacao := .T.
		F472AImpCsv(oView,MODEL_OPERATION_INSERT)
		lProcImportacao := .F.
		oFJF:SetNoInsertLine(.T.)
		oFJF:SetNoDeleteLine(.T.)
	Endif
Endif
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA472A  บAutor  ณMicrosiga           บFecha ณ 24/09/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472ARegConc(aRegConc)
Local lRet			:= .F.
Local nReg			:= 0
Local cCtrl			:= ""
Local cFilFJG		:= ""
Local aArea			:= {}

Default aRegConc	:= {}

If !Empty(aRegConc)
	aArea := GetArea()
	cCtrl := GetSXENum("FJG","FJG_NRCTRL")
	cFilFJG := xFilial("FJG")
	For nReg := 1 To Len(aRegConc)
		RecLock("FJG",.T.)
		Replace FJG_FILIAL	With cFilFJG
		Replace FJG_NRCTRL	With cCtrl
		Replace FJG_DATCON	With dDataBase
		Replace FJG_TABCON	With aRegConc[nReg,1]
		Replace FJG_REGCON	With StrZero(aRegConc[nReg,2],TamSX3("FJG_REGCON")[1],0)
		FJG->(MsUnLock())
	Next
	FJG->(DbCommit())
	ConfirmSX8()
	RestArea(aArea)
	lRet := .T.
Endif
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA472A  บAutor  ณMicrosiga           บFecha ณ 24/09/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472ARegDConc(aRegDConc)
Local nReg			:= 0
Local cReg			:= ""
Local cCtrl			:= ""
Local cFilFJG		:= ""
Local aRet			:= {}
Local aArea			:= {}

Default aRegDConc	:= {}

If !Empty(aRegDConc)
	aArea := GetArea()
	cFilFJG := xFilial("FJG")
	aRet := {}
	For nReg := 1 To Len(aRegDConc)
		FJG->(DbSetOrder(2))
		cReg := StrZero(aRegDConc[nReg,2],TamSX3("FJG_REGCON")[1],0)
		If FJG->(DbSeek(cFilFJG + aRegDConc[nReg,1] + cReg))
			cCtrl := FJG->FJG_NRCTRL
			FJG->(DbSetOrder(1))
			If FJG->(DbSeek(cFilFJG + cCtrl))
				While !(FJG->(Eof())) .And. (FJG->FJG_FILIAL) == cFilFJG .And. (FJG->FJG_NRCTRL == cCtrl)
					RecLock("FJG",.F.)
					Aadd(aRet,{FJG->FJG_TABCON,Val(FJG->FJG_REGCON)})
					FJG->(DbDelete())
					FJG->(MsUnLock())
					FJG->(DbSkip())
				Enddo
			Endif
		Endif
	Next
	FJG->(DbCommit())
	RestArea(aArea)
Endif
Return(Aclone(aRet))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA472A  บAutor  ณMicrosiga           บFecha ณ 04/10/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472ALote(cTab,nReg)
Local cQuery	:= ""
Local cAliasFJG	:= ""
Local aArea		:= {}
Local aRet		:= {}

Default cTab	:= ""
Default nReg	:= 0

If !Empty(cTab) .And. !Empty(nReg)
	aArea := GetArea()
	FJG->(DbSetOrder(2))
	If FJG->(DbSeek(xFilial("FJG") + cTab + StrZero(nReg,TamSX3("FJG_REGCON")[1],0)))
		cQuery := "select FJG_NRCTRL,FJG_TABCON,FJG_REGCON,FJG_DATCON from " + RetSQLName("FJG")
		cQuery += " where FJG_FILIAL = '" + xFilial("FJG") + "'"
		cQuery += " and D_E_L_E_T_ = ' '"
		cQuery += " and FJG_NRCTRL = '" + FJG->FJG_NRCTRL + "'"
		cQuery := ChangeQuery(cQuery)
		cAliasFJG := GetNextAlias()
		DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasFJG,.F.,.T.)
		TcSetField(cAliasFJG,"FJG_DATCON","D",8,0)
		(cALiasFJG)->(DbGoTop())
		aRet := {}
		While ! ((cAliasFJG)->(Eof()))
			Aadd(aRet,{(cAliasFJG)->FJG_NRCTRL,(cAliasFJG)->FJG_TABCON,Val((cAliasFJG)->FJG_REGCON),(cAliasFJG)->FJG_DATCON})
			(cAliasFJG)->(DbSkip())
		Enddo
		DbSelectArea(cAliasFJG)
		DbCloseArea()
	Endif
	RestArea(aArea)
Else
	aRet := {}
Endif
Return(Aclone(aRet))
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA472   บAutor  ณMicrosiga           บFecha ณ 11/10/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472ALegenda(oView)
Local aLeg  := {}
Local aRet  := {}

Aadd(aLeg,{F472AEstMov(_CMOVINCON,@aRet),aRet[2]})
Aadd(aLeg,{F472AEstMov(_CMOVNCONC,@aRet),aRet[2]})
Aadd(aLeg,{F472AEstMov(_CMOVCONC,@aRet),aRet[2]})
/*_*/
BrwLegenda(STR0001,AllTrim(SX3->(RetTitle("FJF_ESTMOV"))),aLeg)
Return()



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ F472AImpCsv ณ Autor ณ Carlos Chigres     ณ Data ณ 19/09/12 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Importacao de Lancamentos, no formato CSV, a partir de     ณฑฑ
ฑฑณ          ณ um Layout (Retorno) pre gravado.                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ                                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function F472AImpCsv( oView )

Local cChave			:= " "
Local cOrig				:= Alias()
Local lRet				:= .T.

Local cArqConf			:= ""
Local cArqEnt			:= ""
Local aRet				:= {}

Private lIncExtrato		:= .T.
Private lIncAutomatica	:= .T.

//--- Caracter Separador de Casa Decimal
Private cChrSepDec		:= SPACE( 1 )

Private aCposCab  		:= {}
Private aCposMov  		:= {}
Private aCposSep 		:= {}
Private aCSVFile		:= {}

aCposCab	:= {{.F.,'Data Inicial'  ,'D'	,"E5_DATA"		,0,0,nil},;
				{.F.,'Data Final'    ,'D'	,"E5_DATA"		,0,0,nil},;
				{.F.,'Cod. Banco'    ,'C'	,"E5_BANCO"		,0,0,nil},;
				{.F.,'Cod. Agencia'  ,'C'	,"E5_AGENCIA"	,0,0,nil},;
				{.F.,'Conta'         ,'C'	,"E5_CONTA"		,0,0,nil},;
				{.F.,'Saldo Anterior','N'	,"E5_VALOR"		,0,0,nil}}
	
aCposMov	:= {{.F.,'Data Movimento'  ,'D'	,"E5_DATA"		,0,0,nil},;
				{.F.,'Num. Movimento'  ,'C'	,"E5_NUMERO"	,0,0,nil},;
				{.F.,'Vlr Lan็amento'  ,'N'	,"E5_VALOR"		,0,0,nil},;
				{.F.,'Tipo Lan็amento' ,'C'	,"FJF_CODCON"	,0,0,nil},;
				{.F.,'Desc. Lan็amento','C'	,"FJF_DESCON"	,0,0,nil},;
				{.F.,'Saldo'           ,'N'	,"E5_VALOR"		,0,0,nil},;
				{.F.,'Moeda'           ,'C'	,"E5_MOEDA"		,0,0,nil}}//'Moeda'

//--- Para os Separadores
aCposSep	:= {{ .F. , nil	, SPACE(1) },;  // 'Separador Arquivo'
				{ .F. , nil	, SPACE(1) },;  // 'Separador Decimais'
				{ .F. , "N"	, 0 } }         // 'Digitos Menos Significativos'


 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Aquisicao do arquivo de configuracao ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 dbSelectArea( "SEE" )
 //---- EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA  
 dbSetOrder( 1 )
 //
 cChave := xFilial( "SEE" ) + SA6->A6_COD + SA6->A6_AGENCIA + SA6->A6_NUMCON
 //
If dbSeek( cChave )

   cArqConf := SEE->EE_ARQCFG
 
Else

    Aviso( STR0020 , STR0029 , { STR0030 } )	//"Importa็ใo"   "Nใo foi localizado o Arquivo de Configura็ใo de Retorno Bancแrio. Verifique o Cadastro de Parametros Bancarios."  Sair
    dbSelectArea( cOrig )
    Return .F.

EndIf
 
dbSelectArea( cOrig )

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ L arquivo de configuracao do CSV e grava Arrays de Movimentacao e de Caracteres Separadores ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
lRet := CFG57Load( cArqConf, @aCposCab, @aCposMov, @aCposSep )

If lRet
	If Len( aCposMov ) == 0

		Aviso( STR0020 , STR0031 , { STR0030 } ) //"Imprtacao" , "Houve erro na recupera็ใo do array de Movimenta็๕es. Nใo ้ possivel prosseguir." , { "Sair"
		Return .F.

	EndIf

	If Len( aCposSep ) == 0

		Aviso( STR0020 , STR0032 , { STR0030 } )	// "Erro" , "Houve erro na recupera็ใo dos caracteres separadores. Nใo ้ possivel prosseguir." , { "Sair" }
		Return .F.

	EndIf

//--- Recupera Caracter de Separacao Decimal
	cChrSepDec := aCposSep[ 2 ][ 3 ]

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Aquisicao do arquivo CSV para a Importacao ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
// STR0012 "Estrut. de Arquiv de Retorno"
// STR0013 "Arquivo .CSV |*.CSV"
// STR0014 "Importar Retorno Bancแrio"
// If ParamBox( {	{ 6, STR0012, padr("",150),"",,"", 90 ,.T.,STR0013,"",GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE}},STR0014,@aRet)  	 //"Estrut. de Entidades Bancแrias"###"Arquivo .CSV |*.CSV"

	If ParamBox( {	{ 6, STR0033, padr("",150),"",,"", 90 ,.F.,STR0034 + " .CSV |*.CSV" ,"",GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE}},STR0035 ,@aRet)  		//"Estrut. de Arquiv de Retorno"  "Arquivo"  "Importar Retorno Bancแrio"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Transforma arquivo CSV em array   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cArqEnt  := aRet[ 1 ]
		If !Empty(cArqEnt)
			aCSVFile := CFG57Csv( cArqEnt )

			If Len( aCSVFile ) == 0

				Aviso( STR0020,STR0036, { STR0030 } )		//importacao "Houve erro na leitura do Arquivo CSV de Retorno. Nใo ้ possivel prosseguir." , { "Sair" }

			Else

				Processa( {|lEnd| F472AGerFJF( oView ) } )  // Chamada com regua

			EndIf

		Else

			Aviso( STR0020 , STR0037 , { STR0030 } ) 		//Imprtacao , "Nenhum arquivo do tipo CSV foi selecionado. Nใo ้ possivel prosseguir." , { "Sair" }

		EndIf
	Endif
Endif

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ F472AGerFJF ณ Autor ณ Carlos Chigres     ณ Data ณ 19/09/12 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑณDescri…o ณ Processamento da Importacao de Lancamentos                 ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ F472ImpCsv                                                 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function F472AGerFJF( oView )

//--- Ambiente
Local aArea	 := GetArea()

//--- Genericas
Local nX     := 1
Local nY     := 1
Local cAux1  := " "
Local cAux2  := " "

Local aLinha    := {}
Local lSavLinha := .F.
Local lFirstLi  := .T.

//--- Lidas a partir do CSV
Local cDescrMov	:= " "
Local cCodMov	:= " "
Local nValorMov := " "
Local cNumMov	:= " "
Local cDataMov  := " "

//--- MVC
Local oModel  := FWModelActive()
Local oFJF    := oModel:GetModel("FJFMOV")
Local nLinha  := 1
Local cStaMov := nil


  //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  //ณ Leitura do array aCsvFile ณ
  //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
  For nX := 1 To Len( aCsvFile )

	  aLinha	:= {}

	  lSavLinha	:= .T.

      //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
      //ณ Tratamento Coluna a Coluna, com base na  ณ
      //ณ Configuracao de Movimento                ณ
      //ณ                                          ณ
      //ณ Variaveis de Saida deste bloco :         ณ
      //ณ                                          ณ
      //ณ cDataMov        E5_DATA                  ณ
      //ณ cNumMov         E5_NUMERO                ณ
      //ณ nValorMov       E5_VALOR                 ณ
      //ณ cCodMov         FJF_CODCON  (Conceito !) ณ
      //ณ cDescrMov       FJF_DESCON               ณ
      //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	  For nY := 1 TO Len( aCposMov )

		  If aCposMov[nY][1]

             //--- Qual eh a Posicao desta Coluna na Configuracao ? 
			 If Len( aCsvFile[ nX ] ) >= aCposMov[ nY ][ 5 ]

				If Empty( aCposMov[ nY ][ 7 ] )
                   //--- Leitura do Conteudo da Coluna 
				   Ret := aCsvFile[ nX ][ aCposMov[ nY ][ 5 ] ]
				Else
                   //--- Roda o Bloco de Codigo para a determinacao do Conteudo
				   Ret := eVal(MontaBlock("{ |x| " + aCposMov[nY,7] + " }"),aCsvFile[nX,aCposMov[nY,5]])
				EndIf
				
				//If VALTYPE(Ret)==aCposMov[nY,3]
				If VALTYPE( Ret ) == "C"

					Do Case						
						Case nY == 1

							cDataMov  := Ret

						Case nY == 2

							cNumMov   := Padr( Ret, TamSX3( aCposMov[ nY ][ 4 ] )[1] )

						Case nY == 3
                            //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
                            //ณ Processo de Campo Numerico - E5_VALOR ณ
                            //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
                            If cChrSepDec == ","
                            
                               //--- 1. Todos os "." sao transformados em "" 
                               cAux1 := StrTran( Ret, ".", "" )
                               
                               //--- 2. Todas as "," sao transformadas em "."
                               cAux2 := StrTran( cAux1, ",", "." )
                               
                               //--- 3. Uso da funcao Val
                               nValorMov := Val( cAux2 )

                            ElseIf cChrSepDec == "."

                               //--- 1. Todas as "," sao transformadas em ""
                               cAux2 := StrTran( Ret, ",", "" )
                               
                               //--- 2. Uso da funcao Val
                               nValorMov := Val( cAux2 )
                            
                            EndIf

						Case nY == 4

							cCodMov   := Padr( Ret, TamSX3( aCposMov[ nY ][ 4 ] )[1] )

						Case nY == 5

							cDescrMov := Padr( Ret, TamSX3( aCposMov[ nY ][ 4 ] )[1] )

						//Case nY==6
					EndCase

				Else

					lSavLinha := .F.
					Exit

				EndIf

			 Else

				Exit
				lSavLinha := .F.

			 EndIf

		  EndIf

	  Next nY
			
     //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
     //ณ Ajuste para o campo de CodMov ณ
     //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	 If VALTYPE( cCodMov ) <> "C"
		cCodMov	:= Space(TamSX3("EJ_OCORBCO")[1])
	 EndIf

     //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
     //ณ Eh interessante testar o tipo da variavel numerica, para verificar ณ
     //ณ se a importacao foi realizada com a Configuracao incorreta         ณ
     //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	 If VALTYPE( nValorMov ) <> "N"
		lSavLinha := .F.
	 EndIf

     //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
     //ณ Processamento adicional das informacoes extraidas do CSV ณ
     //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
     If lSavLinha
        //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
        //ณ ***  Atualizacao do GRID de FJF  *** ณ
        //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
        If lFirstLi 
           lFirstLi := .F.
        Endif
		nLinha := oFJF:AddLine()

		oFJF:GoLine( nLinha )
        
        oFJF:SetValue( 'FJF_ESTMOV' , cStaMov )
        oFJF:SetValue( 'FJFESTMOV'  , F472AEstMov( cStaMov ) )
        oFJF:SetValue( 'FJF_CODCON' , cCodMov )
        oFJF:SetValue( 'FJF_DESCON' , cDescrMov )
        oFJF:SetValue( 'FJF_DATMOV' , CtoD( cDataMov ) )
        oFJF:SetValue( 'FJF_COMPRO' , cNumMov )
        oFJF:SetValue( 'FJF_VALOR'  , nValorMov )
        /*
        valida os dados da nova linha */
		F472AValLin(oFJF)    
     EndIf

     IncProc( STR0021 ) //"Gravando ... "

  Next nX 

  oFJF:GoLine( 1 )

If lFirstLi 
   //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
   //ณ Importacao foi realizada com a Configuracao incorreta ณ
   //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
   Aviso( STR0022 , STR0023 , { STR0030 } ) //"Nenhuma linha foi importada"###"Verifique o Arquivo de Configura็ใo inserido no Cadastro de Parametros Bancarios."###"Sair"
EndIf

RestArea(aArea)

Return(.T.) 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ FJNCON   บ Autor ณ Microsiga           บ Data ณ 25/09/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Consulta Especifica de Ocorrencia Bancaria, SEJ            บฑฑ
ฑฑบ          ณ Criada para contornar a ordem unica da tabela SEJ, que     บฑฑ
ฑฑบ          ณ eh BANCO + OCORRENCIA BANCARIA, quando o campo FJF_CODCON  บฑฑ
ฑฑบ          ณ representa a Ocorrencia Bancaria (Conceito).               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Campo FJF_CODCON                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472SEJ()

    //--- Ambiente
	Local aArea := GetArea()
    
    //--- Select
	Local cQuery	:= ""
	Local cAliasSEJ	:= ""
	Local aItens	:= {}

    //--- Dialog Principal
	Local oDlgSEJ
	Local oBrwSEJ
    
    //--- Variavel Get para Pesquisa 
	Local cDesc		:= ""
	Local oDesc
	Local oSayDesc

    //--- Genericas
	Local aScrRes	:= {}
	Local cFilSEJ	:= xFilial( "SEJ" )
    Local cBanco    := SA6->A6_COD
	Local cDescSEJ	:= STR0025   // "OCORRENCIAS BANCARIAS" //"OCORRENCIAS BANCARIAS"
	Local nItem		:= 0
	Local xRet		:= .F.

	//--- Paineis
	Local oPnlTopo
	Local oPnlEsq
	Local oPnlDir
	Local oPnlBase
	Local oPnlCons
	Local oPnlCons1
	Local oPnlBot
	Local oSep0
	Local oSep1
	Local oSep2
	Local oSep3
	Local oSep4
	Local oSep5

	//--- Botoes	
	Local oBtnSair
	Local oBtnOk
	Local oBtnPesq

	
	
		#IFDEF TOP

			cQuery := " Select SEJ.R_E_C_N_O_, EJ_BANCO,EJ_OCORBCO,EJ_DESCR"  
			cQuery += " From " + RetSqlName("SEJ") + " SEJ " 

			cQuery += " Where SEJ.EJ_FILIAL = '" + cFilSEJ + "'"
			cQuery += " And SEJ.EJ_BANCO = '" + cBanco + "'"
			cQuery += " And SEJ.D_E_L_E_T_ <> '*'" 
			cQuery += " ORDER BY EJ_BANCO,EJ_OCORBCO"

			cAliasSEJ := GetNextAlias()

			cQuery := ChangeQuery( cQuery )

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSEJ,.T.,.T.)

			dbSelectArea( cAliasSEJ )

			While !Eof()
			   Aadd( aItens, { EJ_BANCO, EJ_OCORBCO, EJ_DESCR, R_E_C_N_O_ } )
			   DbSkip()
			Enddo

			dbCloseArea()

		#ELSE

			dbSelectArea("SEJ")
			dbSetOrder(1)
			dbSeek( cFilSEJ + cBanco )

			While !EOF()

	           Aadd( aItens, { SEJ->EJ_BANCO, SEJ->EJ_OCORBCO, SEJ->EJ_DESCR, SEJ->(RECNO()) } )

			   dbSkip()
			Enddo

		#ENDIF
		
        //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
        //ณ Montagem dos Paineis ณ
        //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If !Empty( aItens )

            //--- Variavel Get para Pesquisa 
			cDesc := Space(SEJ->(TamSX3("EJ_OCORBCO")[1]))

			aScrRes := MsAdvSize(.F.,.F.,300)

			oDlgSEJ := TDialog():New(aScrRes[7],0,aScrRes[6]-250,aScrRes[5]-450,AllTrim(cDescSEJ),,,,,,,,,.T.,,,,,)

				oPnlEsq := TPanel():New(01,01,,oDlgSEJ,,,,,,5,5,.F.,.F.)
					oPnlEsq:Align := CONTROL_ALIGN_LEFT
					oPnlEsq:nWidth := 10
				oPnlDir := TPanel():New(01,01,,oDlgSEJ,,,,,,5,5,.F.,.F.)
					oPnlDir:Align := CONTROL_ALIGN_RIGHT
					oPnlDir:nWidth := 10
				oPnlBase := TPanel():New(01,01,,oDlgSEJ,,,,,,5,30,.F.,.F.)
					oPnlBase:Align := CONTROL_ALIGN_BOTTOM
					oPnlBase:nHeight := 10
				oPnlTopo := TPanel():New(01,01,,oDlgSEJ,,,,,,5,30,.F.,.F.)
					oPnlTopo:Align := CONTROL_ALIGN_TOP
					oPnlTopo:nHeight := 10

                //--- Painel da Pesquisa 
				oPnlCons := TPanel():New(01,01,,oDlgSEJ,,,,,,5,30,.F.,.F.)
					oPnlCons:Align := CONTROL_ALIGN_TOP
					oPnlCons:nHeight := 40
					oPnlCons1 := TPanel():New(01,01,,oPnlCons,,,,,,5,30,.F.,.F.)
					oPnlCons1:Align := CONTROL_ALIGN_ALLCLIENT

						@00,00 MSGET oDesc VAR cDesc SIZE 5,100 PIXEL OF oPnlCons1
							oDesc:Align := CONTROL_ALIGN_BOTTOM
							oDesc:nHeight := 20
						oSayDesc := TSay():New(0,0,{|| SEJ->(RetTitle("EJ_OCORBCO"))},oPnlCons1,,,,,,.T.,,,10,10)
							oSayDesc:Align := CONTROL_ALIGN_TOP
							oSayDesc:nHeight := 20

					oSep4 := TPanel():New(01,01,,oPnlCons,,,,,,5,30,.F.,.F.)
						oSep4:Align := CONTROL_ALIGN_RIGHT
						oSep4:nWidth := 10
					oSep5 := TPanel():New(01,01,,oPnlCons,,,,,,5,30,.F.,.F.)
						oSep5:Align := CONTROL_ALIGN_LEFT
						oSep5:nWidth := 10
					oPnlBot := TPanel():New(01,01,,oPnlCons,,,,,,5,30,.F.,.F.)
						oPnlBot:Align := CONTROL_ALIGN_RIGHT
						oPnlBot:nWidth := 100

                    //--- Botao Pesquisar 
					oPnlBot1 := TPanel():New(01,01,,oPnlBot,,,,,,5,30,.F.,.F.)
						oPnlBot1:Align := CONTROL_ALIGN_BOTTOM
						oPnlBot1:nHeight := 20
						oBtnPesq := TButton():New(0,0,STR0038,oPnlBot1,{|| oBrwSEJ:nAt := SEJPes(cDesc,aItens,oBrwSEJ:nAt) },30,10,,,,.T.,,"",,,,)		//"Pesquisar"
							oBtnPesq:Align := CONTROL_ALIGN_RIGHT
							oBtnPesq:nWidth := 80

				oSep3 := TPanel():New(01,01,,oDlgSEJ,,,,,,5,30,.F.,.F.)
					oSep3:Align := CONTROL_ALIGN_TOP
					oSep3:nHeight := 10

				oPnlBotoes := TPanel():New(01,01,,oDlgSEJ,,,,,,5,30,.F.,.F.)
					oPnlBotoes:Align := CONTROL_ALIGN_BOTTOM
					oPnlBotoes:nHeight := 20
					oSep0 := TPanel():New(01,01,,oPnlBotoes,,,,,,5,30,.F.,.F.)
						oSep0:Align := CONTROL_ALIGN_TOP
						oSep0:nHeight := 5
					oSep1 := TPanel():New(01,01,,oPnlBotoes,,,,,,5,30,.F.,.F.)
						oSep1:Align := CONTROL_ALIGN_RIGHT

					oBtnSair := TButton():New(0,0,STR0039,oPnlBotoes,{|| nItem := 0,oDlgSEJ:End()},40,10,,,,.T.,,"",,,,)	//"Abandona"
						oBtnSair:Align := CONTROL_ALIGN_RIGHT

					oSep2 := TPanel():New(01,01,,oPnlBotoes,,,,,,5,30,.F.,.F.)
						oSep2:Align := CONTROL_ALIGN_RIGHT

					oBtnOk := TButton():New(0,0,STR0040,oPnlBotoes,{|| nItem := oBrwSEJ:nAt,oDlgSEJ:End()},40,10,,,,.T.,,"",,,,) //"Selecionar"
						oBtnOk:Align := CONTROL_ALIGN_RIGHT

                //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
                //ณ Montagem das Colunas ณ
                //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				oBrwSEJ := TCBrowse():New(0,0,100,100,,,,oBrwSEJ,,,,,,,,,,,,.T.,"",.T.,{|| .T.},,,,)

				oBrwSEJ:AddColumn(TCColumn():New(SEJ->(RetTitle("EJ_BANCO"))   ,{|| aItens[oBrwSEJ:nAt,1]},,,,"LEFT",20,.F.,.F.,,,,,))
				oBrwSEJ:AddColumn(TCColumn():New(SEJ->(RetTitle("EJ_OCORBCO")),{|| aItens[oBrwSEJ:nAt,2]},,,,"LEFT",25,.F.,.F.,,,,,))
				oBrwSEJ:AddColumn(TCColumn():New(SEJ->(RetTitle("EJ_DESCR")),{|| aItens[oBrwSEJ:nAt,3]},,,,"LEFT",20,.F.,.F.,,,,,))

				oBrwSEJ:Align     := CONTROL_ALIGN_ALLCLIENT
				oBrwSEJ:bLDblClick := {|| nItem := oBrwSEJ:nAt,oDlgSEJ:End()} 
				oBrwSEJ:lAutoEdit := .F.
				oBrwSEJ:lReadOnly := .F.
				oBrwSEJ:SetArray(aItens)
				oDlgSEJ:lCentered := .T.

			oDlgSEJ:Activate(,,,,)

		Else

			ApMsgAlert( STR0026 ) //"Nใo foram encontrados itens para a tabela SEJ" //"Nใo foram encontrados itens para a tabela SEJ"

		EndIf

	RestArea( aArea )

	If nItem > 0
		SEJ->(DbGoTo(aItens[nItem,4]))
		xRet := .T.
	Endif

Return( xRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ SEJPes   บ Autor ณ Microsiga           บ Data ณ 25/09/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Acionada pelo botao Pesquisar da Consulta Especifica       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Consulta Especifica                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SEJPes( cTarget, aSearch, nPos )

Local nPes    := 0
Local nTamTar := Len( AllTrim( cTarget ) )

 If nTamTar > 0
 
   nPes := aScan( aSearch, { |x| Left( x[ 2 ], nTamTar ) == Left( cTarget, nTamTar ) } )

 EndIf
   
 If nPes == 0
    nPes := nPos
 EndIf
   
Return( nPes )