#INCLUDE "FileIO.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "CTBXATU.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE D_PRELAN	"9" 


Static lBlind		:= IsBlind()
Static lAS400	 	:= TcSrvType() == "AS/400"
Static lFWCodFil 	:= .T.
Static lCTxTABORI	:= Nil
Static lCTxRECORI 	:= Nil
Static lCTxRECDES 	:= Nil
Static lCTxIDORIG   := Nil
Static lCTKRECCV3	:= Nil
Static lCTKRECDES	:= .F.
Static lCT2MSUID    := Nil
Static lCV3IDDEST	:= Nil

Static __cRetClean	:= "1"
Static __cCleanLA	:= Nil
Static __lClrFlag	:= ExistBlock( 'CTBCLRFLG' )
Static __cArqFlags	:= ""
Static __IsCtbJob	:= IIf( IsCtbJob(), .T., .F. )
Static __lConOutR	:= FindFunction( "CONOUTR" 	  )
Static __lAgruSld	:= FindFunction( "CtAgrupSld" )
Static __CtbSerialI	:= FindFunction( "CtbSerialI" )
Static __nCTGRUPN
Static __cCTGRUPF
Static __Ct105CT2	// Ponto de entrada complementar CT2
Static __Ct105Sld	// Ponto de entrada que indica se atualiza saldos
Static __lExibeProc := Nil

Static _lCtbGrv
Static _lGrvCT7
Static _lGrvCT3
Static _lGrvCT4
Static _lGrvCTI
Static _lCTBSEQDIA

Static _lAtSldCT7	:= .T.
Static _lAtSldCT3	:= .T.
Static _lAtSldCT4	:= .T.
Static _lAtSldCTI	:= .T.
Static _lAtSldBase  := .T.
Static _lReproc
Static _lCTB150		:= .F.
Static _lCTB185		:= .F.
Static _lCTB153		:= .F.
Static _lFKInUse	:= .F.
Static _lCtbLanc

Static _cTipoDB
Static _cSrvType
Static _lOracle
Static _lPostgres
Static _lDB2
Static _lInformix

Static	__lCTB180
Static	__lCTB181
Static	__lCTB182
Static	__lCTB183

Static cDbsExt		:= GetDBExtension()
Static cIndExt		:= OrdBagExt()
Static nQtdEntid 				//Quantidade de entidades
Static _lCtbIsCube  := .T.
Static oConjCubos
Static _MVSOMA
STATIC cVerSP169A	:= "004"
STATIC cVerSP150A	:= "005"
STATIC __aCache  	:= {"XX",0}
STATIC __lChkCV7	:= .F. // Flag de controle de cria็ใo do CV7
Static lNewSemaforo := Iif(GetRPORelease() >= "12.1.031" .or. CTF->(FieldPos('CTF_USADO')) ,.T.,.F.) ////o semaforo s๓ serแ habilitado apartir da 12.1.31

// Manejo de entidad 05
Static lEntidad05   := (cPaisLoc $ "COL|PER" .And. CtbMovSaldo("CT0",,"05") .And. FWAliasInDic("QL6") .And. FWAliasInDic("QL7"))
Static _lPEGRVCV3   := ExistBlock("GRVCV3")

Static lAntCtbGrv	:= ExistBlock("ANTCTBGRV")
Static lChkCtbGrv	:= ExistBlock("CHKCTBGRV") //Retorno True ou False
Static lVldSld      := ExistBlock("CTBVldSld")
Static _lCTBPCO     := ExistBlock("CTBPCO")
Static lCtbGrvUsu   := ExistBlock("CtbGrvUsu")
Static _lCTB101EXC  := ExistBlock("CTB101EXC")

Static __cTbOrAux := ""
Static __cAliasTb := ""
Static __oCTBUID  := nil 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณProgram   ณCTBGrava  ณ Autor ณ Pilar S. Albaladejo   ณ Data ณ 24.07.00 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Grava dados da MSGETDB para CT2 - CTBA102 / CTBA105        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณCTBGrava(nOpc,dDataLanc,cLote,cSubLote,cDoc,lAglut,cSequenc,ณฑฑ
ฑฑณ          ณlCusto,lItem,lCLVL,nTotInf,cProg)                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ Nenhum                                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Generico                                                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpN1 = Opcao do Menu (Inclusao)                           ณฑฑ
ฑฑณ          ณ ExpD1 = Data do Lancamento                                 ณฑฑ
ฑฑณ          ณ ExpC1 = Numero do Lote                                     ณฑฑ
ฑฑณ          ณ ExpC2 = Numero do documento                                ณฑฑ
ฑฑณ          ณ ExpL1 = Aglutina?                                          ณฑฑ
ฑฑณ          ณ ExpC3 = Sequenciador                                       ณฑฑ
ฑฑณ          ณ ExpL2 = Grava C.custo?                                     ณฑฑ
ฑฑณ          ณ ExpL3 = Grava Item?                                        ณฑฑ
ฑฑณ          ณ ExpL4 = Grava Classe de valor?                             ณฑฑ
ฑฑณ          ณ ExpN2 = Valor Tota Informado                               ณฑฑ
ฑฑณ          ณ ExpC4 = Nome do programa que chamou a funcao               ณฑฑ
ฑฑณ          ณ ExpC5 = Indica o tipo de gravacao do pre-lancamento        ณฑฑ
ฑฑณ          ณ dReproc = Parametro que indica que lancamentos nao atualizaณฑฑ
ฑฑณ          ณ           saldos e apos gravacao executa reprocessamento   ณฑฑ
ฑฑณ          ณ cEmpOri                                                    ณฑฑ
ฑฑณ          ณ cFilOri                                                    ณฑฑ
ฑฑณ          ณ aFlagCTB                                                   ณฑฑ
ฑฑณ          ณ cCTKxCT2                                                   ณฑฑ
ฑฑณ          ณ aTpSaldo = Array para armazenar os tipos de saldos gerados ณฑฑ
ฑฑณ          ณ            no lancamento contabil                          ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑณManuten็ใoณ Renato - 06/12/2007                                        ณฑฑ
ฑฑณ          ณ        Foi movido o controle de semaforo para a ctbgrava p/ณฑฑ
ฑฑณ          ณ        garantir que a rotina passe pelo desbloqueio do     ณฑฑ
ฑฑณ          ณ        semaforo                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Dora Vegaณ08/12/17ณDMINA- ณMerge de replica de llamado TWEKZZ V12.1.14ณฑฑ
ฑฑณ          ณ        ณ   1322ณGraba el correlativo de manera correcta al ณฑฑ
ฑฑณ          ณ        ณ       ณrealizar variacion monetaria.(PERU)        ณฑฑ
ฑฑณRaul Ortizณ13/12/17ณDMICNS-ณSe realizan modificaciones para uso de     ณฑฑ
ฑฑณ          ณ        ณ649    ณtablas temporales - arg                    ณฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function CTBGrava(nOpc,dDatalanc,cLote,cSubLote,cDoc,lAglut,cSequenc,lCusto,lItem,lCLVL,nTotInf,cProg,cPreLcto,dReproc,cEmpOri,cFilOri,aFlagCTB,aCTKxCT2,aTpSaldo,cModoClr,aSeqDiario,lMltSld,cSeqCorr,lSimula,cTabCTK,cTabCT2,;
					cHistLote,cMoedDoc,cCritDoc,dDatTaxDoc,cTipSldDoc,cLivDia,cNroDia,lFirstP,lRegUm,lContb,lCtba190, cCT2_KEY)
Local lRet 		:= .T.
Local cSemaforo	:= 'ON' // controle do semaforo - OFF(bloqueia os outros processos)
Local lTemACTK		:= .F.
Local bCodeProc
Local lRpc			:= Type("oMainWnd") = "U"		// Chamada via Rpc nao tem tela

DEFAULT cProg 		:= Alltrim( FunName() )
DEFAULT cModoClr	:= Alltrim( SuperGetMv( "MV_CTBAPLA" ,.F., "1" ))	//"1"=Inativo,"2"=Pergunta,"3"=Automatico c/Alertas,"4"=Automแtico sem alertas
DEFAULT cSeqCorr  	:= ""
DEFAULT aFlagCTB 	:= {}
DEFAULT aCTKxCT2	:= {}
DEFAULT aSeqDiario	:= {}
DEFAULT lMltSld		:= .F.

Default lSimula		:= .F.
Default cTabCTK		:= "CTK"
Default cTabCT2		:= "CT2"

Default cHistLote	:= ""
Default cMoedDoc	:= ""
Default cCritDoc	:= ""
Default dDatTaxDoc	:= STOD("")
Default cTipSldDoc	:= ""
Default cLivDia		:= ""
Default cNroDia		:= ""
Default lFirstP   := .T. 
Default lRegUm    := .T.
Default lContb    := .T.
Default lCtba190 	:= .F.
DEFAULT __lExibeProc := SuperGetMv( "MV_CTEXBPC" , .F. , .F.)
DEFAULT cCT2_KEY 	:= ""

lTemACTK 			:= Len(aCTKxCT2) > 0
//Se o parโmetro MV_33UPRC estiver ativo, o prelan deve ser desconsiderado (sempre serแ D)
If !(SuperGetMv("MV_M33UPRC",.T.,.F.) .And. AllTrim(cProg)$"MATA330/MATA331/MATA333")
	// em caso da rotina determinar que deve ser um pre-lancamento
	// mas o parametro MV_PRELAN estiver como N, nao vai gravar lancamento
	If cPreLcto == "S" .And. Upper(AllTrim(SuperGetMv("MV_PRELAN", .F., "N"))) == "N"
		If !lRpc //Chamada via Rpc nao tem tela
			Return .F.
		EndIf
	EndIf
EndIf

iF lRegUm
	CtbInVStatic(lTemACTK,lSimula,cTabCTK,cTabCT2)    //inicializa as variaveis Static utilizadas neste fonte
EndIF

CtbIniSemaforo(@cSemaforo, cProg)  //inicializa semaforo de processamento do SIGACTB-variavel por referencia

// executa o processamento de grava็ใo do registro do CTB
bCodeProc := {|| AuxCtbGrava(nOpc,dDatalanc,cLote,cSubLote,cDoc,lAglut,cSequenc,lCusto,lItem,lCLVL,nTotInf,cProg,cPreLcto,dReproc,cEmpOri,cFilOri,@aFlagCTB,@aCTKxCT2,@aTpSaldo,cModoClr,aSeqDiario,lMltSld,cSeqCorr,lSimula,cTabCTK,cTabCT2,;
						cHistLote,cMoedDoc,cCritDoc,dDatTaxDoc,cTipSldDoc,cLivDia,cNroDia,lFirstP,lContb,lCtba190,cCT2_KEY)}
If !lSimula
	if lFirstP .and. __lExibeProc
		lRet := Processa(bCodeProc,'Aguarde...','Contabilizando')
	Else
		lRet := AuxCtbGrava(nOpc,dDatalanc,cLote,cSubLote,cDoc,lAglut,cSequenc,lCusto,lItem,lCLVL,nTotInf,cProg,cPreLcto,dReproc,cEmpOri,cFilOri,@aFlagCTB,@aCTKxCT2,@aTpSaldo,cModoClr,aSeqDiario,lMltSld,cSeqCorr,lSimula,cTabCTK,cTabCT2,;
						cHistLote,cMoedDoc,cCritDoc,dDatTaxDoc,cTipSldDoc,cLivDia,cNroDia,lFirstP,lContb,lCtba190,cCT2_KEY)
	Endif
EndIf

CtbFimSemaforo(cSemaforo, cProg)  //finaliza semaforo de processamento do SIGACTB

// se utilizar controle de flags do ctb --> pergunta se visualiza o log dos flags
If nOpc == 5 .OR. nOpc == 6
	CtbLogFlag(cModoClr)
EndIf


Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBXATU   บAutor  ณMicrosiga           บ Data ณ  10/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInicializa as variaveis Static utilizadas no fonte          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CtbInVStatic(lTemACTK,lSimula,cTabCTK,cTabCT2)

Local cProcExec := '2'
Local cCTB153   := IIf(FindFunction("GetSPName"), IIf(cProcExec ="2",GetSPName("CTB153","06"),GetSPName("CTB153","04")), "CTB153")
Local cCTB185   := IIf(FindFunction("GetSPName"), GetSPName("CTB185","06"), "CTB185")

Local lRetSld   := .F.

DEFAULT lTemACTK := .F.
Default lSimula		:= .F.
Default cTabCTK		:= "CTK"
Default cTabCT2		:= "CT2"

If __lExibeProc == Nil
	__lExibeProc := SuperGetMv( "MV_CTEXBPC" , .F. ,.F.)
EndIf

If __lConOutR == Nil
	__lConOutR := FindFunction( "CONOUTR" )
EndIf

DEFAULT _lCtbGrv 	:= ExistBlock("CTBGRV")
DEFAULT _lGrvCT7	:= ExistBlock("GRVCT7")
DEFAULT _lGrvCT3	:= ExistBlock("GRVCT3")
DEFAULT _lGrvCT4	:= ExistBlock("GRVCT4")
DEFAULT _lGrvCTI	:= ExistBlock("GRVCTI")
DEFAULT _lCTBSEQDIA := ExistBlock("CTBSEQDIA")

If (__Ct105CT2 == Nil)
	__Ct105CT2 := ExistBlock("CT105CT2")
EndIf

If (__Ct105Sld == Nil)
	If __Ct105CT2
		__Ct105Sld := ExistBlock("CT105SLD")
	Else
		__Ct105Sld := .F.
	EndIf
EndIf

//Caso exista algum ponto de entrada de atualizacao de saldos, verificar se deve ou nao atualizar os saldos.
If _lGrvCT7 .And. !lSimula
	_lAtSldCT7	:= ExecBlock("GRVCT7",.F.,.F.)
EndIf

If _lGrvCT3 .And. !lSimula
	_lAtSldCT3	:= ExecBlock("GRVCT3",.F.,.F.)
EndIf

If _lGrvCT4 .And. !lSimula
	_lAtSldCT4	:= ExecBlock("GRVCT4",.F.,.F.)
EndIf

If _lGrvCTI .And. !lSimula
	_lAtSldCTI	:= ExecBlock("GRVCTI",.F.,.F.)
EndIf

//Verifica se os saldos basicos serao atualizados no momento da gravacao do lancamento
//contabil ou se sera gravado via rotina de atualizacao de saldos compostos(CTBA360).
_lAtSldBase	:= IIf(SuperGetMv("MV_ATUSAL")== "S",.T.,.F.)

If _lAtSldBase .and. lVldSld
	lRetSld := ExecBlock("CTBVldSld",.F.,.F., {_lAtSldCT7, _lAtSldCT3, _lAtSldCT4, _lAtSldCTI})
	If lRetSld
		_lAtSldBase := .F.
	EndIf
EndIf

//A variavel _lReproc, sera utilizada na gravacao de saldos. Caso nao seja para atualizar
//os saldos no momento da grav. dos lanc. contab., ira atualizar o saldo somente da DATA.
//Analogo ao Reprocessamento.
_lReproc		:= IIf(_lAtSldBase,.F.,.T.)

If ( lCTxTABORI == Nil ) .Or. ( lCTxRECORI == Nil ) .Or. ( lCTxRECDES == Nil ) .Or. ( lCTKRECCV3 == Nil )
	// Funcao que verifica se existe configuracao para Rastreamento Automatico
	RastAutom()
EndIf

lCTKRECDES := lTemACTK

_lCTB150		:= .F. // Procedure nใo utilizada - Utilizada apenas a CTB185
_lCTB185		:= ExistProc(cCTB185,VerIDProc3()) .And. _lAtSldBase .And. cProcExec == "2"
_lCTB153		:= (_lCTB150 .OR. _lCTB185) .And. ExistProc(cCTB153,VerIDProc2()) .and. _lAtSldBase
_lFKInUse 		:= FkInUse() // se a integridade estiver ligada

If __cCTGRUPF == Nil
	__cCTGRUPF	:= UPPER(ALLTRIM(GetNewPar("MV_CTGRUPF","*")))
EndIf

If __nCTGRUPN == Nil
	__nCTGRUPN := GetNewPar("MV_CTGRUPN",6)
EndIf

If (_lCtbLanc == Nil)		//CTBA101
	_lCtbLanc := ExistBlock("CTBLANC")
EndIf

//carrega as variaveis Static
_cTipoDB	:= Alltrim(Upper(TCGetDB()))
_cSrvType := Alltrim(Upper(TCSrvType()))

_lOracle	:= "ORACLE"   $ _cTipoDB
_lPostgres 	:= "POSTGRES" $ _cTipoDB
_lDB2		:= "DB2"      $ _cTipoDB
_lInformix 	:= "INFORMIX"   $ _cTipoDB

_MVSOMA := If(SuperGetMv("MV_SOMA") == 2, '2','1')
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBXATU   บAutor  ณMicrosiga           บ Data ณ  10/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInicializa semaforo de processamento CTB                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbIniSemaforo(cSemaforo,cProg)
Local cProgSem := "CTBANFE,CTBANFS,CTBAFIN,FINA370,CTBAATF,ATFA370,MATA330,ATFA371,PLSCTB06,PLSCTB11" 
// controle de semaforo do CTB, para grava็๕es simultaneas

If lNewSemaforo // vers๕es >= a 12.1.031
	If __CtbSerialI	.And.  !(Alltrim( cProg ) $ "ATFA371|CTBA102|CTBA101|CTBA103") .And. !__IsCtbJob

		// se vier de integra็ใo com alguma rotina off-line, for็o para que o flag do semaforo vire OFF
		// assim entrarแ no controle de semaforo, caso os outros falhem
		If ( Alltrim( cProg ) $ cProgSem )
			cSemaforo	:= 'OFF'
		Else  //ElseIf lNewSemaforo 
		/* Processos On Line de contabiliza็ใo */
			Return 
		EndIf

		If __lConOutR
			ConOutR( STR0001 + ' - CTBSerialI' ) // "CTBGRAVA | Incializando a Serializa็ใo de processos."
		EndIf

		While ! CTBSerialI( "CTBPROC", cSemaforo)
			If __lConOutR
				ConOutR( STR0002 ) // "CTBGRAVA | Aguarde... Efetuando a tentativa de cria็ใo do Semaforo"
			EndIf
		EndDo

		If __lConOutR
			ConOutR( STR0003 + ' - CTBSerialI' ) // "CTBGRAVA | Fim da inicializa็ใo da Serializa็ใo."
		EndIf
	EndIf

Else // vers๕es anteriores
	If __CtbSerialI	.And.  !(Alltrim( cProg ) $ "ATFA371") .And. !__IsCtbJob

		// se vier de integra็ใo com alguma rotina off-line, for็o para que o flag do semaforo vire OFF
		// assim entrarแ no controle de semaforo, caso os outros falhem
		If ( Alltrim( cProg ) $ cProgSem )
			cSemaforo	:= 'OFF'
		EndIf

		If __lConOutR
			ConOutR( STR0001 + ' - CTBSerialI' ) // "CTBGRAVA | Incializando a Serializa็ใo de processos."
		EndIf

		While ! CTBSerialI( "CTBPROC", cSemaforo)
			If __lConOutR
				ConOutR( STR0002 ) // "CTBGRAVA | Aguarde... Efetuando a tentativa de cria็ใo do Semaforo"
			EndIf
		EndDo

		If __lConOutR
			ConOutR( STR0003 + ' - CTBSerialI' ) // "CTBGRAVA | Fim da inicializa็ใo da Serializa็ใo."
		EndIf
	EndIf

Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBXATU   บAutor  ณMicrosiga           บ Data ณ  10/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFinaliza semaforo de processamento CTB                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbFimSemaforo(cSemaforo, cProg)


If lNewSemaforo
	If __CtbSerialI	.And.  !(Alltrim( cProg ) $ "ATFA371|CTBA102|CTBA101|CTBA103") .And. !__IsCtbJob .and. cSemaforo == 'OFF' 
		If __lConOutR
			ConOutR( STR0001 + ' - CTBSerialF' )  //"CTBGRAVA | Incializando a Serializa็ใo de processos."
		EndIf

		If ! CTBSerialF( "CTBPROC", cSemaforo )
			If __lConOutR
				ConOutR( STR0004 )  //"CTBGRAVA | Erro na libera็ใo dos processos simultaneos."
			EndIf

			FreeUsedCode()  //libera codigos ainda travados
		EndIf

		If __lConOutR
			ConOutR( STR0003 + ' - CTBSerialF' )  //"CTBGRAVA | Fim da inicializa็ใo da Serializa็ใo."
		EndIf
	EndIf

Else
	If __CtbSerialI	.And.  Alltrim( cProg ) <> "ATFA371" .And. !__IsCtbJob
		If __lConOutR
			ConOutR( STR0001 + ' - CTBSerialF' )  //"CTBGRAVA | Incializando a Serializa็ใo de processos."
		EndIf

		If ! CTBSerialF( "CTBPROC", cSemaforo )
			If __lConOutR
				ConOutR( STR0004 )  //"CTBGRAVA | Erro na libera็ใo dos processos simultaneos."
			EndIf

			FreeUsedCode()  //libera codigos ainda travados
		EndIf

		If __lConOutR
			ConOutR( STR0003 + ' - CTBSerialF' )  //"CTBGRAVA | Fim da inicializa็ใo da Serializa็ใo."
		EndIf
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBXATU   บAutor  ณMicrosiga           บ Data ณ  10/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPergunta se exibe o log dos flags de contabiliza็ใo         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbLogFlag(cModoClr)

If ! lBlind .and. cModoClr $ "23"	//"1"=Inativo,"2"=Pergunta,"3"=Automatico c/Alertas,"4"=Automแtico sem alertas
	If !Empty(__cArqFlags) //Valida็ใo para nใo mostrar a tela se o nใo hove exclusใo
		If MsgYesNo( STR0005 , STR0006 )//"Visualizar Log dos Flags de Contabiliza็ใo ?"#"Lan็amento de Integra็ใo. - Exclusใo efetuada."
			CTBShowFLG( __cArqFlags )
		EndIf
	EndIf
EndIf

Return

//--------------------------------------//
//funcoes Staticas usadas AuxCtbGrava   //
//--------------------------------------//

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbNumLoteบAutor  ณMicrosiga           บ Data ณ  10/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณNumero de Lote para operacoes inclusao/estorno/copia        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbNumLote(nOpc,dDataLanc,cLote,cSubLote,cDoc,CTF_LOCK,lSimula,cTabCTK,cTabCT2)
Local nIndCT2 := CT2->(IndexOrd())
Local nRecCT2 := CT2->(Recno())
Local cFilCT2
Local cChaveCT2	:= ""

Default lSimula	:= .F.
Default cTabCTK	:= "CTK"
Default cTabCT2	:= "CT2"

If nOpc == 3 .or. nOpc == 6	.or. nOpc == 7		//// inclusao ou estorno ou copia
	dbSelectArea("CT2")
	If lSimula .and. !(Type("cFunname") <> "U" .and. cFunname == "FINA840")
		dbSelectArea("SIX")
		dbSetOrder(1)		//INDICE+ORDEM
		dbGoTop()
		If SIX->(dbSeek("CT21"))
			cChaveCT2 := AllTrim(SIX->CHAVE)
			IndRegua("CT2", cTabCT2, cChaveCT2, , , )
		EndIf
	Else
		dbSetOrder(1)
	EndIf
	cFilCT2 := xFilial("CT2")
	If dbSeek(cFilCT2+DtoS(dDataLanc)+cLote+cSubLote+cDoc)
		CtbDestrava(dDataLanc,cLote,cSubLote,cDoc,@CTF_LOCK,lSimula,cTabCTK,cTabCT2)
		Do While !ProxDoc(dDataLanc,cLote,cSubLote,@cDoc,@CTF_LOCK,lSimula,cTabCTK,cTabCT2)
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Caso o Nง do Doc estourou, incrementa o lote         ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			cLote := CtbInc_Lot(cLote, cModulo)

		Enddo
	EndIf

	CT2->(dbSetOrder(nIndCT2))
	CT2->(MsGoTo(nRecCT2))
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbProc153บAutor  ณMicrosiga           บ Data ณ  10/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExecuta a procedure CTB153 que cria arquivo de trabalho no  บฑฑ
ฑฑบ          ณbanco com o lancamento atual no caso de altera็ใo/exclusao  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbProc153(nOpc, dDatalanc, cLote, cSubLote, cDoc)
Local lTrbProc := .T.
Local aResult  := {}
Local cProcExec := '2'
Local cCTB153   := IIf(FindFunction("GetSPName"), IIf(cProcExec ="2",GetSPName("CTB153","06"),GetSPName("CTB153","04")), "CTB153")

// grava em tabela temporaria no bancco o registro a alterar/excluir
If (nOpc = 4 .or. nOpc = 5) .And. _lCTB153
	aResult := TCSPEXEC( xProcedures(cCTB153), cFilAnt, Dtos(dDatalanc),cLote, cSubLote, cDoc)
	If Empty(aResult)
  		MsgAlert(STR0007+cCTB153)  //"Falha na chamada do processo - Gravacao de Saldos - Stored Procedure CTB153"
   		lTRBProc := .F.
	EndIf
EndIf

Return(lTrbProc)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbProc185บAutor  ณMicrosiga           บ Data ณ  10/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExecuta a procedure CTB185 que atualiza os saldos nas tab.  บฑฑ
ฑฑบ          ณ CT7/CT3/CT4/CTI                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbProc185(cLote,cSublote,cDoc,dDatalanc,nOpcProc)
Local aResult := {}
Local cFilAux := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
Local nLenAtivDe := Len(CT2->CT2_ATIVDE)
Local cCTB185    := IIf(FindFunction("GetSPName"), GetSPName("CTB185","06"), "CTB185")

aResult := TCSPEXEC( xProcedures(cCTB185), cFilAux, Dtos(dDatalanc),  cLote, cSublote, cDoc, ;
			          StrZero(nOpcProc,1), StrZero(ThreadID(),nLenAtivDe), If(_lFKInUse, '1' , '0' ),_MVSOMA )

If Empty(aResult)
	MsgAlert(STR0007+cCTB185) //"Falha na chamada do processo - Gravacao de Saldos - Stored Procedure CTB150"
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbAgluSldบAutor  ณMicrosiga           บ Data ณ  10/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna se aglutina saldo                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbAgluSld(lAgruSld,cProg)
dbSelectArea("TMP")
If lAgruSld				/// Se tem a funcao da aglutina็ใo
	If __cCTGRUPF == "*"			/// Se MV_CTGRUPF igual *
		lAgruSld := .T.						//Todos programas aglutinam
	ElseIf Empty(__cCTGRUPF)		/// Se MV_CTGRUPF estiver vazio
		lAgruSld := .F.						// Nenhum programa aglutina
	ElseIf cProg$__cCTGRUPF			/// Caso contrario, se o programa atual estiver no parโmetro
		lAgruSld := .F.						// Se estiver indicado aglutina.
	EndIf
	If lAgruSld 		/// Se aglutina em memoria antes de atualizar os saldos.
		lAgruSld := TMP->(RecCount()) >= __nCTGRUPN 	/// Se a quantidade de linhas do DOC for maior que o parametro.
	EndIf
EndIf
Return(lAgruSld)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbCTFLinhบAutor  ณMicrosiga           บ Data ณ  10/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava CTF com linha passada como parametro                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbCTFLinh(dDataLanc, cLote, cSubLote, cDoc,cCTFLINHA)

dbSelectArea("CTF")
CTF->(dbSetOrder(1))
If CTF->(MsSeek(xFilial("CTF")+Dtos(dDataLanc)+cLote+cSubLote+cDoc))
	RecLock("CTF",.F.)
Else
	RecLock("CTF",.T.)
	CTF->CTF_FILIAL := xFilial("CTF")
	CTF->CTF_LOTE	:= cLote
	CTF->CTF_SBLOTE	:= cSubLote
	CTF->CTF_DOC	:= cDoc
	CTF->CTF_DATA	:= dDataLanc
EndIf
CTF->CTF_LINHA := cCTFLINHA

CTF->(MsUnlock())

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbDsTrvCTF บAutor  ณMicrosiga         บ Data ณ  10/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDestrava CTF e alimenta variavel CTF_LOCK com recno da tab. บฑฑ
ฑฑบ          ณCTF                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbDsTrvCTF(dDataLanc,cLote,cSubLote,cDoc,CTF_LOCK)
Local cAliasAnt := Alias()
Local dDataCTF := dDataLanc

If cPaisloc == "MEX"
	dDataCTF := StoD( Substr(DtoS(dDataLanc), 1, 6) + "01" )
ENDIF

dbSelectArea("CTF")
CTF->(dbSetOrder(1))
CTF->(MsSeek(xFilial("CTF")+Dtos(dDataCTF)+cLote+cSubLote+cDoc))
CTF_LOCK := CTF->(Recno())
CtbDestrava(dDataCTF,cLote,cSubLote,cDoc,@CTF_LOCK)

If !Empty(cAliasAnt)
	dbSelectArea(cAliasAnt)
EndIf 

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbExcLTmpบAutor  ณMicrosiga           บ Data ณ  10/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExcluir linhas deletadas no temporario do CT2               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbExcLTmp()
// For็a a exclusใo das linhas deletadas no temporario no CT2
// Quando utiliza-se a rotina automatica, o mesmo exclui os registros com recno e recria sem os mesmo
SET DELETE OFF

TMP->( dbGotop() )
While ! TMP->( Eof() )

	If TMP->CT2_RECNO > 0 .and. TMP->( deleted() )
		CT2->( DbGoTo( TMP->CT2_RECNO ) )

		If CT2->( Recno() ) > 0
			CtbDelCT2()	//// E DA MESMA EMPRESA/FILIAL (CASO CONSOLIDADA)
		EndIf
	EndIf

	TMP->( dbSkip() )
ENDDO

SET DELETE ON

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbPosiCT2บAutor  ณMicrosiga           บ Data ณ  10/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPosiciona na tabela CT2 no registro relativo a gravado no   บฑฑ
ฑฑบ          ณtemporario no caso de alteracao / exclusao                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbPosiCT2(nOpc,lSimula,cTabCTK,cTabCT2)

Local nOpcAlt

Default lSimula	:= .F.
Default cTabCTK	:= "CTK"
Default cTabCT2	:= "CT2"

dbSelectArea("CT2")
If lSimula .and. !(Type("cFunname") <> "U" .and. cFunname == "FINA840")
	dbSelectArea("SIX")
	dbSetOrder(1)		//INDICE+ORDEM
	dbGoTop()
	If SIX->(dbSeek("CT21"))
		cChaveCTK := AllTrim(SIX->CHAVE)
		IndRegua("CT2", cTabCT2, cChaveCTK, , , )
	EndIf
	dbSelectArea("CT2")
Else
	dbSetOrder(1)
EndIf

If TMP->CT2_FLAG
	nOpcAlt := 5
	If nOpc != 3					// Alteracao / Exclusao
		MsGoto(TMP->CT2_RECNO)		// Posiciono no RECNO ja gravado
	EndIf
Else
	If TMP->CT2_RECNO = 0 			// Se o recno estiver zerado eh uma nova linha
		nOpcAlt := 3
	Else
		nOpcAlt := nOpc
		MsGoto(TMP->CT2_RECNO)		// Posiciono no RECNO ja gravado
	EndIf
EndIf

Return(nOpcAlt)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbPesqCT2บAutor  ณMicrosiga           บ Data ณ  10/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPesquisa com MsSeek na tabela CT2 com a chave composta p/   บฑฑ
ฑฑบ          ณparametros informados                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbPesqCT2(dDataLanc,cLote,cSubLote,cDoc,cLinha,cTpSld,cEmpOri,cFilOri,cMoeda,lSimula,cTabCTK,cTabCT2)

Local cChave
Local lRetorno 	:= .F.

Default lSimula	:= .F.
Default cTabCTK	:= "CTK"
Default cTabCT2	:= "CT2"

	dbSelectArea("CT2")
	If lSimula .and. !(Type("cFunname") <> "U" .and. cFunname == "FINA840")
		dbSelectArea("SIX")
		dbSetOrder(1)		//INDICE+ORDEM
		dbGoTop()
		If SIX->(dbSeek("CT21"))
			cChaveCT2 := AllTrim(SIX->CHAVE)
			IndRegua("CT2", cTabCT2, cChaveCT2, , , )
		EndIf
	Else
		dbSetOrder(1)
	EndIf
	cChave	:= xFilial("CT2")+dtos(dDataLanc)+cLote+cSubLote+cDoc+cLinha+cTpSld+cEmpOri+cFilOri+cMoeda

	lRetorno := MsSeek(cChave)
	// lRetorno := dbSeek(cChave) //alterado para dbSeek por conta de performance

/*EndIf*/

Return(lRetorno)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbVOtMoedบAutor  ณMicrosiga           บ Data ณ  10/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna se o valor em outras moedas ้ positivo              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbVOtMoed(nMoedas)
// VerIficacao para identIficar se grava na moeda 01 com Valor 0.00
Local lOutrMoeda   := .F.
Local nContMoeda
For nContMoeda 	:= 2 To nMoedas			//comecao o for a partir da segunda moeda
	If ! TMP->CT2_FLAG
		lOutrMoeda := &( "TMP->CT2_VALR" + StrZero( nContMoeda, 2 )) > 0
    	If lOutrMoeda
    		Exit
    	EndIf
	EndIf
Next

Return(loutrMoeda)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbGetValorบAutor  ณMicrosiga          บ Data ณ  10/09/09   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o valor do lancamento a moeda informada  (tmp)      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbGetValor(cMoeda, cEmpOri, cFilOri)
Local nValor

If !TMP->CT2_FLAG						////// SE NAO ESTIVER DELETADO NO TMP
	If cMoeda == '01'
		nValor	:= TMP->CT2_VALOR
		//Se estiver na empresa consolidadora, ira considerar os campos CT2_EMPORI e CT2_FILORI
		//da moeda 01. Caso inclua algum registro novo em outra moeda, ira gravar com o mesmo
		//conteudo da moeda 01.
		If !Empty(TMP->CT2_EMPORI) .And. !Empty(TMP->CT2_FILORI)
			cEmpOri	:= TMP->CT2_EMPORI
			cFilOri	:= TMP->CT2_FILORI
		EndIf
	Else
		nValor	:= &("TMP->CT2_VALR"+cMoeda)
	EndIf
Else								// Quando a linha for deletada -> garantir valor 0!!
	nValor 	:= 0
EndIf

Return(nValor)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbGetVlAnt บAutor  ณMicrosiga         บ Data ณ  10/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna valor anterior ( gravado CT2 ) conforme parametros  บฑฑ
ฑฑบ          ณinformados                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbGetVlAnt(dDataLanc,cLote,cSubLote,cDoc,cTpSldAnt,cEmpOri,cFilOri,cMoeda,lSimula,cTabCTK,cTabCT2)

Local nValorAnt := 0
Local cAliasAnt	:= Alias()
Local nOrderTMP	:= IndexOrd()
Local nRecnoAnt	:= Recno()
Local cChave 	:= ""

Default lSimula	:= .F.
Default cTabCTK	:= "CTK"
Default cTabCT2	:= "CT2"

dbSelectArea("CT2")
If lSimula .and. !(Type("cFunname") <> "U" .and. cFunname == "FINA840")
	dbSelectArea("SIX")
	dbSetOrder(1)
	dbGoTop()
	If SIX->(dbSeek("CT21"))
		cChaveCT2 := AllTrim(SIX->CHAVE)
		IndRegua("CT2", cTabCT2, cChaveCT2, , , )
	EndIf
	dbSelectArea("CT2")
Else
	dbSetOrder(1)
EndIf

cChave	:= xFilial("CT2")+dtos(dDataLanc)+cLote+cSubLote+cDoc+TMP->CT2_LINHA+cTpSldAnt+cEmpOri+cFilOri+cMoeda
If MsSeek(cChave)						// LOCALIZA O REGISTRO DO VALOR NA MOEDA CORRESPONDENTE (02,03,04,ETC)
	nValorAnt := CT2->CT2_VALOR
EndIf

dbSelectArea(cAliasAnt)
dbSetOrder(nOrderTMP)
MsGoto(nRecnoAnt)

Return(nValorAnt)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbArmSaldบAutor  ณMicrosiga           บ Data ณ  10/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณArmazena o saldo a ser atualizado no array aAtuSaldo para   บฑฑ
ฑฑบ          ณalimentar as tabelas de saldos CT7/CT3/CT4/CTI              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CtbArmSald(	nOpc, nOpcAlt, aAtuSaldos, nContMoeda, cMoeda, lPodeExc,	;
							aTpSaldo, lAgruSld, lTrbProc, lAtuProc, cModoClr, dReproc,	;
							nValor, nValorAnt, lSimula, cTabCTK, cTabCT2)
Local lContinua 	:= .T.
Local aOutrEntid   	:= {}
Local aEntid, aEntidAnt
Local nMoedas		:= __nQuantas

Default lSimula	:= .F.
Default cTabCTK	:= "CTK"
Default cTabCT2	:= "CT2"


If _lCTB150 .and. lTrbProc  // Tem procedure e montou TRB da procedure

	/// As Procedures atualizam as tabelas de saldo - CTC e CT6 sใo atualizados pelo padrao.
	If (nOpc == 4 .Or. nOpc == 5) .And. ;
		dReproc = Nil .And. ;
		TMP->CT2_RECNO <> 0

		lPodeExc := CanDelCt2(nOpc,,cModoClr)

		aOutrEntid 	:= CtbOutrEnt(.F.,Nil,lSimula,cTabCTK,cTabCT2)
		aEntid 		:= aOutrEntid[1]
		aEntidAnt 	:= aOutrEntid[2]

		If lPodeExc .or. (nOpc == 4 .and. !TMP->CT2_FLAG)	/// SE ALTERACAO E NAO DELETADO
			//// SE FOR ALTERACAO/EXCLUSAO E NAO FOR REPROCESSAMENTO E O REGISTRO JA EXISTIA NO CT2
			//// RETIRA O VALOR DAS TABELAS DE SALDOS
			//Bloco 3
			CtbAtuSld(lAgruSld,aAtuSaldos,"-",cMoeda,nOpcAlt,nValor,nValorAnt,CT2->CT2_DTLP/*dLucrPerda*/,nOpc,aEntid,aEntidAnt )

			lAtuProc	:= 	lAtuProc .Or. _lAtSldCT3 .Or. _lAtSldCT4 .Or. _lAtSldCT7 .Or. _lAtSldCTI
			_lAtSldCT7 	:= .F.	/// Chama funcoes de saldo, saldos pelas procedures
			_lAtSldCT3 	:= .F.	/// Chama funcoes de saldo, saldos pelas procedures
			_lAtSldCT4 	:= .F.	/// Chama funcoes de saldo, saldos pelas procedures
			_lAtSldCTI 	:= .F.	/// Chama funcoes de saldo, saldos pelas procedures
		Else
			nContMoeda 	:= nMoedas+1
			lContinua := .F. //Exit
		EndIf
	EndIf

	// Gravacao dos Saldos de Entidades
	If lContinua .And. ;
		(nOpc == 3 .Or. nOpc == 4 .Or. nOpc == 6 .Or. nOpc == 7 ) .And. ;
		dReproc = Nil

		aOutrEntid 	:= CtbOutrEnt(.F.,Nil,lSimula,cTabCTK,cTabCT2)
		aEntid 		:= aOutrEntid[1]
		aEntidAnt 	:= aOutrEntid[2]

		/// SE FOR INCLUSAO/ALTERACAO E NAO FOR REPROCESSAMENTO
		/// GRAVA O VALOR NAS TABELAS DE SALDOS
		//Bloco 4
		CtbAtuSld(lAgruSld,aAtuSaldos,"+",cMoeda,nOpcAlt,nValor,nValorAnt,TMP->CT2_DTLP/*dLucrPerda*/,nOpc,aEntid,aEntidAnt)

		lAtuProc   := lAtuProc .Or. (_lAtSldCT3 .Or. _lAtSldCT4 .Or. _lAtSldCT7 .Or. _lAtSldCTI)
		_lAtSldCT7 := .F.	/// Chama funcoes de saldo, saldos pelas procedures
		_lAtSldCT3 := .F.	/// Chama funcoes de saldo, saldos pelas procedures
		_lAtSldCT4 := .F.	/// Chama funcoes de saldo, saldos pelas procedures
		_lAtSldCTI := .F.	/// Chama funcoes de saldo, saldos pelas procedures
	EndIf

	//	Se receber o array para os tipos de saldo e for uma Inclusao, armazenar os tipos de saldo a
	//	serem reprocessados
	If lContinua
		CtbAdTpSld(nOpc, aTpSaldo)
	EndIf

Else

	If (nOpc == 4 .Or. nOpc == 5) .And. ;
		dReproc = Nil .And. ;
		TMP->CT2_RECNO <> 0  .And.;
	    !(nOpc	== 4 .and. nValor == 0 .And. nValorAnt	== 0)

		lPodeExc := CanDelCt2(nOpc,,cModoClr)

		If TMP->CT2_DC == '4' .And. nOpc == 5 .And.  __cRetClean == "3"  // Se for continua็ใo de hist๓rico e o usuแrio cancelou a exclusใo
			lPodeExc:= .F.
		EndIf

		If lPodeExc .or. (nOpc == 4 .and. !TMP->CT2_FLAG)	/// SE ALTERACAO E NAO DELETADO

			aOutrEntid 	:= CtbOutrEnt(.F.,Nil,lSimula,cTabCTK,cTabCT2)
			aEntid 		:= aOutrEntid[1]
			aEntidAnt 	:= aOutrEntid[2]

			//// SE FOR ALTERACAO/EXCLUSAO E NAO FOR REPROCESSAMENTO E O REGISTRO JA EXISTIA NO CT2
			//// RETIRA O VALOR DAS TABELAS DE SALDOS
			//Bloco 1
			CtbAtuSld(lAgruSld,aAtuSaldos,"-",cMoeda,nOpcAlt,nValor,nValorAnt,CT2->CT2_DTLP/*dLucrPerda*/,nOpc,aEntid,aEntidAnt )
			// Carrega array para atualizacao de saldos fora da transacao
		Else
			nContMoeda := nMoedas+1 //forca saida do for...next
			lContinua := .F.  // Exit //forca saida do for...next
		EndIf

	EndIf

	// Gravacao dos Saldos de Entidades
	If lContinua .And. ;
		(nOpc == 3 .Or. nOpc == 4 .Or. nOpc == 6 .Or. nOpc == 7 ) .And. ;
		dReproc = Nil   .And.;
		!(nOpc	== 4 .and. nValor == 0 .And. nValorAnt	== 0)
	    //Se eh alteracao e os valores anteriores e atual sao ZERO, nao tem nada para atualiza

		aOutrEntid 	:= CtbOutrEnt(.F.,Nil,lSimula,cTabCTK,cTabCT2)
		aEntid 		:= aOutrEntid[1]
		aEntidAnt 	:= aOutrEntid[2]

		/// SE FOR INCLUSAO/ALTERACAO E NAO FOR REPROCESSAMENTO
		/// GRAVA O VALOR NAS TABELAS DE SALDOS
		//Bloco 2
		CtbAtuSld(lAgruSld,aAtuSaldos,"+",cMoeda,nOpcAlt,nValor,nValorAnt,TMP->CT2_DTLP/*dLucrPerda*/,nOpc,aEntid,aEntidAnt )
	EndIf

	If lContinua //	Se receber array p/tipos de saldo for uma Inclusao, armazenar tipos de saldo a serem reprocessados
		CtbAdTpSld(nOpc, aTpSaldo)
	EndIf

EndIf

Return(lContinua)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbAtuSld บAutor  ณMicrosiga           บ Data ณ  10/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณArmazena o saldo a ser atualizado no array aAtuSaldo para   บฑฑ
ฑฑบ          ณalimentar as tabelas de saldos CT7/CT3/CT4/CTI              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbAtuSld(lAgruSld,aAtuSaldos,cSinal,cMoeda,nOpcAlt,nValor,nValorAnt,dLucrPerda,nOpc,aEntid,aEntidAnt )
//CtbInVStatic()
// Carrega array para atualizacao de saldos fora da transacao
If !lAgruSld .OR. _lCTB150 .OR. __IsCtbJob
	aAdd(aAtuSaldos,{	cSinal,,,,,TMP->CT2_DC,;
						cMoeda,TMP->CT2_DEBITO,TMP->CT2_CREDIT,;
						TMP->CT2_CCD,TMP->CT2_CCC,TMP->CT2_ITEMD,TMP->CT2_ITEMC,;
						TMP->CT2_CLVLDB,TMP->CT2_CLVLCR,nValor,TMP->CT2_TPSALD,;
						nOpcAlt,CT2->CT2_DEBITO,CT2->CT2_CREDIT,CT2->CT2_CCD,CT2->CT2_CCC,;
						CT2->CT2_ITEMD,CT2->CT2_ITEMC,CT2->CT2_CLVLDB,CT2->CT2_CLVLCR,;
						nValorAnt,CT2->CT2_DC,CT2->CT2_TPSALD,cMoeda,;
						,,,,,,dLucrPerda,TMP->CT2_FLAG,nOpc,TMP->CT2_LINHA,aEntid,aEntidAnt,;
						TMP->CT2_MOEFDB,CT2->CT2_MOEFDB,TMP->CT2_MOEFCR,CT2->CT2_MOEFCR } )
Else
	CtAgrupSld(@aAtuSaldos,{ {cSinal,,,,,TMP->CT2_DC,;
						cMoeda,TMP->CT2_DEBITO,TMP->CT2_CREDIT,;
						TMP->CT2_CCD,TMP->CT2_CCC,TMP->CT2_ITEMD,TMP->CT2_ITEMC,;
						TMP->CT2_CLVLDB,TMP->CT2_CLVLCR,nValor,TMP->CT2_TPSALD,;
						nOpcAlt,CT2->CT2_DEBITO,CT2->CT2_CREDIT,CT2->CT2_CCD,CT2->CT2_CCC,;
						CT2->CT2_ITEMD,CT2->CT2_ITEMC,CT2->CT2_CLVLDB,CT2->CT2_CLVLCR,;
						nValorAnt,CT2->CT2_DC,CT2->CT2_TPSALD,cMoeda,;
						,,,,,,dLucrPerda,TMP->CT2_FLAG,nOpc,TMP->CT2_LINHA,aEntid,aEntidAnt,; ///Soma chaves iguais no array de entidades /reduz quant. de atualizacoes de saldos
						TMP->CT2_MOEFDB,CT2->CT2_MOEFDB,TMP->CT2_MOEFCR,CT2->CT2_MOEFCR } } )
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbAdTpSldบAutor  ณMicrosiga           บ Data ณ  10/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAdiciona o tipo de saldo digitado na tabela TMP no array    บฑฑ
ฑฑบ          ณaTpSaldo                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbAdTpSld(nOpc, aTpSaldo)

If aTpSaldo <> Nil .And. nOpc == 3 .And. !Empty(TMP->CT2_TPSALD)
	If Ascan( aTpSaldo,TMP->CT2_TPSALD ) == 0
		Aadd( aTpSaldo,TMP->CT2_TPSALD )
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbDelSqLcบAutor  ณMicrosiga           บ Data ณ  10/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExclui a sequencia de lancamento conforme parametros infor- บฑฑ
ฑฑบ          ณmados                                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbDelSqLc(cTpSld,cMoedaDel,nContMoeda,aRecTmp,dDatalanc,cLote,cSubLote,cDoc,cLinha,cSeqLan01,cEmpOri,cFilOri,cSeqHis01,cTpLan01)
Local nMoedas		:= __nQuantas

If CtbPesqCT2(dDataLanc,cLote,cSubLote,cDoc,cLinha,cTpSld,TMP->CT2_EMPORI,TMP->CT2_FILORI,cMoeda)
	// SE ENCONTROU O REGISTRO NA MOEDA INDICADA (FOR)
	cEmpOri		:= TMP->CT2_EMPORI
	cFilOri		:= TMP->CT2_FILORI
	cSeqLan01	:= CT2->CT2_SEQLAN
	cSeqHis01	:= CT2->CT2_SEQHIS
	cTpLan01	:= CT2->CT2_DC

	/* Exclui os lancamentos complementares */
	If CTBLCUso()
		CTBLCDelLC(CT2->(Recno()),.T.)
	EndIf

	CtbExclCT2(aRecTmp)

EndIf

cMoedaDel	:= Left(cMoedaDel,nContMoeda-1)+"1"+Right(cMoedaDel,ABS(Len(cMoedaDel)-(nContMoeda)))

//Se esta for a a ultima moeda. // SO DELETA AS CONTINUACOES SE ERA REGISTRO DE LANCAMENTO (123)
If cTpLan01 <> "4" .and. cMoeda = StrZero(nMoedas,2) .And. At("2",cMoedaDel) <= 0
	CtbDElseqL(aRecTmp,dDatalanc,cLote,cSubLote,cDoc,cSeqLan01,cEmpOri,cFilOri, cSeqHis01)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbExclCT2บAutor  ณMicrosiga           บ Data ณ  10/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExclui o lancamento na tabela CT2 e armazena no array       บฑฑ
ฑฑบ          ณpassado como parametro o Recno do TMP e do CT2              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbExclCT2(aRecTmp)

aAdd(aRecTmp[Len(aRecTmp)], {TMP->(RECNO()), CT2->(RECNO()), 5, NIL})
CtbDelCT2()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbDelCT2 บAutor  ณMicrosiga           บ Data ณ  10/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExclui o lancamento da tabela CT2                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbDelCT2()

If CT2->CT2_MOEDLC = "01"
	CtbCSQDel()  //rotina que exclui o lan็amento extemporaneo CSQ
	CtbCQWDel()  // Deleta o vinculo I157
EndIf

Reclock("CT2", .F., .T. )
CT2->( DbDelete() )
MsUnlock()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbExclCTCบAutor  ณMicrosiga           บ Data ณ  17/01/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExclui a capa do lote dos lancamentos contabeis na tabela CTCบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbExclCTC(dDataLanc,cLote,cSubLote,cDoc)
Local aSaveArea	:= GetArea()
Local aSaveCTC		:= CTC->(GetArea())
Local aSaveCT2		:= CT2->(GetArea())

CT2->(DbSetOrder(1)) //CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC
CTC->(DbSetOrder(1)) //CTC_FILIAL+DTOS(CTC_DATA)+CTC_LOTE+CTC_SBLOTE+CTC_DOC+CTC_MOEDA+CTC_TPSALD
If CTC->(DbSeek(xFilial("CTC")+DTOS(dDataLanc)+cLote+cSubLote+cDoc))
	If !CT2->(DbSeek(xFilial("CTC")+DTOS(CTC->CTC_DATA)+CTC->CTC_LOTE+CTC->CTC_SBLOTE+CTC->CTC_DOC))
		While CTC->(CTC_FILIAL+DTOS(CTC_DATA)+CTC_LOTE+CTC_SBLOTE+CTC_DOC) ==  xFilial("CTC")+DTOS(dDataLanc)+cLote+cSubLote+cDoc .AND. CTC->(!EOF())
			Reclock("CTC",.F.)
			CTC->(DbDelete())
			CTC->(MsUnlock())
			CTC->(DbSkip())
		EndDo
	EndIf
EndIf

RestArea(aSaveCT2)
aSize(aSaveCT2,0)
aSaveCT2 := nil 

RestArea(aSaveCTC)
aSize(aSaveCTC,0)
aSaveCTC := nil 

RestArea(aSaveArea)
aSize(aSaveArea,0)
aSaveArea := nil 

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbDElseqLบAutor  ณMicrosiga           บ Data ณ  10/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExclui sequencia de lancamento da tabela CT2 relativo a     บฑฑ
ฑฑบ          ณHistorio ( CT2_DC == '4' )                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbDElseqL(aRecTmp,dDatalanc,cLote,cSubLote,cDoc,cSeqLan01,cEmpOri,cFilOri, cSeqHis01)
Local nOrderAnt, nRecnoAnt

dbSelectArea("CT2")     //salva ordem e recno corrente
nOrderAnt	:= CT2->(IndexOrd())
nRecnoAnt	:= CT2->(Recno())

dbSelectArea("CT2")

cQuery := " SELECT "
cQuery += " R_E_C_N_O_ CT2_RECNO "
cQuery += " FROM " + RetSqlName("CT2")+" CT2 "
cQuery += " WHERE "
cQuery += " CT2_FILIAL = '"+xFilial("CT2")+"' "
cQuery += " AND CT2_DATA = '"+Dtos(dDatalanc)+"' "
cQuery += " AND CT2_LOTE = '"+cLote+"' "
cQuery += " AND CT2_SBLOTE = '"+cSubLote+"' "
cQuery += " AND CT2_DOC = '"+cDoc+"' "
cQuery += " AND CT2_SEQLAN  = '"+cSeqLan01+"' "
cQuery += " AND CT2_EMPORI = '"+cEmpOri+"' "
cQuery += " AND CT2_FILORI = '"+cFilOri+"' "
cQuery += " AND CT2_DC = '4' "
cQuery += " AND CT2_SEQHIS > '"+cSeqHis01+"' "
cQuery += " AND CT2.D_E_L_E_T_ = ' ' "
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"CT2_QRY",.T.,.F.)

While CT2_QRY->(! Eof() )

	dbSelectArea("CT2")
	CT2->(dbGoto( CT2_QRY->CT2_RECNO ))
	CtbExclCT2(aRecTmp)

	dbSelectarea("TMP")
	TMP->(dbSetOrder(2))
	If TMP->(MsSeek(CT2->CT2_LINHA))
		TMP->CT2_FLAG	:= .T.
	EndIf
	//dbSetOrder(0)

	CT2_QRY->( dbSkip() )

EndDo

dbSelectArea("CT2_QRY")
CT2_QRY->(dbCloseArea())

dbSelectArea("CT2")
dbSetOrder(nOrderAnt)		//// RESTAURA ORDEM DO CT2
dbGoto(nRecnoAnt)			//// E POSICAO DO CT2

dbSelectArea("TMP")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbGrvCT2 บAutor  ณMicrosiga           บ Data ณ  10/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava registro ref. lancamento na tabela CT2                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbGrvCT2(nOpc, lInclui, dDataLanc, cLote, cSubLote, cDoc, cFilOri, cEmpOri, cSequenc, ;
							lAglut, nContMoeda, cMoeda, aHeader, lAltTpSld, cProg, cSeqLan, cSeqLan01, ;
							nSeqHis, cSeqHis01, lFirstSq, lSeqCorr, cSeqCorr, lCusto,lItem,lCLVL, 		;
							nTotInf, lSimula, cTabCTK, cTabCT2,lCTBManual,dDtSeq,cCT2_KEY)

Local nCont
Local cQuery		:= ""
Local lMudaTRT		:= SuperGetMV("MV_MUDATRT",.F.,.T.)
Local nRecCT2
Local lCubo			:= CTBISCUBE()
Local cHoraLc		:= Time()
Local cTabTRW 		:= "TRW"+SM0->M0_CODIGO+"0"+Iif(lMudaTRT, "_SP", "")
Local lExistTRW     := .T.

Default lSimula		:= .F.
Default cTabCTK		:= "CTK"
Default cTabCT2		:= "CT2"
Default lCTBManual	:= .F.
Default cCT2_KEY	:= ""

Static nPosHora := CT2->( FieldPos( 'CT2_HORALC' ) )

dbSelectArea("CT2")

RecLock( "CT2", lInclui )
If lInclui
	CT2->CT2_FILIAL		:= xFilial("CT2")
	CT2->CT2_DATA		:= dDataLanc
	CT2->CT2_LOTE		:= cLote
	CT2->CT2_SBLOTE		:= cSubLote
	CT2->CT2_DOC		:= cDoc
	CT2->CT2_FILORI		:= cFilOri
	CT2->CT2_EMPORI		:= cEmpOri
	CT2->CT2_LP			:= TMP->CT2_LP
	CT2->CT2_SEQUEN		:= cSequenc
	CT2->CT2_ROTINA		:= cProg
	CT2->CT2_ORIGEM		:= TMP->CT2_ORIGEM
	CT2->CT2_AGLUT		:= IIf(lAglut,"1","2")
	CT2->CT2_MOEDLC		:= cMoeda
	CT2->CT2_DTCV3		:= Iif(Empty(TMP->CT2_DTCV3),dDtSeq,TMP->CT2_DTCV3)

	If nPosHora > 0
		CT2->CT2_HORALC	:= cHoraLc
	EndIf
Else
	/* Exclui os lancamentos complementares */
	If CTBLCUso()
		CTBLCDelLC(CT2->(Recno()),.T.)
	EndIf
EndIf

//- retirado para evitar o I/O de flush da CT2 - Performance
//nRecCT2 := CT2->(Recno())

For nCont := 1 To Len(aHeader)
	If (aHeader[nCont][10] != "V" )
		// VerIfica se o campo existe na estrutura do CT2
		If CT2->(FieldPos(aHeader[nCont][2])) != 0
			CT2->(FieldPut( FieldPos(aHeader[nCont][2]), TMP->(FieldGet(FieldPos(aHeader[nCont][2]))) ))
		EndIf
	EndIf
Next nCont

If cPaisLoc == "RUS" .And. SuperGetMv("MV_REDSTORN",.F.,.F.)
	CT2_EC05DB := CT2->CT2_CREDIT
	CT2_EC05CR := CT2->CT2_DEBITO
Endif

If nOpc == 4 .And. !lInclui .And. lAltTpSld
	CT2->CT2_TPSALD	:= TMP->CT2_TPSALD
EndIf

// Gravacao dados complementares
If Empty(CT2->CT2_SEQUEN) .Or. lCTBManual	// Lancamento manual
	CT2->CT2_MANUAL	:= "1"
	// Agora grava a sequencia para tornar possivel a verIficacao do
	// drill down.
	CT2->CT2_SEQUEN	:= cSequenc
Else
	CT2->CT2_MANUAL	:= "2"
	CT2->CT2_KEY	:= TMP->CT2_KEY
EndIf

If  !Empty(cCT2_KEY) .and. funName() == "PROJETOGESPLAN"  // Gravo o campo CT2_KEY com a informa็ใo enviada via execauto Gesplan
	CT2->CT2_KEY := cCT2_KEY
EndIF

//Realiza a grava็ใo do tipo de saldo para a rotina ctba103, pois o campo nใo estแ no aheader
If Alltrim(Upper(cProg)) == "CTBA103"
	CT2->CT2_TPSALD	:= TMP->CT2_TPSALD
EndIf

//Tratamento somente para a moeda 01
If cMoeda = '01'
	If cProg == 'CTBA101'
		If CT2->CT2_DC <> "4"
			cSeqLan := Soma1(cSeqLan)
			CT2->CT2_SEQHIS	:= "001"
			CT2->CT2_SEQLAN	:= cSeqLan
			nSeqHis	:= 1
		ElseIf CT2->CT2_DC == "4"
			nSeqHis++
			CT2->CT2_SEQLAN	:= cSeqLan
			CT2->CT2_SEQHIS	:= StrZero(nSeqHis,3)
		EndIf

	Else         //Se for CTBA105/CTBA102/CTBA103

		//Os campos TMP->CT2_SEQLAN e TMP->CT2_SEQHIS estarao em branco qdo for incluido
		//linhas na GETDB do CTBA105.
		If CT2->CT2_LINHA == StrZero( 1, Len(CT2->CT2_LINHA) )//'001'
			cSeqLan	:= StrZero( 1, Len(CT2->CT2_SEQLAN) )// "001"
			nSeqHis	:= 1
			CT2->CT2_SEQLAN := cSeqLan
			CT2->CT2_SEQHIS := StrZero(nSeqHis,3)

		ElseIf CT2->CT2_DC <> "4" .And. CT2->CT2_LINHA !=  StrZero( 1,Len(CT2->CT2_LINHA) )//'001'
			CT2->CT2_SEQHIS	:= "001"
			nSeqHis := 1
			If !Empty(TMP->CT2_SEQLAN)
				CT2->CT2_SEQLAN	:= TMP->CT2_SEQLAN
				cSeqLan 		:= CT2->CT2_SEQLAN
			Else
				cSeqLan := Soma1(cSeqLan)
				CT2->CT2_SEQLAN := cSeqLan
			EndIf

		ElseIf CT2->CT2_DC == "4" .And. CT2->CT2_LINHA !=  StrZero( 1,Len(CT2->CT2_LINHA) )//'001'
			If Empty(TMP->CT2_SEQLAN)
				CT2->CT2_SEQLAN	:= cSeqLan
			Else
				CT2->CT2_SEQLAN	:= TMP->CT2_SEQLAN
				cSeqLan 		:= CT2->CT2_SEQLAN
			EndIf

			If Empty(TMP->CT2_SEQHIS)
				nSeqHis++
				CT2->CT2_SEQHIS	:= StrZero(nSeqHis,3)
			Else
				CT2->CT2_SEQHIS	:= TMP->CT2_SEQHIS
				nSeqHis 		:= Val(CT2->CT2_SEQHIS)
			EndIf
		EndIf
	EndIf

	CT2->CT2_CRCONV	:= Subs(TMP->CT2_CONVER,1,1)

Else
	CT2->CT2_CRCONV	:= Subs(TMP->CT2_CONVER,nContMoeda,1)
    	   	       	CT2->CT2_SEQLAN	:= cSeqLan01
        	       	CT2->CT2_SEQHIS	:= cSeqHis01
	CT2->CT2_VALOR	:= &("TMP->CT2_VALR"+cMoeda)
EndIf

If lSeqCorr

	If lFirstSq .and. (nOpc == 3 .Or. nOpc == 7 .Or. nOpc == 6 )
		// efetua a grava็ใo do numero gerado, caso jแ exista o numero, ele  irแ gerar um novo.
		cSeqCorr := CTBSQGrv( cSeqCorr ,dDataLanc )
	EndIf
	// Grava sequancia do correlativo
	CT2->CT2_SEGOFI	:= cSeqCorr
	CT2->CT2_NODIA 	:= cSeqCorr

	// Efetua a grava็ใo do codigo do diario no ct2
	If CT2->( FieldPos( "CT2_DIACTB" ) > 0 ) .And. !Empty(cSeqCorr)
		CT2->CT2_DIACTB := Substr( cSeqCorr , 1 , 2)
	EndIf

	If lFirstSq
		FreeUsedCode()  //libera codigos de correlativos reservados pela MayIUseCode()
		lFirstSq := .F.
	EndIf

EndIf

If CtbUso("CT2_DTTX"+cMoeda)
	CT2->CT2_DATATX	:= &("TMP->CT2_DTTX"+cMoeda)
EndIf

If !(cProg $ 'CTBA101,CTBA102,CTBA103') .And. __Ct105CT2 .And. !lSimula
	ExecBlock("CT105CT2", .F., .F., {__nQuantas, dDatalanc,cLote,cSubLote,cDoc,lCusto,lItem,lCLVL,nTotInf,_lAtSldBase,_lReproc })
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณgrava o status do lancamento contabil para que o mesmo sejaณ
//ณvalidado na rotina de copia de saldos                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
CT2->CT2_MLTSLD	:= TMP->CT2_MLTSLD
CT2->CT2_CTLSLD	:= "0"

If _lCtbGrv .And. !lSimula
	ExecBlock("CTBGRV",.f.,.f.,{nOpc,cProg})
EndIf

CT2->( MsUnlock() )
nRecCT2 := CT2->( Recno())

/*
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณLancamento de complementarณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
If cMoeda == "01" .And. CT2->CT2_DC <> "4"	
	If CTBLCUso()
		CTBLCAdCT2(CT2->(Recno()))
	EndIf
EndIf

dbSelectArea("CT2")
CT2->(MsGoto(nRecCT2))

//neste ponto deve ser colocado insert into na tabela trw para passar para a procedure
//de atualizacao de saldos um codigo (transacao)
//nos casos de nOpc --->  3 = inclusao 6 = estorno  7 = copia
lExistTRW := TcCanOpen(cTabTRW)

If lExistTRW .And. ! __IsCtbJob .And. _lctb185 .And. ( nOpc == 3 .OR. nOpc == 6 .OR. nOpc == 7 ) .And. !lSimula
	//popula a tabela TRW com os dados incluidos diretamente no banco de dados
	cQuery := " Insert Into "+cTabTRW//RetSqlName("TRW")
 	cQuery += "  ( CT2_FILIAL, CT2_DATA,   CT2_LOTE,   CT2_SBLOTE, CT2_DOC, "
	cQuery += "    CT2_MOEDLC, CT2_TPSALD, CT2_DC,     CT2_DEBITO, CT2_CREDIT, "
	cQuery += "    CT2_VALOR,  CT2_CCD,    CT2_CCC, CT2_ITEMD,  CT2_ITEMC, "
	cQuery += "    CT2_CLVLDB, CT2_CLVLCR, CT2_EMPORI, CT2_FILORI, CT2_LINHA, "
	cQuery += "    CT2_ATIVDE, R_E_C_N_O_  "
	If lCubo
		If CT2->(FieldPos("CT2_EC05DB")) > 0 .and. CT2->(FieldPos("CT2_EC05CR")) > 0
			cQuery += " ,CT2_EC05DB, CT2_EC05CR  "
		EndIf
		If CT2->(FieldPos("CT2_EC06DB")) > 0 .and. CT2->(FieldPos("CT2_EC06CR")) > 0
			cQuery += " ,CT2_EC06DB, CT2_EC06CR  "
		EndIf
		If CT2->(FieldPos("CT2_EC07DB")) > 0 .and. CT2->(FieldPos("CT2_EC07CR")) > 0
			cQuery += " ,CT2_EC07DB, CT2_EC07CR  "
		EndIf
		If CT2->(FieldPos("CT2_EC08DB")) > 0 .and. CT2->(FieldPos("CT2_EC08CR")) > 0
			cQuery += " ,CT2_EC08DB, CT2_EC08CR  "
		EndIf
		If CT2->(FieldPos("CT2_EC09DB")) > 0 .and. CT2->(FieldPos("CT2_EC09CR")) > 0
			cQuery += " ,CT2_EC09DB, CT2_EC09CR  "
		EndIf
	EndIf
	cQuery += " )"
	cQuery += " Values ( "
	cQuery += "  '"+CT2->CT2_FILIAL+"', '"+DTOS(CT2->CT2_DATA)+"', '"+CT2->CT2_LOTE+"', '"+CT2->CT2_SBLOTE+"', '"+CT2->CT2_DOC+"', "
	cQuery += "  '"+CT2->CT2_MOEDLC+"', '"+CT2->CT2_TPSALD+"', '"+CT2->CT2_DC+"', '"+CT2->CT2_DEBITO+"', '"+CT2->CT2_CREDIT+"', "
	cQuery += "  "+Str(CT2->CT2_VALOR,TamSX3('CT2_VALOR')[1],TamSX3('CT2_VALOR')[2])+", '"+CT2->CT2_CCD+"', '"+CT2->CT2_CCC+"', '"+CT2->CT2_ITEMD+"', '"+CT2->CT2_ITEMC+"', "
	cQuery += "  '"+CT2->CT2_CLVLDB+"', '"+CT2->CT2_CLVLCR+"', '"+CT2->CT2_EMPORI+"', '"+CT2->CT2_FILORI+"', '"+CT2->CT2_LINHA+"', "
	cQuery += "  '"+StrZero(ThreadID(),Len(CT2->CT2_ATIVDE))+"', "+CT2->(Str(Recno(),17))

	If lCubo
		If CT2->(FieldPos("CT2_EC05DB")) > 0 .and. CT2->(FieldPos("CT2_EC05CR")) > 0
			cQuery += " ,'" + CT2->CT2_EC05DB + "' , '" + CT2->CT2_EC05CR +"'"
		EndIf
		If CT2->(FieldPos("CT2_EC06DB")) > 0 .and. CT2->(FieldPos("CT2_EC06CR")) > 0
			cQuery += " ,'" + CT2->CT2_EC06DB + "' , '" + CT2->CT2_EC06CR +"'"
		EndIf
		If CT2->(FieldPos("CT2_EC07DB")) > 0 .and. CT2->(FieldPos("CT2_EC07CR")) > 0
			cQuery += " ,'" + CT2->CT2_EC07DB + "' , '" + CT2->CT2_EC07CR +"'"
		EndIf
		If CT2->(FieldPos("CT2_EC08DB")) > 0 .and. CT2->(FieldPos("CT2_EC08CR")) > 0
			cQuery += " ,'" + CT2->CT2_EC08DB + "' , '" + CT2->CT2_EC08CR +"'"
		EndIf
		If CT2->(FieldPos("CT2_EC09DB")) > 0 .and. CT2->(FieldPos("CT2_EC09CR")) > 0
			cQuery += " ,'" + CT2->CT2_EC09DB + "' , '" + CT2->CT2_EC09CR +"'"
		EndIf
	EndIf
	cQuery += " )"

	If TcSqlExec(cQuery) <> 0
		UserException(STR0043 + CRLF + STR0044+ CRLF + TCSqlError() )//"Erro na preparacao do arquivo de trabalho para procedure atualizar saldos. "##"Efetuar o Reprocessamento dos saldos"
	EndIf
EndIf

Return nRecCT2


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbGrvCV3 บAutor  ณMicrosiga           บ Data ณ  10/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava na tabela CV3 (rastreamento) dados referente ao lanca-บฑฑ
ฑฑบ          ณtos gravados na tabela CTK                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbGrvCV3(lInclui,aRecTmp,aCTKxCT2,nPosATMP,cMoeda,cSeqLan01,cSeqHis01,lSimula,cTabCTK,cTabCT2)

Local cAliasAnt	:= Alias()
Local nRecnoAnt	:= Recno()
Local nPosACTK
Local nRecnoCT2 := CT2->(RECNO())
Local cFieldUID := CtbCpoUID("CT2")

Default lSimula	:= .F.
Default cTabCTK	:= "CTK"
Default cTabCT2	:= "CT2"

//Alterado para passar no issue x cobertura. Prote็ใo por se tratar de variแvel static.
_lPostgres :=  IIf(_lPostgres == NIL,Upper(TcGetDb())$"POSTGRES",_lPostgres)

If lCV3IDDEST == Nil
	lCV3IDDEST := CV3->(FieldPos("CV3_IDDEST")) > 0
EndIf

If lCT2MSUID == Nil
	lCT2MSUID := !Empty(cFieldUID)			
EndIf

If lInclui
	aAdd(aRecTmp[Len(aRecTmp)], {TMP->(RECNO()), nRecnoCT2, 3, NIL})

	///////////////////////////////////////////////////////////////////////////////////
	/// CONTROLE DE RASTREAMENTO DOS LANCAMENTOS (SEM CTL) -> ARRAY ALIMENTADO NA CTB105GRV()
	///////////////////////////////////////////////////////////////////////////////////
	If lCTKRECDES .and. nPosATMP > 0 .And. Len(aCTKxCT2[nPosATMP]) > 0
		For nPosACTK	:= 1 TO Len(aCTKxCT2[nPosATMP][2])
	
			CTK->(dbGoTo(aCTKxCT2[nPosATMP][2][nPosACTK]))
			If CTK->(Recno()) == aCTKxCT2[nPosATMP][2][nPosACTK] .and. Empty(CTK->CTK_RECDES)
				CTK->(RecLock("CTK",.F.))
				CTK->CTK_RECDES := ALLTRIM(STR(INT(nRecnoCT2)))
				CTK->(MsUnlock())

				If lCTKRECCV3
					
					If Empty(CTK->CTK_RECCV3) 			/// CTL NรO CONFIGURADO - CRIA CV3
						NewCV3byCTK(lSimula,cTabCTK,cTabCT2)
					Else
						CV3->( dbGoTo(int(val(CTK->CTK_RECCV3))) )
						If CV3->(Recno()) == int(val(CTK->CTK_RECCV3)) /// SE ENCONTROU O CV3 - ALIMENTA CAMPO
							CV3->( recLock("CV3", .f.) )
							CV3->CV3_RECDES := CTK->CTK_RECDES
							If lCV3IDDEST .And. lCT2MSUID
								CT2->(dbSkip(-1))
								CT2->(dbGoTo(nRecnoCT2))
								CV3->CV3_IDDEST := If(_lPostgres,Lower(&("CT2->"+cFieldUID)),&("CT2->"+cFieldUID))
							EndIf
							CV3->(MsUnlock())
						Else
							NewCV3byCTK(lSimula,cTabCTK,cTabCT2)							   /// SE NรO ENCONTROU O CV3 - CRIA CV3
						EndIf
					EndIf

				EndIf
			EndIf
		Next
	EndIf
Else
	aAdd(aRecTmp[Len(aRecTmp)], {TMP->(RECNO()), CT2->(RECNO()), 4, NIL})
EndIf

If cMoeda ='01'
	cSeqLan01	:= CT2->CT2_SEQLAN
	cSeqHis01	:= CT2->CT2_SEQHIS
EndIf

dbSelectArea(cAliasAnt)
MsGoto(nRecnoAnt)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbEftCorrบAutor   ณMicrosiga           บ Data ณ  10/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava seuencia do correlativo                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbEftCorr(aFlagCTB,aCTKxCT2,lSeqCorr,cSeqCorr,aSeqDiario,cSeqDiario,aRecTmp)
Local nPosAFlag
Local nCtdASeq
Local cCodDia		:= "" // codigo do diario de portugal
Local x
Local aFlagTmp	:= {}
Local lUsaFlag	:= GetNewPar("MV_CTBFLAG", .F.)
Local lContabOf := AllTrim(FunName()) $ "CTBANFE,CTBANFS,CTBAFIN,FINA370,CTBAATF,ATFA370,MATA330,ATFA371,PLSCTB06,PLSCTB11"

Default aFlagCTB	:= {}
Default aCTKxCT2	:= {}
Default lSeqCorr	:= .F.
Default cSeqCorr	:= ""
Default aSeqDiario	:= {}
Default cSeqDiario	:= ""
Default aRecTmp		:= {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Efetua a atualiza็ใo dos flags de contabiliza็ใo                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nPosAFlag := 1 to Len(aFlagCTB)
	If aFlagCTB[nPosAFlag][4] <> 0
		If lUsaFlag .And. lContabOf //Controle flag de transa็?o habilitado e Contabiliza็?o Off-Line
			If aFlagCTB[nPosAFlag][7] <> 0 //Aplica flag no registro
				dbSelectArea(aFlagCTB[nPosAFlag][3])
				MsGoTo(aFlagCTB[nPosAFlag][4])

				RecLock(aFlagCTB[nPosAFlag][3],.F.)
				&(aFlagCTB[nPosAFlag][1]) := aFlagCTB[nPosAFlag][2]
				MsUnlock()
			Else
				aAdd(aFlagTmp, aFlagCTB[nPosAFlag]) //Salva registro com flag para execu็ใo posterior 
			EndIf
		Else
			dbSelectArea(aFlagCTB[nPosAFlag][3])
			MsGoTo(aFlagCTB[nPosAFlag][4])

			RecLock(aFlagCTB[nPosAFlag][3],.F.)
			&(aFlagCTB[nPosAFlag][1]) := aFlagCTB[nPosAFlag][2]
			MsUnlock()
		EndIf
	EndIf
Next

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Efetua a gravacao na tabela de origiem do item para contabilizar    ณ
//ณ no Diario                                                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lSeqCorr .And. Len( aSeqDiario ) > 0 .AND. !empty(aRecTmp) //ultima condi็ใo inserida para verIficar se as linha do lancamento foram apagadas
	// limpo a variavel de sequencia para garatir a integridade do diario
	cSeqDiario 	:= cSeqCorr
	cCodDia		:= Substr( cSeqCorr , 1 , 2 )

	// efetua a grava็ใo no documento de origem
	For nCtdASeq :=  1 to Len(aSeqDiario)
		// procurar o codigo do diario(aSeqDiario[nCtdASeq][2]) na tabela CVL
		// E procurar o ultimo numero sequencial(CVM_SEQULT)+1 conforme dDataLanc informado
		// E atualizar o campo CVM_SEQULT e CVM_DTSEQ
		If aSeqDiario[nCtdASeq][2] <> 0

			// efetuo o posicionamento a origem para atualiza็ใo
			dbSelectArea(aSeqDiario[nCtdASeq][1])
			dbGoTo(aSeqDiario[nCtdASeq][2])

			// Grava apenas se o registro existir e o codigo do correlativo em branco
			If !( (aSeqDiario[nCtdASeq][1])->(Eof()) ) .And. Empty( &(aSeqDiario[nCtdASeq][4]) )

				RecLock(aSeqDiario[nCtdASeq][1],.F.)
				&(aSeqDiario[nCtdASeq][4]) := cSeqDiario
				//Se o Lan็amento for dIferente de inclusao ele ira gravar o campo CTBDIA
				If Len(aSeqDiario[nCtdASeq]) == 5
					//VerIfica se o campo esta trazendo o nome do campo para gravar o campo DIACTB.
					If aSeqDiario[nCtdASeq][5] <> ""
						&(aSeqDiario[nCtdASeq][5]) := cCodDia
					EndIf
				EndIf

				MsUnlock()

				If _lCTBSEQDIA
					ExecBlock("CTBSEQDIA",.F.,.F.,{aSeqDiario[nCtdASeq],cCodDia,cSeqDiario})
				EndIf
			Else
				cSeqDiario := &(aSeqDiario[nCtdASeq][4])
			EndIf
		EndIf

	Next nCtdASeq

	// efetua a grava็ใo no registro contabilizado CTB
	If ValType( cSeqDiario ) == "C" .And. ! Empty( cSeqDiario ) .And. CT2->( FieldPos( 'CT2_NODIA' ) ) > 0
		For nCtdASeq := 1 to Len(aRecTmp)
			For x := 1 to Len(aRecTmp[nCtdASeq])
				CT2->(dbGoTo(aRecTmp[nCtdASeq][x][2]))

				RecLock('CT2',.F.)
				CT2->CT2_NODIA  := cSeqDiario
				If CT2->( FieldPos( 'CT2_SEGOFI' ) ) > 0
					CT2->CT2_SEGOFI := cSeqCorr
				EndIf

				// Efetua a grava็ใo do codigo do diario no ct2
				If CT2->( FieldPos( "CT2_DIACTB" ) > 0 )
					CT2->CT2_DIACTB := cCodDia
				EndIf

				MsUnlock()
			Next x
		NEXT
	EndIf
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ BOPS 00000125253 - Limpeza do array aFlagCTB ap๓s utilizacao        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aFlagCTB := aClone(aFlagTmp)

aCTKxCT2 := {}

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ NEwCtbEftCorrบ  Autor  ณMicrosiga     บ Data ณ  10/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava seuencia do correlativo e atualiza flag de conta-     บฑฑ
ฑฑบ          ณbiliza็ใo na origem                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function NewCtbEftCorr(aFlagCTB,aCTKxCT2,lSeqCorr,cSeqCorr,aSeqDiario,cSeqDiario,aRecTmp,aFlgSimple)
Local nPosAFlag
Local nCtdASeq
Local cCodDia		:= "" // codigo do diario de portugal
Local x
Local aFlagTmp	:= {}
Local lUsaFlag	:= GetNewPar("MV_CTBFLAG", .F.)
Local lContabOf := AllTrim(FunName()) $ "CTBANFE,CTBANFS,CTBAFIN,FINA370,CTBAATF,ATFA370,MATA330,ATFA371,PLSCTB06,PLSCTB11"

Default aFlagCTB	:= {}
Default aCTKxCT2	:= {}
Default lSeqCorr	:= .F.
Default cSeqCorr	:= ""
Default aSeqDiario	:= {}
Default cSeqDiario	:= ""
Default aRecTmp		:= {}
Default aFlgSimple  := {}   // vetor p armazenar os recnos a tirar o SimpleLock
/*  ---------------------------------------------------------------------------
	Tirar o simpleLock dos registros da Origem antes de gravar o flag
    --------------------------------------------------------------------------- */
//105LockFlg(aFlagCtb,aFlegados)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Efetua a atualiza็ใo dos flags de contabiliza็ใo                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nPosAFlag := 1 to Len(aFlagCTB)
	If aFlagCTB[nPosAFlag][4] <> 0
		If lUsaFlag .And. lContabOf //Controle flag de transa็?o habilitado e Contabiliza็?o Off-Line
			If aFlagCTB[nPosAFlag][7] <> 0 //Aplica flag no registro
				dbSelectArea(aFlagCTB[nPosAFlag][3])
				MsGoTo(aFlagCTB[nPosAFlag][4])
				//Sempre dentro da transa็ใo de grava็ใo do CTW e SimpleLock
				RecLock(aFlagCTB[nPosAFlag][3], .F.)
				&(aFlagCTB[nPosAFlag][1]) := aFlagCTB[nPosAFlag][2]
				MsUnlock()
				Aadd(aFlgSimple, {aFlagCTB[nPosAFlag][3], aFlagCTB[nPosAFlag][4]})
			Else
				aAdd(aFlagTmp, aFlagCTB[nPosAFlag]) //Salva registro com flag para execu็ใo posterior 
			EndIf
		Else
			dbSelectArea(aFlagCTB[nPosAFlag][3])
			MsGoTo(aFlagCTB[nPosAFlag][4])
			RecLock(aFlagCTB[nPosAFlag][3], .F.)
			&(aFlagCTB[nPosAFlag][1]) := aFlagCTB[nPosAFlag][2]
			MsUnlock()
			Aadd(aFlgSimple, {aFlagCTB[nPosAFlag][3], aFlagCTB[nPosAFlag][4]})
		EndIf
	EndIf
Next

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Efetua a gravacao na tabela de origiem do item para contabilizar    ณ
//ณ no Diario                                                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lSeqCorr .And. Len( aSeqDiario ) > 0 .AND. !empty(aRecTmp) //ultima condi็ใo inserida para verIficar se as linha do lancamento foram apagadas
	// limpo a variavel de sequencia para garatir a integridade do diario
	cSeqDiario 	:= cSeqCorr
	cCodDia		:= Substr( cSeqCorr , 1 , 2 )

	// efetua a grava็ใo no documento de origem
	For nCtdASeq :=  1 to Len(aSeqDiario)
		// procurar o codigo do diario(aSeqDiario[nCtdASeq][2]) na tabela CVL
		// E procurar o ultimo numero sequencial(CVM_SEQULT)+1 conforme dDataLanc informado
		// E atualizar o campo CVM_SEQULT e CVM_DTSEQ
		If aSeqDiario[nCtdASeq][2] <> 0

			// efetuo o posicionamento a origem para atualiza็ใo
			dbSelectArea(aSeqDiario[nCtdASeq][1])
			dbGoTo(aSeqDiario[nCtdASeq][2])

			// Grava apenas se o registro existir e o codigo do correlativo em branco
			If !( (aSeqDiario[nCtdASeq][1])->(Eof()) ) .And. Empty( &(aSeqDiario[nCtdASeq][4]) )

				RecLock(aSeqDiario[nCtdASeq][1],.F.)
				&(aSeqDiario[nCtdASeq][4]) := cSeqDiario
				//Se o Lan็amento for dIferente de inclusao ele ira gravar o campo CTBDIA
				If Len(aSeqDiario[nCtdASeq]) == 5
					//VerIfica se o campo esta trazendo o nome do campo para gravar o campo DIACTB.
					If aSeqDiario[nCtdASeq][5] <> ""
						&(aSeqDiario[nCtdASeq][5]) := cCodDia
					EndIf
				EndIf

				MsUnlock()

				If _lCTBSEQDIA
					ExecBlock("CTBSEQDIA",.F.,.F.,{aSeqDiario[nCtdASeq],cCodDia,cSeqDiario})
				EndIf
			Else
				cSeqDiario := &(aSeqDiario[nCtdASeq][4])
			EndIf
		EndIf

	Next nCtdASeq

	// efetua a grava็ใo no registro contabilizado CTB
	If ValType( cSeqDiario ) == "C" .And. ! Empty( cSeqDiario ) .And. CT2->( FieldPos( 'CT2_NODIA' ) ) > 0
		For nCtdASeq := 1 to Len(aRecTmp)
			For x := 1 to Len(aRecTmp[nCtdASeq])
				CT2->(dbGoTo(aRecTmp[nCtdASeq][x][2]))

				RecLock('CT2',.F.)
				CT2->CT2_NODIA  := cSeqDiario
				If CT2->( FieldPos( 'CT2_SEGOFI' ) ) > 0
					CT2->CT2_SEGOFI := cSeqCorr
				EndIf

				// Efetua a grava็ใo do codigo do diario no ct2
				If CT2->( FieldPos( "CT2_DIACTB" ) > 0 )
					CT2->CT2_DIACTB := cCodDia
				EndIf

				MsUnlock()
			Next x
		NEXT
	EndIf
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ BOPS 00000125253 - Limpeza do array aFlagCTB ap๓s utilizacao        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aFlagCTB := aClone(aFlagTmp)

aCTKxCT2 := {}
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbShwMsgSq บAutor  ณMicrosiga         บ Data ณ  10/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExibe a mensagem informando o sequencial numerico do diario บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbShwMsgSq(cSeqDiario)

If UsaSeqCor() .And. ;
	ValType( cSeqDiario ) == "C" .And.;
	! Empty( cSeqDiario )
	If GetNewPar( "MV_MTRDIAR" , 2 ) == 1  // 1=exibe a mensagem para o usuario do numero da sequencia gerada
		ApMsgInfo( STR0042 + cSeqDiario, STR0042 ) // "O numero sequencial gerado foi " ## "Sequencial numerico do diario"
	EndIf
EndIf

Return

//-------------------------------------------------------------------
/*{Protheus.doc} CtbPrSaldo บAutor
Processa a atualizacao de saldos

@author Alvaro Camillo Neto

@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Static Function CtbPrSaldo(nOpc,cProg,aAtuSaldos,cLote,cSubLote,cDoc,dDataLanc,lCusto,lItem,lClVL,lTRBProc,cHistLote,cMoedDoc,cCritDoc,dDatTaxDoc,cTipSldDoc,cLivDia,cNroDia,cFilOri)

//Efetua a atualiza็ใo dos saldos fora da transacao dos lancamentos

Local aSldJaOk		:= {}
Local lUltCj		:= .F.
Local lPodeGrv		:= .T.	/// Permite gravar sem o semaforo de contas
Local lIntegraPre	:= .F.
Local nx
Local aTravas
Local nOpcProc   	:= nOpc
Local aLinhas		:=	{}
Local cFilAux		:= IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
Local cOperacao 	:= ""
Local nVlMo01		:= 0
Local nVlAntMo01	:= 0
Local nTxMoed		:= 0
Local nTxAntMoed	:= 0
Local nTamDec		:= TamSX3("CQB_COTMOE")[2]

Default cHistLote	:= ""
Default cMoedDoc	:= ""
Default cCritDoc	:= ""
Default dDatTaxDoc	:= STOD("")
Default cTipSldDoc	:= ""
Default cLivDia		:= ""
Default cNroDia		:= ""
Default	cFilOri		:= cFilant

lIntegraPre	:= ! cProg$'CTBA101,CTBA102,CTBA350,CTBA103' .and. SuperGetMv("MV_PRELAN") == "S"	/// Indica lan็amento de integra็ใo com Pr้-lan็amentos

nOpcProc 			:= IIf( nOpc == 6 .or. nOpc == 7 , 3, nOpc)

//Atualiza a tabela de saldos da variacao monetaria
For nx := 1 to Len(aAtuSaldos)

	If aAtuSaldos[nx,7] == "01"
		nVlMo01	:= aAtuSaldos[nx,16]
		nVlAntMo01	:= aAtuSaldos[nx,27]
	EndIf

	If aAtuSaldos[nx,1] == "-"
		If (aAtuSaldos[nx,7] == aAtuSaldos[nX,44] .And. !Empty(aAtuSaldos[nx,19])) .Or.  (aAtuSaldos[nx,7] == aAtuSaldos[nX,46] .And. !Empty(aAtuSaldos[nx,20]))

			If VldAltCQB(nOpc,aAtuSaldos[nx,8],aAtuSaldos[nx,9],aAtuSaldos[nx,10],aAtuSaldos[nx,11],aAtuSaldos[nx,12],aAtuSaldos[nx,13],aAtuSaldos[nx,14],aAtuSaldos[nx,15],aAtuSaldos[nx,41],;
				aAtuSaldos[nx,19],aAtuSaldos[nx,20],aAtuSaldos[nx,21],aAtuSaldos[nx,22],aAtuSaldos[nx,23],aAtuSaldos[nx,24],aAtuSaldos[nx,25],aAtuSaldos[nx,26],aAtuSaldos[nx,42],;
				aAtuSaldos[nx,16],aAtuSaldos[nx,27],;
				aAtuSaldos[nx,43],aAtuSaldos[nx,44],;
				aAtuSaldos[nx,45],aAtuSaldos[nx,46])
				//----------------------------------------------------------------
				// Diminui o saldo da chave anterior
				//----------------------------------------------------------------
				//Debito
				If (aAtuSaldos[nx,7] == aAtuSaldos[nX,44] .And. !Empty(aAtuSaldos[nx,19]))
					nTxAntMoed := Round(nVlAntMo01/aAtuSaldos[nx,27],nTamDec)
					GravaCQB(1,"-",dDataLanc,aAtuSaldos[nX,44],nTxAntMoed,aAtuSaldos[nx,27],aAtuSaldos[nx,19],aAtuSaldos[nx,21],aAtuSaldos[nx,23],aAtuSaldos[nx,25],aAtuSaldos[nx,42])
				Endif
				If (aAtuSaldos[nx,7] == aAtuSaldos[nX,46] .And. !Empty(aAtuSaldos[nx,20]))
					//Credito
					nTxAntMoed := Round(nVlAntMo01/aAtuSaldos[nx,27],nTamDec)
					GravaCQB(2,"-",dDataLanc,aAtuSaldos[nx,46],nTxAntMoed,aAtuSaldos[nx,27],aAtuSaldos[nx,20],aAtuSaldos[nx,22],aAtuSaldos[nx,24],aAtuSaldos[nx,26],aAtuSaldos[nx,42])
				Endif
			Endif
		Endif
	Else
		If (aAtuSaldos[nx,7] == aAtuSaldos[nX,43] .And. !Empty(aAtuSaldos[nx,8])) .Or.  (aAtuSaldos[nx,7] == aAtuSaldos[nX,45] .And. !Empty(aAtuSaldos[nx,9]))

			If VldAltCQB(nOpc,aAtuSaldos[nx,8],aAtuSaldos[nx,9],aAtuSaldos[nx,10],aAtuSaldos[nx,11],aAtuSaldos[nx,12],aAtuSaldos[nx,13],aAtuSaldos[nx,14],aAtuSaldos[nx,15],aAtuSaldos[nx,41],;
				aAtuSaldos[nx,19],aAtuSaldos[nx,20],aAtuSaldos[nx,21],aAtuSaldos[nx,22],aAtuSaldos[nx,23],aAtuSaldos[nx,24],aAtuSaldos[nx,25],aAtuSaldos[nx,26],aAtuSaldos[nx,42],;
				aAtuSaldos[nx,16],aAtuSaldos[nx,27],;
				aAtuSaldos[nx,43],aAtuSaldos[nx,44],;
				aAtuSaldos[nx,45],aAtuSaldos[nx,46])
				//----------------------------------------------------------------
				// Aumenta o saldo da chave nova
				//----------------------------------------------------------------
				//Debito
				If (aAtuSaldos[nx,7] == aAtuSaldos[nX,43] .And. !Empty(aAtuSaldos[nx,8]))
					nTxMoed := Round(nVlMo01/aAtuSaldos[nx,16],nTamDec)
					GravaCQB(1,"+",dDataLanc,aAtuSaldos[nx,43],nTxMoed,aAtuSaldos[nx,16],aAtuSaldos[nx,8],aAtuSaldos[nx,10],aAtuSaldos[nx,12],aAtuSaldos[nx,14],aAtuSaldos[nx,41])
				Endif
				If (aAtuSaldos[nx,7] == aAtuSaldos[nX,45] .And. !Empty(aAtuSaldos[nx,9]))
					//Credito
					nTxMoed := Round(nVlMo01/aAtuSaldos[nx,16],nTamDec)
					GravaCQB(2,"+",dDataLanc,aAtuSaldos[nx,45],nTxMoed,aAtuSaldos[nx,16],aAtuSaldos[nx,9],aAtuSaldos[nx,11],aAtuSaldos[nx,13],aAtuSaldos[nx,15],aAtuSaldos[nx,41])
				Endif
			Endif
		EndIf
	Endif
Next nX

If IsCtbJob() .And. ( nOpc == 3 .OR. nOpc == 6 .OR. nOpc == 7 ) //Apenas Inclusใo
	For nx := 1 TO Len(aAtuSaldos)
		If ( (!aAtuSaldos[nx,38] .and. aAtuSaldos[nx,39] != 4 ) .or.;          // nao deletado e nao ้ alteracao
			 ( aAtuSaldos[nx,39] = 4 .and. aAtuSaldos[nx,1] == "+"  )) .And.;	//alteracao com sinal '+' pois passa apenas uma vez
             ( aAtuSaldos[nx,6] <> '4' )                                 .And.;	//	Se nao for Complemento de Historico
			 ! ( aAtuSaldos[nx,17]=='9' .And. (aAtuSaldos[nx,29]=='9'.Or. nOpc<>4) .And.;
        	  	SuperGetMv("MV_PRELAN") $ "SD" )									 .And.; 	 //	Se nao for Pre-Lan็amento
             ( !Empty(aAtuSaldos[nx,8]) .Or. !Empty(aAtuSaldos[nx,9]) )		//	Conta D้bito ou Cr้dito preenchida

 			Aadd(aLinhas,{ cFilAux, cLote, cSublote, cDoc, dDatalanc, aAtuSaldos[nx,40],aAtuSaldos[nx,17],cEmpAnt,cFilOri,aAtuSaldos[nx,7] })
 		EndIf
	Next

	// Inicializo o reprocessamento por fila
	// Processamento da fila de saldos
	CTBGrvCQA(aLinhas)

	//se faz atualizacao dos saldos por job retorna
	Return

Else
	If lTRBProc   //se atualizacao dos saldos ocorre por procedure

		If  _lCTB185 .and. _cSrvType != "ISERIES"

			CtbProc185(cLote,cSublote,cDoc,dDatalanc,nOpcProc)
			_lAtSldCT7	:= .F.	// para nao efetuar a grava็ใo de saldos 2 vezes
			_lAtSldCT3	:= .F.	// para nao efetuar a grava็ใo de saldos 2 vezes
			_lAtSldCT4	:= .F.	// para nao efetuar a grava็ใo de saldos 2 vezes
			_lAtSldCTI	:= .F.	// para nao efetuar a grava็ใo de saldos 2 vezes

			// Se fez por procedure entao retorna
			Return
		EndIf
	EndIf
EndIf


//se nao atualizado por procedure ou por job faz pelo processo padrao
While Len(aSldJaOk) < Len(aAtuSaldos)

	If ( Len(aAtuSaldos) - Len(aSldJaOk) ) <= __nQuantas
		lUltCj := .T.		///Determina o ๚ltimo conjunto para entrar em "loop" na CtbCanGrv()
	Else
		lUltCj := .F.
	EndIf

	For nx := 1 to Len(aAtuSaldos)

		If aScan(aSldJaOk, {|x| x == nx }) >  0
			// se o item atual for um dos jแ processados passa para o pr๓ximo
			Loop
		EndIf

		If lIntegraPre	/// Se for integra็ao gravando Pr้-Lan็amento//! cProg $ 'CTBA101,CTBA102' .and. mv_prelan = S
			lPodeGrv	:= .T.	/// Permite gravar sem o semaforo de contas
			_lAtSldCT7	:= .F.	/// e Sem atualiza็ใo de saldos (atualizados pela efetiva็ใo)
			_lAtSldCT3	:= .F.	/// e Sem atualiza็ใo de saldos (atualizados pela efetiva็ใo)
			_lAtSldCT4	:= .F.	/// e Sem atualiza็ใo de saldos (atualizados pela efetiva็ใo)
			_lAtSldCTI	:= .F.	/// e Sem atualiza็ใo de saldos (atualizados pela efetiva็ใo)
			// Nao mudar _lAtSldBase para .F. pois precisa atualizar CTC e CT6 para a efetiva็ใo.
		Else
			lPodeGrv := .F.

			aTravas := {}
			If !Empty(aAtuSaldos[nx,8])
			   AADD(aTravas,aAtuSaldos[nx,8])	/// CONTA ATUAL A DEBITO
			EndIf
			If !Empty(aAtuSaldos[nx,9])
			   AADD(aTravas,aAtuSaldos[nx,9])	/// CONTA ATUAL A CREDITO
			EndIf

			If nOpc == 4		// NO CASO DE ALTERACAO MULTLOCK DAS CONTAS ANTERIORES TAMBEM
				If aAtuSaldos[nx,8] <> aAtuSaldos[nx,19] .and. !Empty(aAtuSaldos[nx,19])
				   AADD(aTravas,aAtuSaldos[nx,19])			/// CONTA ANTERIOR A DEBITO
				EndIf
				If aAtuSaldos[nx,9] <> aAtuSaldos[nx,20]  .and. !Empty(aAtuSaldos[nx,20])
				   AADD(aTravas,aAtuSaldos[nx,20])			/// CONTA ANTERIOR A CREDITO
				EndIf
			EndIf

			If CtbCanGrv(aTravas,@_lAtSldBase,@_lAtSldCT7,@_lAtSldCT3,@_lAtSldCT4,@_lAtSldCTI,.T.,lUltCj)
				lPodeGrv := .T.
			EndIf
	 	EndIf

	   	If lPodeGrv
			/// Adiciona posi็ใo atual aos itens jแ processados
		    aAdd(aSldJaOk,nX)

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Efetua o travamento das contas a serem atualizadas                  ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			cOperacao := aAtuSaldos[nx,1]

			If cOperacao == "-" // Desgrava
				If __lConOutR
					ConOutR("*CTBGRV*|INI CTBDSGRAVA")
				EndIf

				CtbGravSaldo(cLote,cSubLote,cDoc,dDataLanc,aAtuSaldos[nx,6],aAtuSaldos[nx,7],aAtuSaldos[nx,8],aAtuSaldos[nx,9],aAtuSaldos[nx,10],;
								aAtuSaldos[nx,11],aAtuSaldos[nx,12],aAtuSaldos[nx,13],aAtuSaldos[nx,14],aAtuSaldos[nx,15],aAtuSaldos[nx,16],aAtuSaldos[nx,17],aAtuSaldos[nx,18],aAtuSaldos[nx,19],aAtuSaldos[nx,20],;
								aAtuSaldos[nx,21],aAtuSaldos[nx,22],aAtuSaldos[nx,23],aAtuSaldos[nx,24],aAtuSaldos[nx,25],aAtuSaldos[nx,26],aAtuSaldos[nx,27],aAtuSaldos[nx,28],aAtuSaldos[nx,29],aAtuSaldos[nx,30],;
								lCusto			 ,lItem			   ,lClVL			 ,				   ,_lAtSldBase		 ,_lReproc		   	,aAtuSaldos[nx,37],_lGrvCT7		       ,_lGrvCT3		  ,_lGrvCT4		   ,;
								_lGrvCTI			 ,_lAtSldCT7	   ,_lAtSldCT3	 ,_lAtSldCT4	   ,_lAtSldCTI		, lTrbProc			,cOperacao 		  ,aAtuSaldos[nx,41],aAtuSaldos[nx,42], cHistLote,;
								cMoedDoc,cCritDoc,dDatTaxDoc,cTipSldDoc,cLivDia,cNroDia)
				If __lConOutR
					ConOutR("*CTBGRV*|END CTBDSGRAVA")
				EndIf
			ElseIf cOperacao == "+" //Grava
				If __lConOutR
					ConOutR("*CTBGRV*|INI CTBGRAVSALDO")
				EndIf

				CtbGravSaldo(cLote,cSubLote,cDoc,dDataLanc,aAtuSaldos[nx,6],aAtuSaldos[nx,7],aAtuSaldos[nx,8],aAtuSaldos[nx,9],aAtuSaldos[nx,10],;
								aAtuSaldos[nx,11],aAtuSaldos[nx,12],aAtuSaldos[nx,13],aAtuSaldos[nx,14],aAtuSaldos[nx,15],aAtuSaldos[nx,16],aAtuSaldos[nx,17],aAtuSaldos[nx,18],aAtuSaldos[nx,19],aAtuSaldos[nx,20],;
								aAtuSaldos[nx,21],aAtuSaldos[nx,22],aAtuSaldos[nx,23],aAtuSaldos[nx,24],aAtuSaldos[nx,25],aAtuSaldos[nx,26],aAtuSaldos[nx,27],aAtuSaldos[nx,28],aAtuSaldos[nx,29],aAtuSaldos[nx,30],;
								lCusto			 ,lItem			   ,lClVL			 ,				   ,_lAtSldBase		 ,_lReproc		   	,aAtuSaldos[nx,37],_lGrvCT7		       ,_lGrvCT3		  ,_lGrvCT4		   ,;
								_lGrvCTI			 ,_lAtSldCT7	   ,_lAtSldCT3	 ,_lAtSldCT4	   ,_lAtSldCTI		, lTrbProc			,cOperacao	 	   ,aAtuSaldos[nx,41],aAtuSaldos[nx,42], cHistLote,;
								cMoedDoc,cCritDoc,dDatTaxDoc,cTipSldDoc,cLivDia,cNroDia)
				If __lConOutR
					ConOutR("*CTBGRV*|END CTBGRAVSALDO")
				EndIf
			EndIf

			MsUnLockAll()
			Ct1MUnLock()
			dbCommitAll()
		EndIf
	Next
EndDo

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbPcoLancบAutor  ณMicrosiga           บ Data ณ  10/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณIntegracao da Contabilidade com Modulo SIGAPCO              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CtbPcoLanc(aRecTmp)
Local aRecCT2 := {}
Local lPcoLanc
Local nx, ny
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Integracao com o modulo SIGAPCO - geracao dos lcto.          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If SuperGetMV("MV_PCOINTE",.T.,"2")=="1"
	// Fazer tratamento para o modulo PCO
	// Estrutura do Array aRecTmp
	// para cada recno do tmp ha um array com a estrutura a seguir
	// 1-Recno do TMP
	// 2-Recno do CT2
	// 3-Operacao (3-Inclusao 4-Alteracao 5-Exclusao)
	// 4-Conteudo do Recno CT2

	PcoIniLan("000082")

	For nx := 1 TO Len(aRecTmp)

	    //garantir que as exclusoes sejam processadas primeiro
	    // depois alteracoes e por fim inclusao
	    aRecCT2 := aClone(aRecTmp[nx])
	    ASORT(aRecCT2,,, { |x, y| y[2] < x[2] })

		If Len(aRecCT2) > 0
			For ny := 1 TO Len(aRecCT2)

			   dbSelectArea("CT2")
			   CT2->(dbGoto(aRecCT2[ny,2]))

				lPcoLanc := .T.

				If CT2->(! Deleted())

					If _lCTBPCO
						//Ponto de entrada para verIficar se entra na pcodetlan()
						lPcoLanc  := ExecBlock("CTBPCO",.f.,.f.,{ "000082","01","CTBA105" } )
					EndIf

			    EndIf

				If lPcolanc
        	    	lPcoLanc := ( CT2->CT2_DC != "4" ) //"4" eh continuacao do historico
            	EndIf

			   BEGIN TRANSACTION //Transacao linha a linha

				If lPcolanc
					PcoDetLan("000082","01","CTBA105",CT2->(Deleted()))
				EndIf

	     	   END TRANSACTION

			Next

		EndIf

	Next

	PcoFinLan("000082")

EndIf

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณProgram   ณAuxCTBGrava ณ Autor ณ Pilar S. Albaladejo ณ Data ณ 24.07.00 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Fun็ใo de grava็ใo disparado do CTBGRAVA                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function AuxCtbGrava(nOpc,dDatalanc,cLote,cSubLote,cDoc,lAglut,cSequenc,lCusto,lItem,lCLVL, ;
							nTotInf,cProg,cPreLcto,dReproc,cEmpOri,cFilOri,aFlagCTB,aCTKxCT2,;
							aTpSaldo,cModoClr,aSeqDiario,lMltSld,cSeqCorr,lSimula,cTabCTK,cTabCT2,;
							cHistLote,cMoedDoc,cCritDoc,dDatTaxDoc,cTipSldDoc,cLivDia,cNroDia,lFirstP,lContb,lCtba190,cCT2_KEY)
//Local nCont
Local cSeqLan		:= StrZero( 0, Len(CT2->CT2_SEQLAN) ) // "000"
Local nSeqHis		:= 1
Local nValor		:= 0
Local nValorAnt 	:= 0
Local nOpcAlt		:= nOpc
Local nContMoeda	:= 0

Local nMoedas		:= __nQuantas
Local cSeqLan01		:= ""													//// _SEQLAN (Sequencia de Lanc) do registro deletado
Local cSeqHis01		:= ""													//// _SEQHIS (Sequencia de Hist) do registro deletado
Local cTpLan01		:= ""													//// _DC (Tipo do Lancamento) do registro deletado
Local cMoedaDel		:= Replicate("2",nMoedas)								//// PARA CONTROLAR SE TODAS AS MOEDAS FORAM DELETADOS
//Local cAliasAnt		:= ""
Local nRecnoAnt		:= 0
Local nRecnoTMP		:= 0
Local nOrderAnt		:= 0
//Local nOrderTMP		:= 0
Local lInclui		:= .T.
Local lOutrMoeda
Local aAtuSaldos	:= {}
//Local aTravas		:= {}
Local lFirstSq 		:= .T.
Local lAltTpSld		:= .F.
//Local lPodeGrv		:= .F.			/// INDICA SE PODE PROCEDER COM A GRAVAวรO / NรO (TRATAMENTO NA MULTLOCK)
Local cTpSldAnt		:= ""
Local CTF_LOCK		:= CTF->(Recno())
Local lTRBProc		:= .T.
Local aRecTmp       := {}
Local nPosATMP		:= 0
Local lPodeExc		:= .T.

Local lAgruSld		:= __lAgruSld
Local lAtuProc		:= .F.

Local cSeqDiario	:= "" // sequencial utilizado em portugal
Local lSeqCorr		:= .F.
Local lContinua		:= .T.
//Local lMudaTRT      := SuperGetMV("MV_MUDATRT",.F.,.T.)
//Local cDropTRW      := ""
//Local cTableTRW     := If(lMudaTRT, "TRW"+SM0->M0_CODIGO+"0"+"_SP", "TRW"+SM0->M0_CODIGO+"0")
Local cHoraLc		:= Time()

Local dDtSeq			:= ctod("  /  /  ")
Local nRecCT2		:= 0
Local lCTBManual	:= .F.
Local nPosRecTMP	:= 0
Local lUseProc   	:= If( FindFunction( "CtbProcedBD()" ), CtbProcedBD(), .F.)
Local lRedStorn  	:= cPaisLoc == "RUS" .And. SuperGetMV("MV_REDSTOR",.F.,.F.) // CAZARINI - 20/06/2017 - Parameter to activate Red Storn
Local aFlgSimple    as array
//Local nX            as integer

Default lSimula		:= .F.
Default cTabCTK		:= "CTK"
Default cTabCT2		:= "CT2"

Default cHistLote	:= ""
Default cMoedDoc	:= ""
Default cCritDoc	:= ""
Default dDatTaxDoc	:= STOD("")
Default cTipSldDoc	:= ""
Default cLivDia		:= ""
Default cNroDia		:= ""
Default lFirstP := .T. 
Default lContb :=  IIf(SuperGetMv("MV_ATUSAL")=="S",.T.,.F.)
Default cCT2_KEY := ""

If lFirstP .and. __lExibeProc
	ProcRegua(0)
EndIf
If Type("lCt102Auto") == "U"
	lCt102Auto	:= .F.
EndIf

If Type("__aCT2LC")	<> "A"
	__aCT2LC := {}
EndIf

//Verifica se a contabilizacao TXT sera considerada manual ou sistema (CT2_MANUAL)
If AllTrim(cProg) == "CTBA500"
	lCTBManual := GetAdvFVal("SX1","X1_PRESEL",PadR("CTB500",Len(SX1->X1_GRUPO))+"08",1,1,.T.) == 1
EndIf

lSeqCorr			:= UsaSeqCor()
If nOpcAlt == 3 .or. nOpcAlt == 7 .or. nOpcAlt ==6
	CtbNumLote(nOpc,dDataLanc,@cLote,cSubLote,@cDoc,@CTF_LOCK,lSimula,cTabCTK,cTabCT2) //numero lote/sublote/documento
EndIf
lTrbProc := CtbProc153(nOpc, dDatalanc, cLote, cSubLote, cDoc)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Determina o uso da funcao de aglutinacao dos saldos no doc atual    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
lAgruSld := CtbAgluSld(lAgruSld,cProg)

BEGIN TRANSACTION   //inicio da transacao para efetuar a gravacao dos lancamentos na tabela CT2

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Efetua a gravacao dos lancamentos no CT2                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea( "TMP" )
TMP->( DbGoTop() )
if lFirstP .and. __lExibeProc
	ProcRegua(TMP->(LastRec())-1+Len(aFlagCTB))
EndIf

If __lConOutR
	ConOutR("*CTBGRV*|INI LEITURA TMP")
EndIf
If !lCt102Auto
	CtbExcLTmp()   // For็a a exclusใo das linhas deletadas no temporario no CT2
				// Quando utiliza-se a rotina automatica, o mesmo exclui os registros com recno e recria sem os mesmo
EndIf
// Efetua a grava็ใo dos lan็amentos
If  nOpc == 3 .And. lUseProc .And. FindFunction("CTBby_Proc") .and. !funName() == "PROJETOGESPLAN"  
	CTBby_Proc(nOpc, lInclui, dDataLanc, cLote, cSubLote, cDoc, cFilOri, cEmpOri, cSequenc, ;
									lAglut, nContMoeda, "01", aHeader, lAltTpSld, cProg, cSeqLan, cSeqLan01, ;
									nSeqHis, cSeqHis01, @lFirstSq, lSeqCorr, @cSeqCorr, lCusto,lItem,lCLVL, ;
									nTotInf, lSimula, cTabCTK, cTabCT2,_lCTB185,__nQuantas, aTpSaldo, __lAgruSld,lTrbProc,;
									cModoClr, cPreLcto, dReproc, cHoraLc, @aAtuSaldos )

Else
	TMP->( dbGotop() )
	While ! TMP->( Eof() )

		lPodeExc 	:= .T.
		lContinua 	:= .T.

		If nOpc == 3
			If __lExibeProc 
				IncProc( STR0049 + cLote + " " + cSubLote + " " + cDoc + " " + TMP->CT2_SEQLAN)
			EndIf
		ElseIf nOpc == 5
			if lFirstP .and. __lExibeProc
				IncProc( STR0050 + cLote + " " + cSubLote + " " + cDoc + " " + TMP->CT2_SEQLAN)
			Endif	
		EndIf


		//Se a linha estiver deletada e nao foi incluido nada avanca registro do tmp
		If (TMP->CT2_RECNO == 0 .And. TMP->CT2_FLAG)  .Or. ;
			( nOpc ==4 .And. Alltrim(cProg) $ "CTBA102#CTBA103" .And. FieldPos('MODIfIED')>0 .And. TMP->MODIfIED==0 .And. TMP->CT2_RECNO > 0 .And. !TMP->CT2_FLAG .And. !lCt102Auto)
			/* Exclui as linas nใo alteradas do TRW na altera็ao com procedure ctb150*/
			Ctb_TRW_(nOpC, _lCTB153, _lCTB150, xFilial("CT2"),Dtos(dDataLanc), cLote, cSubLote, cDoc, cFilOri, cEmpOri, TMP->CT2_LINHA)
			TMP->( DbDelete() )							/// apaga a linha do temporario e do trw do banco
			dbSelectArea("TMP")
			TMP->( dbSkip() )
			Loop
		EndIf

		aAdd(aRecTmp, aClone({}))

		LanceiCtb	:= .F.							// Inicializado com Falso
		If cPreLcto # Nil .And. cPreLcto # "N"
			TMP->CT2_TPSALD := "9"
		EndIf

		//Posiciona na tabela CT2 se fora alteracao e exclusao e carrega variavel nOpcAlt
		nOpcAlt := CtbPosiCT2(nOpc,lSimula,cTabCTK,cTabCT2)

		If !(cProg $ 'CTBA101,CTBA102,CTBA103') .And. __Ct105CT2 .And. __Ct105Sld .And. !lSimula
		 	If ! ExecBlock("CT105SLD")
				nMoedas := 0
				lAltSldBase := .F.
			EndIf
		EndIf

		nRecnoTMP	:= TMP->(Recno())

		// VerIficacao para identIficar se grava na moeda 01 com Valor 0.00
		lOutrMoeda   := CtbVOtMoed(nMoedas)

		//Se for alteracao, verIficar se o tipo de saldo da linha de lancamento foi alterado.
		If nOpc == 4 .And. TMP->CT2_TPSALD <> CT2->CT2_TPSALD
			lAltTpSld	:= .T.
			cTpSldAnt	:= CT2->CT2_TPSALD
		Else
			cTpSldAnt	:= TMP->CT2_TPSALD
		EndIf

		///////////////////////////////////
		/// ZERA VARIAVEIS DA DELECAO DC=4
		///////////////////////////////////
		cSeqLan01		:= TMP->CT2_SEQLAN										//// _SEQLAN (Sequencia de Lanc) do registro deletado
		cSeqHis01		:= TMP->CT2_SEQHIS										//// _SEQHIS (Sequencia de Hist) do registro deletado
		cTpLan01		:= TMP->CT2_DC											//// _DC (Tipo do Lancamento) do registro deletado
		cMoedaDel		:= Replicate("2",nMoedas)								//// PARA CONTROLAR SE TODAS AS MOEDAS FORAM DELETADOS

		If lCTKRECDES
			nPosRecTMP	:= TMP->(Recno())                        				// Variavel garante performance no Ascan
			nPosATMP 	:= Ascan(aCTKxCT2,{|x| x[1] == nPosRecTMP })
		EndIf

		//Laco para gravacao do lancamento na tabela CT2 em todas as moedas
		For nContMoeda := 1 To nMoedas

			cMoeda 	:= StrZero(nContMoeda,2)
			nValor := CtbGetValor(cMoeda, @cEmpOri, @cFilOri)
			If cMoeda = '01'
				nValorAnt:= CT2->CT2_VALOR
			Else
				//Se for historico complementar, so gravar na moeda 01
				If TMP->CT2_DC == '4' 			//// SE O REGISTRO NO TMP FOR CONTINUACAO DE HISTORICO
					dbSelectArea( "TMP" )
					TMP->(dbSkip())
					Exit						//// SAI DO FOR DE MOEDAS POIS NAO HA VALOR PARA GRAVAR
				EndIf
				// LOCALIZA O REGISTRO DO VALOR NA MOEDA CORRESPONDENTE (02,03,04,ETC)
				nValorAnt := CtbGetVlAnt(dDataLanc,cLote,cSubLote,cDoc,If(lAltTpSld, cTpSldAnt, TMP->CT2_TPSALD)/*cTpSldAnt*/,cEmpOri,cFilOri,cMoeda,lSimula,cTabCTK,cTabCT2)
			EndIf

	        //armazena no array aAtuSaldos para posterior a gravacao do CT2 proceder atualizacao de saldos
			If	lContb .and. 	!lCtba190
					lContinua := CtbArmSald(nOpc, nOpcAlt, aAtuSaldos, nContMoeda, cMoeda, lPodeExc, aTpSaldo, lAgruSld, ;
							lTrbProc, @lAtuProc, cModoClr, dReproc, nValor, nValorAnt, lSimula, cTabCTK, cTabCT2)
			EndIF
			If ! lContinua
				Exit //forca saida do for......next nContMoeda
			EndIf

			//Se for alteracao, e estiver zerando o valor nas outras moedas, deleta o registro do lancamento existente.
			If ( nOpc	== 4 .and. nValor = 0 .And. nValorAnt	<> 0 .and. !TMP->CT2_FLAG ) .OR. ( lCt102Auto .And. nValor = 0 .And. nValorAnt	<> 0 )
				CtbDelSqLc( If(lAltTpSld, cTpSldAnt, TMP->CT2_TPSALD),@cMoedaDel,nContMoeda,aRecTmp,dDatalanc,cLote,cSubLote,cDoc,TMP->CT2_LINHA,@cSeqLan01,@cEmpOri,@cFilOri,@cSeqHis01,@cTpLan01)
			EndIf

			// Se nao for moeda 01 grava somente se for lancamento (123) ou
			// Se for Moeda 01 com valor zerado e tiver valores em outras moedas
			// e se for inclusao ou alteracao (e a linha nao estiver deletada).
			If TMP->CT2_DC <> '4' .And. ((nValor < 0 .and. !lRedStorn) .or. nValor = 0) ;
				.And. ( (nOpc == 4 .And. !TMP->CT2_FLAG) .Or. nOpc = 3 .Or. nOpc == 6 .Or. nOpc == 7 ) ;
				.And. ( cMoeda <> "01" .Or. (cMoeda = "01" .And. ! lOutrMoeda))
				Loop
			EndIf

			If ! TMP->CT2_FLAG								/// SE NAO ESTIVER DELETADO
				If nOpc <> 5								// Inclusao / Alteracao (dIferente de exclusao)

					lInclui := ! CtbPesqCT2(dDataLanc,cLote,cSubLote,cDoc,TMP->CT2_LINHA,If(lAltTpSld, cTpSldAnt, TMP->CT2_TPSALD)/*cTpSld*/,TMP->CT2_EMPORI,TMP->CT2_FILORI,cMoeda,lSimula,cTabCTK,cTabCT2)

					If TMP->CT2_DC=="3" .And. TMP->CT2_SEQUEN==cSequenc .And. !Empty(TMP->CT2_DTCV3)
						dDtSeq:= TMP->CT2_DTCV3
					EndIf
					nRecCT2 := CtbGrvCT2(nOpc, lInclui, dDataLanc, cLote, cSubLote, cDoc, cFilOri, cEmpOri, cSequenc, ;
								lAglut, nContMoeda, cMoeda, aHeader, lAltTpSld, cProg, cSeqLan, cSeqLan01, ;
								nSeqHis, cSeqHis01, @lFirstSq, lSeqCorr, @cSeqCorr, lCusto,lItem,lCLVL, 	;
								nTotInf, lSimula, cTabCTK, cTabCT2,lCTBManual,@dDtSeq,cCT2_KEY)

					If !Empty(nRecCT2)
						CtbGrvCV3(lInclui,aRecTmp,aCTKxCT2,nPosATMP,cMoeda,@cSeqLan01,@cSeqHis01,lSimula,cTabCTK,cTabCT2)
					Else
						UserException("ERRO NA GERAวรO DA CT2 -> Nใo foi possivel efetuar a gera็ใo" )
					Endif

				ElseIf TMP->CT2_RECNO > 0 			// Se for Exclusao de lancamento e o registro existe no CT2
					/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
					//// BLOCO PARA TRATAMENTO DA OPERAวรO EXLUIR (DOCUMENTO) TMP->CT2_FLAG ษ MANTIDO COMO REGISTRO VALIDO NO TMP (.F.)
					/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
					If nOpc == 5			// Exclusao de lancamento
						If CtbPesqCT2(dDataLanc,cLote,cSubLote,cDoc,TMP->CT2_LINHA,TMP->CT2_TPSALD/*cTpSld*/,TMP->CT2_EMPORI,TMP->CT2_FILORI,cMoeda)
							lPodeExc := CanDelCt2(nOpc,,cModoClr)
							If lPodeExc
								/* Exclui os lancamentos complementares */
								If CTBLCUso()
									CTBLCDelLC(CT2->(Recno()),.T.)
								EndIf
								CtbExclCT2(aRecTmp)
							Else
								nContMoeda := nMoedas+1
								Exit
							EndIf
						EndIf
					EndIf
					If cMoeda = '01'
						CtbDsTrvCTF(dDataLanc,cLote,cSubLote,cDoc,@CTF_LOCK)
					EndIf
				EndIf

				dbSelectArea( "TMP" )

				/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
				//// BLOCO PARA TRATAMENTO DOS REGISTROS DELETADOS NO TMP->CT2_FLAG == .T.
				/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			ElseIf TMP->CT2_RECNO > 0			//// SE A LINHA ESTIVER MARCADA COMO DELETADA E O REGISTRO JA EXISTIA NO CT2

				dbSelectArea("CT2")
				CT2->(dbSetOrder(1))
				nOrderAnt	:= CT2->(IndexOrd())
				nRecnoAnt	:= CT2->(Recno())

				If CtbPesqCT2(dDataLanc,cLote,cSubLote,cDoc,TMP->CT2_LINHA,TMP->CT2_TPSALD/*cTpSld*/,TMP->CT2_EMPORI,TMP->CT2_FILORI,cMoeda)
					lPodeExc := CanDelCt2(nOpc,,cModoClr)
					If lPodeExc
						cSeqLan01	:= CT2->CT2_SEQLAN
						cSeqHis01	:= CT2->CT2_SEQHIS
						cTpLan01	:= CT2->CT2_DC

						/* Exclui os lancamentos complementares */
						If CTBLCUso()
							CTBLCDelLC(CT2->(Recno()),.T.)
						EndIf

						// DELETA A LINHA INDICADA NO TMP
						CtbExclCT2(aRecTmp)
					Else
						nContMoeda := nMoedas+1
						Exit
					EndIf
				Else
					CT2->(dbSetOrder(nOrderAnt))
					CT2->(MsGoto(nRecnoAnt))
				EndIf

				cMoedaDel	:= Left(cMoedaDel,nContMoeda-1)+"1"+Right(cMoedaDel,ABS(Len(cMoedaDel)-(nContMoeda)))

				If cTpLan01 <> "4" .and. cMoeda = StrZero(nMoedas,2) .And. At("2",cMoedaDel) <= 0 //Se esta for a a ultima moeda. //// SO DELETA AS CONTINUACOES SE ERA REGISTRO DE LANCAMENTO (123)
					CtbDElseqL(aRecTmp,dDatalanc,cLote,cSubLote,cDoc,cSeqLan01,cEmpOri,cFilOri, cSeqHis01)
				EndIf

			EndIf

			LanceiCtb := .T. 				// Flag indicativo de que contabilizou
			nOpcAlt	:= nOpc
		Next	//nContMoeda

		dbSelectArea("TMP")
		TMP->(MsGoto(nRecnoTMP))
		TMP->(dbSkip())

		lAltTpSld	:= .F.

		If !( lChkCtbGrv .And. Execblock("CHKCTBGRV" , .F., .F. , {lAntCtbGrv} ) )  //Se controlado pelo Ponto de Entrada, nao entra nesse trecho
			
			//Funcionamento padrao do produto
			//Alimenta as variaveis cEmpori e cFilori com a empresa/filial corrente. Se o proximo lancamento
			//for historico complementar, devera manter o empori/filori da empresa/filial origem.
			If TMP->CT2_DC <> '4' 
				cEmpOri	:= cEmpAnt
				cFilOri	:= cFilAnt
			EndIf
		
		EndIf
	Enddo

Endif
If __lConOutR
	ConOutR("*CTBGRV*|INI FLAGS _LA")
EndIf
/*  comentar para validar release 12.1.031*/
If lNewSemaforo
	aFlgSimple := {}
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Efetua a atualiza็ใo dos flags de contabiliza็ใo + Correlativo      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	NewCtbEftCorr(aFlagCTB,aCTKxCT2,lSeqCorr,cSeqCorr,aSeqDiario,@cSeqDiario,aRecTmp, @aFlgSimple)
Else
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Efetua a atualiza็ใo dos flags de contabiliza็ใo + Correlativo      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	CtbEftCorr(aFlagCTB,aCTKxCT2,lSeqCorr,cSeqCorr,aSeqDiario,@cSeqDiario,aRecTmp)
EndIf
If __lConOutR
	ConOutR("*CTBGRV*|END FLAGS _LA")
EndIf
END TRANSACTION
/* comentar para validar */
If lNewSemaforo
	/*  ---------------------------------------------------------------------------
		Tirar o simpleLock dos registros da Origem feito pela Fun็ใo 105LockFlg
		no inํcio do CTB_Incl 
		O MsRUnlock() - NยO pode ser executado dentro de BEGIN TRANSACTION
		--------------------------------------------------------------------------- */
	If !(Intransact()) .and. FindFunction("_105UnLckFlg") .and. Len(aFlgSimple) > 0
		_105UnLckFlg(@aFlgSimple)
	EndIf
	aSize(aFlgSimple,0)
	aFlgSimple := NIL
EndIf
// deve estar fora da transa็ใo principal do ctb
CtbShwMsgSq(cSeqDiario) // exibe a mensagem para o usuario do numero da sequencia gerada

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Efetua a atualiza็ใo dos flags de contabiliza็ใo                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
if lFirstP .and. __lExibeProc
	ProcRegua(Len(aAtuSaldos))
EndIf
If __lConOutR
	ConOutR("*CTBGRV*|INI ARRAY SLD")
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Efetua a atualiza็ใo dos saldos fora da transacao dos lancamentos   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !lSimula .and. lContb 
	If !lCtba190
		CtbPrSaldo(nOpc,cProg,aAtuSaldos,cLote,cSubLote,cDoc,dDataLanc,lCusto,lItem,lClVL,lTrbProc,cHistLote,cMoedDoc,cCritDoc,dDatTaxDoc,cTipSldDoc,cLivDia,cNroDia,cFilOri)
	EndIf
EndIf 

If __lConOutR
	ConOutR("*CTBGRV*|END ARRAY SLD")
EndIf

FreeUsedCode()  //libera codigos de correla7tivos reservados pela MayIUseCode()

// Gravo o valor informado no final pois eh em relacao ao documento
If nTotInf <> Nil .And. nTotInf > 0
	CtbGrvlInf(dDataLanc,cLote,cSubLote,cDoc,"01",nTotInf,nOpc)
EndIf

//Gravo o Historico da Capa do Lote - Altera็ใo
If cPaisLoc == "ARG" .And. X3USADO("CTC_DOCHIS") .And. !Empty(cHistLote) .And. nOpc == 4
	CtbGrvHCP(dDataLanc,cLote,cSubLote,cDoc,"01",cHistLote)
EndIf

If nOpc == 5 .OR. nOpc == 4
	CtbExclCTC(dDataLanc,cLote,cSubLote,cDoc)
EndIf

dbSelectArea("TMP")
If lSimula .and. !(Type("cFunname") <> "U" .and. cFunname == "FINA840")
	dbSelectArea("SIX")
	dbSetOrder(1)
	dbGoTop()
	If SIX->(dbSeek("CT21"))
		cChaveCT2 := AllTrim(SIX->CHAVE)
		IndRegua("CT2", cTabCT2, cChaveCT2, , , )
	EndIf
	dbSelectArea("CT2")	
Else
	dbSelectArea("CT2")
	CT2->(dbSetOrder(1))
EndIf

If !lSimula
	CtbPcoLanc(aRecTmp)
EndIf

__cCleanLA := Nil
__cRetClean	:= "1"

Return

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno	 ณCtbGravSaldoณ Autor ณ Pilar S. Albaladejo 			ณ Data ณ 27/11/00 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณGravacao de Saldos                                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe	 ณCtbGravSaldo(cLote,cSubLote,cDoc,dData,cTipo,cMoeda,cDebito,cCredito,   ณฑฑ
ฑฑณ       	 ณcCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlDeb,cClVlCrd,nValor,cTpSald, ณฑฑ
ฑฑณ       	 ณnOpc,cDebitoAnt,cCreditoAnt,cCustoDAnt,cCustoCAnt,cItemDAnt,cItemCAnt,  ณฑฑ
ฑฑณ       	 ณcCLVLDAnt,cCLVLCant,nValorAnt,cTipoant,cTpSaldAnt,cMoedaAnt,lCusto,	  ณฑฑ
ฑฑณ       	 ณlItem,lClVl,nTotInf)                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno	 ณNenhum                                                      			  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		 ณ Generico 												 			  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC1 = Lote                             				 			  ณฑฑ
ฑฑณ			 ณ ExpC2 = SubLote     													  ณฑฑ
ฑฑณ			 ณ ExpC3 = Documento   													  ณฑฑ
ฑฑณ			 ณ ExpD1 = Data        													  ณฑฑ
ฑฑณ			 ณ ExpC4 = Tipo do lancamento											  ณฑฑ
ฑฑณ			 ณ ExpC5 = Moeda              											  ณฑฑ
ฑฑณ			 ณ ExpC6 = Conta debito        											  ณฑฑ
ฑฑณ			 ณ ExpC7 = Conta credito       											  ณฑฑ
ฑฑณ			 ณ ExpC8 = Centro de custo debito										  ณฑฑ
ฑฑณ			 ณ ExpC9 = Centro de custo credito										  ณฑฑ
ฑฑณ			 ณ ExpC10= Item Debito             										  ณฑฑ
ฑฑณ			 ณ ExpC11= Item Credito            										  ณฑฑ
ฑฑณ			 ณ ExpC12= Classe de Valor Debito  										  ณฑฑ
ฑฑณ			 ณ ExpC13= Classe de Valor Credito 										  ณฑฑ
ฑฑณ			 ณ ExpN1 = Valor														  ณฑฑ
ฑฑณ			 ณ ExpC14= Tipo de Saldo           										  ณฑฑ
ฑฑณ			 ณ ExpN2 = Numero da Opcao escolhida					   				  ณฑฑ
ฑฑณ			 ณ ExpC15= Conta debito anterior										  ณฑฑ
ฑฑณ			 ณ ExpC16= Conta credito anterior										  ณฑฑ
ฑฑณ			 ณ ExpC17= Centro de custo debito anterior								  ณฑฑ
ฑฑณ			 ณ ExpC18= Centro de custo credito	anterior							  ณฑฑ
ฑฑณ			 ณ ExpC19= Item Debito anterior    										  ณฑฑ
ฑฑณ			 ณ ExpC20= Item Credito anterior   										  ณฑฑ
ฑฑณ			 ณ ExpC21= Classe de Valor Debito anterior								  ณฑฑ
ฑฑณ			 ณ ExpC22= Classe de Valor Credito anterior								  ณฑฑ
ฑฑณ			 ณ ExpN3 = Valor anterior												  ณฑฑ
ฑฑณ			 ณ ExpC22= Tipo de lancamento anterior									  ณฑฑ
ฑฑณ			 ณ ExpC23= Tipo de Saldo anterior  										  ณฑฑ
ฑฑณ			 ณ ExpC24= Moeda Anterior          										  ณฑฑ
ฑฑณ			 ณ ExpL1 = Indica se atualiza centro de custo							  ณฑฑ
ฑฑณ			 ณ ExpL2 = Indica se atualiza item               						  ณฑฑ
ฑฑณ			 ณ ExpL3 = Indica se atualiza classe de valor							  ณฑฑ
ฑฑณ			 ณ ExpN4 = Valor Total informado              							  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function CtbGravSaldo(cLote,cSubLote,cDoc,dData,cTipo,cMoeda,cDebito,;
					  cCredito,cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,;
					  cClVlDeb,cClVlCrd,nValor,cTpSald,nOpc,cDebitoAnt,;
					  cCreditoAnt,cCustoDAnt,cCustoCAnt,cItemDAnt,;
					  cItemCAnt,cCLVLDAnt,cCLVLCAnt,nValorAnt,;
					  cTipoAnt,cTpSaldAnt,cMoedaAnt,lCusto,lItem,lClVL,nTotInf,;
					  lAtSldBase,lReproc,dDataLP,lGrvCT7,lGrvCT3,lGrvCT4,lGrvCTI,;
					  lAtuSldCT7,lAtuSldCT3,lAtuSldCT4,lAtuSldCTI, lTrbProc, cOperacao,aEntid,aEntidAnt,;
					  cHistLote,cMoedDoc,cCritDoc,dDatTaxDoc,cTipSldDoc,cLivDia,cNroDia)

Local lAltDeb		:= .F.
Local lAltCrd		:= .F.
Local lAltValor 	:= .F.
Local lAltTpSald	:= .F.
Local lAltMoeda		:= .F.
Local lAltDC		:= .F.
Local lPartDob 		:= .F.
Local lMudouSld 	:= .F.
Local lCtDeb 		:= .F.
Local lCCDeb 		:= .F.
Local lITDeb 		:= .F.
Local lCLDeb 		:= .F.
Local lE5Deb		:= .F.

Local lCtCrd 		:= .F.
Local lCCCrd 		:= .F.
Local lITCrd 		:= .F.
Local lCLCrd 		:= .F.
Local lE5Crd		:= .F.
Local aEnt05		:= {}

lReproc 			:= IIf(lReproc==Nil,.F.,lReproc)
lAtSldBase 			:= IIf(lAtSldBase==Nil,(If(SuperGetMv("MV_ATUSAL")=="S",.T.,.F.)),lAtSldBase)
dDataLP				:= IIf(dDataLP==Nil,CTOD("  /  /  "),dDataLP)

DEFAULT lGrvCT7		:= .F.
DEFAULT lGrvCT3		:= .F.
DEFAULT lGrvCT4		:= .F.
DEFAULT lGrvCTI		:= .F.
DEFAULT lAtuSldCT7	:= .T.
DEFAULT lAtuSLdCT3	:= .T.
DEFAULT lAtuSldCT4	:= .T.
DEFAULT lAtuSldCTI	:= .T.
DEFAULT cOperacao	:= "+"
DEFAULT lTrbProc	:= .F.
DEFAULT aEntid		:= {}
DEFAULT aEntidAnt	:= {}

DEFAULT cHistLote	:= ""
DEFAULT cMoedDoc	:= ""
DEFAULT cCritDoc	:= ""
DEFAULT dDatTaxDoc	:= STOD("")
DEFAULT cTipSldDoc	:= ""
DEFAULT cLivDia		:= ""
DEFAULT cNroDia		:= ""


// SE FOR CONTINUACAO DE HISTORICO NAO ATUALIZA OS SALDOS
If ( cOperacao == "+" .And. cTipo == "4" ) .OR. ;
		( cOperacao == "-" .And. cTipoAnt == "4" )
	Return
EndIf

// VerIfica o que ira Recalcular/Descalcular - comparando variaveis que irใo afetar a grava็ใo do
// saldo -> Tipo Lcto, Valor, Tipo do Saldo, Moeda do Lcto. Se nใo houve altera็ใo
// NรO PODERม REGRAVAR!!!!!
If cOperacao == "+"
	lCtDeb := !Empty(cDebito)
	lCCDeb := !Empty(cCustoDeb)
	lITDeb := !Empty(cItemDeb)
	lCLDeb := !Empty(cCLVLDeb)

	lCtCrd := !Empty(cCredito)
	lCCCrd := !Empty(cCustoCrd)
	lITCrd := !Empty(cItemCrd)
	lCLCrd := !Empty(cCLVLCrd)

	If lEntidad05 .And. !Empty(aEntid) .And. Len(aEntid) > 0
		aEnt05 := aClone(aEntid[1])
		lE5Deb := !Empty(aEnt05[1])
		lE5Crd := !Empty(aEnt05[2])
	EndIf

	If cTipo == "3"
		lPartDob := .T.
	EndIf

ElseIf cOperacao == "-"
	lCtDeb := !Empty(cDebitoAnt)
	lCCDeb := !Empty(cCustoDAnt)
	lITDeb := !Empty(cItemDAnt)
	lCLDeb := !Empty(cCLVLDAnt)

	lCtCrd := !Empty(cCreditoAnt)
	lCCCrd := !Empty(cCustoCAnt)
	lITCrd := !Empty(cItemCAnt)
	lCLCrd := !Empty(cCLVLCAnt)

	If lEntidad05 .And. !Empty(aEntidAnt) .And. Len(aEntidAnt) > 0
		aEnt05 := aClone(aEntidAnt[1])
		lE5Deb := !Empty(aEnt05[1])
		lE5Crd := !Empty(aEnt05[2])
	EndIf

	If cTipoAnt == "3"
		lPartDob	:= .T.
	EndIf

EndIf

If nOpc == 5			/// SE FOR EXCLUSAO SEMPRE VAI ATUALIZAR OS SALDOS (APAGAR)

	If cTipoAnt $ "1/3"
		lAltDeb := .T.
	EndIf
	If cTipoAnt $ "2/3"
		lAltCrd := .T.
	EndIf

ElseIf nOpc == 3 .Or. nOpc == 6 .Or. nOpc == 7		/// SE FOR INCLUSAO OU COPIA SEMPRE VAI ATUALIZAR OS SALDOS (ADICIONAR)

	If cTipo $ "1/3"
		lAltDeb := .T.
	EndIf
	If cTipo $ "2/3"
		lAltCrd := .T.
	EndIf

ElseIf nOpc == 4						/// SE FOR ALTERACAO VERIfICA AS CONDICOES PARA ATUALIZAR (ADICIONAR)

	lAltValor 	:= nValor <> nValorAnt
	lAltTpSald	:= cTpSald <> cTpSaldAnt
	lAltMoeda	:= cMoeda <> cMoedaAnt
	lAltDC		:= cTipo <> cTipoAnt

	If lAltValor .or. lAltTpSald .or. lAltMoeda .or. lAltDC

		If cOperacao == "+"

			If cTipo $ "1/3"
				lAltDeb := .T.
			EndIf
			If cTipo $ "2/3"
				lAltCrd := .T.
			EndIf

		ElseIf cOperacao == "-"

			If cTipoAnt $ "1/3"
				lAltDeb := .T.
			EndIf
			If cTipoAnt $ "2/3"
				lAltCrd := .T.
			EndIf

		EndIf

	Else

		lCtDeb := lCtDeb .and. cDebito	 	<> cDebitoAnt
		lCCDeb := lCCDeb .and. cCustoDeb 	<> cCustoDAnt
		lITDeb := lITDeb .and. cItemDeb	 	<> cItemDAnt
		lCLDeb := lCLDeb .and. cClVlDeb 	<> cCLVLDAnt

		lCtCrd := lCtCrd .and. cCredito		<> cCreditoAnt
		lCCCrd := lCCCrd .and. cCustoCrd 	<> cCustoCAnt
		lITCrd := lITCrd .and. cItemCrd		<> cItemCAnt
		lCLCrd := lCLCrd .and. cClVlCrd		<> cCLVLCAnt

		If cOperacao == "+"

			If cTipo $ "1/3" .and. (lCtDeb .or. lCcDeb .or. lItDeb .or. lClDeb )
				lAltDeb := .T.
			EndIf
			If cTipo $ "2/3" .and. (lCtCrd .or. lCcCrd .or. lItCrd .or. lClCrd )
				lAltCrd := .T.
			EndIf

		ElseIf cOperacao == "-"

			If cTipoAnt $ "1/3" .and. (lCtDeb .or. lCcDeb .or. lItDeb .or. lClDeb )
				lAltDeb := .T.
			EndIf
			If cTipoAnt $ "2/3" .and. (lCtCrd .or. lCcCrd .or. lItCrd .or. lClCrd )
				lAltCrd := .T.
			EndIf

		EndIf

	EndIf

EndIf

If lAtSldBase .And. cOperacao == "+"
	BEGIN TRANSACTION

	// Saldos de Documento
	If cTipo $ "1/3"
		GravaCTC(cLote,cSubLote,cDoc,"1",dData,cMoeda,nValor,cTpSald,lPartDob,cOperacao,,,cHistLote,cMoedDoc,cCritDoc,dDatTaxDoc,cTipSldDoc,cLivDia,cNroDia)
	EndIf

	If cTipo $ "2/3"
		GravaCTC(cLote,cSubLote,cDoc,"2",dData,cMoeda,nValor,cTpSald,lPartDob,cOperacao,,,cHistLote,cMoedDoc,cCritDoc,dDatTaxDoc,cTipSldDoc,cLivDia,cNroDia)
	EndIf

	END TRANSACTION

ElseIf lAtSldBase .And. cOperacao == "-"

	BEGIN TRANSACTION

	// subtrai o saldo atual da conta no ctc
	If cTipoAnt $ '1/3'
		GravaCTC(cLote,cSubLote,cDoc,"1",dData,cMoedaAnt,nValorAnt,cTpSaldAnt,lPartDob,cOperacao,,,cHistLote,cMoedDoc,cCritDoc,dDatTaxDoc,cTipSldDoc,cLivDia,cNroDia)
	EndIf
	If cTipoAnt $ '2/3'
		GravaCTC(cLote,cSubLote,cDoc,"2",dData,cMoedaAnt,nValorAnt,cTpSaldAnt,lPartDob,cOperacao,,,cHistLote,cMoedDoc,cCritDoc,dDatTaxDoc,cTipSldDoc,cLivDia,cNroDia)
	EndIf

	END TRANSACTION


EndIf

If	cOperacao == "+"

	If lPartDob .And. lAltDeb .And. lAltCrd .And. cTpSald != D_PRELAN

		If lAtuSldCT7 .And. lCtDeb .And. lCtCrd
			If lAtSldBase
				GRAVACT7(nOpc,cDebito,cCredito,cTipo,dData,cMoeda,nValor,cTpSald,lReproc,lAtSldBase,/*lZera*/,dDataLP,lTrbProc,cOperacao)
			Else
				lMudouSld	:= .T.
			EndIf
		EndIf

		// Saldos de Centro de Custo
		If lCusto .And. lAtuSldCT3 .And. ( lCtDeb .or. lCCDeb )
			If lAtSldBase
				GRAVACT3(cDebito,cCustoDeb,cCredito,cCustoCrd,cTipo,dData,cMoeda,nValor,cTpSald,lReproc,lAtSldBase,,dDataLP,nOpc,lTrbProc,cOperacao)
			Else
				lMudouSld	:= .T.
			EndIf
		EndIf
		// Saldos de Itens Contabeis
		If lItem .And. lAtuSldCT4
			If lCtDeb .or. lCCDeb .or. lItDeb
				If lAtSldBase
					GRAVACT4(cDebito,cCustoDeb,cItemDeb,cCredito,cCustoCrd,cItemCrd,cTipo,dData,cMoeda,nValor,cTpSald,lReproc,lAtSldBase,,dDataLP,nOpc,lTrbProc,cOperacao)
				Else
					lMudouSld	:= .T.
				EndIf
			EndIf
		EndIf
		// Saldos Classe de Valor
		If lClvl .And. lAtuSldCTI
			If lCtDeb .or. lCCDeb .or. lItDeb .or. lClDeb
				If lAtSldBase
					GRAVACTI(cDebito,cCustoDeb,cItemDeb,cClVlDeb,cCredito,cCustoCrd,cItemCrd,cClVlCrd,cTipo,dData,cMoeda,nValor,cTpSald,lReproc,lAtSldBase,,dDataLP,nOpc,lTrbProc,cOperacao)
				Else
					lMudouSld	:= .T.
				EndIf
			EndIf
		EndIf
		// Saldos Entidad 05
		If lEntidad05
			If lCtDeb .or. lCCDeb .or. lItDeb .or. lClDeb .Or. lE5Deb
				If lAtSldBase
					GRAVACQ("CV0",nOpc,cDebito,cCredito,cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlDeb,cClVlCrd,/*cIdent*/,cTipo,dData,cMoeda,nValor,cTpSald,lReproc,lAtSldBase,,dDataLP,lTrbProc,cOperacao,/*cFilMov*/,aEnt05)
				Else
					lMudouSld	:= .T.
				EndIf
			EndIf
		EndIf

	Else

		If lAltDeb
			If cTpSald != D_PRELAN		// Pre-Lancamento nao controla saldos
				// Saldos de Conta
				If lAtuSldCT7 .and. lCtDeb
					If lAtSldBase
						GRAVACT7(nOpc,cDebito,""/*cContaCrd*/,"1"/*cTipo*/,dData,cMoeda,nValor,cTpSald,lReproc,lAtSldBase,/*lZera*/,dDataLP,lTrbProc,cOperacao)
					Else
						lMudouSld	:= .T.
					EndIf
				EndIf
				// Saldos de Centro de Custo
				If lCusto .And. lAtuSldCT3
					If lCtDeb .or. lCCDeb
						If lAtSldBase
							GRAVACT3(cDebito,cCustoDeb,""/*cContaCrd*/,""/*cCustoCrd*/,"1"/*cTipo*/,dData,cMoeda,nValor,cTpSald,lReproc,lAtSldBase,,dDataLP,nOpc,lTrbProc,cOperacao)
						Else
							lMudouSld	:= .T.
						EndIf
					EndIf
				EndIf
				// Saldos de Itens Contabeis
				If lItem .And. lAtuSldCT4
					If lCtDeb .or. lCCDeb .or. lItDeb
						If lAtSldBase
							GRAVACT4(cDebito,cCustoDeb,cItemDeb,""/*cContaCrd*/,""/*cCustoCrd*/,""/*cItemCrd*/,"1"/*cTipo*/,dData,cMoeda,nValor,cTpSald,lReproc,lAtSldBase,,dDataLP,nOpc,lTrbProc,cOperacao)
						Else
							lMudouSld	:= .T.
						EndIf
					EndIf
				EndIf
				// Saldos Classe de Valor
				If lClvl .And. lAtuSldCTI
					If lCtDeb .or. lCCDeb .or. lItDeb .or. lClDeb
						If lAtSldBase
							GRAVACTI(cDebito,cCustoDeb,cItemDeb,cClVlDeb,""/*cCredito*/,""/*cCustoCrd*/,""/*cItemCrd*/,""/*cClVlCrd*/,"1"/*cTipo*/,dData,cMoeda,nValor,cTpSald,lReproc,lAtSldBase,,dDataLP,nOpc,lTrbProc,cOperacao)
						Else
							lMudouSld	:= .T.
						EndIf
					EndIf
				EndIf
				// Saldos Entidad 05
				If lEntidad05
					If lCtDeb .or. lCCDeb .or. lItDeb .or. lClDeb .Or. lE5Deb
						If lAtSldBase
							GRAVACQ("CV0",nOpc,cDebito,""/*cCredito*/,cCustoDeb,""/*cCustoCrd*/,cItemDeb,""/*cItemCrd*/,cClVlDeb,""/*cClVlCrd*/,/*cIdent*/,"1"/*cTipo*/,dData,cMoeda,nValor,cTpSald,lReproc,lAtSldBase,,dDataLP,lTrbProc,cOperacao,/*cFilMov*/,{aEnt05[1],""})
						Else
							lMudouSld	:= .T.
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf

		// Grava Saldos CREDORES
		If lAltCrd .And. cTpSald != D_PRELAN		// Pre-Lancamento nao controla saldos
			// Saldos de Conta
			If lAtuSldCT7 .and. lCtCrd
				If lAtSldBase
					GRAVACT7(nOpc,""/*cContaDeb*/,cCredito,"2"/*cTipo*/,dData,cMoeda,nValor,cTpSald,lReproc,lAtSldBase,/*lZera*/,dDataLP,lTrbProc,cOperacao)
				Else
					lMudouSld	:= .T.
				EndIf
			EndIf
			// Saldos de Centro de Custo
			If lCusto .And. lAtuSldCT3
				If lCtCrd .or. lCCCrd
					If lAtSldBase
						GRAVACT3(""/*cContaDeb*/,""/*cCustoDeb*/,cCredito,cCustoCrd,"2"/*cTipo*/,dData,cMoeda,nValor,cTpSald,lReproc,lAtSldBase,,dDataLP,nOpc,lTrbProc,cOperacao)
					Else
						lMudouSld	:= .T.
					EndIf
				EndIf
			EndIf
			// Saldos de Item Contabil
			If lItem .And. lAtuSldCT4
				If lCtCrd .or. lCCCrd .or. lItCrd
					If lAtSldBase
						GRAVACT4(""/*cContaDeb*/,""/*cCustoDeb*/,""/*cItemDeb*/,cCredito,cCustoCrd,cItemCrd,"2"/*cTipo*/,dData,cMoeda,nValor,cTpSald,lReproc,lAtSldBase,,dDataLP,nOpc,lTrbProc,cOperacao)
					Else
						lMudouSld	:= .T.
					EndIf
				EndIf
			EndIf
			// Saldos de Classe de Valor
			If lCLVL .And. lAtuSldCTI
				If lCtCrd .or. lCCCrd .or. lItCrd .or. lClCrd
					If lAtSldBase
						GRAVACTI(""/*cDebito*/,""/*cCustoDeb*/,""/*cItemDeb*/,""/*cClVlDeb*/,cCredito,cCustoCrd,cItemCrd,cClVlCrd,"2"/*cTipo*/,dData,cMoeda,nValor,cTpSald,lReproc,lAtSldBase,,dDataLP,nOpc,lTrbProc,cOperacao)
					Else
						lMudouSld	:= .T.
					EndIf
				EndIf
			EndIf
			// Saldos Entidad 05
			If lEntidad05
				If lCtCrd .or. lCCCrd .or. lItCrd .or. lClCrd .Or. lE5Crd
					If lAtSldBase
						GRAVACQ("CV0",nOpc,""/*cDebito*/,cCredito,""/*cCustoDeb*/,cCustoCrd,""/*cItemDeb*/,cItemCrd,""/*cClVlDeb*/,cClVlCrd,/*cIdent*/,"2"/*cTipo*/,dData,cMoeda,nValor,cTpSald,lReproc,lAtSldBase,,dDataLP,lTrbProc,cOperacao,/*cFilMov*/,{"",aEnt05[2]})
					Else
						lMudouSld	:= .T.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	If lAtSldBase
		//Grava saldo do cubo
		If _lCtbIsCube .And. CtbIsCube() .And. (lAtuSldCT7 .or.lAtuSldCT3 .or. lAtuSldCT4 .or. lAtuSldCTI) .And. Len(aEntid) > 0
			CtbGravCub( nValor, cTipo, cTpSald, cMoeda, dData, cDebito, cCredito, cCustoDeb, cCustoCrd, cItemDeb, cItemCrd, cClVlDeb, cClVlCrd, aEntid)
		EndIf
	Else
		lMudouSld	:= .T.
	EndIf

ElseIf  cOperacao == "-"

	// DesGravacao de Saldos de Contas
	If lAtuSldCT7
		If lAltDeb .and. lCtDeb
			If lAtSldBase
				GRAVACT7(nOpc,cDebitoAnt,""/*cContaCrd*/,"1"/*cTipo*/,dData,cMoedaAnt,nValorAnt,cTpSaldAnt,lReproc,lAtSldBase,.F./*lZera*/,dDataLP,lTrbProc,"-"/*cOperacao*/)
			Else
				lMudouSld	:= .T.
			EndIf
		EndIf
		If lAltCrd .and. lCtCrd
			If lAtSldBase
				GRAVACT7(nOpc,""/*cContaDeb"*/,cCreditoAnt,"2"/*cTipo*/,dData,cMoedaAnt,nValorAnt,cTpSaldAnt,lReproc,lAtSldBase,.F./*lZera*/,dDataLP,lTrbProc,"-"/*cOperacao*/)
			Else
				lMudouSld	:= .T.
			EndIf
		EndIf
	EndIf

	// DesGravacao de Saldos de Centro de Custo
	If lCusto .And. lAtuSldCT3

		If lAltDeb .and. (lCtDeb .or. lCCDeb)
			If lAtSldBase
				GRAVACT3(cDebitoAnt,cCustoDAnt,""/*cContaCrd*/,""/*cCustoCrd*/,"1"/*cTipo*/,dData,cMoedaAnt,nValorAnt,cTpSaldAnt,lReproc,lAtSldBase,,dDataLP,nOpc,lTrbProc,"-"/*cOperacao*/)
			Else
				lMudouSld	:= .T.
			EndIf
		EndIf

		If lAltCrd .and. (lCtCrd .or. lCCCrd)
			If lAtSldBase
				GRAVACT3(""/*cContaDeb*/,""/*cCustoDeb*/,cCreditoAnt,cCustoCAnt,"2"/*cTipo*/,dData,cMoedaAnt,nValorAnt,cTpSaldAnt,lReproc,lAtSldBase,,dDataLP,nOpc,lTrbProc,"-"/*cOperacao*/)
			Else
				lMudouSld	:= .T.
			EndIf
		EndIf
	EndIf

	// DesGravacao de Saldos de Item Contabil
	If lItem .And. lAtuSldCT4
		If lAltDeb .and. (lCtDeb .or. lCCDeb .or. lItDeb)
			If lAtSldBase
				GRAVACT4(cDebitoAnt,cCustoDAnt,cItemDAnt,""/*cContaCrd*/,""/*cCustoCrd*/,""/*cItemCrd*/,"1"/*cTipo*/,dData,cMoedaAnt,nValorAnt,cTpSaldAnt,lReproc,lAtSldBase,,dDataLP,nOpc,lTrbProc,"-"/*cOperacao*/)
			Else
				lMudouSld	:= .T.
			EndIf
		EndIf

		If lAltCrd .and. (lCtCrd .or. lCCCrd .or. lItCrd)
			If lAtSldBase
				GRAVACT4(""/*cContaDeb*/,""/*cCustoDeb*/,""/*cItemDeb*/,cCreditoAnt,cCustoCAnt,cItemCAnt,"2"/*cTipo*/,dData,cMoedaAnt,nValorAnt,cTpSaldAnt,lReproc,lAtSldBase,,dDataLP,nOpc,lTrbProc,"-"/*cOperacao*/)
			Else
				lMudouSld	:= .T.
			EndIf
		EndIf
	EndIf

	// Desgravacao dos Saldos da Classe de Valor
	If lCLVL .And. lAtuSldCTI
		If lAltDeb .and. (lCtDeb .or. lCCDeb .or. lItDeb .or. lClDeb)
			If lAtSldBase
				GRAVACTI(cDebitoAnt,cCustoDAnt,cItemDAnt,cCLVLDAnt,""/*cContaCrd*/,""/*cCustoCrd*/,""/*cItemCrd*/,""/*cClVlrCrd*/,"1"/*cTipo*/,dData,cMoedaAnt,nValorAnt,cTpSaldAnt,lReproc,lAtSldBase,,dDataLP,nOpc,lTrbProc,"-"/*cOperacao*/)
			Else
				lMudouSld	:= .T.
			EndIf
		EndIf

		If lAltCrd .and. (lCtCrd .or. lCCCrd .or. lItCrd .or. lClCrd)
			If lAtSldBase
				GRAVACTI(""/*cContaDeb*/,""/*cCustoDeb*/,""/*cItemDeb*/,""/*cClVlrDeb*/,cCreditoAnt,cCustoCAnt,cItemCAnt,cCLVLCAnt,"2"/*cTipo*/,dData,cMoedaAnt,nValorAnt,cTpSaldAnt,lReproc,lAtSldBase,,dDataLP,nOpc,lTrbProc,"-"/*cOperacao*/)
			Else
				lMudouSld	:= .T.
			EndIf
		EndIf
	EndIf

	// Desgravacao dos Saldos da Entidad 05
	If lEntidad05
		If lAltDeb .and. (lCtDeb .or. lCCDeb .or. lItDeb .or. lClDeb .Or. lE5Deb)
			If lAtSldBase
				GRAVACQ("CV0",nOpc,cDebitoAnt,""/*cCredito*/,cCustoDAnt,""/*cCustoCrd*/,cItemDAnt,""/*cItemCrd*/,cCLVLDAnt,""/*cClVlCrd*/,/*cIdent*/,"1"/*cTipo*/,dData,cMoedaAnt,nValorAnt,cTpSaldAnt,lReproc,lAtSldBase,,dDataLP,lTrbProc,"-"/*cOperacao*/,/*cFilMov*/,{aEnt05[1],""})
			Else
				lMudouSld	:= .T.
			EndIf
		EndIf

		If lAltCrd .and. (lCtCrd .or. lCCCrd .or. lItCrd .or. lClCrd .Or. lE5Crd)
			If lAtSldBase
				GRAVACQ("CV0",nOpc,""/*cDebito*/,cCreditoAnt,""/*cCustoDeb*/,cCustoCAnt,""/*cItemDeb*/,cItemCAnt,""/*cClVlDeb*/,cCLVLCAnt,/*cIdent*/,"2"/*cTipo*/,dData,cMoedaAnt,nValorAnt,cTpSaldAnt,lReproc,lAtSldBase,,dDataLP,lTrbProc,"-"/*cOperacao*/,/*cFilMov*/,{"",aEnt05[2]})
			Else
				lMudouSld	:= .T.
			EndIf
		EndIf
	EndIf

	If lAtSldBase
		//desgrava saldo do cubo
		If _lCtbIsCube .And. CtbIsCube() .And. (lAtuSldCT7 .or.lAtuSldCT3 .or. lAtuSldCT4 .or. lAtuSldCTI)
			CtbDsGrCub( nValorAnt, cTipoAnt, cTpSaldAnt, cMoedaAnt, dData, cDebitoAnt, cCreditoAnt, cCustoDAnt, cCustoCAnt, cItemDAnt, cItemCAnt, cCLVLDAnt, cCLVLCAnt, aEntidAnt)
		EndIf
	Else
		lMudouSld	:= .T.
	EndIf

EndIf

If  ( cOperacao == "+" .And. nTotInf <> Nil ) .OR. ;
		( cOperacao == "-" .And. nTotInf <> Nil .And. nOpc = 5 )
	BEGIN TRANSACTION
		CtbGrvlInf(dData,cLote,cSubLote,cDoc,cMoeda,nTotInf,nOpc)
	END TRANSACTION
EndIf

//Atualiza a ultima data de atualiza็ใo do saldo
If lMudouSld .And. !lAtSldBase
	If cOperacao == "+"
		AtuCv7Date(cTpSald,cMoeda,dData)
	ElseIf cOperacao == "-"
		AtuCv7Date(cTpSaldAnt,cMoedaAnt,dData)
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbGravCubบAutor  ณMicrosiga           บ Data ณ  16/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava saldo do cubo (soma)                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CtbGravCub( nValor, cTipo, cTpSald, cMoeda, dData, cDebito, cCredito, cCustoDeb, cCustoCrd, cItemDeb, cItemCrd, cClVlDeb, cClVlCrd, aEntid)
Local cAliasAux := Alias()
Local cQuery 	:= ""
Local nEntid

Local aEntidAux := {}

Default aEntid	:= {}

If nQtdEntid == NIL
	nQtdEntid:= CtbQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
EndIf

If oConjCubos == NIL
	oConjCubos := Ctb_Load_Cubes()
EndIf

aAdd( aEntidAux, { cDebito, "CT2_DEBITO", cCredito, "CT2_CREDIT" } )
aAdd( aEntidAux, { cCustoDeb, "CT2_CCD", cCustoCrd, "CT2_CCC" } )
aAdd( aEntidAux, { cItemDeb, "CT2_ITEMD",cItemCrd, "CT2_ITEMC" } )
aAdd( aEntidAux, { cClVlDeb, "CT2_CLVLDB", cClVlCrd, "CT2_CLVLCR" } )

If !Empty( aEntid )
	For nEntid := 1 TO ( nQtdEntid - 4 ) // quatro entidades sai padrao Conta/Centro Custo/Item Contabil/Classe de Valor
		aAdd(aEntidAux, { aEntid[nEntid, 1], "CT2_EC"+StrZero(nEntid+4,2)+"DB", aEntid[nEntid, 2], "CT2_EC"+StrZero(nEntid+4,2)+"CR"} )
	Next
EndIf

For nEntid := 1 TO Len( aEntidAux )
	cQuery += If( nEntid == 1, " SELECT ", "")
	cQuery += "'"+aEntidAux[nEntid, 1]+"' "+aEntidAux[nEntid, 2]+", "
	cQuery += "'"+aEntidAux[nEntid, 3]+"' "+aEntidAux[nEntid, 4]+", "
Next
cQuery += Str(nValor,TamSX3('CT2_VALOR')[1],TamSX3('CT2_VALOR')[2]) + " CT2_VALOR, "
cQuery += "'"+cTipo+"'" + " CT2_DC, "
cQuery += "'"+cTpSald+"'" + " CT2_TPSALD, "
cQuery += "'"+cMoeda+"'" + " CT2_MOEDLC, "
cQuery += "'"+DTOS(dData)+"'" + " CT2_DATA, "
cQuery += " MAX(R_E_C_N_O_) RECNO "  //para pegar soh um registro da CT0
cQuery += " FROM "+RetSqlName("CT0")

ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "_TMPCT2_", .T., .T. )
TcSetField("_TMPCT2_","CT2_DATA","D",8,0)
TcSetField("_TMPCT2_","CT2_VALOR","N",TamSX3('CT2_VALOR')[1],TamSX3('CT2_VALOR')[2])

Ctb_Run_Cubes(oConjCubos,"_TMPCT2_"/*cAliasMov*/,"+"/*cOperacao*/)   //grava saldo nos cubos

//dbSelectArea("_TMPCT2_")
_TMPCT2_->(dbCloseArea())

dbSelectArea(cAliasAux)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณProgram   ณGravaCtC  ณ Autor ณ Pilar S. Albaladejo   ณ Data ณ 24.07.00 	 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Grava Totais do Documento Contabil                        	 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณGRAVACTC(cLote,cSubLote,cDoc,cTipo,dData,cMoeda,nValor,cTpSald)ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ Nenhum                                                     	 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC1 = Lote do Lancamento Contabil                      	 ณฑฑ
ฑฑณ          ณ ExpC2 = Sub-Lote do Lancamento Contabil              	     ณฑฑ
ฑฑณ          ณ ExpC3 = Documento do Lancamento Contabil          	         ณฑฑ
ฑฑณ          ณ ExpC4 = Tipo do Lancamento Contabil                  	     ณฑฑ
ฑฑณ          ณ ExpC5 = Tipo do Lancamento Contabil                  	     ณฑฑ
ฑฑณ          ณ ExpD1 = Data do Lancamento Contabil              	         ณฑฑ
ฑฑณ          ณ ExpN6 = Valor do Lancamento Contabil        		          	 ณฑฑ
ฑฑณ          ณ ExpC7 = Tipo do saldo                                     	 ณฑฑ
ฑฑณ          ณ 1 - Real = 2 - Orcado = 3 - Gerencial = 4 - Pre-Lancamento	 ณฑฑ
ฑฑณ          ณ lPartDob = Indica se eh partida dobrada ou nao                ณฑฑ
ฑฑณ          ณ ExpC8 = Operacao ("+" Soma "-" Subtrai do saldo)  	         ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/              //  1      2      3     4    5     6       7      8       9         10      11  12
Function GRAVACTC(cLote,cSubLote,cDoc,cTipo,dData,cMoeda,nValor,cTpSald,lPartDob,cOperacao,cLp,cSeq,cHistLote,;
					cMoedDoc,cCritDoc,dDatTaxDoc,cTipSldDoc,cLivDia,cNroDia)

Local aSaveArea		:= GetArea()
Local lInclui		:= .F.
Local nMvSoma		:= SuperGetMv("MV_SOMA") //Determina se o lancam. tipo 3 ira ser somado 1 ou 2 vezes
Local lCt102inc		:= Iif(Type("Inclui") =="L" .And. (IsIncallstack("CTBA102") .Or. IsIncallstack("CTBA101") ),Inclui,.F.) // se for inclusใo pelo CTBA101 e CTBA102
Local lRedStorn  	:= cPaisLoc == "RUS" .And. SuperGetMV("MV_REDSTOR",.F.,.F.) // CAZARINI - 20/06/2017 - Parameter to activate Red Storn

Default cOperacao	:= "+"
Default cLp			:= CT2->CT2_LP
Default cSeq		:= CT2->CT2_SEQLAN
Default cHistLote	:= ""
Default cMoedDoc	:= ""
Default cCritDoc	:= ""
Default dDatTaxDoc	:= STOD("")
Default cTipSldDoc	:= ""
Default cLivDia		:= ""
Default cNroDia		:= ""

If cOperacao == "+" .And. (nValor <= 0 .and. !lRedStorn)
	Return
EndIf

DbSelectArea( "CTC" )
CTC->(DbSetOrder( 3 ))

If CTC->(! MsSeek(xFilial("CTC")+cMoeda+cTpSald+cLote+cSubLote+cDoc+Dtos(dData)))
	If cOperacao == "-"
		Return
	EndIf
	lInclui := .T.
Else
	lInclui := .F.
EndIf

If cOperacao == "+"
	// Nao ha registro para o dia -> cria!!
	If lInclui
		RecLock( "CTC", .t. )
		CTC->CTC_FILIAL 	:= xFilial("CTC")
		CTC->CTC_DATA		:= dData
		CTC->CTC_LOTE		:= cLote
		CTC->CTC_SBLOTE		:= cSubLote
		CTC->CTC_DOC		:= cDoc
		CTC->CTC_MOEDA		:= cMoeda
		CTC->CTC_STATUS		:= "1"						// Periodo Aberto
		CTC->CTC_TPSALD		:= cTpSald					// Real / Orcado / Gerencial / Pre
		If cPaisLoc == "EQU" .And. X3Usado("CTC_DOCHIS") .And. X3Usado("CT5_DOCHIS")
			CTC->CTC_DOCHIS	:= Posicione("CT5", 1, xFilial("CT5") + cLp + cSeq, "CT5_DOCHIS")
		EndIf
		If cPaisLoc == "ARG"
			//Grava็ใo das informacoes adicionais da capa do lote
			If(CTC->(FieldPos('CTC_MOEDDC')) > 0	,CTC->CTC_MOEDDC	:= cMoedDoc		,Nil) //Moeda do Documento Contabil
			If(CTC->(FieldPos('CTC_CRITDC')) > 0	,CTC->CTC_CRITDC	:= cCritDoc		,Nil) //Criterio de Conversao do Documento Contabil
			If(CTC->(FieldPos('CTC_DTTXDC')) > 0	,CTC->CTC_DTTXDC	:= dDatTaxDoc	,Nil) //Data da Taxa de Conversao do Documento Contabil
			If(CTC->(FieldPos('CTC_TPSADC')) > 0	,CTC->CTC_TPSADC	:= cTipSldDoc	,Nil) //Tipo de Saldo do Documento Contabil
			If(CTC->(FieldPos('CTC_DIACTB')) > 0	,CTC->CTC_DIACTB	:= cLivDia		,Nil) //Livro diario
			If(CTC->(FieldPos('CTC_NODIA')) > 0		,CTC->CTC_NODIA		:= cNroDia		,Nil) //Nro diario
		EndIf
	Else
		RecLock( "CTC", .f. )
	EndIf

	If !_lCTB185 .Or. lCt102inc	//Procedure CTB233 jแ realizou a atualiza็ใo da CTC, por essa razใo nใo grava novamente para nใo duplicar.
		// Grava valores atuais
		If cTipo == "1"
			CTC->CTC_DEBITO	:= (CTC->CTC_DEBITO + nValor)
		ElseIf cTipo == "2"
			CTC->CTC_CREDIT	:= (CTC->CTC_CREDIT + nValor)
		EndIf

		//Se o tipo do lancamento e 3, verIfica o parametro MV_SOMA:caso seja 1, soma 1 vez
		//Se for igual a 2, soma 2 vezes no valor digitado.

		If lPartDob
			If nMvSoma == 1 .And. cTipo == '1'
			    CTC->CTC_DIG := CTC->CTC_DIG + nValor
			ElseIf nMvSoma == 2
				CTC->CTC_DIG := CTC->CTC_DIG + nValor
			EndIf
		Else
		  	CTC->CTC_DIG := CTC->CTC_DIG + nValor
		EndIf
	EndIf

ElseIf cOperacao == "-"

	RecLock( "CTC", .f. )

	// Descalcula - Subtrai valores aos ja existentes
	If cTipo == "1"
		If CTC->CTC_DEBITO < nValor
			CTC_DEBITO := 0
		Else
			CTC->CTC_DEBITO	:= (CTC->CTC_DEBITO - nValor)
		EndIf
	ElseIf cTipo == "2"
		If CTC->CTC_CREDIT < nValor
			CTC_CREDIT := 0
		Else
			CTC->CTC_CREDIT	:= (CTC->CTC_CREDIT - nValor)
		EndIf
	EndIf

	//Se o tipo do lancamento e 3, verIfica o parametro MV_SOMA:caso seja 1, soma 1 vez
	//Se for igual a 2, soma 2 vezes no valor digitado.

	If lPartDob
		If nMvSoma == 1 .And. cTipo == '1'
		    CTC->CTC_DIG := CTC->CTC_DIG - nValor
		ElseIf nMvSoma == 2
			CTC->CTC_DIG := CTC->CTC_DIG - nValor
		EndIf
	Else
	  	CTC->CTC_DIG := IIf(CTC->CTC_DIG >0,CTC->CTC_DIG - nValor,0)
	EndIf

	If CTC->CTC_DIG < 0
		CTC->CTC_DIG := 0
	EndIf

EndIf

If cPaisLoc == "ARG"
	//Grava็ใo do historico da capa do lote
	If X3Usado("CTC_DOCHIS") .And. X3Usado("CT5_DOCHIS") .And. !Empty(cHistLote)

		//Tratamento para nใo exceder a capacidade de campo CTC_DOCHIS
		If Len(cHistLote) > TamSX3("CTC_DOCHIS")[1]
			cHistLote := SubStr(cHistLote,1,TamSX3("CTC_DOCHIS")[1])
		EndIf

		CTC->CTC_DOCHIS := cHistLote

	EndIf
EndIf

MsUnlock()
FKCOMMIT()

RestArea(aSaveArea)
aSize(aSaveArea,0)
aSaveArea := nil 

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbDsGrCubบAutor  ณMicrosiga           บ Data ณ  16/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Desgrava o saldo dos cubos (subtrai)                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function CtbDsGrCub( nValorAnt, cTipoAnt, cTpSaldAnt, cMoedaAnt, dData, cDebitoAnt, cCreditoAnt, cCustoDAnt, cCustoCAnt, cItemDAnt, cItemCAnt, cCLVLDAnt, cCLVLCAnt, aEntidAnt)

Local cAliasAux := Alias()
Local cQuery := ""
Local nEntid
Local aEntidAux := {}

If nQtdEntid == NIL
	nQtdEntid:= CtbQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
EndIf

If oConjCubos == NIL
	If _lCtbIsCube .And. CtbIsCube()
		oConjCubos := Ctb_Load_Cubes()
	EndIf
EndIf

aAdd( aEntidAux, { cDebitoAnt, "CT2_DEBITO", cCreditoAnt, "CT2_CREDIT" } )
aAdd( aEntidAux, { cCustoDAnt, "CT2_CCD", cCustoCAnt, "CT2_CCC" } )
aAdd( aEntidAux, { cItemDAnt, "CT2_ITEMD",cItemCAnt, "CT2_ITEMC" } )
aAdd( aEntidAux, { cCLVLDAnt, "CT2_CLVLDB", cCLVLCAnt, "CT2_CLVLCR" } )

For nEntid := 1 TO ( nQtdEntid - 4 ) // quatro entidades sai padrao Conta/Centro Custo/Item Contabil/Classe de Valor
	aAdd(aEntidAux, { aEntidAnt[nEntid, 1], "CT2_EC"+StrZero(nEntid+4,2)+"DB", aEntidAnt[nEntid, 2], "CT2_EC"+StrZero(nEntid+4,2)+"CR"} )
Next

For nEntid := 1 TO nQtdEntid
	cQuery += If( nEntid == 1, " SELECT ", "")
	cQuery += "'"+aEntidAux[nEntid, 1]+"' "+aEntidAux[nEntid, 2]+", "
	cQuery += "'"+aEntidAux[nEntid, 3]+"' "+aEntidAux[nEntid, 4]+", "
Next
cQuery += Str(nValorAnt,TamSX3('CT2_VALOR')[1],TamSX3('CT2_VALOR')[2]) + " CT2_VALOR, "
cQuery += "'"+cTipoAnt+"'" + " CT2_DC, "
cQuery += "'"+cTpSaldAnt+"'" + " CT2_TPSALD, "
cQuery += "'"+cMoedaAnt+"'" + " CT2_MOEDLC, "
cQuery += "'"+DTOS(dData)+"'" + " CT2_DATA, "
cQuery += " MAX(R_E_C_N_O_) RECNO "  //para pegar soh um registro da CT0
cQuery += " FROM "+RetSqlName("CT0")

ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "_TMPCT2_", .T., .T. )
TcSetField("_TMPCT2_","CT2_DATA","D",8,0)
TcSetField("_TMPCT2_","CT2_VALOR","N",TamSX3('CT2_VALOR')[1],TamSX3('CT2_VALOR')[2])

Ctb_Run_Cubes(oConjCubos,"_TMPCT2_"/*cAliasMov*/,"-"/*cOperacao*/)   //grava saldo nos cubos

//dbSelectArea("_TMPCT2_")
_TMPCT2_->(dbCloseArea())

dbSelectArea(cAliasAux)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbOutrEntบAutor  ณMicrosiga           บ Data ณ  16/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna array com conteudo atual e da base das outras       บฑฑ
ฑฑบ          ณentidades                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CtbOutrEnt( lMemory, cArqTmp, lSimula, cTabCTK, cTabCT2 )
Local aEntid := {}
Local aEntidAnt := {}
Local nEntid
Local cCpoDeb
Local cCpoCrd

Default lMemory := .F.
Default cArqTmp	:= "TMP"
Default lSimula	:= .F.
Default cTabCTK	:= "CTK"
Default cTabCT2	:= "CT2"

If nQtdEntid == NIL
	nQtdEntid:= CtbQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
EndIf

aEntid := {}
aEntidAnt := {}
For nEntid := 1 TO ( nQtdEntid - 4 ) //quatro entidades sao padrao Conta /CC / Item / Classe de Valor
    cCpoDeb := CtbCposCrDb("", "D", StrZero(nEntid + 4,2))
	cCpoCrd := CtbCposCrDb("", "C", StrZero(nEntid + 4,2))
	If lMemory
		aAdd(aEntid, { &("M->"+cCpoDeb), &("M->"+cCpoCrd) } )
	Else
		aAdd(aEntid, { &(cArqTmp+ "->" +cCpoDeb), &(cArqTmp+ "->" +cCpoCrd) } )
	EndIf
	aAdd(aEntidAnt, { &("CT2->"+cCpoDeb), &("CT2->"+cCpoCrd) } )
Next

Return { aEntid, aEntidAnt }

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณCtbGrvlInf ณ Autor ณ Simone Sato           ณ Data ณ14.02.01 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณGrava Valor Informado no  CT6_INF					          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณCtbGrvlInf(dData,cLote,cSubLote,cMoeda,nTotInf,nOpc)		  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ Nenhum                                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ CTB		                                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณdData    = Data                                             ณฑฑ
ฑฑณ          ณcLote    = Numero do Lote                                   ณฑฑ
ฑฑณ          ณcSubLote = Numero do SubLote                                ณฑฑ
ฑฑณ          ณcDoc     = Numero do Documento                              ณฑฑ
ฑฑณ          ณcMoeda   = Codigo da Moeda                                  ณฑฑ
ฑฑณ          ณnTotInf  = Valor Total Informado para o documento           ณฑฑ
ฑฑณ          ณnOpc     = Opcao atual em execucao                          ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function CtbGrVlInf(dData,cLote,cSubLote,cDoc,cMoeda,nTotInf,nOpc)

Local aSaveArea	:= GetArea(), nDimLot := 0

// Saldo por Documento
dbSelectArea('CTC')
CTC->(dbSetOrder(1))
If CTC->(MsSeek(xFilial('CTC')+dtos(dData)+cLote+cSubLote+cDoc+cMoeda))

	// No caso de exclusao, caso ainda tenha valores digitados nao manipula o valor
	// Tratamento necessario pois a exclusao do CTBA101 e por linha nao deletando o documento
	If nOpc = 5 .And. CTC->CTC_DIG > 0
		Return .T.
	EndIf

	RecLock( "CTC", .F. )

	// Valor informado a ser diminuido
	nDimLot := CTC->CTC_INF

	If nOpc # 5 .And. !(IsIncallStack("Ctb280Proc")) // Caso positivo altere para o valor recebido
		CTC->CTC_INF := nTotInf
	Else			// Caso contrario eh exclusao ou seja zero o documento
		CTC->CTC_INF := 0.00
	EndIf
	CTC->(MsUnlock())
EndIf


RestArea(aSaveArea)
aSize(aSaveArea,0)
aSaveArea := nil 

Return

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณCtGrVlMoed  ณ Autoraณ Simone Mie Sato     ณ Data ณ 22.07.02 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณGrava valor em outra moeda                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณCtGrVlMoed()                                                ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณNenhum                                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Generico                                                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ dData	  = Data do Lancamento                            ณฑฑ
ฑฑณ          ณ cLote	  = Lote           	                              ณฑฑ
ฑฑณ          ณ cSublote   = SubLote                                       ณฑฑ
ฑฑณ          ณ cDoc       = Documento                                     ณฑฑ
ฑฑณ          ณ cLinha     = Numero da Linha                               ณฑฑ
ฑฑณ          ณ cTpSald    = Tipo do Saldo                                 ณฑฑ
ฑฑณ          ณ cMoeda     = Moeda                                         ณฑฑ
ฑฑณ          ณ cEmpOri    = Empresa Origem                                ณฑฑ
ฑฑณ          ณ cFilOri    = Filial Origem                                 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function CtGrVlMoed(dData,cLote,cSubLote,cDoc,cLinha,cTpSald,cMoeda,cEmpOri,cFilOri,nValor,cDc,;
	cContaDeb,cDigDeb,cContaCrd,cDigCrd,cCustoDeb,cCustoCrd,cItemdeb,cItemCrd,cClVlDeb,cClVlCrd,;
	cLP,cSequenc,cOrigem,cAglut,cCriter,cHp,cHist,cSeqLan,cSeqHis,dDatalP,cSlBase,cKeyCT2,dDtCV3)

Local aSaveArea	:= GetArea()
DEFAULT cKeyCT2 := ""
DEFAULT dDtCV3	:= CTOD("  /  /  ")

dbSelectArea("CT2")
CT2->(dbSetOrder(1))
If CT2->(!MsSeek(xFilial("CT2")+dtos(dData)+cLote+cSubLote+cDoc+cLinha+cTpSald+cEmpOri+cFilOri+cMoeda))
	Reclock("CT2",.T.)
	CT2->CT2_FILIAL		:= xFilial("CT2")
	CT2->CT2_DATA		:= dData
	CT2->CT2_LOTE		:= cLote
	CT2->CT2_SBLOTE		:= cSubLote
	CT2->CT2_DOC		:= cDoc
	CT2->CT2_LINHA		:= cLinha
	CT2->CT2_FILORI		:= cFilOri
	CT2->CT2_EMPORI		:= cEmpOri
	CT2->CT2_DC			:= cDc
	CT2->CT2_DEBITO		:= cContaDeb
	CT2->CT2_DCD		:= cDigDeb
	CT2->CT2_CREDIT		:= cContaCrd
	CT2->CT2_DCC		:= cDigCrd
	CT2->CT2_CCD		:= cCustoDeb
	CT2->CT2_CCC		:= cCustoCrd
	CT2->CT2_ITEMD		:= cItemDeb
	CT2->CT2_ITEMC		:= cItemCrd
	CT2->CT2_CLVLDB		:= cClVlDeb
	CT2->CT2_CLVLCR		:= cClVlCrd
	CT2->CT2_LP			:= cLP
	CT2->CT2_SEQUEN		:= cSequenc
	CT2->CT2_ROTINA		:= FUNNAME()
	CT2->CT2_ORIGEM		:= cOrigem
	CT2->CT2_AGLUT		:= cAglut
	CT2->CT2_MOEDLC		:= cMoeda
	CT2->CT2_TPSALD		:= cTpSald
	CT2->CT2_HP			:= cHP
	CT2->CT2_HIST		:= cHist
	CT2->CT2_SEQLAN		:= cSeqLan
	CT2->CT2_SEQHIS		:= cSeqHis
	CT2->CT2_MANUAL		:= "1"
	CT2->CT2_DTLP		:= dDataLp
	CT2->CT2_SLBASE		:= cSlBase
Else
	RecLock("CT2",.F.)
EndIf
If Empty(CT2->CT2_KEY)
	CT2->CT2_KEY := cKeyCT2
EndIf
If Empty(CT2->CT2_DTCV3)
	CT2->CT2_DTCV3 := dDtCV3
EndIf
CT2->CT2_VALOR	:= nValor
CT2->CT2_CRCONV	:= cCriter
CT2->(MsUnlock())

RestArea(aSaveArea)
aSize(aSaveArea,0)
aSaveArea := nil 

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNewCV3byCTบAutor  ณMarcos S. Lobo      บ Data ณ  01/26/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria registro no arquivo de rastreamento CV3 a partir do CTKบฑฑ
ฑฑบ          ณposicionado.                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP - DetProva() - MATXFUNA e CTBGRAVA() - CTBXFUN		  บฑฑ
ฑฑบ          ณ Grava็ใo de lan็amentos de integra็ao              		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function NewCV3byCTK(lSimula,cTabCTK,cTabCT2)

Default lSimula	:= .F.
Default cTabCTK := "CTK"
Default cTabCT2 := "CT2"

If ( lCTxTABORI == Nil ) .Or. ( lCTxRECORI == Nil ) .Or. ( lCTxRECDES == Nil ) .Or. ( lCTKRECCV3 == Nil )
	// Funcao que verIfica se existe configuracao para Rastreamento Automatico
	RastAutom(lSimula,cTabCTK,cTabCT2)
EndIf

CV3->( RecLock("CV3", .T.) )
CV3->CV3_FILIAL	:=	xFilial("CV3")
CV3->CV3_DTSEQ	:=	CTK->CTK_DATA
CV3->CV3_SEQUEN	:=	CTK->CTK_SEQUEN
CV3->CV3_DC		:=	CTK->CTK_DC
CV3->CV3_LP		:= 	CTK->CTK_LP
CV3->CV3_LPSEQ	:=	CTK->CTK_LPSEQ
CV3->CV3_KEY	:=	CTK->CTK_KEY
CV3->CV3_DEBITO	:=	CTK->CTK_DEBITO
CV3->CV3_CREDIT	:= 	CTK->CTK_CREDIT
CV3->CV3_VLR01	:=	CTK->CTK_VLR01
CV3->CV3_VLR02	:= 	CTK->CTK_VLR02
CV3->CV3_VLR03	:=	CTK->CTK_VLR03
CV3->CV3_VLR04	:= 	CTK->CTK_VLR04
CV3->CV3_VLR05	:=	CTK->CTK_VLR05
CV3->CV3_HIST	:=	CTK->CTK_HIST
CV3->CV3_CCC	:=	CTK->CTK_CCC
CV3->CV3_CCD	:=	CTK->CTK_CCD
CV3->CV3_ITEMC	:= 	CTK->CTK_ITEMC
CV3->CV3_ITEMD	:=	CTK->CTK_ITEMD
CV3->CV3_CLVLDB	:=	CTK->CTK_CLVLDB
CV3->CV3_CLVLCR	:= 	CTK->CTK_CLVLCR
CV3->CV3_MOEDLC	:=	CTK->CTK_MOEDLC


If lCTxTABORI
	CV3->CV3_TABORI	:= CTK->CTK_TABORI
EndIf
If lCTxRECORI
	CV3->CV3_RECORI	:= CTK->CTK_RECORI
EndIf

//Alterado para passar no issue x cobertura. Prote็ใo por se tratar de variแvel static.
_lPostgres :=  IIf(_lPostgres == NIL,Upper(TcGetDb())$"POSTGRES",_lPostgres)

If lCTxIDORIG == Nil
	lCTxIDORIG :=  CTK->(FieldPos("CTK_IDORIG")) > 0
	If lCTxIDORIG
		 lCTxIDORIG := CV3->(FieldPos("CV3_IDORIG")) > 0
	EndIf
EndIf

If lCTxIDORIG
	CV3->CV3_IDORIG	:= IIf(_lPostgres,Lower(CTK->CTK_IDORIG),CTK->CTK_IDORIG)
EndIf

If lCTxRECDES 							/// NA CHAMADA PELA DETPROVA NAO VAI ESTAR PREENCHIDO
	CV3->CV3_RECDES := CTK->CTK_RECDES	/// NA CHAMADA PELA CTBGRAVA() JA ESTARA PREENCHIDO
EndIf


CV3->(MsUnlock())

If lCTKRECCV3
	dbSelectArea("CTK")
	RecLock("CTK",.F.)
	CTK->CTK_RECCV3	:= alltrim(str(int(CV3->(Recno()))))/// GUARDA O CV3 CORRESP. NO CTK.
	CTK->(MsUnlock())									/// USADO CTBXFUN - CTBGRAVA()
EndIf


dbSelectArea("CV3")
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Ponto de entrada para complementar a gravacao da tabela CV3 - campos de usuแrio. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If _lPEGRVCV3 .And. !lSimula
	ExecBlock( "GRVCV3", .F., .F. )
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCT2ClearLAบAutor  ณMarcos S. Lobo      บ Data ณ  01/26/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLimpa o flag de contabiliza็ใo (_LA / _DTLANC) nas tabelas  บฑฑ
ฑฑบ          ณde origem de integra็ใo baseado no CT2 posicionado          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP - Exclusใo de Lan็amentos de Integra็ใo  				  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CT2ClearLA(cModoClr)

Local aAreaOri	:= GetArea()
Local aAreaCT2	:= CT2->(GetArea())

Local lCanProc	:= .F.				/// VERIfICACAO DOS CAMPOS QUE DEVEM SER CRIADOS CTK e CV3
Local cRetorno	:= "2"				/// RETORNO '1'=Excluir CT2 flags limpos, '2'=Excluir CT2 sem Flags, '3'=Cancelar Exclusao CT2
Local cRecCT2	:= ""				/// NUMERO DE RECNO() DO CT2 (CARACTER) PARA SEEK e WHILE NO CV3
Local cFilCV3	:= ""				/// xFilial() do CV3
Local lSemOrig	:= .F.				/// REGISTROS SEM ORIGEM PARA RASTREAMENTO

Local cTabAtu  := ""
Local cCpoFlag := ""
Local cNoDia   := ""
Local cDiaCTB  := ""
Local xInFlag  := ""
Local cAliasOrig := ""
Local nRecOrigem  := 0

Local aAreaSFX	:= {}
Local cFilOriLnc	:= ""
Local lLimpaFlag := .F.
Local cTamIdORI  := Space(TAMSX3("FKA_IDORIG")[1])
Local cIdOrig 	 := cTamIdORI
local lMV_PLSATIV := SuperGetMV("MV_PLSATIV",.F., .F.)
Local cKeySE5	:= ""
Local cKeySF3   := ""

Default cModoClr	:= Alltrim(SuperGetMV("MV_CTBAPLA",.F.,"1"))	//"1"=Inativo,"2"=Pergunta,"3"=Automatico c/Alertas,"4"=Automแtico sem alertas


If cModoClr == "1"					/// SE A LIMPEZA DE FLAG ESTIVER DESLIGADA
	RestArea(aAreaCT2)
	aSize(aAreaCT2,0)
	aAreaCT2 := nil 

	RestArea(aAreaOri)
	aSize(aAreaOri,0)
	aAreaOri := nil 
	Return "2"					/// PODE EXCLUIR CT2 sem limpar flags
EndIf

If CT2->(Eof())
	Return "2"
EndIf

// Funcao que verIfica se existe configuracao para Rastreamento Automatico
If ( lCTxTABORI == Nil ) .Or. ( lCTxRECORI == Nil ) .Or. ( lCTxRECDES == Nil ) .Or. ( lCTKRECCV3 == Nil )
	// Funcao que verIfica se existe configuracao para Rastreamento Automatico
	RastAutom()
EndIf

dbSelectArea("CTK")
lCanProc := lCTxTABORI .and. lCTxRECORI .and. lCTxRECDES .and. lCTKRECCV3
If !lCanProc
	If !lBlind
		nAviso := 4
		While nAviso >= 3
			nAviso := Aviso(STR0008+STR0009,; //"Lan็amentos de integra็ใo."#" - ATENCAO ! Administrador."
							STR0010+CRLF+;    //"Campos de rastreamento e remarca็ใo de flags na origem."
							STR0011+CRLF+;    //"VerIfique criacao dos campos: "
							"CTK_TABORI (Char - 3)"+CRLF+;
							"CTK_RECORI (Char - 17)"+CRLF+;
							"CTK_RECDES (Char - 17)"+CRLF+;
							"CTK_RECCV3 (Char - 17)"+CRLF+;
							"CV3_TABORI (Char - 3)"+CRLF+;
							"CV3_RECORI (Char - 17)"+CRLF+;
							"CV3_RECDES (Char - 17)."+CRLF+;
							STR0012,;         //"Nใo serแ possํvel remarca็ใo automแtica de flags."
							{STR0013,STR0014},3,"")   //"Excluir"##"Manter Reg."

			If nAviso == 1			/// Excluir mesmo assim (apaga CT2 mesmo sem limpar flag.
				cRetorno := "2"
				__cArqFlags := TRBFlags("5")	/// REMARCACAO CANCELADA P/ USUARIO (linha)
			ElseIf nAviso == 2      /// Cancela a exclusใo do lan็amento no CT2.
				cRetorno := "3"
			EndIf
		EndDo
	Else
		If __lConOutR
			ConoutR("CT2ClearLA-CTBXFUN-"+STR0011+"CTK_TABORI,CTK_RECORI,CTK_RECDES,CTK_RECCV3,CV3_TABORI,CV3_RECORI,CV3_RECDES - Recno. "+cRecCT2+STR0015)//"VerIfique criacao dos campos: "#" do CT2 excluํdo, flags nao limpos."
		EndIf
	EndIf
	RestArea(aAreaCT2)
	RestArea(aAreaOri)
	aSize(aAreaCT2,0)
	aAreaCT2 := nil 
	aSize(aAreaOri,0)
	aAreaOri := nil 
	Return cRetorno					/// 2 = EXCLUIR CT2 sem limpar flags / 3 = Mantem Registro
EndIf

dbSelectArea("CT2")
dbSelectArea("CV3")

cFilOriLnc := CT2->CT2_FILORI
cFilCV3 := xFilial( "CV3" , cFilOriLnc )

If dbNickOrder("CV3","CV3RECDES") == 0
	If !lBlind
		nAviso := 4
		While nAviso >= 3
			nAviso := Aviso(STR0008+STR0009,; //"Lan็amentos de integra็ใo."#" - ATENCAO ! Administrador."
							STR0016+CRLF+;    //"Indices de rastreamento e remarca็ใo de flags na origem."
							STR0017+CRLF+;    //"VerIfique criacao de indices: "
							"CV3_FILIAL+CV3_RECDES - NickName CV3RECDES "+CRLF+;
							STR0018,;         //"Nใo serแ possํvel remarca็ใo automแtica de flags."
							{STR0013,STR0014},3,"")//"Excluir"#"Manter reg."

			If nAviso == 1			/// Excluir mesmo assim (apaga CT2 mesmo sem limpar flag.
				cRetorno := "2"
				__cArqFlags := TRBFlags("5")	/// REMARCACAO CANCELADA P/ USUARIO (linha)
			ElseIf nAviso == 2      /// Cancela a exclusใo do lan็amento no CT2.
				cRetorno := "3"
			EndIf
		EndDo
    Else
		If __lConOutR
			ConoutR("CT2ClearLA-CTBXFUN-"+STR0017+CRLF+"CV3_FILIAL+CV3_RECDES - NickName CV3RECDES "+CRLF+" - Recno. "+cRecCT2+STR0015)  //"VerIfique criacao de indices: "#" do CT2 excluํdo, flags nao limpos."
		EndIf
    EndIf
    RestArea(aAreaCT2)
	RestArea(aAreaOri)
	aSize(aAreaCT2,0)
	aAreaCT2 := nil 
	aSize(aAreaOri,0)
	aAreaOri := nil 
	Return cRetorno					/// 2 = EXCLUIR CT2 sem limpar flags / 3 = Mantem Registro
EndIf

If cModoClr == "2"
	If !lBlind
		If ValType(__cCleanLA) == Nil .or. __cCleanLA <> CT2->(CT2_FILIAL+DTOC(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC)
			nAviso := 1
			nAviso := Aviso("Doc: "+CT2->(DTOC(CT2_DATA)+" - "+CT2_LOTE+" - "+CT2_SBLOTE+" - "+CT2_DOC),;
							STR0019;  //"Limpar flags de contabiliza็ใo nas tabelas de origem ?"
							,{STR0020,STR0021,STR0022},2,STR0008)  //"Sim"#"Nใo"#"Nใo Excluir"#"Lancamento de Integra็ใo."

			If nAviso == 1
				__cRetClean := "1"			///PODE DELECTAR CT2 - EFETUA REMARCAวรO DOS FLAGS
			ElseIf nAviso == 2
				__cRetClean := "2"			///PODE PODE DELETAR CT2 - MAS NAO REMARCA (NAO PASSA PELA REMARCACAO)
				__cArqFlags := TRBFlags("4")	/// INCONSISTENTE REMARCACAO CANCELADA P/ USUARIO (DOC TODO).
			ElseIf nAviso == 3
				__cRetClean := "3"			///NAO PODE DELETAR CT2 - CANCELOU EXCLUSAO (NAO PASSA PELA REMARCACAO)
			EndIf

			__cCleanLA := CT2->(CT2_FILIAL+DTOC(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC)/// PARA NAO PERGUNTAR NOVAMENTE NO MESMO DOC.

			If __cRetClean >= "2"
				RestArea(aAreaCT2)
				RestArea(aAreaOri)
				aSize(aAreaCT2,0)
				aAreaCT2 := nil 
				aSize(aAreaOri,0)
				aAreaOri := nil 
				Return __cRetClean					/// 1 = EXCLUI CT2 REMARCA FLAGS / 2 = EXCLUI CT2 SEM FLAGS / 3= NAO EXCLUI
			EndIf
		Else
			If __cRetClean >= "2"
				RestArea(aAreaCT2)
				RestArea(aAreaOri)
				aSize(aAreaCT2,0)
				aAreaCT2 := nil 
				aSize(aAreaOri,0)
				aAreaOri := nil 
				Return __cRetClean					/// 1 = EXCLUI CT2 REMARCA FLAGS / 2 = EXCLUI CT2 SEM FLAGS / 3= NAO EXCLUI
			EndIf
		EndIf
	EndIf
EndIf

cRecCT2 := PADR( ALLTRIM(STR(INT( CT2->(Recno()) )) ),len(CV3->CV3_RECDES))



cQuery := " SELECT "
cQuery += " CV3_TABORI, CV3_RECORI"
cQuery += " FROM " + RetSqlName("CV3")+" CV3 "
cQuery += " WHERE "
cQuery += " CV3_FILIAL = '"+cFilCV3+"' "
cQuery += " AND CV3_RECDES = '"+cRecCT2+"' "
cQuery += " AND CV3_DC != '4' "
cQuery += " AND CV3.D_E_L_E_T_ = ' ' "


dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"CV3_QRY",.T.,.F.)

If CV3_QRY->( Eof() )
	__cArqFlags := TRBFlags("3")					/// INCONSISTENTE NAO ENCONTRADO NO CV3
	lSemOrig := .T.
Else
	While CV3_QRY->( ! Eof() )
		If Empty(CV3_QRY->CV3_TABORI) .or. Empty(CV3_QRY->CV3_RECORI)
			__cArqFlags := TRBFlags("1")					/// INCONSISTENTE TAB.REC. ORIGEM NAO GRAVADOS
			lSemOrig := .T.
		Else
			cAliasOrig := CV3_QRY->CV3_TABORI
			nRecOrigem := int(val(CV3_QRY->CV3_RECORI))
			If AliasInDic(cAliasOrig)
				dbSelectArea(cAliasOrig)
				dbGoTo(nRecOrigem)
				If (cAliasOrig)->(Eof()) .or. nRecOrigem <> (cAliasOrig)->(Recno())			/// SE NรO ENCONTRAR NA ORIGEM
					__cArqFlags := TRBFlags("2")					/// INCONSISTENTE NAO ENCONTRADO NA ORIGEM
					lSemOrig := .T.
				EndIf
			Else
				lSemOrig := .T.
			EndIf
		EndIf
		CV3_QRY->( dbSkip() )
	EndDo
EndIf

dbSelectArea("CV3_QRY")
CV3_QRY->(dbCloseArea())


If !lBlind .and. cModoCLR < "4" /// SE PERGUNTA AO USUมRIO - DEMONSTRA SE HOUVER CV3 SEM RASTREAMENTO
	If ValType(__cCleanLA) == Nil .or. __cCleanLA <> CT2->(CT2_FILIAL+DTOC(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC)
		If lSemOrig
			nAviso := 4
			While nAviso >= 3
				nAviso := 4
				nAviso := Aviso("Doc: "+CT2->(DTOC(CT2_DATA)+" - "+CT2_LOTE+" - "+CT2_SBLOTE+" - "+CT2_DOC),;
								STR0023+CT2->CT2_LINHA+STR0024+CRLF+;  //"Linha "##" no documento sem rastreamento."
								STR0025+CRLF+CRLF+;  	//"Excluir pode nใo remarcar todos flags na origem."
								STR0026+CRLF+;			//"Manter Reg. -> Cancela a Excluisใo do Lancamento."
								STR0027+CRLF+;          //"Exc. + Flag -> Excluir Lancamentos e limpar flags possํveis."
								STR0028+CRLF,;          //"Exc. - Flag -> Excluir Lancamentos sem limpar flags."
								{STR0014,STR0029,STR0030,STR0031},3,STR0008)//"Manter Reg."#"Exc + Flag."#"Exc. - Flag."#"Ver Log"#"Lan็amentos de integra็ใo."

				If nAviso == 1				/// REGISTROS NAO SERAO DELETADOS DO CT2
					cRetorno := "3"
					If MsgYesNo(STR0032,STR0033)//"Mesma resposta para todos no DOC ?"#"Manter Reg. -> Cancela a Excluisใo do Lancamento."
						__cRetClean := "3"		/// 1 = EXCLUI CT2 REMARCA FLAGS / 2 = EXCLUI CT2 SEM FLAGS / 3= NAO EXCLUI
						__cCleanLA := CT2->(CT2_FILIAL+DTOC(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC)/// PARA NAO PERGUNTAR NOVAMENTE NO MESMO DOC.
					EndIf
					RestArea(aAreaCT2)
					RestArea(aAreaOri)
					aSize(aAreaCT2,0)
					aAreaCT2 := nil 
					aSize(aAreaOri,0)
					aAreaOri := nil 
					Return cRetorno
				ElseIf nAviso == 2			/// REGISTROS SERAO DELETADOS DO CT2 LIMPANDO FLAGS POSSอVEIS
					If MsgYesNo(STR0032,STR0034)//"Mesma resposta para todos no DOC ?"#"Exc. + Flag -> Excluir Lancamentos e limpar flags possํveis."
						__cRetClean := "1"		/// 1 = EXCLUI CT2 REMARCA FLAGS / 2 = EXCLUI CT2 SEM FLAGS / 3= NAO EXCLUI
						__cCleanLA := CT2->(CT2_FILIAL+DTOC(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC)/// PARA NAO PERGUNTAR NOVAMENTE NO MESMO DOC.
					EndIf
					Exit //SAI DO WHILE DE AVISO
				ElseIf nAviso == 3			/// REGISTROS SERAO DELETADOS DO CT2 SEM LIMPAR FLAGS
					cRetorno := "2"
					If MsgYesNo(STR0032,STR0035)//"Mesma resposta para todos no DOC ?"#"Exc. - Flag -> Excluir Lancamentos e limpar flags possํveis."
						__cRetClean := "2"		/// 1 = EXCLUI CT2 REMARCA FLAGS / 2 = EXCLUI CT2 SEM FLAGS / 3= NAO EXCLUI
						__cCleanLA := CT2->(CT2_FILIAL+DTOC(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC)/// PARA NAO PERGUNTAR NOVAMENTE NO MESMO DOC.
						__cArqFlags := TRBFlags("4")	/// INCONSISTENTE REMARCACAO CANCELADA P/ USUARIO (TODO DOC).
					Else
						__cArqFlags := TRBFlags("5")	/// INCONSISTENTE REMARCACAO CANCELADA P/ USUARIO (LINHA).
					EndIf
					RestArea(aAreaCT2)
					RestArea(aAreaOri)
					aSize(aAreaCT2,0)
					aAreaCT2 := nil 
					aSize(aAreaOri,0)
					aAreaOri := nil 
					Return cRetorno
				ElseIf nAviso == 4			/// EXIBE O LOG DE RASTREAMENTO E REGISTROS DELETADOS
					CTBShowFLG()
				EndIf
			EndDo
		EndIf
	Else
		If __cRetClean >= "2"
			RestArea(aAreaCT2)
			RestArea(aAreaOri)
			aSize(aAreaCT2,0)
			aAreaCT2 := nil 
			aSize(aAreaOri,0)
			aAreaOri := nil 
			Return __cRetClean					///1 = EXCLUI CT2 REMARCA FLAGS / 2 = EXCLUI CT2 SEM FLAGS / 3= NAO EXCLUI
		EndIf
	EndIf
EndIf

///////////////////////////////////////////////////////////
/// LIMPEZA DOS FLAGS NAS TABELAS DE ORIGEM DOS LANวAMENTOS
///////////////////////////////////////////////////////////
cTabAtu  := ""

CV3->(DBSetOrder(2)) //CV3_FILIAL+CV3_RECDES

CV3->(MsSeek(cFilCV3+cRecCT2,.T.))

While CV3->(!Eof()) .and. CV3->CV3_FILIAL == cFilCV3 .and. CV3->CV3_RECDES == cRecCT2

	If Empty(CV3->CV3_TABORI) .or. Empty(CV3->CV3_RECORI) .or. CV3->CV3_DC == "4"
		CV3->(dbSkip())
		Loop
	EndIf

	cAliasOrig	:= CV3->CV3_TABORI
	nRecOrigem	:= Int(Val(CV3->CV3_RECORI))
	cCpoFlag 	:= ""
	xInFlag		:= ""
	cTabAtu  := ""
	aAreaSFX := {}

	If AliasInDic(cAliasOrig)
		dbSelectArea(cAliasOrig)
		dbGoTo(nRecOrigem)

		If (cAliasOrig)->(Eof()) .or. nRecOrigem <> (CV3->CV3_TABORI)->(Recno())			/// SE NรO ENCONTRAR NA ORIGEM
			CV3->(dbSkip())
			Loop
		EndIf
	Else
		CV3->(dbSkip())
		Loop
	EndIf

	If cAliasOrig <> cTabAtu

		If __lClrFlag
			// Ponto de entrada de manipula็ใo do campo de flag.
			// Utilizado pelo modulo de PLS.
			cCpoFlag := Execblock( "CTBCLRFLG" , .F., .F. , {cAliasOrig, nRecOrigem} )

			If ValType( cCpoFlag ) == 'C'
				If (cAliasOrig)->(FieldPos(cCpoFlag) > 0)
					If ValType( (cAliasOrig)->(cCpoFlag) ) == 'C'
						xInFlag := ''

					ElseIf ValType( (cAliasOrig)->(cCpoFlag) ) == 'N'
						xInFlag := 0

					ElseIf ValType( (cAliasOrig)->(cCpoFlag) ) == 'L'
						xInFlag := .F.

					ElseIf ValType( (cAliasOrig)->(cCpoFlag) ) == 'D'
						xInFlag  := CTOD("")
    				Else
						xInFlag  := Nil
					EndIf
				EndIf
			EndIf
		EndIf

		if lMV_PLSATIV .and. empty(cCpoFlag)
			cCpoFlag := plClrFlg(CV3->CV3_LP)
		endif
		If Empty( cCpoFlag )
			cCpoFlag := PrefixoCpo(cAliasOrig) + "_LA"		/// CAMPO DO FLAG DE CONTABILIZACAO
			xInFlag  := ""							 			/// CONTEUDO PARA LIMPAR O FLAG DE CONTABILIZACAO

			If CV3->CV3_LP = '903'  //LANCAMENTO DO TMS - EMISSAO CUSTO TRANSPORTE (CAMPO DE FLAG ESPECIFICO DEVIDO O MESMO REGISTRO SER CONTABLIZADO 2X)
				cCpoFlag := PrefixoCpo(cAliasOrig) + "_DTLAEMI"
				xInFlag  := CTOD("")
			EndIf

			If CV3->CV3_LP $ '940|941|942|943|944|945|946|947|948|949|956|957' .And. FindFunction("J265LpFlag") // LANCAMENTOS DO SIGAPFS
				cCpoFlag := J265LpFlag(CV3->CV3_LP)
				xInFlag  := CTOD("")
			EndIf

			If (cAliasOrig)->(FieldPos(cCpoFlag) <= 0)
				cCpoFlag := PrefixoCpo(cAliasOrig) + "_DTLANC"
				xInFlag  := CTOD("")							/// CONTEUDO PARA LIMPAR O FLAG DE CONTABILIZACAO

				If (cAliasOrig)->(FieldPos(cCpoFlag) <= 0)
					cCpoFlag := PrefixoCpo(cAliasOrig) + "_DCONTAB"
					xInFlag  := CTOD("")							/// CONTEUDO PARA LIMPAR O FLAG DE CONTABILIZACAO

					/// VERIFICA REGISTROS DA SF1, POIS A FLAG CONTมBIL ESTม SOMENTE NO CABEวALHO
					If cAliasOrig == "SD1"

						//----------------------------------------------------------------
						// Tratamento para limpeza do campo D1_CTAREC - EFD Contribui็๕es
						//----------------------------------------------------------------
						If SD1->(ColumnPos("D1_CTAREC")) > 0 .And. !Empty(SD1->D1_CTAREC)
							SD1->(RecLock(cAliasOrig,.F.))
							SD1->D1_CTAREC := CriaVar("D1_CTAREC",.F.)
							SD1->(MSUnlock())
						EndIf

						cCpoFlag := "F1_DTLANC"
						xInFlag  := CtoD("")
						aAreaSFX := SF1->( GetArea() )
						dbSelectArea( "SF1" )
						SF1->( dbSetOrder( 1 ) )
						SF1->( MsSeek( xFilial( "SF1" , cFilOriLnc ) + SD1->( D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA + D1_TIPO ) ) )
					/// VERIFICA REGISTROS DA SF2, POIS A FLAG CONTมBIL ESTม SOMENTE NO CABEวALHO
					ElseIf cAliasOrig == "SD2"
					
						//----------------------------------------------------------------
						// Tratamento para limpeza do campo D2_CTAREC - EFD Contribui็๕es
						//----------------------------------------------------------------
						If SD2->(ColumnPos("D2_CTAREC")) > 0 .And. !Empty(SD2->D2_CTAREC)
							SD2->(RecLock(cAliasOrig,.F.))
							SD2->D2_CTAREC := CriaVar("D2_CTAREC",.F.)
							SD2->(MSUnlock())
						EndIf

						cCpoFlag := "F2_DTLANC"
						xInFlag  := CtoD("")
						aAreaSFX := SF2->( GetArea() )
						dbSelectArea( "SF2" )
						SF2->( dbSetOrder( 1 ) )
						SF2->( MsSeek( xFilial( "SF2" , cFilOriLnc ) + SD2->( D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA + D2_FORMUL + D2_TIPO ) ) )
					ElseIf (cAliasOrig)->(FieldPos(cCpoFlag) <= 0)
						CV3->(dbSkip())								/// PROXIMO REGISTRO SEM ATUALIZA cTabAtu (DEVE VERIfICAR PROX. REG.)
						Loop
					EndIf
				EndIf
			EndIf
		EndIf

		If Empty( cCpoFlag ) .Or. xInFlag == Nil
			If __lConOutR
				ConoutR( 'Erro na limpeza dos Flags de contabiliza็ใo. Origem: ' + cAliasOrig + " - Registro: " + Alltrim( Str( nRecOrigem ) ) )
			EndIf
		EndIf
		cTabAtu := cAliasOrig
	EndIf

	If !Empty(&(cCpoFlag))

		If cAliasOrig == "SD1"
			cAliasOrig := "SF1"
		ElseIf cAliasOrig == "SD2"
			cAliasOrig := "SF2"
		EndIf

		cNoDia  := PrefixoCpo(cAliasOrig) + "_NODIA"
		cDiaCTB := PrefixoCpo(cAliasOrig) + "_DIACTB"

		RecLock(cAliasOrig,.F.)							/// LIMPA O FLAG DE CONTABILIZACAO NA ORIGEM
		&(cCpoFlag) := xInFlag

		If (cAliasOrig)->(FieldPos(cNoDia) > 0)
			&(cNoDia) := ""
		EndIf

		If (cAliasOrig)->(FieldPos(cDiaCTB) > 0)
			&(cDiaCTB) := ""
		EndIf

		If cAliasOrig == "CNW" // Altera Flag da Apropriacao feita pelo GCT para permitir novo reprocessamento da Apropriacao Contabil
			cFLGAPR := PrefixoCpo(cAliasOrig) + "_FLGAPR"
			&(cFLGAPR) := "2"
		EndIf

		(cAliasOrig)->(MsUnlock())
		If lCtbGrvUsu
			ExecBlock("CtbGrvUsu",.F.,.F.,alias())
		EndIf

		If cAliasOrig == "SF1"
			cKeySF3 := SF1->F1_SERIE + SF1->F1_DOC + SF1->F1_FORNECE + SF1->F1_LOJA
		ElseIf cAliasOrig == "SF2"
			cKeySF3 := SF2->F2_SERIE + SF2->F2_DOC + SF2->F2_CLIENTE + SF2->F2_LOJA
		EndIf
		
		If FindFunction("CTBDeleSF3")
			If Empty(xInFlag)
		  		CTBDeleSF3(cKeySF3,xInFlag)   //  Fun็ใo para limpar FLAG da tabela SF3 ( F3_DTLANC )
			EndIF   
		EndIf

        if lMV_PLSATIV
            plGrvUsu(CV3->CV3_LP)
        endIf    

    EndIf
	__cArqFlags := TRBFlags("0")				// REMARCAวรO DO RASTREAMENTO OK
	If FindFunction("ClearFlagE5")
		ClearFlagE5(cAliasOrig)	
	Else

		// Limpa flags da tabelas nos cadastros de multiplas natureza (Rateio FIN)
		If cAliasOrig $ "SEZ|SEV|SE1|SE2|SE5"
			CTBApLTMP(cAliasOrig)						
		EndIf

		/// VERIFICA REGISTROS DO SE5 RELACIONADOS A BAIXA DE TITULOS (JUROS/MULTA/DESCONTO)
		If (cAliasOrig $ "SE5|SEZ" .and. !Empty(SE5->E5_NUMERO)) .OR.  ( cAliasOrig == "SE1" .AND. Alltrim(SE1->E1_TIPO) == 'RA')

			cKeySE5 := SE5->(E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DTOS(E5_DATA)+E5_CLIFOR+E5_LOJA+E5_SEQ)
					
			FK1->(dbSetOrder(1)) //FK1_FILIAL, FK1_IDFK1, R_E_C_N_O_, D_E_L_E_T_
			FK2->(dbSetOrder(1)) //FK2_FILIAL, FK2_IDFK2, R_E_C_N_O_, D_E_L_E_T_
			FKA->(dbSetOrder(3)) //FKA_FILIAL, FKA_TABORI, FKA_IDORIG, R_E_C_N_O_, D_E_L_E_T_
			FK5->(dbSetOrder(1)) //FK5_FILIAL, FK5_IDMOV, R_E_C_D_E_L_
			SE5->(dbSetOrder(7)) //E5_FILIAL, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, E5_CLIFOR, E5_LOJA, E5_SEQ, R_E_C_N_O_, D_E_L_E_T_
			if SE5->(MsSeek(cKeySE5,.T.))

				While SE5->(!Eof()) .and.cKeySE5 == SE5->(E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DTOS(E5_DATA)+E5_CLIFOR+E5_LOJA+E5_SEQ)

					lLimpaFlag := !Empty(SE5->E5_LA)

					If lLimpaFlag
						If (CV3->CV3_LP == '531') .And. (SE5->(RecNo()) != Int(Val(CV3->CV3_RECORI)))
							lLimpaFlag := .F.
						EndIf
					EndIf

					If lLimpaFlag

						//Baixas a Receber
						If SE5->E5_TABORI = 'FK1'
							If FK1->(dbseek(SE5->E5_FILIAL+SE5->E5_IDORIG))	
								If FK1->FK1_LA == "S"
									FK1->(RecLock("FK1",.F.))
									FK1->FK1_LA := ""
									FK1->(MsUnlock())
								EndIf
							Endif	
						//Baixas a Pagar
						ElseIf SE5->E5_TABORI = 'FK2'
							If FK2->(dbseek(SE5->E5_FILIAL+SE5->E5_IDORIG))
								If FK2->FK2_LA == "S"	
									FK2->(RecLock("FK2",.F.))
									FK2->FK2_LA := ""
									FK2->(MsUnlock())
								EndIf
							Endif
						//Movimenta็ใo bancaria.
						ElseIf SE5->E5_TABORI = 'FK5'
							//Posiciona a FKA com base no IDORIG da SE5 posicionada
							If FKA->(dbseek(SE5->E5_FILIAL+"FK5"+SE5->E5_IDORIG))	
								cIdOrig := FKA->FKA_IDORIG
							Endif

							If !Empty(cIdOrig) 
								If FK5->(dbseek(SE5->E5_FILIAL+cIdOrig))
									If FK5->FK5_LA == "S"	
										FK5->(RecLock("FK5",.F.))
										FK5->FK5_LA := ""
										FK5->(MsUnlock())
									EndIf
								Endif
							EndIf	
						EndIf
						//Atualiza a flag da SE5
						Reclock("SE5")
							REPLACE E5_LA With ''
						MsUnlock()

					EndIf

					CTBApLTMP(cAliasOrig)			// Limpa flags da tabelas nos cadastros de multiplas natureza (Rateio FIN)
				
					cIdOrig := cTamIdORI

					SE5->(dbSkip())
				EndDo
			EndIf
		EndIf	
	EndIf

	If !Empty( aAreaSFX )
		RestArea( aAreaSFX )
		aSize(aAreaSFX,0)
		aAreaSFX := nil 
	EndIf

	CV3->(dbSkip())
EndDo

RestArea(aAreaCT2)
RestArea(aAreaOri)
aSize(aAreaCT2,0)
aAreaCT2 := nil 
aSize(aAreaOri,0)
aAreaOri := nil 
Return cRetorno
//-------------------------------------------------------------------------
/*/{Protheus.doc} CTBApLTMP

Apaga flag de contabilizacao nos movimentos com Rateio de 
Multiplas Naturezas ou Multiplas Naturezas por C.Custo 

Essa fun็ใo ้ uma duplica็ใo da fun็ใo CTBAPLAMN, pois quando foi movida para o FINXCTB.PRW, em alguns casos,
estava exibindo falta da fun็ใo. 
. 
@author Marcos S. Lobo
@since  01/28/06
@version 12
/*/
//-------------------------------------------------------------------------  

Function CTBApLTMP(cAliasPos)

	Local aAreaOri		:= GetArea()
	Local aAreaMN
	Local cFilSEV		:= xFilial("SEV")
	Local cFilSEZ		:= xFilial("SEZ")
	Local cAliasORI 	:= ""
	Local cTamIdORI 	:= Space(TAMSX3("FKA_IDORIG")[1])
	Local cTamIdPRO		:= Space(TAMSX3("FKA_IDPROC")[1])
	Local cIdOrig 		:= cTamIdORI 
	Local cIdProc		:= cTamIdPRO 
	Local cChaveSev 	:= ""
	Local cChaveSez 	:= ""
	Local lSEVLimpaFlag := .F.

	DEFAULT cAliasPos := ""

	cAliasORI := cAliasPos

	If !Empty(cAliasPos)
		aAreaMN := (cAliasPos)->(GetArea())
	EndIf

	If cAliasPos == "SEZ"			/// SE RASTREAMENTO ESTIVER PELO SEZ LOCALIZA O TอTULO DE ORIGEM
		If SEZ->EZ_RECPAG == "R"	/// SE FOR REGISTRO DO CONTAS A RECEBER
			If SEZ->EZ_IDENT == "1" /// OPERACAO INCLUSAO
				dbSelectArea("SE1")
				dbSetorder(2)
				If MsSeek(xFilial("SE1")+SEZ->(EZ_CLIfOR+EZ_LOJA+EZ_PREFIXO+EZ_NUM+EZ_PARCELA+EZ_TIPO),.F.)
					If !Empty(SE1->E1_LA)
						RecLock("SE1",.F.)
						E1_LA := ""
						SE1->(MsUnlock())
					EndIf
					cAliasPos := "SE1"	/// REMARCA TODOS REGISTROS DE MULT.NATUREZA RELACIONADOS AO TอTULO
				EndIf

			ElseIf SEZ->EZ_IDENT == "2"	/// OPERACAO DE BAIXA
				dbSelectArea("SE5")
				dbSetorder(7)
				cChaveE5 := xFilial("SE5")+SEZ->(EZ_PREFIXO+EZ_NUM+EZ_PARCELA+EZ_TIPO+EZ_CLIfOR+EZ_LOJA)
				If !Empty(SEZ->EZ_SEQ)
					cChaveE5+=SEZ->EZ_SEQ
				EndIf
				
				SE5->(MsSeek(cChaveE5,.F.))	/// FALTA RECPAG NA CHAVE SE5 (P/ NAO MISTURAR BX CP. E CR.)
				While cChaveE5 $ SE5->&(INDEXKEY()) .AND. SEZ->EZ_SITUACA == 'E' .AND. SE5->E5_TIPODOC <> 'ES'
					SE5->(DBSKIP())
				EndDo
				
				If SE5->(!EOF()) .AND. cChaveE5 $ SE5->&(INDEXKEY())

					If !Empty(SE5->E5_LA)
						RecLock("SE5",.F.)
						E5_LA := ""
						SE5->(MsUnlock())
					EndIf

					//Posiciona a FK1 com base no IDORIG da SE5 posicionada
					FK1->(dbSelectArea("FK1"))							
					FK1->(dbSetOrder(1))
					If FK1->(dbseek(SE5->E5_FILIAL+SE5->E5_IDORIG))
						If FK1->FK1_LA == "S"	
							FK1->(RecLock("FK1",.F.))
							FK1->FK1_LA := ""
							FK1->(MsUnlock())
						EndIf
					Endif	

					//Posiciona a FKA com base no IDORIG da SE5 posicionada
					FKA->(dbSelectArea("FKA"))							
					FKA->(dbSetOrder(3))
					If FKA->(dbseek(SE5->E5_FILIAL+"FK1"+SE5->E5_IDORIG))	
						cIdProc := FKA->FKA_IDPROC
					Endif	
					
					FKA->(dbSetOrder(2))
					If FKA->(dbseek(FKA->FKA_FILIAL+cIdProc))

						While !EOF() .AND. FKA->FKA_IDPROC == cIdProc

							If FKA->FKA_TABORI == "FK5"
								cIdOrig := FKA->FKA_IDORIG
							Endif
							FKA->(dbskip())

						Enddo 
					
					EndIf

						//Posiciona a FK5 com base no IDORIG da FKA posicionada
					If !Empty(cIdOrig) 
						FK5->(dbSelectArea("FK5"))							
						FK5->(dbSetOrder(1))
						If FK5->(dbseek(SE5->E5_FILIAL+cIdOrig))
							If FK5->FK5_LA == "S"		
								FK5->(RecLock("FK5",.F.))
								FK5->FK5_LA := ""
								FK5->(MsUnlock())
							EndIf
						Endif
					Endif	

					cAliasPos := "SE5"	/// REMARCA TODOS REGISTROS DE MULT.NATUREZA RELACIONADOS AO TอTULO
					cIdOrig := cTamIdORI 
					cIdProc	:= cTamIdPRO
				EndIf

			EndIf
		Else
			If SEZ->EZ_IDENT == "1" /// OPERACAO INCLUSAO
				dbSelectArea("SE2")
				dbSetorder(1)
				If MsSeek(xFilial("SE2")+SEZ->(EZ_PREFIXO+EZ_NUM+EZ_PARCELA+EZ_TIPO+EZ_CLIfOR+EZ_LOJA),.F.)
					RecLock("SE2",.F.)
					E2_LA := ""
					SE2->(MsUnlock())
					cAliasPos := "SE2"	/// REMARCA TODOS REGISTROS DE MULT.NATUREZA RELACIONADOS AO TอTULO
				EndIf

			ElseIf SEZ->EZ_IDENT == "2"	/// OPERACAO DE BAIXA
				dbSelectArea("SE5")
				dbSetorder(7)
				cChaveE5 := xFilial("SE5")+SEZ->(EZ_PREFIXO+EZ_NUM+EZ_PARCELA+EZ_TIPO+EZ_CLIfOR+EZ_LOJA)
				If !Empty(SEZ->EZ_SEQ)
					cChaveE5+=SEZ->EZ_SEQ
				EndIf

				SE5->(MsSeek(cChaveE5,.F.))	/// FALTA RECPAG NA CHAVE SE5 (P/ NAO MISTURAR BX CP. E CR.)
				While cChaveE5 $ SE5->&(INDEXKEY()) .AND. SEZ->EZ_SITUACA == 'E' .AND. SE5->E5_TIPODOC <> 'ES'
					SE5->(DBSKIP())
				EndDo
				
				If SE5->(!EOF()) .AND. cChaveE5 $ SE5->&(INDEXKEY())

					If !Empty(SE5->E5_LA)
						RecLock("SE5",.F.)
						E5_LA := ""
						SE5->(MsUnlock())
					EndIf

					//Posiciona a FK2 com base no IDORIG da SE5 posicionada
					FK2->(dbSelectArea("FK2"))							
					FK2->(dbSetOrder(1))
					If FK2->(dbseek(SE5->E5_FILIAL+SE5->E5_IDORIG))
						If FK2->FK2_LA == "S"	
							FK2->(RecLock("FK2",.F.))
							FK2->FK2_LA := ""
							FK2->(MsUnlock())
						EndIf
					Endif	

					//Posiciona a FKA com base no IDORIG da SE5 posicionada
					FKA->(dbSelectArea("FKA"))							
					FKA->(dbSetOrder(3))
					If FKA->(dbseek(SE5->E5_FILIAL+"FK2"+SE5->E5_IDORIG))	
						cIdProc := FKA->FKA_IDPROC
					Endif	
					
					FKA->(dbSetOrder(2))
					If FKA->(dbseek(FKA->FKA_FILIAL+cIdProc))

						While !EOF() .AND. FKA->FKA_IDPROC == cIdProc

							If FKA->FKA_TABORI == "FK5"
								cIdOrig := FKA->FKA_IDORIG
							Endif
							FKA->(dbskip())

						Enddo 

					EndIf

					//Posiciona a FK5 com base no IDORIG da FKA posicionada
					If !Empty(cIdOrig) 
						FK5->(dbSelectArea("FK5"))							
						FK5->(dbSetOrder(1))
						If FK5->(dbseek(SE5->E5_FILIAL+cIdOrig))
							If FK5->FK5_LA == "S"		
								FK5->(RecLock("FK5",.F.))
								FK5->FK5_LA := ""
								FK5->(MsUnlock())
							EndIf
						Endif
					Endif	

					cAliasPos := "SE5"	/// REMARCA TODOS REGISTROS DE MULT.NATUREZA RELACIONADOS AO TอTULO
					cIdOrig := cTamIdORI 
					cIdProc	:= cTamIdPRO
				EndIf

			EndIf
		EndIf
	ElseIf cAliasPos == "SEV"			/// SE RASTREAMENTO ESTIVER PELO SEV LOCALIZA O TอTULO DE ORIGEM
		If SEV->EV_RECPAG == "R"	/// SE FOR REGISTRO DO CONTAS A RECEBER
			If SEV->EV_IDENT == "1" /// OPERACAO INCLUSAO
				dbSelectArea("SE1")
				dbSetorder(2)
				If MsSeek(xFilial("SE1")+SEV->(EV_CLIfOR+EV_LOJA+EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO),.F.)
					RecLock("SE1",.F.)
					E1_LA := ""
					SE1->(MsUnlock())
					cAliasPos := "SE1"	/// REMARCA TODOS REGISTROS DE MULT.NATUREZA RELACIONADOS AO TอTULO
				EndIf

			ElseIf SEV->EV_IDENT == "2"	/// OPERACAO DE BAIXA
				dbSelectArea("SE5")
				dbSetorder(7)
				cChaveE5 := xFilial("SE5")+SEV->(EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIfOR+EV_LOJA)
				If !Empty(SEV->EV_SEQ)
					cChaveE5+=SEV->EV_SEQ
				EndIf

				SE5->(MsSeek(cChaveE5,.F.))	/// FALTA RECPAG NA CHAVE SE5 (P/ NAO MISTURAR BX CP. E CR.)
				While cChaveE5 $ SE5->&(INDEXKEY()) .AND. SEV->EV_SITUACA == 'E' .AND. SE5->E5_TIPODOC <> 'ES'
					SE5->(DBSKIP())
				EndDo
				
				If SE5->(!EOF()) .AND. cChaveE5 $ SE5->&(INDEXKEY())

					If !Empty(SE5->E5_LA)
						RecLock("SE5",.F.)
						E5_LA := ""
						SE5->(MsUnlock())
					EndIf

					//Posiciona a FK1 com base no IDORIG da SE5 posicionada
					FK1->(dbSelectArea("FK1"))							
					FK1->(dbSetOrder(1))
					If FK1->(dbseek(SE5->E5_FILIAL+SE5->E5_IDORIG))
						If FK1->FK1_LA == "S"		
							FK1->(RecLock("FK1",.F.))
							FK1->FK1_LA := ""
							FK1->(MsUnlock())
						EndIf
					Endif	

					//Posiciona a FKA com base no IDORIG da SE5 posicionada
					FKA->(dbSelectArea("FKA"))							
					FKA->(dbSetOrder(3))
					If FKA->(dbseek(SE5->E5_FILIAL+"FK1"+SE5->E5_IDORIG))	
						cIdProc := FKA->FKA_IDPROC
					Endif	
					
					FKA->(dbSetOrder(2))
					If FKA->(dbseek(FKA->FKA_FILIAL+cIdProc))

						While !EOF() .AND. FKA->FKA_IDPROC == cIdProc

							If FKA->FKA_TABORI == "FK5"
								cIdOrig := FKA->FKA_IDORIG
							EndIf
							FKA->(dbskip())

						Enddo 	

					EndIf

					//Posiciona a FK5 com base no IDORIG da FKA posicionada

					If !Empty(cIdOrig) 
						FK5->(dbSelectArea("FK5"))							
						FK5->(dbSetOrder(1))
						If FK5->(dbseek(SE5->E5_FILIAL+cIdOrig))
							If FK5->FK5_LA == "S"		
								FK5->(RecLock("FK5",.F.))
								FK5->FK5_LA := ""
								FK5->(MsUnlock())
							EndIf
						EndIf
					EndIf	

					cAliasPos := "SE5"	/// REMARCA TODOS REGISTROS DE MULT.NATUREZA RELACIONADOS AO TอTULO
					cIdOrig := cTamIdORI 
					cIdProc	:= cTamIdPRO
				EndIf

			EndIf
		Else
			If SEV->EV_IDENT == "1" /// OPERACAO INCLUSAO
				dbSelectArea("SE2")
				dbSetorder(1)
				If MsSeek(xFilial("SE2")+SEV->(EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIfOR+EV_LOJA),.F.)
					RecLock("SE2",.F.)
					E2_LA := ""
					SE2->(MsUnlock())
					cAliasPos := "SE2"	/// REMARCA TODOS REGISTROS DE MULT.NATUREZA RELACIONADOS AO TอTULO
				EndIf

			ElseIf SEV->EV_IDENT == "2"	/// OPERACAO DE BAIXA
				dbSelectArea("SE5")
				dbSetorder(7)
				cChaveE5 := xFilial("SE5")+SEV->(EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIfOR+EV_LOJA)
				If !Empty(SEV->EV_SEQ)
					cChaveE5+=SEV->EV_SEQ
				EndIf

				SE5->(MsSeek(cChaveE5,.F.))	/// FALTA RECPAG NA CHAVE SE5 (P/ NAO MISTURAR BX CP. E CR.)
				While cChaveE5 $ SE5->&(INDEXKEY()) .AND. SEV->EV_SITUACA == 'E' .AND. SE5->E5_TIPODOC <> 'ES'
					SE5->(DBSKIP())
				EndDo
				
				If SE5->(!EOF()) .AND. cChaveE5 $ SE5->&(INDEXKEY())

					If !Empty(SE5->E5_LA)
						RecLock("SE5",.F.)
						E5_LA := ""
						SE5->(MsUnlock())
					EndIf

					//Posiciona a FK2 com base no IDORIG da SE5 posicionada
					FK2->(dbSelectArea("FK2"))							
					FK2->(dbSetOrder(1))
					If FK2->(dbseek(SE5->E5_FILIAL+SE5->E5_IDORIG))
						If FK2->FK2_LA == "S"	
							FK2->(RecLock("FK2",.F.))
							FK2->FK2_LA := ""
							FK2->(MsUnlock())
						EndIf
					Endif	

					//Posiciona a FKA com base no IDORIG da SE5 posicionada
					FKA->(dbSelectArea("FKA"))							
					FKA->(dbSetOrder(3))
					If FKA->(dbseek(SE5->E5_FILIAL+"FK2"+SE5->E5_IDORIG))	
						cIdProc := FKA->FKA_IDPROC
					Endif	
					
					FKA->(dbSetOrder(2))
					If FKA->(dbseek(FKA->FKA_FILIAL+cIdProc))

						While !EOF() .AND. FKA->FKA_IDPROC == cIdProc

							If FKA->FKA_TABORI == "FK5"
								cIdOrig := FKA->FKA_IDORIG
							Endif
							FKA->(dbskip())

						Enddo

					EndIF
					
					//Posiciona a FK5 com base no IDORIG da FKA posicionada
					If !Empty(cIdOrig) 
						FK5->(dbSelectArea("FK5"))							
						FK5->(dbSetOrder(1))
						If FK5->(dbseek(SE5->E5_FILIAL+cIdOrig))
							If FK5->FK5_LA == "S"		
								FK5->(RecLock("FK5",.F.))
								FK5->FK5_LA := ""
								FK5->(MsUnlock())
							EndIf
						Endif
					EndIf	

					cAliasPos := "SE5"	/// REMARCA TODOS REGISTROS DE MULT.NATUREZA RELACIONADOS AO TอTULO
					cIdOrig := cTamIdORI 
					cIdProc	:= cTamIdPRO
				EndIf		                                                                                   // |
			EndIf                                                                                              // |
		EndIf                                                                                                  // |
	EndIf		/// If DE MULTIPLA NATUREZA ESTA NA MESMA LINHA (CASO HABILITAR REMARCAวรO DE TODOS SEV E SEZ)----|

	
	If cAliasPos == "SE1"				/// Rateio no Contas a Receber
	
		cChaveSev := RetChaveSev("SE1")
		cChaveSez := RetChaveSev("SE1",,"SEZ")

		DbSelectArea("SEV")
		// Se utiliza multiplas naturezas, contabiliza pelo SEV
		If SE1->E1_MULTNAT=="1" .And. SEV->(MsSeek(cChaveSev))
			DbSelectArea("SEV")
			dbSetOrder(2)
			While SEV->(!Eof()) .and.;
				cFilSEV+SEV->(EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIfOR+EV_LOJA+EV_IDENT) == ;
				cChaveSev+"1"

				lSEVLimpaFlag := .F.
				If aAreaOri[1] == 'SEZ' .AND. SEV->EV_RATEICC == "1" // Rateou multinat por c.custo

					dbSelectArea("SEZ")
					dbSetOrder(4)
					MsSeek(cChaveSeZ+SEV->EV_NATUREZ) // Posiciona no arquivo de Rateio C.Custo da MultiNat

					While SEZ->(!Eof()) .and.;
						cFilSEZ+SEZ->(EZ_PREFIXO+EZ_NUM+EZ_PARCELA+EZ_TIPO+EZ_CLIfOR+EZ_LOJA+EZ_NATUREZ+EZ_IDENT);
						== cChaveSeZ+SEV->EV_NATUREZ+"1"

						If SEZ->(RECNO() <> aAreaOri[3])
							SEZ->(DBSKIP())
							Loop
						EndIF

						lSEVLimpaFlag := .T.
						If !Empty(SEZ->EZ_LA)
							RecLock("SEZ")
							SEZ->EZ_LA := ""
							SEZ->(MsUnlock())
						EndIf

						dbSkip()
					Enddo

					DbSelectArea("SEV")

				EndIf

				If (aAreaOri[1] == 'SEV' .and. aAreaOri[3] == SEV->(RECNO()) .OR.;
					aAreaOri[1] == 'SEZ' .and. lSEVLimpaFlag) .AND.;
					!Empty(SEV->EV_LA)
					RecLock("SEV")
					SEV->EV_LA := ""
					SEV->(MsUnlock())
				EndIf

				DbSelectArea("SEV")
				DbSkip()
			Enddo
		EndIf
	
	ElseIf cAliasPos == "SE2"			/// Rateio no Contas a Pagar
	
		If SE2->E2_RATEIO != "S"
			cChaveSev := RetChaveSev("SE2")
			cChaveSeZ := RetChaveSev("SE2",,"SEZ")
			DbSelectArea("SEV")
			// Se utiliza multiplas naturezas, contabiliza pelo SEV
			If SE2->E2_MULTNAT == "1" .And. MsSeek(cChaveSev)
				DbSelectArea("SEV")
				dbSetOrder(2)
				While SEV->(!Eof()) .and.;
						cFilSEV+SEV->(EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIfOR+EV_LOJA+EV_IDENT);
						== cChaveSev+"1"

					lSEVLimpaFlag := .F.
					If aAreaOri[1] == 'SEZ' .AND. SEV->EV_RATEICC == "1" // Rateou multinat por c.custo

						dbSelectArea("SEZ")
						dbSetOrder(4)
						MsSeek(cChaveSeZ+SEV->EV_NATUREZ) // Posiciona no arquivo de Rateio C.Custo da MultiNat

						While SEZ->(!Eof()) .and.;
							cFilSEZ+SEZ->(EZ_PREFIXO+EZ_NUM+EZ_PARCELA+EZ_TIPO+EZ_CLIfOR+EZ_LOJA+EZ_NATUREZ+EZ_IDENT);
							== cChaveSeZ+SEV->EV_NATUREZ+"1"

							If SEZ->(RECNO() <> aAreaOri[3])
								SEZ->(DBSKIP())
								Loop
							EndIF

							lSEVLimpaFlag := .T.
							If !Empty(SEZ->EZ_LA)
								RecLock("SEZ")
								SEZ->EZ_LA := ""
								SEZ->(MsUnlock())
							EndIf
							dbSkip()
						Enddo
					EndIf

					If (aAreaOri[1] == 'SEV' .and. aAreaOri[3] == SEV->(RECNO()) .OR.;
						aAreaOri[1] == 'SEZ' .and. lSEVLimpaFlag) .AND.;
						!Empty(SEV->EV_LA)
						RecLock("SEV")
						SEV->EV_LA := ""
						SEV->(MsUnlock())
					EndIf

					dbSelectArea("SEV")
					DbSkip()
				Enddo
			EndIf
		EndIf
	
	ElseIf cAliasPos == "SE5"			/// Rateio nas Baixas e Mov.Bancario
	
		If SE5->E5_MULTNAT == "1"

			cSeqSE5	:= SE5->E5_SEQ

			/////////////////////////////////////////////////////////////////////////////////////////////
			If SE5->E5_RECPAG == "R" 		/// Movimentos de Baixas e Mov. Bancario Receber
			/////////////////////////////////////////////////////////////////////////////////////////////
				lAdiant 	:= .f.
				lEstorno 	:= .F.
				lEstRaNcc 	:= .F.
				lCompens 	:= .F.

				If SE5->E5_TIPODOC == "ES"
					lEstorno := .T.
				EndIf
				If SE5->E5_TIPODOC == "ES" .and. SE5->E5_TIPO $ MVRECANT+"/"+MV_CRNEG
					lEstRaNcc := .T.
				EndIf
				If SE5->E5_TIPO $ MVPAGANT+"/"+MV_CPNEG
					lAdiant := .T.
				EndIf
				If  SE5->E5_TIPODOC == "BA" .and. SE5->E5_MOTBX == "CMP"
					lCompens := .T.
				EndIf

				If (lAdiant .or. lEstorno) .and. !lEstRaNcc
					dbSelectArea("SE2")
					dbSetOrder(1)
					MsSeek(xFilial("SE2")+SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIfOR+E5_LOJA),.T.)
				Else
					dbSelectArea( "SE1" )
					dbSetOrder(2)
					cFilorig := xFilial("SE1")
					If lCompens
						If !Empty(xFilial("SE5"))
							If !Empty(SE5->E5_FILORIG)
								cFilOrig := SE5->E5_FILORIG
							EndIf
						EndIf
					EndIf

					MsSeek(cFilOrig+SE5->(E5_CLIfOR+E5_LOJA+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO),.T.)
				EndIf

				If Found()
					If lEstorno
						cChaveSev := RetChaveSev("SE2")+"2"+cSeqSE5
						cChaveSez := RetChaveSev("SE2",,"SEZ")
					Else
						cChaveSev := RetChaveSev("SE1")+"2"+cSeqSE5
						cChaveSez := RetChaveSev("SE1",,"SEZ")
					EndIf

					DbSelectArea("SEV")
					dbSetOrder(2)
					// Se utiliza multiplas naturezas, contabiliza pelo SEV
					If MsSeek(cChaveSev)

						DbSelectArea("SEV")
						While SEV->(!Eof()) .and.;
							cFilSEV+SEV->(EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIfOR+EV_LOJA+EV_IDENT+EV_SEQ);
							== cChaveSev

							//Se estou contabilizando um estorno, trata-se de um C. Pagar,
							//So contabiliza EV_SITUACA == E
							If (lEstorno .and. !(SEV->EV_SITUACA == "E")) .or. ;
								(!lEstorno .and. (SEV->EV_SITUACA == "E"))
								//Se nao for um estorno, nao devo contabilizar o registro se
								//EV_SITUACA == E
								dbSkip()
								Loop
							EndIf

							lSEVLimpaFlag := .F.
							If aAreaOri[1] == 'SEZ' .AND. SEV->EV_RATEICC == "1" // Rateou multinat por c.custo

								dbSelectArea("SEZ")
								dbSetOrder(4)
								MsSeek(cChaveSeZ+SEV->EV_NATUREZ+"2"+cSeqSE5) // Posiciona no arquivo de Rateio C.Custo da MultiNat

								While SEZ->(!Eof()) .and.;
									cFilSEZ+SEZ->(EZ_PREFIXO+EZ_NUM+EZ_PARCELA+EZ_TIPO+EZ_CLIfOR+EZ_LOJA+EZ_NATUREZ+EZ_IDENT+EZ_SEQ);
									== cChaveSeZ+SEV->EV_NATUREZ+"2"+cSeqSE5

									//Se estou contabilizando um estorno, trata-se de um C. Pagar,
									//So vou contabilizar os EZ_SITUACA == E
									//Se nao for um estorno, nao devo contabilizar o registro se
									//EZ_SITUACA == E
									If (lEstorno .and. !(SEZ->EZ_SITUACA == "E")) .or. ;
										(!lEstorno .and. (SEZ->EZ_SITUACA == "E"))
										dbSkip()
										Loop
									EndIf

									If SEZ->(RECNO() <> aAreaOri[3])
										SEZ->(DBSKIP())
										Loop
									EndIF

									lSEVLimpaFlag := .T.
									If !Empty(SEZ->EZ_LA)
										RecLock("SEZ")
										SEZ->EZ_LA    := ""
										MsUnlock( )
									EndIf

									dbSkip()
								Enddo
							EndIf			/// Se Rateou Mult.Natur x C.Custo

							DbSelectArea("SEV")
							If (aAreaOri[1] == 'SEV' .and. aAreaOri[3] == SEV->(RECNO()) .OR.;
								aAreaOri[1] == 'SEZ' .and. lSEVLimpaFlag) .AND.;
								!Empty(SEV->EV_LA)

								RecLock("SEV")
								SEV->EV_LA := ""
								MsUnlock( )
							EndIf

							DbSelectArea("SEV")
							DbSkip()
						Enddo
					EndIf		/// Encontrou no SEV
				EndIf

			/////////////////////////////////////////////////////////////////////////////////////////////
			ElseIf SE5->E5_RECPAG == "P" 	/// Movimentos de Baixas e Mov. Bancario Pagar
			/////////////////////////////////////////////////////////////////////////////////////////////
				lAdiant 	:= .F.
				lEstorno 	:= .F.
				lEstPaNdf 	:= .F.
				lEstCart2 	:= .F.
				lCompens  	:= .F.

				If SE5->E5_TIPODOC == "ES"
					lEstorno := .T.
				EndIf

				If SE5->E5_TIPODOC == "E2"
					lEstCart2 := .T.
				EndIf

				If SE5->E5_TIPO $ MVPAGANT+"/"+MV_CPNEG .and. SE5->E5_TIPODOC == "ES"
					lEstPaNdf := .T.
				EndIf

				If SE5->E5_TIPO $ MVRECANT+"/"+MV_CRNEG
					lAdiant := .T.
				EndIf

				If SE5->E5_TIPODOC == "BA" .and. SE5->E5_MOTBX == "CMP"
					lCompens := .T.
				EndIf


				If (lAdiant .or. lEstorno .or. lEstCart2) .and. !lEstPaNdf
					dbSelectArea("SE1")
					dbSetOrder(2)
					MsSeek(xFilial("SE1")+SE5->(E5_CLIfOR+E5_LOJA+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO),.T.)
				Else
					dbSelectArea( "SE2" )
					dbSetOrder(1)
					cFilorig := xFilial("SE2")
					If lCompens
						If !Empty(xFilial("SE5"))
							If !Empty(SE5->E5_FILORIG)
								cFilOrig := SE5->E5_FILORIG
							EndIf
						EndIf
					EndIf

					MsSeek( cFilOrig +SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIfOR+E5_LOJA),.T.)
				EndIf

				If Found()

					//Contabilizando estorno de C.Receber
					If lEstorno
						cChaveSev := RetChaveSev("SE1")+"2"+cSeqSE5
						cChaveSez := RetChaveSev("SE1",,"SEZ")
					Else
						cChaveSev := RetChaveSev("SE2")+"2"+cSeqSE5
						cChaveSez := RetChaveSev("SE2",,"SEZ")
					EndIf

					DbSelectArea("SEV")
					dbSetOrder(2)
					If MsSeek(cChaveSev)

						DbSelectArea("SEV")
						While SEV->(!Eof()) .and.;
							cFilSEV+SEV->(EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIfOR+EV_LOJA+EV_IDENT+EV_SEQ);
							== cChaveSev

							//Se estou contabilizando um estorno, trata-se de um C. Pagar,
							//So vou contabilizar os EV_SITUACA == E
							//Se nao for um estorno, nao devo contabilizar o registro se
							//EV_SITUACA == E
							If (lEstorno .and. !(SEV->EV_SITUACA == "E")) .or. ;
								(!lEstorno .and. (SEV->EV_SITUACA == "E"))
								dbSkip()
								Loop
							EndIf

							dbSelectArea("SEV")

							lSEVLimpaFlag := .F.
							If aAreaOri[1] == 'SEZ' .AND. SEV->EV_RATEICC == "1"  // Rateou multinat por c.custo

								dbSelectArea("SEZ")
								dbSetOrder(4)
								MsSeek(cChaveSeZ+SEV->EV_NATUREZ+"2"+cSeqSE5) // Posiciona no arquivo de Rateio C.Custo da MultiNat

								While SEZ->(!Eof()) .and.;
									cFilSEZ+SEZ->(EZ_PREFIXO+EZ_NUM+EZ_PARCELA+EZ_TIPO+EZ_CLIfOR+EZ_LOJA+EZ_NATUREZ+EZ_IDENT+EZ_SEQ);
									== cChaveSeZ+SEV->EV_NATUREZ+"2"+cSeqSE5

									//Se estou contabilizando um estorno, trata-se de um C. Pagar,
									//So vou contabilizar os EZ_SITUACA == E
									//Se nao for um estorno, nao devo contabilizar o registro se
									//EZ_SITUACA == E
									If (lEstorno .and. !(SEZ->EZ_SITUACA == "E")) .or. ;
										(!lEstorno .and. (SEZ->EZ_SITUACA == "E"))
										dbSkip()
										Loop
									EndIf

									If SEZ->(RECNO() <> aAreaOri[3])
										SEZ->(DBSKIP())
										Loop
									EndIF

									lSEVLimpaFlag := .T.
									If !Empty(SEZ->EZ_LA)
										RecLock("SEZ")
										SEZ->EZ_LA    := ""
										MsUnlock( )
									EndIf

									dbSkip()
								Enddo

								DbSelectArea("SEV")
							EndIf

							If (aAreaOri[1] == 'SEV' .and. aAreaOri[3] == SEV->(RECNO()) .OR.;
								aAreaOri[1] == 'SEZ' .and. lSEVLimpaFlag) .AND.;
								!Empty(SEV->EV_LA)

								RecLock("SEV")
								SEV->EV_LA := ""
								MsUnlock()
							EndIf

							DbSelectArea("SEV")
							DbSkip()
						Enddo
					EndIf	/// Se achou SEV
				EndIf
			/////////////////////////////////////////////////////////////////////////////////////////////
			EndIf
			/////////////////////////////////////////////////////////////////////////////////////////////
		EndIf	/// Fecha If do E5_MULTNAT == '1'
	EndIf

	If !Empty(cAliasPos)
		RestArea(aAreaMN)
		aSize(aAreaMN,0)
		aAreaMN := nil 
	EndIf
	RestArea(aAreaOri)
	aSize(aAreaOri,0)
	aAreaOri := nil 
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTRBFlags  บAutor  ณMarcos S. Lobo      บ Data ณ  01/27/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAdiciona registro de LOG em arquivo .FLG por empresa, baseadบฑฑ
ฑฑบ          ณno CT2 e CV3 posicionados (cria .FLG se nใo existir)        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP - Rastreamento e Exclusใo de Lan็amentos de Integra็ใo  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TRBFlags(cTipoLog)
Local aAreaQL5	:= {}
Local aAreaTRB	:= GetArea()
Local cArqTRB	:= "LOGCTB"+cEmpAnt+".FLG"
Local cRecCT2	:= ''

DEFAULT cTipoLog := ""
	/* TIPOS DE REGISTRO NO LOG
	0 = Exclusao CT2 efetuada, remarcacao flags OK
	1 = INCONSISTENCIA - Tabela ou Registro de origem no CV3 em branco.
	2 = INCONSISTENCIA - Registro nใo encontrado na tabela de origem.
	3 = INCONSISTENCIA - Registro nใo encontrado na tabela CV3.
	4 = INCONSISTENCIA - Registro apagado CT2 sem remarcar flags na origem     (cancelado pelo usuแrio -> MV_CTCLEAN = 2)
	5 = INCONSISTENCIA - Registro apagado CT2 (LINHA) sem remarcar flags orig. (cancelado pelo usuแrio -> MV_CTCLEAN = 2)
	*/

	////Tratamento para relises < 12.1.17
	If TableInDic("QL5")
		aAreaQL5 := QL5->(getArea())
		QL5->(dbSetOrder(3)) //QL5_FILIAL+QL5_RCNCT2
		cRecCT2 := Padr(Alltrim(Str(CT2->(Recno()))),TamSX3('QL5_RCNCT2')[1])
		If QL5->(!dbSeek(FWxFilial("QL5")+cRecCT2))
			RecLock("QL5",.T.)
			QL5->QL5_FILIAL	:= FWxFilial("QL5")
			QL5->QL5_TIPORE	:= cTipoLog		/// "0"=Remarcado OK ,"1"=Inconsist. Tab/Rec.Origem,"2"=ั.encontrado origem
			QL5->QL5_USER	:= cUserName
			QL5->QL5_DTEXC	:= MsDate()
			QL5->QL5_HREXC	:= Time()
			QL5->QL5_RCNCT2	:= ALLTRIM(STR(INT(CT2->(Recno()))))
			QL5->QL5_VALOR	:= CT2->CT2_VALOR
			QL5->QL5_FLCT2	:= CT2->CT2_FILIAL
			QL5->QL5_DATA	:= CT2->CT2_DATA
			QL5->QL5_LOTE	:= CT2->CT2_LOTE
			QL5->QL5_SBLOTE	:= CT2->CT2_SBLOTE
			QL5->QL5_DOC	:= CT2->CT2_DOC
			QL5->QL5_MOEDLC	:= CT2->CT2_MOEDLC
			QL5->QL5_LINHA	:= CT2->CT2_LINHA
			If cTipoLog < "4"
				QL5->QL5_HIST	:= CT2->CT2_HIST
				QL5->QL5_RCNCV3	:= ALLTRIM(STR(INT(CV3->(Recno()))))
				QL5->QL5_TABORI	:= CV3->CV3_TABORI
				QL5->QL5_RECORI	:= CV3->CV3_RECORI
				QL5->QL5_VLR01	:= CV3->CV3_VLR01 //FIXADO MOEDA 01 (RASTREAMENTO ESTA BASEADO NA MOEDA 01- MESMO $ ZERADO)
				QL5->QL5_LP		:= CV3->CV3_LP
				QL5->QL5_LPSEQ	:= CV3->CV3_LPSEQ
			ElseIf cTipoLog >= "4"
				QL5->QL5_HIST	:= STR0040	//"Flags cancelados pelo usuario."
			EndIf
			QL5->(MsUnlock())
		EndIf
		QL5->(RestArea(aAreaQL5))
		aSize(aAreaQL5,0)
		aAreaQL5 := nil 
	EndIf

RestArea(aAreaTRB)
aSize(aAreaTRB,0)
aAreaTRB := nil 
Return cArqTRB

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณProgram   ณGravaCV8ณ Autor ณ Edson Maricate                 ณ Data ณ 31.01.06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณGrava tabela CV8 - logs de Processamento                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณGravaCV8(cType, cBatchProc, cMsg, cDetalhes, cSubProc, cMsgSubProc,ณฑฑ
ฑฑณ          ณlCabec,cIdCV8)                                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function GravaCV8(cType, cBatchProc, cMsg, cDetalhes, cSubProc, cMsgSubProc, lCabec, cIdCV8, cFilProc)

Default lCabec		:= Nil
Default cIdCV8		:= ""
Default cFilProc	:= cFilAnt

If (Valtype(lCabec) == "L" .And. lCabec ) .Or. Valtype(lCabec) == "U"
	dbSelectArea("CV8")
	RecLock("CV8",.T.)
	CV8->CV8_FILIAL	:= xFilial("CV8", cFilProc)
	CV8->CV8_DATA 	:= MsDate()
	CV8->CV8_HORA 	:= SubStr(Time(),1,TamSx3("CV8_HORA")[1])
	CV8->CV8_PROC	:= cBatchProc
	CV8->CV8_USER	:= cUserName
	CV8->CV8_INFO   := cType
	CV8->CV8_MSG 	:= cMsg
	CV8->CV8_DET	:= cDetalhes
	CV8->CV8_SBPROC := cSubProc
	CV8->CV8_IDMOV	:= cIdCV8
	CV8->(MsUnlock())
EndIf

// Grava o Log do Sub-Processo
If (ValType(lCabec) == "L" .And. !lCabec) .Or. ValType(lCabec) == "U"
	If !Empty(cSubProc)
		//inverte na gravacao no caso do subprocesso
		GravaCV8(cType, cSubProc  , cMsgSubProc, cDetalhes, ""/*cSubProc*/,,.T.,cIdCV8, cFilProc)
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGravaCV9  บAutor  ณMicrosiga           บ Data ณ  10/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Inclusao de registro na tabela CV9 - Historico de rateios  บฑฑ
ฑฑบ          ณ off-line                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function GravaCV9(cRevisao, cRotina, cLote, cSubLote, cDoc, dData, aCposEqv,nTotCpos,cAlias)
Local nCpo

RecLock("CV9",.T.)

CV9->CV9_REVISA		:= cRevisao
CV9->CV9_ROTINA		:= cRotina
CV9->CV9_STATUS		:= If( cRotina $ "CTBA270/CTBA277", "1", "2" )

If ! (cRotina $ "CTBA270/CTBA277")
	CV9->CV9_LOTE		:= cLote
	CV9->CV9_SBLOTE		:= cSubLote
	CV9->CV9_DOC		:= cDoc
	CV9->CV9_DATA		:= dData
EndIf

For nCpo := 1 To nTotCpos
	If aCposEqv[nCpo,1] == "CTQ_FILIAL"
		CV9->CV9_FILIAL := xFilial("CV9")
	Else
		// CTQ e CV9 tem a mesma estrutura com excecao do campo CV9_REVISA gravado acima
		CV9->( FieldPut( FieldPos( aCposEqv[nCpo,2]), (cAlias)->(FieldGet(nCpo)) ) )
	EndIf
Next nCpo

CV9->( MsUnlock() )

Return

//-------------------------------------------------------------------
/*{Protheus.doc} CTBGrvCQA
VerIfica se podera usar o JOB do CTB

@author Alvaro Camillo Neto

@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Function CTBGrvCQA( aLinhas )
Local nX := 1
Local aArea
Local aAreaCT2
Local cFilAux
Local cLote
Local cSublote
Local cDoc
Local dData
Local cLinha
Local cTpSald
Local cEmpOri
Local cFilOri
Local cMoeda
Local aBind 
Static _cQryGrvCQA

If _lAtSldBase
	aArea    := GetArea()
	aAreaCT2 := CT2->(GetArea())
	aBind := {}
	CT2->(dbSetOrder(1))//CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC
	DbSelectArea('CQA')
	For nX := 1 To Len(aLinhas)

		cFilAux	:= aLinhas[nX,01]
		cLote	:= aLinhas[nX,02]
		cSublote:= aLinhas[nX,03]
		cDoc	:= aLinhas[nX,04]
		dData	:= aLinhas[nX,05]
		cLinha	:= aLinhas[nX,06]
		cTpSald	:= aLinhas[nX,07]
		cEmpOri	:= aLinhas[nX,08]
		cFilOri	:= aLinhas[nX,09]
		cMoeda 	:= aLinhas[nX,10]
		If _cQryGrvCQA == nil 
			_cQryGrvCQA := "SELECT CT2_FILIAL, CT2_DC, CT2_VALOR FROM "
			_cQryGrvCQA += RetSqlName("CT2")+" CT2 "
			_cQryGrvCQA += " WHERE CT2_FILIAL = ? "
			_cQryGrvCQA += " AND CT2_DATA     = ? "
			_cQryGrvCQA += " AND CT2_LOTE     = ? "
			_cQryGrvCQA += " AND CT2_SBLOTE   = ? "
			_cQryGrvCQA += " AND CT2_DOC      = ? "
			_cQryGrvCQA += " AND CT2_LINHA    = ? "
			_cQryGrvCQA += " AND CT2_TPSALD   = ? "
			_cQryGrvCQA += " AND CT2_EMPORI   = ? "
			_cQryGrvCQA += " AND CT2_FILORI   = ? "
			_cQryGrvCQA += " AND CT2_MOEDLC   = ? "
			_cQryGrvCQA += " AND CT2.D_E_L_E_T_   = ? "
			//- EFETUA A VALIDAวรO DE QUE NรO EXISTA O CQA
			_cQryGrvCQA += " AND NOT EXISTS(SELECT 1 FROM "
			_cQryGrvCQA += RetSqlName('CQA')+" CQA "
			_cQryGrvCQA += " WHERE CQA_FILIAL = ?"
			_cQryGrvCQA += " AND CQA_FILCT2   = CT2_FILIAL"
			_cQryGrvCQA += " AND CQA_DATA     = CT2_DATA "
			_cQryGrvCQA += " AND CQA_LOTE     = CT2_LOTE "
			_cQryGrvCQA += " AND CQA_SBLOTE   = CT2_SBLOTE" 
			_cQryGrvCQA += " AND CQA_DOC      = CT2_DOC "
			_cQryGrvCQA += " AND CQA_LINHA    = CT2_LINHA"
			_cQryGrvCQA += " AND CQA_TPSALD   = CT2_TPSALD"
			_cQryGrvCQA += " AND CQA_EMPORI   = CT2_EMPORI"
			_cQryGrvCQA += " AND CQA_FILORI   = CT2_FILORI"
			_cQryGrvCQA += " AND CQA_MOEDLC   = CT2_MOEDLC"
			_cQryGrvCQA += " AND CQA.D_E_L_E_T_ = ?"
			_cQryGrvCQA := ChangeQuery(_cQryGrvCQA)
		EndIf 
		aBind := {}
		aadd(aBind,FWxFilial("CT2"))
		aadd(aBind,DTOS(dData))
		aadd(aBind,cLote)
		aadd(aBind,cSublote)
		aadd(aBind,cDoc)
		aadd(aBind,cLinha)
		aadd(aBind,cTpSald)
		aadd(aBind,cEmpOri)
		aadd(aBind,cFilOri)
		aadd(aBind,cMoeda)
		aadd(aBind,Space(1))
		aadd(aBind,FWxFilial("CQA"))
		aadd(aBind,Space(1))
		dbUseArea(.T.,"TOPCONN",TcGenQry2(,,_cQryGrvCQA,aBind),'QGrvCQA')

		If QGrvCQA->(!Eof())
			// Saldos de Documento
			lPartDob := QGrvCQA->CT2_DC == '3'
			If QGrvCQA->CT2_DC  $ "1/3"
				GravaCTC(cLote,cSubLote,cDoc,"1",dData,cMoeda,QGrvCQA->CT2_VALOR,cTpSald,lPartDob,"+",,,,cMoeda)
			EndIf
			If QGrvCQA->CT2_DC  $ "2/3"
				GravaCTC(cLote,cSubLote,cDoc,"2",dData,cMoeda,QGrvCQA->CT2_VALOR,cTpSald,lPartDob,"+",,,,cMoeda)
			EndIf

			RecLock('CQA',.T.)
			CQA->CQA_FILIAL	:= FWxFilial( 'CQA' )
			CQA->CQA_FILCT2 := QGrvCQA->CT2_FILIAL
			CQA->CQA_DATA 	:= dData
			CQA->CQA_LOTE 	:= cLote
			CQA->CQA_SBLOTE := cSublote
			CQA->CQA_DOC 	:= cDoc
			CQA->CQA_LINHA 	:= cLinha
			CQA->CQA_EMPORI := cEmpOri
			CQA->CQA_FILORI := cFilOri
			CQA->CQA_MOEDLC := cMoeda
			CQA->CQA_TPSALD := cTpSald
			MsUnLock()
		EndIf
		QGrvCQA->(dbCloseArea())
	Next
	RestArea(aAreaCT2)
	aSize(aAreaCT2,0)
	aAreaCT2 := nil 

	RestArea(aArea)
	aSize(aArea,0)
	aArea := nil 

	aSize(aBind,0)
	aBind := nil 
EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGravaCVM  บAutor  ณMicrosiga           บ Data ณ  09/10/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava tabela CVM - Sequencial de Diario                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบEstrutura ณaCVM[01]	=	CVM_FILIAL                                    บฑฑ
ฑฑบ          ณaCVM[02]	=	CVM_COD	                                      บฑฑ
ฑฑบ          ณaCVM[03]	=	CVM_DESCR                                     บฑฑ
ฑฑบ          ณaCVM[04]	=	CVM_TIPOSE                                    บฑฑ
ฑฑบ          ณaCVM[05]	=	CVM_DTINI	                                  บฑฑ
ฑฑบ          ณaCVM[06]	=	CVM_DTFIM	                                  บฑฑ
ฑฑบ          ณaCVM[07]	=	CVM_DTSEQ	                                  บฑฑ
ฑฑบ          ณaCVM[08]	=	CVM_SEQINI                                    บฑฑ
ฑฑบ          ณaCVM[09]	=	CVM_SEQULT                                    บฑฑ
ฑฑบ          ณaCVM[10]	=	CVM_INCRE	                                  บฑฑ
ฑฑบ          ณaCVM[11]	=	CVM_RAD		                                  บฑฑ
ฑฑบ          ณaCVM[12]	=	CVM_CALEND	                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GravaCVM(aCVM)

Reclock( "CVM" , .T. )
CVM->CVM_FILIAL  := aCVM[01]
CVM->CVM_COD	    := aCVM[02]
CVM->CVM_DESCR   := aCVM[03]
CVM->CVM_TIPOSE  := aCVM[04]
CVM->CVM_DTINI	:= aCVM[05]
CVM->CVM_DTFIM	:= aCVM[06]
CVM->CVM_DTSEQ	:= aCVM[07]
CVM->CVM_SEQINI  := ALLTRIM(aCVM[08])
CVM->CVM_SEQULT  := ALLTRIM(aCVM[09])
CVM->CVM_INCRE	:= aCVM[10]
CVM->CVM_RAD		:= aCVM[11]
CVM->CVM_CALEND	:= aCVM[12]
MsUnlock()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GravaCVL บAutor  ณMicrosiga           บ Data ณ  09/10/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava Tabela CVL - Controle de Diario                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบEstrutura ณaCVM[01]	=	CVM_FILIAL                                    บฑฑ
ฑฑบ          ณaCVM[02]	=	CVM_COD	                                      บฑฑ
ฑฑบ          ณaCVM[03]	=	CVM_DESCR                                     บฑฑ
ฑฑบ          ณaCVM[04]	=	CVM_TIPOSE                                    บฑฑ
ฑฑบ          ณaCVM[05]	=	CVM_DTINI	                                  บฑฑ
ฑฑบ          ณaCVM[06]	=	CVM_DTFIM	                                  บฑฑ
ฑฑบ          ณaCVM[07]	=	CVM_DTSEQ	                                  บฑฑ
ฑฑบ          ณaCVM[08]	=	CVM_SEQINI                                    บฑฑ
ฑฑบ          ณaCVM[09]	=	CVM_SEQULT                                    บฑฑ
ฑฑบ          ณaCVM[10]	=	CVM_INCRE	                                  บฑฑ
ฑฑบ          ณaCVM[11]	=	CVM_RAD		                                  บฑฑ
ฑฑบ          ณaCVM[12]	=	CVM_CALEND	                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GravaCVL( aCVM )

RecLock ( "CVL", .T.)
CVL->CVL_FILIAL	:= aCVM[1]
CVL->CVL_COD		:= aCVM[2]
CVL->CVL_DESCR	:= aCVM[3]
MsUnLock()

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณVerIDProc2ณ Autor ณ Marcelo Pimentel      ณ Data ณ24.07.2007ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณIdentIfica a sequencia de controle do fonte ADVPL com a     ณฑฑ
ฑฑณ          ณstored procedure, qualquer alteracao que envolva diretamenteณฑฑ
ฑฑณ          ณa stored procedure a variavel sera incrementada.            ณฑฑ
ฑฑณ          ณProcedure CTB153                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao Efetuada                         ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function VerIDProc2()
Return '010'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณVerIDProc3ณ Autor ณ Marcelo Pimentel      ณ Data ณ24.07.2007ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณIdentIfica a sequencia de controle do fonte ADVPL com a     ณฑฑ
ฑฑณ          ณstored procedure, qualquer alteracao que envolva diretamenteณฑฑ
ฑฑณ          ณa stored procedure a variavel sera incrementada.            ณฑฑ
ฑฑณ          ณProcedure CTB185                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao Efetuada                         ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function VerIDProc3()
Return '010'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณRastAutom ณ Autor ณ Eduardo Nunes         ณ Data ณ31.08.2007ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณVerIfica na base se existe configuracao para rastreamento   ณฑฑ
ฑฑณ          ณautomatico de lancamentos de integreacao.                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao Efetuada                         ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function RastAutom(lSimula,cTabCTK,cTabCT2)

Local aArea := GetArea()

Default lSimula	:= .F.
Default cTabCTK	:= "CTK"
Default cTabCT2	:= "CT2"

If Select("CV3") == 0
	DbSelectArea("CV3")
EndIf

If ( lCTxTABORI == Nil )
	lCTxTABORI	:= .T.
EndIf

If ( lCTxRECORI == Nil )
	lCTxRECORI 	:= .T.
EndIf

If ( lCTxRECDES == Nil )
	lCTxRECDES 	:= .T.
EndIf

If Select("CTK") == 0
	DbSelectArea("CTK")
EndIf
If ( lCTKRECCV3 == Nil )
	lCTKRECCV3	:= .T.
	// Tratamento para o parametro MV_PROCCV3
	If lCTKRECCV3 .And. Type('lMATA330') == 'L' .And. lMATA330
		 If !SuperGetMV("MV_PROCCV3",.F.,.T.)
			lCTKRECCV3 := .F.
		 EndIf
	EndIf
EndIf

RestArea(aArea)
aSize(aArea,0)
aArea := nil 

Return

/////////////////////////////////////////////////////////////////////////////////////////////////
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณProgram   ณCtb101Grv ณ Autor ณ Pilar S. Albaladejo   ณ Data ณ 24.07.00 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Grava Lancamento Contabil do Folder                        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณCtb101Grv(dData,cLote,cSubLote,cDoc,cLinha,cTipo,cMoeda,    ณฑฑ
ฑฑณ          ณcHistPad,cDebito,cCredito,cCustoDeb,cCustoCrd,cItemDeb,     ณฑฑ
ฑฑณ		     ณcItemCrd,cClVlDeb,cClVlCrd,nValor,cTexto,cTpSald,cSeqLan,	  ณฑฑ
ฑฑณ          ณnOpc,aOutros,cDebitoAnt,cCreditoAnt,cCustoDAnt,cCustoCAnt,  ณฑฑ
ฑฑณ          ณcItemDAnt,cItemCAnt,cCLVLDAnt,cCLVLCAnt,nValorAnt,cTipoAnt, ณฑฑ
ฑฑณ	  		 ณcTpSaldAnt,cMoedaAnt,aColsAnt,nTotInf) 					  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ Nenhum                                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Generico                                                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpD1 = Data do Lancamento Contabil                        ณฑฑ
ฑฑณ          ณ ExpC1 = Lote do Lancamento Contabil                        ณฑฑ
ฑฑณ          ณ ExpC2 = Sub-Lote do Lancamento Contabil                    ณฑฑ
ฑฑณ          ณ ExpC3 = Documento do Lancamento Contabil                   ณฑฑ
ฑฑณ          ณ ExpC4 = Linha Inicial do Lancamento Contabil               ณฑฑ
ฑฑณ          ณ ExpC5 = Tipo do Lancamento Contabil                        ณฑฑ
ฑฑณ          ณ ExpC6 = Moeda do Lancamento Contabil                  	  ณฑฑ
ฑฑณ          ณ ExpC7 = Historico Padrao                                   ณฑฑ
ฑฑณ          ณ ExpC8 = Conta debito                                       ณฑฑ
ฑฑณ          ณ ExpC9 = Conta Credito                                      ณฑฑ
ฑฑณ          ณ ExpC10= Centro Custo Debito                                ณฑฑ
ฑฑณ          ณ ExpC11= Centro Custo Credito                               ณฑฑ
ฑฑณ          ณ ExpC12= Item Debito                                        ณฑฑ
ฑฑณ          ณ ExpC13= Item Credito                                       ณฑฑ
ฑฑณ          ณ ExpC14= Classe de Valor Debito                             ณฑฑ
ฑฑณ          ณ ExpC15= Classe de Valor Credito                            ณฑฑ
ฑฑณ          ณ ExpN1 = Valor do Lancamento Contabil                       ณฑฑ
ฑฑณ          ณ ExpC16= Conteudo do Historico                              ณฑฑ
ฑฑณ          ณ ExpC17= Tipo do Saldo                                      ณฑฑ
ฑฑณ          ณ ExpC18= Sequencia do Lancamento Contabil                   ณฑฑ
ฑฑณ          ณ ExpN2 = Opcao do Menu (Inclusao/Alteracao/Exclusao )       ณฑฑ
ฑฑณ          ณ ExpA1 = Matriz com outros campos -> de usuario             ณฑฑ
ฑฑณ          ณ ExpC19= Conta debito anterior                              ณฑฑ
ฑฑณ          ณ ExpC20= Conta Credito anterior                             ณฑฑ
ฑฑณ          ณ ExpC21= Centro Custo Debito anterior                       ณฑฑ
ฑฑณ          ณ ExpC22= Centro Custo Credito anterior                      ณฑฑ
ฑฑณ          ณ ExpC23= Item Debito anterior                               ณฑฑ
ฑฑณ          ณ ExpC24= Item Credito anterior                              ณฑฑ
ฑฑณ          ณ ExpC25= Classe de Valor Debito anterior                    ณฑฑ
ฑฑณ          ณ ExpC26= Classe de Valor Credito anterior                   ณฑฑ
ฑฑณ          ณ ExpN3 = Valor do Lancamento Contabil anterior              ณฑฑ
ฑฑณ          ณ ExpC27= Tipo do Lancamento Contabil anterior               ณฑฑ
ฑฑณ          ณ ExpC28= Tipo do Saldo anterior                        	  ณฑฑ
ฑฑณ          ณ ExpC29= Moeda anterior                                	  ณฑฑ
ฑฑณ          ณ ExpA2 = Matriz Acols anterior                         	  ณฑฑ
ฑฑณ          ณ ExpN4 = Valor Total informado na capa de lote              ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function Ctb101Grv(	dData,cLote,cSubLote,cDoc,cLinha,cTipo,cMoeda,cHistPad,cDebito,;
					cCredito,cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,;
					cClVlDeb,cClVlCrd,nValor,cTexto,cTpSald,;
					cSeqLan,nOpc,aOutros,cDebitoAnt,cCreditoAnt,cCustoDAnt,;
					cCustoCAnt,cItemDAnt,cItemCAnt,cCLVLDAnt,cCLVLCAnt,nValorAnt,;
					cTipoAnt,cTpSaldAnt,cMoedaAnt,aColsAnt,nTotInf,dDataAnt,;
					cLoteAnt,cSubLoteAnt,cDocAnt,cEmpOri,cFilOri,cDCD,cDCC,cDCDAnt,;
					cDCCAnt,cCodSeq,lSeqCorr,cSeqCorr,aEntid,aEntidAnt,lAtuCorr,;
					cHistLote,cMoFatDB,cMoAnFatDB,cMoFatCR,cMoAnFatCR)

Local aSaveArea		:= GetArea()
Local nVal			:= 0
Local nValAnt		:= 0
Local nRecnoAnt
Local cMoed
Local cMoedAnt
Local nCont
Local cFilCTO		:= ""
Local nRegLan		:= 0

Local cLinMoeda		:= cLinha
Local cAliasAnt		:= ""

Local lAltTpSld		:= .F.
Local lPodeExc		:= .T.
Local lCtbPesqCt2   := .F.
Local lTrbProc      := .T.
Local nForaCols		:= 0
Local lGrvCQB		:= .T.
Local nTxMoed		:= 0
Local nTxAntMoed	:= 0


Private __aCT2LC	:= {}
Default lSeqCorr	:= UsaSeqCor()
Default lAtuCorr	:= .T.
Default cHistLote	:= ""
Default cMoFatDB	:= ""
Default cMoAnFatDB	:= ""
Default cMoFatCR	:= ""
Default cMoAnFatCR	:= ""

If nOpc == 4 .Or. nOpc == 5
	lCtbPesqCt2 := CtbPesqCT2(dData,cLote,cSubLote,cDoc,cLinha,cTpSaldAnt/*cTpSld*/,cEmpOri,cFilOri,cMoeda)
EndIf

CtbInVStatic()

lTrbProc := .F.

If lSeqCorr .And. ValType(cSeqCorr) == "U"
	cSeqCorr := space(TamSx3("CT2_NODIA")[1])
EndIf

dbSelectArea("CTO")
CTO->(dbSetOrder(1))
cFilCTO := xFilial("CTO")
For nCont := 1 to Len(aCols)
	If CTO->(MsSeek(cFilCTO+aCols[nCont][1]))
		aCols[nCont][3]	:= Round(NoRound(aCols[nCont][3],CTO->CTO_DECIM),CTO->CTO_DECIM)
	EndIf
Next

//Se for alteracao, verIficar se o tipo de saldo da linha de lancamento foi alterado.
If nOpc == 4 .And. cTpSald <> cTpSaldAnt
	lAltTpSld	:= .T.
EndIf

CtbIniSemaforo("ON"/*cSemaforo*/,"CTBA101"/*cProg*/)

//Chamar a multlock
aTravas := {}
If !Empty(cDebito)
   AADD(aTravas,cDebito)
EndIf
If !Empty(cCredito)
   AADD(aTravas,cCredito)
EndIf

If nOpc == 4		// NO CASO DE ALTERACAO MULTLOCK DAS CONTAS ANTERIORES TAMBEM
	If cDebito <> CT2->CT2_DEBITO .and. !Empty(CT2->CT2_DEBITO)
	   AADD(aTravas,CT2->CT2_DEBITO)
	EndIf
	If cCredito <> CT2->CT2_CREDIT  .and. !Empty(CT2->CT2_CREDIT)
 	   AADD(aTravas,CT2->CT2_CREDIT)
	EndIf
EndIf

/// VERIfICA SE O SEMAFORO DE CONTAS PERMITE GRAVAวรO DOS LANวAMENTOS/SALDOS
If CtbCanGrv(aTravas,@_lAtSldBase,@_lAtSldCT7,@_lAtSldCT3,@_lAtSldCT4,@_lAtSldCTI)
    BEGIN TRANSACTION

    nValAnt := 	If(nOpc==4 .Or. nOpc==5, CT2->CT2_VALOR, 0) // valor atual do lan็amento p/ alterar/excluir

	// Desgrava Saldos no Caso de Alteracao / Exclusao
	If nOpc == 4 .Or. nOpc == 5
		///POSICIONA NO CT2 PARA VERIfICAR RASTREAMENTO NA EXCLUSAO
		lPodeExc := lCtbPesqCt2
		lPodeExc := lPodeExc .And. CanDelCt2(nOpc,1)
		lPodeExc := lPodeExc .And. CtbP101EXC()

		If lPodeExc .or. nOpc == 4/// SE ALTERACAO

			CtbGravSaldo(cLote,cSubLote,cDoc,dData,cTipo,cMoeda,cDebito,;
						cCredito,cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,;
						cClVlDeb,cClVlCrd,nValor,cTpSald,nOpc,cDebitoAnt,;
						cCreditoAnt,cCustoDAnt,cCustoCAnt,cItemDAnt,;
						cItemCAnt,cCLVLDAnt,cCLVLCAnt,nValorAnt,;
						cTipoAnt,cTpSaldAnt,cMoedaAnt,__lCusto,__lItem,__lClVL,nTotInf,;
						_lAtSldBase,_lReproc,CT2->CT2_DTLP,_lGrvCT7,_lGrvCT3,;
						_lGrvCT4,_lGrvCTI,_lAtSldCT7,_lAtSldCT3,_lAtSldCT4,_lAtSldCTI,/*lTrbProc*/,"-"/*cOperacao*/,aEntid,aEntidAnt,;
						cHistLote)

			/* Apaga os lancamentos complementares (em todas as moedas */
			If CTBLCUso()
				CTBLCDelLC(CT2->(Recno()),.T.)
			EndIf
		EndIf
	EndIf

	//Grava lancamento na moeda 01
	If lPodeExc
		GravaLanc(dData,cLote,cSubLote,cDoc,@cLinha,cTipo,'01',cHistPad,cDebito,cCredito,;
					cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlDeb,cClVlCrd,nValor,cTexto,;
					cTpSald,cSeqLan,nOpc,_lAtSldBase,aCols,cEmpOri,cFilOri,,cDCD,cDCC,cDCDAnt,cDCCAnt,,;
					lAltTpSld,cTpSaldAnt,aOutros,,@nRegLan,cCodSeq,lSeqCorr,@cSeqCorr,lAtuCorr,;
					cMoFatDB,cMoFatCR)

		// Gravacao dos Saldos de Contas
		If ( ( nOpc == 3 .Or. nOpc == 6 .Or. nOpc == 7 ) .And. !__IsCtbJob ) .Or. nOpc == 4   //3=Inclusao 4=Alteracao 6=Estorno 7-copia
			CtbGravSaldo(cLote,cSubLote,cDoc,dData,cTipo,'01',cDebito,;
						 cCredito,cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,;
						 cClVlDeb,cClVlCrd,nValor,cTpSald,nOpc,cDebitoAnt,;
						 cCreditoAnt,cCustoDAnt,cCustoCAnt,cItemDAnt,;
						 cItemCAnt,cCLVLDAnt,cCLVLCAnt,nValAnt,;
						 cTipoAnt,cTpSaldAnt,cMoedaAnt,__lCusto,__lItem,__lClVL,;
						 ,_lAtSldBase,_lReproc,CT2->CT2_DTLP,_lGrvCT7,_lGrvCT3,;
						_lGrvCT4,_lGrvCTI,_lAtSldCT7,_lAtSldCT3,_lAtSldCT4,_lAtSldCTI,,"+"/*cOperacao*/,aEntid,aEntidAnt,;
						cHistLote)
		EndIf
	EndIf

	lGrvCQB := VldAltCQB(	nOpc,;
				cDebito		,cCredito	,cCustoDeb	,cCustoCrd	,cItemDeb	,cItemCrd	,cClVlDeb	,cClVlCrd	,aEntid,;
				cDebitoAnt	,cCreditoAnt	,cCustoDAnt	,cCustoCAnt	,cItemDAnt	,cItemCAnt	,cCLVLDAnt	,cCLVLCAnt	,aEntidAnt,;
				nValor,nValAnt,;
				cMoFatDB,cMoAnFatDB,;
				cMoFatCR,cMoAnFatCR)

	// Grava demais moedas -> a partir de aCols
	For nCont 	 := 1 To Len(aCols)
		cMoed	 := aCols[nCont][1]
		nVal 	 := aCols[nCont][3]
		cMoedAnt := aColsAnt[nCont][1]
		nValAnt	 := aColsAnt[nCont][3]

		If Empty(cMoed)  .Or. cMoed == cMoeda
			Loop
		EndIf

		If nOpc == 4 .And. nVal == 0 //Se o valor em outras moedas esta zerado
			nRecnoAnt	:= Recno()
			cAliasAnt	:= Alias()

			If CtbPesqCT2(dData,cLote,cSubLote,cDoc,cLinMoeda,If(lAltTpSld, cTpSaldAnt, cTpSald)/*cTpSld*/,cEmpOri,cFilOri,cMoed)
				CtbDelCT2()
			EndIf

			dbSetOrder(10)

			dbSelectArea(cAliasAnt)
			MSGoto(nRecnoAnt)

		EndIf

		// DesGravacao de Saldos
		If nOpc == 4 .Or. nOpc == 5

			CtbGravSaldo(cLote,cSubLote,cDoc,dData,cTipo,cMoed,cDebito,;
						cCredito,cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,;
						cClVlDeb,cClVlCrd,nVal,cTpSald,nOpc,cDebitoAnt,;
						cCreditoAnt,cCustoDAnt,cCustoCAnt,cItemDAnt,;
						cItemCAnt,cCLVLDAnt,cCLVLCAnt,nValAnt,;
						cTipoAnt,cTpSaldAnt,cMoedAnt,__lCusto,__lItem,__lClVL,,;
						_lAtSldBase,_lReproc,CT2->CT2_DTLP,_lGrvCT7,_lGrvCT3,;
						_lGrvCT4,_lGrvCTI,_lAtSldCT7,_lAtSldCT3,_lAtSldCT4,_lAtSldCTI,/*lTrbProc*/,"-"/*cOperacao*/,aEntid,aEntidAnt,;
						cHistLote)

			//----------------------------------------------------------------
			// Variacao Cambial - Diminui o saldo da chave anterior
			//----------------------------------------------------------------
			//Debito
			If lGrvCQB .And. !Empty(cDebitoAnt) .And. !Empty(cMoAnFatDB) .And. cMoedAnt == cMoAnFatDB
				nTxAntMoed	:= nValorAnt/nValAnt
				GravaCQB(1,"-",dData,cMoAnFatDB,nTxAntMoed,nValAnt,cDebitoAnt,cCustoDAnt,cItemDAnt,cCLVLDAnt,aEntidAnt)
			EndIf

			//Credito
			If lGrvCQB .And. !Empty(cCreditoAnt) .And. !Empty(cMoAnFatCR) .And. cMoedAnt == cMoAnFatCR
				nTxAntMoed	:= nValorAnt/nValAnt
				GravaCQB(2,"-",dData,cMoAnFatCR,nTxAntMoed,nValAnt,cCreditoAnt,cCustoCAnt,cItemCAnt,cCLVLCAnt,aEntidAnt)
			EndIf

		EndIf

		If nVal > 0
			nForaCols := Val(cMoed) - nCont

			// Colocado CT2_LINHA pois o lan็amento jแ esta posicionado na moeda 1 e a variavel cLinha jแ foi incrementada nใo devendo ser utilizada
			GravaLanc(dData,cLote,cSubLote,cDoc,CT2->CT2_LINHA,cTipo,cMoed,cHistPad,cDebito,cCredito,;
						cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlDeb,cClVlCrd,nValor,cTexto,;
						cTpSald,cSeqLan,nOpc,_lAtSldBase,aCols,cEmpOri,cFilOri,nForaCols,cDCD,cDCC,cDCDAnt,cDCCAnt,,;
						lAltTpSld,cTpSaldAnt,aOutros,,,cCodSeq,lSeqCorr,@cSeqCorr,.F.,cMoFatDB,cMoFatCR)

			// Gravacao dos Saldos de Contas
			If ( ( nOpc == 3 .Or. nOpc == 6 .Or. nOpc == 7 ) .And. !__IsCtbJob ) .Or. nOpc == 4   //3=Inclusao 4=Alteracao 6=Estorno 7-copia
				CtbGravSaldo(cLote,cSubLote,cDoc,dData,cTipo,cMoed,cDebito,;
							 cCredito,cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,;
							 cClVlDeb,cClVlCrd,nVal,cTpSald,nOpc,cDebitoAnt,;
							 cCreditoAnt,cCustoDAnt,cCustoCAnt,cItemDAnt,;
							 cItemCAnt,cCLVLDAnt,cCLVLCAnt,nValAnt,;
							 cTipoAnt,cTpSaldAnt,cMoedAnt,__lCusto,__lItem,__lClVL,;
							 ,_lAtSldBase,_lReproc,CT2->CT2_DTLP,_lGrvCT7,_lGrvCT3,;
							_lGrvCT4,_lGrvCTI,_lAtSldCT7,_lAtSldCT3,_lAtSldCT4,_lAtSldCTI,,"+"/*cOperacao*/,aEntid,aEntidAnt,;
							cHistLote)

				//----------------------------------------------------------------
				// Variacao Cambial - Aumenta o saldo da chave nova
				//----------------------------------------------------------------
				//Debito
				If lGrvCQB .And. !Empty(cDebito) .And. !Empty(cMoFatDB) .And. cMoed == cMoFatDB
					nTxMoed := nValor/nVal
					GravaCQB(1,"+",dData,cMoFatDB,nTxMoed,nVal,cDebito,cCustoDeb,cItemDeb,cClVlDeb,aEntid)
				EndIf

				//Credito
				If lGrvCQB .And. !Empty(cCredito) .And. !Empty(cMoFatCR) .And. cMoed == cMoFatCR
					nTxMoed := nValor/nVal
					GravaCQB(2,"+",dData,cMoFatCR,nTxMoed,nVal,cCredito,cCustoCrd,cItemCrd,cClVlCrd,aEntid)
				EndIf


			EndIf
		EndIf
	Next nCont

	/* Inclusใo de lancamentos complementares, em todas as moedas disponiveis. */
	If nOpc <> 5
		If CTBLCUso()
			CTBLCGerLC(nRegLan,cTexto)
		EndIf
	EndIf

	END TRANSACTION
	Ct1MUnLock()
	dbCommitAll()
EndIf

If _lCtbLanc
	ExecBlock("CTBLANC",.F.,.F.,{	dData,cLote,cSubLote,cDoc,@cLinha,cTipo,cMoeda,;
									cHistPad,cDebito,cCredito,cCustoDeb,cCustoCrd,;
									cItemDeb,cItemCrd,cClVlDeb,cClVlCrd,nValor,cTexto,;
									cTpSald,cSeqLan,nOpc,aCols,cDCD,cDCC})
EndIf

CtbFimSemaforo("ON"/*cSemaforo*/, "CTBA101"/*cProg*/)  //finaliza semaforo de processamento do SIGACTB

RestArea(aSaveArea)
aSize(aSaveArea,0)
aSaveArea := nil 

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbP101EXCบAutor  ณMicrosiga           บ Data ณ  10/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPonto de Entrada CTB101EXC utilizado na funcao Ctb101Grv    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbP101EXC()
Local lPodeExc := .T.

If _lCTB101EXC
	lPodeExc := ExecBlock("CTB101EXC",.F.,.F.)
	If ValType(lPodeExc) <> "L"
		lPodeExc := .T.
	EndIf
EndIf

Return(lPodeExc)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณProgram   ณ GravaLancณ Autor ณ Pilar S. Albaladejo   ณ Data ณ 24.07.00 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Grava Lancamento Contabil  - CT2                           ณฑฑ
ฑฑณ          ณ ROTINA CHAMADA EXTERNAMENTE - Atencao para criar parametrosณฑฑ
ฑฑณ          ณ e sempre tratar valor DEFAULT                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณGravaLanc(dData,cLote,cSubLote,cDoc,cLinha,cTipo,cMoeda,    ณฑฑ
ฑฑณ          ณcHistPad,cDebito,cCredito,cCustoDeb,cCustoCrd,cItemDeb,     ณฑฑ
ฑฑณ          ณcItemCrd,cClVlDeb,cClVlCrd,nValor,cTexto,cTpSald,cSeqLan,   ณฑฑ
ฑฑณ			 ณnOpc)                                                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ.T.                                                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpD1 = Data do Lancamento Contabil                        ณฑฑ
ฑฑณ          ณ ExpC1 = Lote do Lancamento Contabil                        ณฑฑ
ฑฑณ          ณ ExpC3 = Sub_Lote do Lancamento Contabil                    ณฑฑ
ฑฑณ          ณ ExpC4 = Documento do Lancamento Contabil                   ณฑฑ
ฑฑณ          ณ ExpC5 = Linha Inicial do Lancamento Contabil               ณฑฑ
ฑฑณ          ณ ExpC6 = Tipo do Lancamento Contabil                        ณฑฑ
ฑฑณ          ณ ExpC7 = Moeda do Lancamento Contabil                  	  ณฑฑ
ฑฑณ          ณ ExpC8 = Historico Padrao                                   ณฑฑ
ฑฑณ          ณ ExpC9 = Conta debito                                       ณฑฑ
ฑฑณ          ณ ExpC10= Conta Credito                                      ณฑฑ
ฑฑณ          ณ ExpC11= Centro Custo Debito                                ณฑฑ
ฑฑณ          ณ ExpC12= Centro Custo Credito                               ณฑฑ
ฑฑณ          ณ ExpC13= Item Debito                                        ณฑฑ
ฑฑณ          ณ ExpC14= Item Credito                                       ณฑฑ
ฑฑณ          ณ ExpC15= Classe de Valor Debito                             ณฑฑ
ฑฑณ          ณ ExpC16= Classe de Valor Credito                            ณฑฑ
ฑฑณ          ณ ExpN1 = Valor do Lancamento Contabil                       ณฑฑ
ฑฑณ          ณ ExpC17= Conteudo do Historico                              ณฑฑ
ฑฑณ          ณ ExpC18= Tipo de Saldo                                      ณฑฑ
ฑฑณ          ณ ExpC19= Sequencia do Lancamento Contabil                   ณฑฑ
ฑฑณ          ณ ExpN2 = Opcao do Menu (Inclusao/Alteracao/Exclusao )       ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function GravaLanc(	dData, cLote, cSubLote, cDoc, cLinha, cTipo, cMoeda, cHistPad, cDebito,;
					cCredito, cCustoDeb, cCustoCrd, cItemDeb, cItemCrd, cClVlDeb,;
					cClVlCrd, nValor, cTexto, cTpSald, cSeqLan, nOpc, lAtSldBase, aCols,;
					cEmpOri, cFilOri, nForaCols, cDCD, cDCC, cDCDAnt, cDCCAnt, cRotina,;
					lAltTpSald, cTpSaldAnt, aOutros, dDataLP, nRecLan, cCodSeq, lSeqCorr, cSeqCorr, lAtuCorr, cInterc,;
					cMoFatDB,cMoFatCR,cProxLin,aEntAdc)

Local aSaveArea		:= GetArea()
Local cDescricao	:= ""
Local lInclui		:= .F.
Local nPasso		:= 0
Local nLinTotal		:= 0
Local nLinhasAnt	:= 0
Local nTamHist		:= Len(CriaVar("CT2_HIST"))
Local nContaLinhas	:= 1		// Para o loop de gravacao de lancamento - Contador de linhas
Local lFirstHist	:= .T.
Local nRecCt1		:= CT1->(Recno()), nIndCt1	:= CT1->(IndexOrd())
Local nCont			:= 0
Local CTF_LOCK      := CTF->( Recno() )

Local lDtTxUso		:= .F.
Local lMltSld		:= CT2->( FieldPos( "CT2_CTLSLD" ) ) > 0
Local aLinhas		:=	{}
Local lCtb211		:= .F.


Default cCodSeq 	:= ''
Default lSeqCorr	:= UsaSeqCor()
Default lAtuCorr	:= .T.
DEFAULT nForaCols	:= 1
DEFAULT cRotina		:= "CTBA101"
DEFAULT lAltTpSald	:= .F.
DEFAULT cTpSaldAnt	:= cTpSald
DEFAULT aOutros		:= {}
DEFAULT dDataLP		:= CTOD("  /  /  ")
DEFAULT nRecLan		:= 0 		/// PASSADO POR REFERENCIA PARA RETORNAR O RECNO DO REG. DE LANCTO (CTBA211 C/CT.PONTE)
DEFAULT cInterc     := " "
DEFAULT cMoFatDB	:= ""
DEFAULT cMoFatCR	:= ""
Default cProxLin	:= ""
Default aEntAdc		:= {}

CtbInVStatic()

If lSeqCorr .And. ValType(cSeqCorr) == "U"
	cSeqCorr := space(TamSx3("CT2_NODIA")[1])
EndIf

If cPaisLoc == "PER" .And. FunName()=="CTBA381"
	cCodSeq := CtbRdia()
EndIf

//****************************
// Controle do Correlativo   *
//****************************
If lSeqCorr .AND. Empty(cSeqCorr)
 	lCtb211 := FwIsInCallStack("CTBA211")

 	If (nOpc == 3 .Or. nOpc == 6 .Or. nOpc == 7) .AND. Val(cLinha) < 2  // a partir da segunda linha do lanc., o correlativo eh o mesmo
		If cPaisLoc == "PER" .And. FunName()=="CTBA381"
			cSeqCorr := CTBSQCor( "" , cCodSeq, dData )
			cCorrel := cSeqCorr
		Else
			cSeqCorr := CTBSqCor( CTBSubToPad(cSubLote), cCodSeq, dData  )
		EndIf
	ElseIf nOpc <> 3;
	.Or. (lCtb211 .And. Val(cLinha) > 1) .Or. (funname()=="CTBA381" .And. Val(cLinha) > 1 .And. cPaisLoc == "PER")  // Condi็ใo utilizada na rotina de apura็ใo de resultado para que a mesma nใo traga o correlativo em branco a partir da segunda linha do lan็amento
		If lCtb211 .and. Empty(CT2->CT2_SEGOFI)
			cSeqCorr := CTBSqCor( CTBSubToPad(cSubLote), cCodSeq, dData  )
		ElseIf (cPaisLoc == "PER" .And. FunName()=="CTBA381")
			cSeqCorr := cCorrel
		Else
			cSeqCorr := CT2->CT2_SEGOFI
		EndIf
	EndIf
EndIf

//inicio do lancamento para modulo SIGAPCO
PcoIniLan("000082")

For nCont	:= 2 to __nQuantas
	If CtbUso("CT2_DTTX"+StrZero(nCont,2))
		lDtTxUso		:= .T.
		Exit
	EndIf
Next

cSeqCorr  := If(ValType(cSeqCorr) != "C","",cSeqCorr)

CT1->(DbSetOrder(1))
DbSelectArea( "CT2" )

// Conta numero de linhas do lancamento no caso de alteracao
If nOpc == 4
	// Conta numero de linhas do lancamento no caso de alteracao
	CtbContLin(@nLinhasAnt, dData, cLote, cSubLote, cDoc, cSeqLan, cEmpOri, cFilOri, cMoeda)
ElseIf nOpc == 5			// Exclusao de lancamento
	If __lConOutR
		ConoutR( 'Antes da Exclusใo: ' + dtos(dData) + '|' + cLote + '|' + cSublote + '|' + cDoc + '|' + cLinha + '|TPSALD ' + cTpSald + '|' + cEmpOri + '|' + cFilOri + '|' + cMoeda )
	EndIf

	CtbExclLct(dData,cLote,cSublote,cDoc,cLinha,cTpSald,cEmpOri,cFilOri,cMoeda)

	If cMoeda = '01'
		If __lConOutR
			ConoutR( 'Limpa a CTF da Exclusใo: ' + dtos(dData) + '|' + cLote + '|' + cSublote + '|' + cDoc + '|' + cLinha + '|TPSALD ' + cTpSald + '|' + cEmpOri + '|' + cFilOri + '|' + cMoeda )
		EndIf

		CtbDsTrvCTF(dData,cLote,cSubLote,cDoc,@CTF_LOCK)

		If __lConOutR
			ConoutR( 'Excluir os historicos' )
		EndIf
		CtbExcHist(2,dData, cLote, cSubLote, cDoc, cSeqLan, cEmpOri, cFilOri, cMoeda ,cTpSald)		// Exclui continuacao de historico
	EndIf
EndIf

If nOpc != 5					// Inclusao / Alteracao
	DbSetOrder( 1 )
	nLintotal := If(cMoeda=="01", CtbQLinHis(@cTexto,nTamHist,@nPasso), 1)

	While nContaLinhas <= nLinTotal

		cDescricao := MemoLine(cTexto, nTamHist, nPasso)

		If Empty(cDescricao)
			nPasso++						//  Contador para leitura do Memoline
			Loop
		EndIf

		If nContaLinhas == 1				// Grava primeira linha de informacoes -> debito/credito etc

			//No aCols nao tem a moeda 01.
			If cMoeda <> '01' .And. aCols[Val(cMoeda)-nForaCols][4] = "5"		// Moeda do lancamento ou bloqueada nao tem conversao
				Return
			EndIf
			lInclui := CtbVeIncLc(nOpc,lAltTpSald,cTpSaldAnt,dData,cLote,cSubLote,cDoc,cLinha,cTpSald,cEmpOri,cFilOri,cMoeda)
            //1o. parametro da funcao (nTipo) indica 1 - Lct Normal 2 - continuacao historico
			CtbGrv101(1,lInclui,nOpc,dData,cLote,cSubLote,cDoc,cLinha,cFilOri,cEmpOri,cTipo,;
						cDebito,cCredito,cMoeda,nValor,cHistPad,cCustoDeb,cCustoCrd,;
						cItemDeb,cItemCrd,cClVlDeb,cClVlCrd,cDescricao,cTpSald,cSeqLan,;
						cRotina,dDataLP,aOutros,cDCD,cDCC,lSeqCorr,cSeqCorr,cCodSeq,lMltSld,;
						lDtTxUso,nContaLinhas,aCols,nForaCols,aLinhas,lAtuCorr, cInterc,;
						cMoFatDB,cMoFatCR,aEntAdc)

			nRecLan	:= CT2->(Recno())  //nao tirar essa linha pois eh parametro passado por referencia

			CtbPcoLct(CT2->CT2_DC)

			//Chama rotina para atualizar os flags de saldos a partir da data para frente.

		Else		// Continuacao de historico

			If cMoeda = '01'//O historico complementar sera gravado somente e sempre na moeda 01!!!

				If nOpc == 3
					lInclui := .T.
				Else
					CtbLinSeq(@cLinha,@lInclui,@lFirstHist,nContaLinhas,nLinhasAnt,dData,cLote,cSubLote,cDoc,cSeqLan,cEmpOri,cFilOri,@nOpc)
				EndIf

            	//1o. parametro da funcao (nTipo) indica 1 - Lct Normal 2 - continuacao historico
            	If CTBLCUso()
					CtbGrv101(2,lInclui,nOpc,dData,cLote,cSubLote,cDoc,cLinha,cFilOri,cEmpOri,"4"/*cTipo*/,;
							/*cDebito*/,/*cCredito*/,cMoeda,/*nValor*/,/*cHistPad*/,/*cCustoDeb*/,/*cCustoCrd*/,;
							/*cItemDeb*/,/*cItemCrd*/,/*cClVlDeb*/,/*cClVlCrd*/,cDescricao,cTpSald,cSeqLan,;
							cRotina,dDataLP,/*aOutros*/,/*cDCD*/,/*cDCC*/,/*lSeqCorr*/,/*cSeqCorr*/,/*cCodSeq*/,/*lMltSld*/,;
							/*lDtTxUso*/,nContaLinhas,/*aCols*/,/*nForaCols*/,/*aLinhas*/)
				Else
				CtbGrv101(2,lInclui,nOpc,dData,cLote,cSubLote,cDoc,cLinha,cFilOri,cEmpOri,"4"/*cTipo*/,;
						/*cDebito*/,/*cCredito*/,cMoeda,/*nValor*/,/*cHistPad*/,/*cCustoDeb*/,/*cCustoCrd*/,;
						/*cItemDeb*/,/*cItemCrd*/,/*cClVlDeb*/,/*cClVlCrd*/,cDescricao,cTpSald,cSeqLan,;
						/*cRotina*/,dDataLP,/*aOutros*/,/*cDCD*/,/*cDCC*/,/*lSeqCorr*/,/*cSeqCorr*/,/*cCodSeq*/,/*lMltSld*/,;
						/*lDtTxUso*/,nContaLinhas,/*aCols*/,/*nForaCols*/,/*aLinhas*/)
				EndIf
			EndIf

		EndIf

		nPasso++						//  Contador para leitura do Memoline
		cLinha  := Soma1(cLinha)

		//--------------------------------------------------------------------
		// Tratamento para identificar a proxima linha a ser gerada quando hแ
		// historico com mais de uma linha e lan็amento em mais de uma moeda
		//--------------------------------------------------------------------
		If cLinha > cProxLin
			cProxLin := cLinha
		EndIf

		//se for inclusao e rotina chamadora for apuracao de resultados incrementa com Soma1
		cSeqLan := If(nOpc==3.And.AllTrim(cRotina)=="CTBA211", Soma1(cSeqLan), cSeqLan)

		nContaLinhas++

	EndDo

	// Volta Numeracao da linha -> para que no proximo documento comece corretamente!
	nContaLinhas--

	// Deletar registros excedentes de historico
	If cMoeda = '01' .And. nContaLinhas < nLinhasAnt
		CtbExcHist(1,dData, cLote, cSubLote, cDoc, cSeqLan, cEmpOri, cFilOri, cMoeda,cTpSald)
	EndIf

	// posiciona o lan็amento correto caso tenham sidos criadas linhas historicas
	Ct2->(DbGoTo(nRecLan))

	// AQUI - Outros campos de usuario
EndIf

// Grava numero da ultima linha no arquivo de controle (CTF)
// Registro jแ foi travado no inํcio do lan็amento.
If cMoeda == '01'
	CtbCTFLinh(dData, cLote, cSubLote, cDoc, CT2->CT2_LINHA)
EndIf

//finalizacao do lancamento no modulo SIGAPCO
PcoFinLan("000082")

RestArea(aSaveArea)
aSize(aSaveArea,0)
aSaveArea := nil 

CT1->(DbGoto(nRecCt1))
CT1->(DbSetOrder(nIndCt1))

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbExcHistบAutor  ณMicrosiga           บ Data ณ  20/10/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExclusao de historico de lancamentos CT2_DC == "4"          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbExcHist(nTipo,dData, cLote, cSubLote, cDoc, cSeqLan, cEmpOri, cFilOri, cMoeda, cTpSald)
Local aArea
Local cQuery
Local nRecAux

Default cTpSald := ""

If nTipo == 1

	If __lConOutR
		ConoutR('CtbExcHist: ' + str(nTipo) + '|' + dtos(dData) + '|' + cLote + '|' + cSubLote + '|' + cDoc + '|' + cSeqLan + '|' + cEmpOri + '|' + cFilOri + '|' + cMoeda + '|TPSALD ' + cTpSald)
	EndIf

		dbSelectArea("CT2")
		nRecAux := CT2->( Recno() )
		aArea := GetArea()
		
		cQuery := " SELECT "
		cQuery += " R_E_C_N_O_ CT2_RECNO "
		cQuery += " FROM " + RetSqlName("CT2")+" CT2 "
		cQuery += " WHERE "
		cQuery += " CT2_FILIAL = '"+xFilial("CT2")+"' "
		cQuery += " AND CT2_DATA = '"+Dtos(dData)+"' "
		cQuery += " AND CT2_LOTE = '"+cLote+"' "
		cQuery += " AND CT2_SBLOTE = '"+cSubLote+"' "
		cQuery += " AND CT2_DOC = '"+cDoc+"' "
		cQuery += " AND CT2_SEQLAN  = '"+cSeqLan+"' "
		cQuery += " AND CT2_EMPORI = '"+cEmpOri+"' "
		cQuery += " AND CT2_FILORI = '"+cFilOri+"' "
		cQuery += " AND CT2_MOEDLC = '"+cMoeda+"' "
		cQuery += " AND CT2_DC = '4' "
		cQuery += " AND CT2_LINHA > '"+CT2->CT2_LINHA+"' "
		cQuery += " AND R_E_C_N_O_ != "+Str(nRecAux,10)+" "
		cQuery += " AND CT2.D_E_L_E_T_ = ' ' "


		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"CT2_QRY",.T.,.F.)

		While CT2_QRY->(! Eof() )
			dbSelectArea("CT2")
			CT2->(dbGoto( CT2_QRY->CT2_RECNO ))

			If __lConOutR
				ConoutR( 'Hist. Posicionou: ' + StrZero( CT2_QRY->CT2_RECNO,10 ) + "|" + CT2->(  Strzero(Recno(),10) + "|" + Dtos( CT2_DATA ) + "|" + CT2_LOTE + "|" + CT2_SBLOTE + "|" + CT2_DOC + "|" + CT2_LINHA + "|" + CT2_DC + "|" + CT2_MOEDLC + "|TPSALD " + CT2_TPSALD + "|" + CT2_SEQLAN ) )
			EndIf

			CtbDelCT2()
			CT2_QRY->( dbSkip() )
		EndDo

		dbSelectArea("CT2_QRY")
		CT2_QRY->(dbCloseArea())
	RestArea(aArea)
	aSize(aArea,0)
	aArea := nil 

ElseIf nTipo == 2

	// Exclui continuacao de historico - aqui nao precisa testar CT2->CT2_DC == "4" pois lct ja excluido

	aArea := GetArea()
	cQuery := " SELECT "
	cQuery += " R_E_C_N_O_ CT2_RECNO "
	cQuery += " FROM " + RetSqlName("CT2")+" CT2 "
	cQuery += " WHERE "
	cQuery += " CT2_FILIAL = '"+xFilial("CT2")+"' "
	cQuery += " AND CT2_DATA = '"+Dtos(dData)+"' "
	cQuery += " AND CT2_LOTE   = '"+cLote+"' "
	cQuery += " AND CT2_SBLOTE = '"+cSubLote+"' "
	cQuery += " AND CT2_DOC    = '"+cDoc+"' "
	cQuery += " AND CT2_SEQLAN = '"+cSeqLan+"' "
	cQuery += " AND CT2_EMPORI = '"+cEmpOri+"' "
	cQuery += " AND CT2_FILORI = '"+cFilOri+"' "
	cQuery += " AND CT2_MOEDLC = '01' "
	cQuery += " AND CT2_TPSALD = '" + cTpSald+"' "
	cQuery += " AND CT2.D_E_L_E_T_ = ' ' "


	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"CT2_QRY",.T.,.F.)

	While CT2_QRY->(! Eof() )
		dbSelectArea("CT2")
		CT2->(dbGoto( CT2_QRY->CT2_RECNO ))
		CtbDelCT2()
		CT2_QRY->( dbSkip() )
	EndDo

	dbSelectArea("CT2_QRY")
	CT2_QRY->(dbCloseArea())
	RestArea(aArea)
	aSize(aArea,0)
	aArea := nil 

EndIf


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbExclLctบAutor  ณMicrosiga           บ Data ณ  20/10/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExclusao de lancamentos                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbExclLct(dData,cLote,cSublote,cDoc,cLinha,cTpSald,cEmpOri,cFilOri,cMoeda)

If CtbPesqCT2(dData,cLote,cSublote,cDoc,cLinha,cTpSald,cEmpOri,cFilOri,cMoeda)
	// Exclui lancamento principal
	CtbPcoLct(, .T.)
	CtbDelCT2()

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbContLinบAutor  ณMicrosiga           บ Data ณ  20/10/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConta quantas linhas possui o documento na moeda 01         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbContLin(nLinhas,dData,cLote,cSubLote,cDoc,cSeqLan,cEmpOri,cFilOri,cMoeda)
Local cQuery
Local aArea

If cMoeda = '01'

	aArea := GetArea()
	cQuery := " SELECT "

	If _lOracle .Or. _lInformix
		cQuery += " NVL( COUNT(CT2_FILIAL), 0) CT2_QTLINH"
	ElseIf  _lDB2  .Or. _lPostgres
		cQuery += " COALESCE( COUNT(CT2_FILIAL), 0) CT2_QTLINH"
	Else
		cQuery += " ISNULL( COUNT(CT2_FILIAL), 0) CT2_QTLINH"
	EndIf
	cQuery += " FROM " + RetSqlName("CT2")+" CT2 "
	cQuery += " WHERE "
	cQuery += " CT2_FILIAL = '"+xFilial("CT2")+"' "
	cQuery += " AND CT2_DATA = '"+Dtos(dData)+"' "
	cQuery += " AND CT2_LOTE = '"+cLote+"' "
	cQuery += " AND CT2_SBLOTE = '"+cSubLote+"' "
	cQuery += " AND CT2_DOC = '"+cDoc+"' "
	cQuery += " AND CT2_SEQLAN  = '"+cSeqLan+"' "
	cQuery += " AND CT2_EMPORI = '"+cEmpOri+"' "
	cQuery += " AND CT2_FILORI = '"+cFilOri+"' "
	cQuery += " AND CT2_MOEDLC = '01' "
	cQuery += " AND CT2.D_E_L_E_T_ = ' ' "


	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"CT2_QRY",.T.,.F.)

	If CT2_QRY->(! Eof() )
		nLinhas	:= CT2_QRY->CT2_QTLINH
	EndIf

	//dbSelectArea("CT2_QRY")
	CT2_QRY->(dbCloseArea())
	RestArea(aArea)
	aSize(aArea,0)
	aArea := nil 
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbQLinHisบAutor  ณMicrosiga           บ Data ณ  20/10/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna quantas linhas possui o historico do lancamento     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbQLinHis(cTexto,nTamHist,nPasso)
Local nLinTotal
Local nContador
// Conta numero total de linhas a serem gravadas
// o historico indica quantas linhas existirao
cTexto		:= strtran(cTexto, chr(13), '')
cTexto		:= strtran(cTexto, chr(10), '')
nLinTotal 	:= mlCount( cTexto , nTamHist)

For nContador := 1 To nLinTotal
	cDescricao := MemoLine(cTexto, nTamHist, nContador)
	If Empty(cDescricao)
		Loop
	EndIf
	nPasso++
Next nContador

nLinTotal 	:= nPasso		// Numero total de linhas do lancamento
nPasso		:= 1

Return(nLinTotal)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbVeIncLcบAutor  ณMicrosiga           บ Data ณ  20/10/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna se vai incluir um lancamento (CT2)                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbVeIncLc(nOpc,lAltTpSald,cTpSaldAnt,dData,cLote,cSubLote,cDoc,cLinha,cTpSald,cEmpOri,cFilOri,cMoeda)
Local lInclui := .F.

If nOpc == 3 .Or. nOpc == 6	// Inclusao
	lInclui := ! CtbPesqCT2(dData,cLote,cSubLote,cDoc,cLinha,cTpSald,cEmpOri,cFilOri,cMoeda)
Else
	If nOpc == 4  .And. lAltTpSald  //Se for alteracao de tipo de Saldo
		lInclui := ! CtbPesqCT2(dData,cLote,cSubLote,cDoc,cLinha,cTpSaldAnt,cEmpOri,cFilOri,cMoeda)
	Else
		lInclui := ! CtbPesqCT2(dData,cLote,cSubLote,cDoc,cLinha,cTpSald,cEmpOri,cFilOri,cMoeda)
	EndIf
EndIf

Return(lInclui)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbPcoLancบAutor  ณMicrosiga           บ Data ณ  10/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณIntegracao da Contabilidade com Modulo SIGAPCO              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbPcoLct(cCt2_DC, lExcluir)
Local lPcoLanc := .T.

Default cCt2_DC := NIL
Default lExcluir := .F.

If lExcluir
	PcoDetLan("000082","01","CTBA101",.T.)
Else
	If _lCTBPCO
		//Ponto de entrada para verIficar se entra na pcodetlan()
		lPcoLanc  := ExecBlock("CTBPCO",.f.,.f.,{ "000082","01","CTBA101" } )
	EndIf

	If lPcolanc
		lPcoLanc := ( cCt2_DC != "4" ) //"4" eh continuacao do historico
	EndIf

	If lPcolanc
		PcoDetLan("000082","01","CTBA101")
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbGrv101 บAutor  ณMicrosiga           บ Data ณ  10/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGravacao do registro na tabela CT2 - Lancamentos Contabeis  บฑฑ
ฑฑบ          ณChamada da funcao GravaLanc                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbGrv101(nTipo, lInclui,nOpc,dData,cLote,cSubLote,cDoc,cLinha,cFilOri,cEmpOri,cTipo,;
							cDebito,cCredito,cMoeda,nValor,cHistPad,cCustoDeb,cCustoCrd,;
							cItemDeb,cItemCrd,cClVlDeb,cClVlCrd,cDescricao,cTpSald,cSeqLan,;
							cRotina,dDataLP,aOutros,cDCD,cDCC,lSeqCorr,cSeqCorr,cCodSeq,lMltSld,;
							lDtTxUso,nContaLinhas,aCols,nForaCols,aLinhas,lAtuCorr, cInterc,;
							cMoFatDB,cMoFatCR,aEntAdc)
Local aSaveSx3
Local nOutros
Local cFilAux		:= IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
Local nZ			:= 0

Default lAtuCorr	:= (Val(cLinha) < 2)
Default cInterc     := " "
Default cMoFatDB	:= ""
Default cMoFatCR	:= ""
Default aEntAdc		:= {}

If nTipo == 1
	RecLock("CT2",lInclui)
	CT2->CT2_FILIAL		:= xFilial()
	CT2->CT2_DATA		:= dData
	CT2->CT2_LOTE		:= cLote
	CT2->CT2_SBLOTE		:= cSubLote
	CT2->CT2_DOC		:= cDoc
	CT2->CT2_LINHA		:= cLinha
	CT2->CT2_FILORI		:= cFilOri
	CT2->CT2_EMPORI		:= cEmpOri
	CT2->CT2_DC			:= cTipo
	CT2->CT2_DEBITO		:= cDebito
	CT2->CT2_CREDIT		:= cCredito
	CT2->CT2_MOEDLC		:= cMoeda

	If cMoeda = '01'
		CT2->CT2_VALOR		:= nValor
	Else
		CT2->CT2_VALOR		:= aCols[Val(cMoeda)-nForaCols][3]
	EndIf

	CT2->CT2_HP			:= cHistPad
	CT2->CT2_CCD		:= cCustoDeb
	CT2->CT2_CCC		:= cCustoCrd
	CT2->CT2_ITEMD		:= cItemDeb
	CT2->CT2_ITEMC		:= cItemCrd
	CT2->CT2_CLVLDB		:= cClVlDeb
	CT2->CT2_CLVLCR		:= cClVlCrd
	CT2->CT2_HIST		:= cDescricao
	CT2->CT2_SEQHIS		:= StrZero(nContaLinhas,3)
	CT2->CT2_TPSALD		:= cTpSald
	CT2->CT2_SEQLAN		:= cSeqLan
	CT2->CT2_ROTINA		:= cRotina			// Indica qual o programa gerador
	CT2->CT2_MANUAL		:= Iif (AllTrim(cRotina) == 'CTBA101' .Or. AllTrim(cRotina) == 'CTBA102', "1" , "2")				// Lancamento manual
	CT2->CT2_AGLUT		:= "2"				// Nao aglutina
	CT2->CT2_MOEFDB		:= cMoFatDB			// Moeda do fato debito - Varia็ใo monetaria (CTBA382)
	CT2->CT2_MOEFCR		:= cMoFatCR			// Moeda do fato credito - Varia็ใo monetaria (CTBA382)

	If Alltrim(Upper(cRotina)) == "CTBA280" .and. cInterc == '1'
		CT2->CT2_INTERC := "1"
    ElseIf Alltrim(Upper(cRotina)) == "CTBA281" .AND. ( CTQ->CTQ_INTERC == "1" )
		CT2->CT2_INTERC := "1"
	EndIf
	If !Empty(dDataLP)
		CT2->CT2_DTLP	:= dDataLP
	EndIf

	If Len(aOutros) > 0
		aSaveSx3 := SX3->(GetArea())
		For nOutros	:= 1 to Len(aOutros)
			If Posicione("SX3",2,AllTrim(aoutros[nOutros]),"X3_CONTEXT") != "V"
				&("CT2->"+(aoutros[nOutros]))	:= &("M->"+(aoutros[nOutros]))
			EndIf
		Next
		RestArea(aSaveSx3)
		aSize(aSaveSx3,0)
		aSaveSx3 := nil 
	EndIf

	If CtbUso("CT2_DCD")
		If cDCD = Nil
			If CT2->CT2_DC $ "13"
				CT1->(MsSeek(xFilial() + CT2->CT2_DEBITO))
				cDCD := CT1->CT1_DC
			Else
				cDCD := ""
			EndIf
		EndIf
		CT2->CT2_DCD	:= cDCD
	EndIf
	If CtbUso("CT2_DCC")
		If cDCC = Nil
			If CT2->CT2_DC $ "23"
				CT1->(MsSeek(xFilial() + CT2->CT2_CREDIT))
				cDCC := CT1->CT1_DC
			Else
				cDCD := ""
			EndIf
		EndIf
		CT2->CT2_DCC	:= cDCC
	EndIf

	If lSeqCorr
		If cPaisLoc <>"BOL"  .Or. (cPaisloc=="BOL" .And.  funname()<> "CTBA211")
			If lAtuCorr
				// Grava sequancia do correlativo
				If (funname()=="CTBA381" .And. cPaisLoc == "PER")
					If Val(cLinha) < 2
						cSeqCorr := CTBSQGrv( cSeqCorr, dData )
					EndIf
				Else
					cSeqCorr := CTBSQGrv( cSeqCorr, dData ) // efetua a grava็ใo do numero gerado, caso jแ exista o numero, ele  irแ gerar um novo.
				EndIf
			EndIf
		EndIf

		CT2->CT2_SEGOFI	:= cSeqCorr
		CT2->CT2_NODIA 	:= cSeqCorr

		// Efetua a grava็ใo do codigo do diario no ct2
		If CT2->( FieldPos( "CT2_DIACTB" ) > 0 ) .And. !Empty(cSeqCorr)
			CT2->CT2_DIACTB := cCodSeq
		EndIf

		FreeUsedCode()  //libera codigos de correlativos reservados pela MayIUseCode()
	EndIf

	If cMoeda = '01'
		If CT2->CT2_VALOR = 0
			CT2->CT2_CRCONV := "5"
		Else
			CT2->CT2_CRCONV	:= "1"
	    EndIf
	Else
		If (Empty(aCols[Val(cMoeda)-nForaCols][2]) .And. CT2->CT2_VALOR = 0)
			CT2->CT2_CRCONV		:= "5"
		Else
			CT2->CT2_CRCONV		:= aCols[Val(cMoeda)-nForaCols][2]
		EndIf

		If lDtTxUso .And. ValType(aCols[Val(cMoeda)-nForaCols][5]) == "D"
			CT2->CT2_DATATX	:= 	aCols[Val(cMoeda)-nForaCols][5]
		EndIf

	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณgrava o status do lancamento contabil para que o mesmo sejaณ
	//ณvalidado na rotina de copia de saldos                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lMltSld
		CT2->CT2_CTLSLD	:= "0"
	EndIf

	If cPaisLoc == "RUS" .And. SuperGetMv("MV_REDSTORN",.F.,.F.)
		CT2->CT2_EC05DB		:= CT2->CT2_CREDIT
		CT2->CT2_EC05CR		:= CT2->CT2_DEBITO
	Else

		For nZ := 1 to Len(aEntAdc)

			CT2->&("CT2_EC" + STRZERO(nZ+4,2) + "DB" ) := aEntAdc[nZ,1]
			CT2->&("CT2_EC" + STRZERO(nZ+4,2) + "CR" ) := aEntAdc[nZ,2]

		Next nZ

	Endif

	// adiciona a fila o novo lancamento
	If __IsCtbJob .And. lInclui
		Aadd(aLinhas,{ cFilAux, cLote, cSublote, cDoc, dData, cLinha,cTpSald,cEmpOri,cFilOri,cMoeda })
		CTBGrvCQA(aLinhas)
	EndIf

ElseIf nTipo == 2   //continuacao de historico

	RecLock("CT2",lInclui)
	CT2->CT2_FILIAL		:= xFilial()
	CT2->CT2_DATA		:= dData
	CT2->CT2_LOTE		:= cLote
	CT2->CT2_SBLOTE		:= cSubLote
	CT2->CT2_DOC		:= cDoc
	CT2->CT2_LINHA		:= cLinha
	CT2->CT2_FILORI		:= cFilOri
	CT2->CT2_EMPORI		:= cEmpOri
	CT2->CT2_HIST		:= cDescricao
	CT2->CT2_DC			:= "4"				// Continuacao de Historico
	CT2->CT2_SEQHIS		:= StrZero(nContaLinhas,3)
	CT2->CT2_SEQLAN		:= cSeqLan
	CT2->CT2_TPSALD		:= cTpSald
	CT2->CT2_MOEDLC		:= cMoeda
	CT2->CT2_ROTINA		:= cRotina			// Indica qual o programa gerador
	CT2->CT2_MANUAL		:= "1"				// Lancamento manual
	CT2->CT2_AGLUT		:= "2"				// Nao aglutina
	CT2->CT2_SLBASE		:= "S"				// Flag de saldo basico

	If !Empty(dDataLP)
		CT2->CT2_DTLP	:= dDataLP
	EndIf

EndIf

//Ponto de Entrada para Gravacao de lancamentos contabeis
If _lCtbGrv
	ExecBlock("CTBGRV",.f.,.f.,{ nOpc,cRotina,dData,cLote,cSubLote,cDoc } )
EndIf

MsUnlock()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbLinSeq บAutor  ณMicrosiga           บ Data ณ  10/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna a ultima linha gravada no lancamento e ja incrementaบฑฑ
ฑฑบ          ณesta com a funcao Soma1()                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbLinSeq(cLinha,lInclui,lFirstHist,nContaLinhas,nLinhasAnt,dData,cLote,cSubLote,cDoc,cSeqLan,cEmpOri,cFilOri,nOpc)
Local cQuery
Local aArea
dbSelectArea("CT2")
CT2->(dbSetOrder(10))   //CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_SEQLAN+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC+CT2_SEQHIS
CT2->(dbSkip())
If  CT2->CT2_SEQLAN == cSeqLan .And. CT2->CT2_LOTE == cLote .And. ;
	CT2->CT2_SBLOTE == cSubLote .And. CT2->CT2_DOC == cDoc .And. ;
	DTOS(CT2_DATA) == DTOS(dData) .And. CT2->CT2_MOEDLC == '01' .And.;
	CT2->CT2_EMPORI == cEmpOri .And. CT2->CT2_FILORI == cFilOri
	lInclui := .F.
	cLinha	:= CT2->CT2_LINHA
Else
	//Se o Seqlan for dIferente e ainda existir lancamentos gravados
	//com a mesma sequencia, pulo para o proximo lancamento.
	If nContaLinhas <= nLinhasAnt
		While CT2->CT2_SEQLAN <> cSeqLan .And. CT2->(!Eof())
			CT2->(dbSkip())
			Loop
		End
        If CT2->CT2_LOTE == cLote .And. CT2->CT2_SBLOTE == cSubLote .And. CT2->CT2_DOC == cDoc .And. ;
			DTOS(CT2_DATA) == DTOS(dData) .And. CT2->CT2_MOEDLC == '01' .And.;
			CT2->CT2_EMPORI == cEmpOri .And. CT2->CT2_FILORI == cFilOri
			cLinha := CT2->CT2_LINHA
		EndIf
	Else
		lInclui := .T.
		If lFirstHist //Se for a primeira linha de historico complementar
			aArea := GetArea()
			cQuery := " SELECT "
	    	If _lOracle .Or. _lInformix
				cQuery += " NVL ( MAX(CT2_LINHA), '"+Space(LEN(CT2->CT2_LINHA))+"') CT2_LINHA"
    		ElseIf  _lDB2  .Or. _lPostgres
				cQuery += " COALESCE( MAX(CT2_LINHA), '"+Space(LEN(CT2->CT2_LINHA))+"') CT2_LINHA"
	    	Else
				cQuery += " ISNULL( MAX(CT2_LINHA), '"+Space(LEN(CT2->CT2_LINHA))+"') CT2_LINHA"
			EndIf
			cQuery += " FROM " + RetSqlName("CT2")+" CT2 "
			cQuery += " WHERE "
			cQuery += " CT2_FILIAL = '"+xFilial("CT2")+"' "
			cQuery += " AND CT2_LOTE = '"+cLote+"' "
			cQuery += " AND CT2_SBLOTE = '"+cSubLote+"' "
			cQuery += " AND CT2_DOC = '"+cDoc+"' "
			cQuery += " AND CT2.D_E_L_E_T_ = ' ' "


			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"CT2_QRY",.T.,.F.)

			If nOpc == 7 // para corrigir nบ da linha quando ้ c๓pia
				If CT2_QRY->(! Eof() ) .And. cLinha == CT2_QRY->CT2_LINHA
					cLinha	:= Soma1(CT2_QRY->CT2_LINHA)
				EndIf
			Else
				If CT2_QRY->(! Eof() ) .And. cLinha <> CT2_QRY->CT2_LINHA //para corre็ใo de error log na altera็ใo do hist๓rico pela CTBA101
					cLinha	:= Soma1(CT2_QRY->CT2_LINHA)
				EndIf
			Endif

			//dbSelectArea("CT2_QRY")
			CT2_QRY->(dbCloseArea())
			RestArea(aArea)
			aSize(aArea,0)
			aArea := nil 

			lFirstHist := .F.
		EndIf
	EndIf
EndIf

Return



///////////////////FUNCOES RETIRADO DO FONTE CTBXSAL.PRW E PASSADO PARA CTBXATU.PRW ////////////////////////
/*/



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbGrvHCP บAutor  ณMarcos R. Pires     บ Data ณ  05/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava็ใo do Hist๓rico na Capa do Lote na altera็ใo         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CtbGrvHCP(dData,cLote,cSubLote,cDoc,cMoeda,cHistLote)
Local aSaveArea	:= GetArea()
Local aSaveCTC	:= CTC->(GetArea())

DbSelectArea("CTC")
DbSetOrder(1)
If DbSeek(xFilial("CTC")+dtos(dData)+cLote+cSubLote+cDoc+cMoeda)
	RecLock( "CTC", .F. )
	CTC->CTC_DOCHIS := cHistLote
	MsUnlock()
EndIf

RestArea(aSaveCTC)
aSize(aSaveCTC,0)
aSaveCTC := nil 
RestArea(aSaveArea)
aSize(aSaveArea,0)
aSaveArea := nil 


Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBA102   บAutor  ณMicrosiga           บ Data ณ  08/11/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ   Exclui as linhas que ficaram no TRW na alteracao de      บฑฑ
ฑฑบ          ณlancamentos por procedures                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ctb_TRW_(nOpC, _lCTB153, _lCTB150, cFil, cDataLanc, cLote, cSubLote, cDoc, cFilOri, cEmpOri, cLinha )
Local lMudaTRT      := SuperGetMV("MV_MUDATRT",.F.,.F.)
Local cTableTRW     := If(lMudaTRT, "TRW"+SM0->M0_CODIGO+"0"+"_SP", "TRW"+SM0->M0_CODIGO+"0")

If _lCTB153 .and. _lCTB150 .and. nOpc == 4
	cDropTRW := " Delete from "+cTableTRW
	cDropTRW += " Where CT2_FILIAL = '"+cFil+"'"
	cDropTRW += "   and CT2_DATA   = '"+cDataLanc+"'"
	cDropTRW += "   and CT2_LOTE   = '"+cLote+"'"
	cDropTRW += "   and CT2_SBLOTE = '"+cSubLote+"'"
	cDropTRW += "   and CT2_DOC    = '"+cDoc+"'"
	cDropTRW += "   and CT2_FILORI = '"+cFilOri+"'"
	cDropTRW += "   and CT2_EMPORI = '"+cEmpOri+"'"
	cDropTRW += "   and CT2_LINHA  = '"+cLinha+"'"
	cDropTRW += "   and D_E_L_E_T_ = ' '"

	If TcSqlExec(cDropTRW) <> 0
		UserException(STR0045 + CRLF + STR0046+ CRLF + TCSqlError() )//"Erro na exclusao de linha do TRW "##"Efetuar o Reprocessamento dos saldos"
	EndIf
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtb101_TRWบAutor  ณMicrosiga           บ Data ณ  08/11/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ   Exclui as linhas que ficaram no TRW na exclusao de lanca-บฑฑ
ฑฑบ          ณmentos por procedures/job_ctb_sal                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ctb101_TRW(nOpC, _lCTB153, _lCTB150, cFil, cDataLanc, cLote, cSubLote, cDoc, cFilOri, cEmpOri, cLinha )
Local lMudaTRT      := SuperGetMV("MV_MUDATRT",.F.,.T.)
Local cTableTRW     := If(lMudaTRT, "TRW"+SM0->M0_CODIGO+"0"+"_SP", "TRW"+SM0->M0_CODIGO+"0")

If _lCTB153 .and. _lCTB150 .and. (nOpc == 5 .or. nOpc == 4)
	cDropTRW := " Delete from "+cTableTRW
	cDropTRW += " Where CT2_FILIAL = '"+cFil+"'"
	cDropTRW += "   and CT2_DATA   = '"+cDataLanc+"'"
	cDropTRW += "   and CT2_LOTE   = '"+cLote+"'"
	cDropTRW += "   and CT2_SBLOTE = '"+cSubLote+"'"
	cDropTRW += "   and CT2_DOC    = '"+cDoc+"'"
	cDropTRW += "   and CT2_FILORI = '"+cFilOri+"'"
	cDropTRW += "   and CT2_EMPORI = '"+cEmpOri+"'"
	cDropTRW += "   and CT2_LINHA != '"+cLinha+"'"
	cDropTRW += "   and D_E_L_E_T_ = ' '"

	If TcSqlExec(cDropTRW) <> 0
		UserException(STR0045 + CRLF + STR0046+ CRLF + TCSqlError() )//"Erro na exclusao de linha do TRW "##"Efetuar o Reprocessamento dos saldos"
	EndIf
EndIf
Return()


//---------------------------------------------------------------------------------
/*/{Protheus.doc} CtbGrvCQB
Grava/Altera/Exclui os lan็amentos na tabela CQB em que a moeda do fato ้ diferente
da moeda forte (01). Dados utilizados no cแlculo da varia็ใo cambial (CTBA382).

@author Totvs
@since 18/11/2014
@version P11 R8

@param nTipoMov	,Numerico	,Indica o tipo de movimento (1=Debito,2=Credito)
@param cOperacao	,Caractere	,Indica a opera็ใo no saldo (+=Soma,-=Subtrai)
@param dData		,Data		,Data do lan็amento
@param cMoeda		,Caractere	,Moeda do lan็amento (moeda estrangeira)
@param nVal		,Num้rico	,Valor do lan็amento
@param cConta		,Caractere	,Conta contแbil
@param cCCusto		,Caractere	,Centro de Custo
@param cItem		,Caractere	,Item Contแbil
@param cCLVL		,Caractere	,Classe de Valor
@param cEnt05		,Caractere	,Entidade 05
@param cEnt06		,Caractere	,Entidade 06
@param cEnt07		,Caractere	,Entidade 07
@param cEnt08		,Caractere	,Entidade 08
@param cEnt09		,Caractere	,Entidade 09

@return Nil
/*/
//-----------------------------------------------------------------------------------
Function GravaCQB(nTipoMov,cOperacao,dData,cMoeda,nCotMoeda,nVal,cConta,cCCusto,cItem,cCLVL,aEntidAdc)
Local aArea		:= GetArea()
Local lIncluiCQB	:= .F.
Local lAlteraCQB	:= .F.
Local lExcluiCQB	:= .F.
Local cAliasQry	:= GetNextAlias()
Local cEnt05		:= CriaVar("CQB_ENT05",.F.)
Local cEnt06		:= CriaVar("CQB_ENT06",.F.)
Local cEnt07		:= CriaVar("CQB_ENT07",.F.)
Local cEnt08		:= CriaVar("CQB_ENT08",.F.)
Local cEnt09		:= CriaVar("CQB_ENT09",.F.)
Local nX			:= 0

Default nTipoMov	:= 0
Default cOperacao	:= ""
Default dData		:= CriaVar("CQB_DATA",.F.)
Default cMoeda		:= CriaVar("CQB_MOEDA",.F.)
Default nCotMoeda	:= 0
Default nVal		:= 0
Default cConta		:= CriaVar("CQB_CONTA",.F.)
Default cCCusto		:= CriaVar("CQB_CCUSTO",.F.)
Default cItem		:= CriaVar("CQB_ITEM",.F.)
Default cCLVL		:= CriaVar("CQB_CLVL",.F.)
Default aEntidAdc	:= {}

//Alimenta as variveis das entidades adicionais
//Nao inseri uma atribui็ใo dinamica pois a macro execu็ใo estแ falhando
For nX := 1 To Len(aEntidAdc)
	If nX == 1
		cEnt05 := aEntidAdc[nX][nTipoMov]
	ElseIf nX == 2
		cEnt06 := aEntidAdc[nX][nTipoMov]
	ElseIf nX == 3
		cEnt07 := aEntidAdc[nX][nTipoMov]
	ElseIf nX == 4
		cEnt08 := aEntidAdc[nX][nTipoMov]
	ElseIf nX == 5
		cEnt09 := aEntidAdc[nX][nTipoMov]
	EndIf
Next nX

//-------------------------------
// Verifica se o registro existe
//-------------------------------
BeginSQL Alias cAliasQry

SELECT
	CQB.R_E_C_N_O_
FROM
	%Table:CQB% CQB
WHERE
	CQB_FILIAL			= %XFilial:CQB%
	AND CQB_DATA		= %Exp:dData%
	AND CQB_MOEDA		= %Exp:cMoeda%
	AND CQB_CONTA		= %Exp:cConta%
	AND CQB_CCUSTO	= %Exp:cCCusto%
	AND CQB_ITEM		= %Exp:cItem%
	AND CQB_CLVL		= %Exp:cCLVL%
	AND CQB_ENT05		= %Exp:cEnt05%
	AND CQB_ENT06		= %Exp:cEnt06%
	AND CQB_ENT07		= %Exp:cEnt07%
	AND CQB_ENT08		= %Exp:cEnt08%
	AND CQB_ENT09		= %Exp:cEnt09%
	AND CQB_COTMOE	= %Exp:nCotMoeda%
	AND CQB.%NotDel%

EndSQL

If (cAliasQry)->(!Eof())

	DbSelectArea("CQB")
	CQB->(DbSetOrder(1))
	CQB->(DbGoTo((cAliasQry)->R_E_C_N_O_))

	//------------------------------------
	// Alteracao de registro
	// Aumentou o valor do saldo na data
	//------------------------------------
	If cOperacao == "+"
		lAlteraCQB := .T.

	//---------------------------------------------------------------
	// Altera็ใo/Exclusใo do registro de acordo com o saldo restante
	//---------------------------------------------------------------
	ElseIf cOperacao == "-"
		If nTipoMov == 1 //Debito
			If (CQB->CQB_DEBITO - nVal) == 0
				lExcluiCQB := .T.
			Else
				lAlteraCQB := .T.
			EndIf
		ElseIf nTipoMov == 2 //Credito
			If (CQB->CQB_CREDIT - nVal) == 0
				lExcluiCQB := .T.
			Else
				lAlteraCQB := .T.
			EndIf
		EndIf
	EndIf

//-------------------------------------------------------------
// Caso nao exista e seja inclusao/alteracao inclui o registro
//-------------------------------------------------------------
ElseIf cOperacao == "+"
	lIncluiCQB := .T.
EndIf

//-----------------------
// Atualiza a tabela CQB
//-----------------------
Do Case
	//-----------
	// Alteracao
	//-----------
	Case lAlteraCQB
		RecLock("CQB",.F.)
		If nTipoMov == 1 //Debito
			If cOperacao == "-"
				CQB->CQB_DEBITO := CQB->CQB_DEBITO - nVal
			ElseIf cOperacao == "+"
				CQB->CQB_DEBITO := CQB->CQB_DEBITO + nVal
			EndIf
		ElseIf nTipoMov == 2 //Credito
			If cOperacao == "-"
				CQB->CQB_CREDIT := CQB->CQB_CREDIT - nVal
			ElseIf cOperacao == "+"
				CQB->CQB_CREDIT := CQB->CQB_CREDIT + nVal
			EndIf
		EndIf
		CQB->(MsUnlock())

	//-----------
	// Exclusao
	//-----------
	Case lExcluiCQB
		RecLock("CQB",.F.)
		CQB->(DBDelete())
		CQB->(MsUnlock())

	//-----------
	// Inclusao
	//-----------
	Case lIncluiCQB
		RecLock("CQB",.T.)
		CQB->CQB_FILIAL	:= XFilial("CQB")
		CQB->CQB_IDSLD	:= FWUUIDV4()
		CQB->CQB_DATA	:= dData
		CQB->CQB_MOEDA	:= cMoeda
		If nTipoMov == 1 //Debito
			CQB->CQB_DEBITO := nVal
		ElseIf nTipoMov == 2 //Credito
			CQB->CQB_CREDIT := nVal
		EndIf
		CQB->CQB_CONTA	:= cConta
		CQB->CQB_CCUSTO	:= cCCusto
		CQB->CQB_ITEM	:= cItem
		CQB->CQB_CLVL	:= cCLVL
		CQB->CQB_ENT05	:= cEnt05
		CQB->CQB_ENT06	:= cEnt06
		CQB->CQB_ENT07	:= cEnt07
		CQB->CQB_ENT08	:= cEnt08
		CQB->CQB_ENT09	:= cEnt09
		CQB->CQB_COTMOE	:= nCotMoeda
		CQB->(MsUnlock())
EndCase
(cAliasQry)->(dbCloseArea())
RestArea(aArea)

Return Nil

//---------------------------------------------------------------------------------
/*/{Protheus.doc} VldAltCQB
Funcao para indicar se houve alteracao nos dados que a CQB considera para composicao
do saldo

@author Totvs
@since 26/11/2014
@version P11 R8

/*/
//---------------------------------------------------------------------------------
Function VldAltCQB(	nOpc,;
						cDebito	,cCredito		,cCustoDeb		,cCustoCrd		,cItemDeb	,cItemCrd	,cClVlDeb	,cClVlCrd	,aEntid,;
						cDebitoAnt	,cCreditoAnt	,cCustoDAnt	,cCustoCAnt	,cItemDAnt	,cItemCAnt	,cCLVLDAnt	,cCLVLCAnt	,aEntidAnt,;
						nValor,nValAnt,;
						cMoFatDB,cMoAnFatDB,;
						cMoFatCR,cMoAnFatCR)
Local lRet	:= .F.
Local nX	:= 0

If nOpc == 4
	If cDebito+cCustoDeb+cItemDeb+cClVlDeb <> cDebitoAnt+cCustoDAnt+cItemDAnt+cCLVLDAnt
		lRet := .T.
	ElseIf cCredito+cCustoCrd+cItemCrd+cClVlCrd <> cCreditoAnt+cCustoCAnt+cItemCAnt+cCLVLCAnt
		lRet := .T.
	ElseIf nValor <> nValAnt
		lRet := .T.
	ElseIf cMoFatDB <> cMoAnFatDB
		lRet := .T.
	ElseIf cMoFatCR <> cMoAnFatCR
		lRet := .T.
	EndIf

	//---------------------------------------------------
	// Avalia se as entidades adicionais foram alteradas
	//---------------------------------------------------
	If lRet == .F.
		For nX := 1 To Len(aEntid)
			If aEntid[nX,1] <> aEntidAnt[nX,1] .Or. aEntid[nX,2] <> aEntidAnt[nX,2]
				lRet := .T.
				Exit
			EndIf
		Next nX
	EndIf
Else
	lRet	:= .T.
EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} GRAVACT7
Rotina de grava็ใo de saldos online substituida pela rotina GRAVACQ()

@author Alvaro Camillo Neto

@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Function GRAVACT7(nOpc,cContaDeb,cContaCrd,cTipo,dData,cMoeda,nValor,cTpSald,lReproc,lAtSldBase,lZera,dDataLP,lTrbProc,cOperacao)

//Redirecionada para a GRAVACQ0
GRAVACQ("CT1",nOpc,cContaDeb,cContaCrd,/*cCustoDeb*/,/*cCustoCrd*/,/*cItemDeb*/,/*cItemCrd*/,/*cClassDeb*/,/*cClassCrd*/,/*cIdent*/,cTipo,dData,cMoeda,nValor,cTpSald,lReproc,lAtSldBase,lZera,dDataLP,lTrbProc,cOperacao)

Return

//-------------------------------------------------------------------
/*{Protheus.doc} GravaCt3
Grava Saldos dos Centros de Custo e atualiza saldo dia dia.
substituida pela rotina GRAVACQ()

@author Alvaro Camillo Neto

@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------

Function GRAVACT3(cContaDeb,cCustoDeb,cContaCrd,cCustoCrd,cTipo,dData,cMoeda,nValor,cTpSald,lReproc,lAtSldBase,lZera,dDataLP,nOpc,lTrbProc,cOperacao)

//Redirecionada para a GRAVACQ
GRAVACQ("CTT",nOpc,cContaDeb,cContaCrd,cCustoDeb,cCustoCrd,/*cItemDeb*/,/*cItemCrd*/,/*cClassDeb*/,/*cClassCrd*/,/*cIdent*/,cTipo,dData,cMoeda,nValor,cTpSald,lReproc,lAtSldBase,lZera,dDataLP,lTrbProc,cOperacao)

Return


//-------------------------------------------------------------------
/*{Protheus.doc} GravaCt4
Grava Saldos dos Itens Contabeis e atualiza saldo dia dia
substituida pela rotina GRAVACQ()

@author Alvaro Camillo Neto

@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------

Function GRAVACT4(cContaDeb,cCustoDeb,cItemDeb,cContaCrd,cCustoCrd,cItemCrd,cTipo,dData,cMoeda,nValor,cTpSald,lReproc,lAtSldBase,lZera,dDataLP,nOpc,lTrbProc,cOperacao)

//Redirecionada para a GRAVACQ
GRAVACQ("CTD",nOpc,cContaDeb,cContaCrd,cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,/*cClassDeb*/,/*cClassCrd*/,/*cIdent*/,cTipo,dData,cMoeda,nValor,cTpSald,lReproc,lAtSldBase,lZera,dDataLP,lTrbProc,cOperacao)

Return

//-------------------------------------------------------------------
/*{Protheus.doc} GravaCt4
Grava Saldos da Classe de Valores  atualiza saldo dia dia
substituida pela rotina GRAVACQ()

@author Alvaro Camillo Neto

@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------

Function GRAVACTI(cContaDeb,cCustoDeb,cItemDeb,cClVlrDeb,cContaCrd,cCustoCrd,cItemCrd,cClVlrCrd,cTipo,dData,cMoeda,nValor,cTpSald,lReproc,lAtSldBase,lZera,dDataLP,nOpc,lTrbProc,cOperacao)

//Redirecionada para a GRAVACQ
GRAVACQ("CTH",nOpc,cContaDeb,cContaCrd,cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlrDeb,cClVlrCrd,/*cIdent*/,cTipo,dData,cMoeda,nValor,cTpSald,lReproc,lAtSldBase,lZera,dDataLP,lTrbProc,cOperacao)

Return


//-------------------------------------------------------------------
/*{Protheus.doc} GRAVACQ
Grava Saldos das Contas Contabeis e atualiza saldo dia dia

@author Alvaro Camillo Neto

@param cArqBase 		Arquivo Base para o saldo ( CT1 - Conta , CTT - Centro de Custo, CTD - Item Contแbil , CTH - Classe de Valor, CTU - Saldo por entidade )
@param nOpc 			Op็ใo de tela ( 3 - Inclusao, 4 - Altera็ใo, 5 - Exclusใo)
@param cContaDeb 		Conta D้bito
@param cContaCrd		Conta Credito
@param cCustoDeb 		Centro de Custo D้bito
@param cCustoCrd		Centro de Custo Credito
@param cItemDeb 		Item Contแbil D้bito
@param cItemCrd		Item Contแbil Credito
@param cClassDeb 		Classe de Valor D้bito
@param cClassCrd		Classe de Valor Credito
@param cIdent			Identificado( Para saldo por entidade )
@param cTipo 			Tipo do Lancamento Contabil
@param dData 			Data do Lancamento Contabil
@param cMoeda 		Moeda do Lancamento Contabil
@param nValor 		Valor do Lancamento Contabil
@param cTpSald 		Tipo do Saldo
@param lReproc 		Define se foi chamado pelo Reprocessamento
@param lAtSldBase 	Define se o saldo basico eh atualizado na dig.lanc.
@param lZera 			Define se deve zerar os movimentos.
@param dDataLP 		Data do Lan็amento de Lucros/Perdas
@param lTrbProc 		Flag de processamento com procedure
@param cOperacao 		Opera็ใo ( Soma/Subtrai)

@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------

Function GRAVACQ(cArqBase,nOpc,cContaDeb,cContaCrd,cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClassDeb,cClassCrd,cIdent,;
				cTipo,dData,cMoeda,nValor,cTpSald,lReproc,lAtSldBase,lZera,dDataLP,lTrbProc,cOperacao,cFilMov,aEntid)

Local aSaveArea	:= GetArea()
Local lInclui		:= .F.
Local cChave		:= ""
//Local aResult		:= {}
Local nX			:= 0
Local cConta  	:= ""
Local cCusto  	:= ""
Local cItem  		:= ""
Local cClasse 	:= ""
Local cCodigo 	:= ""
Local cTipoAux	:= ""
Local lDeletSald	:= .F.
Local nTabela 	:= 0 // Tabela 1- Mensal, Tabela 2-Diแrio
Local cArquivo 	:= ""
Local dDataChv	:= CTOD("")
Local aArq			:= Array(2)
Local cLP			:= ""
Local cFilX		:= cFilAnt
Local lRedStorn	:= cPaisLoc == "RUS" .And. SuperGetMV("MV_REDSTOR",.F.,.F.) // CAZARINI - 20/06/2017 - Parameter to activate Red Storn
Local cEnt05	:= ""
Local nLenEnt05	:= 0

Default cContaDeb		:= ""
Default cContaCrd		:= ""
Default cCustoDeb		:= ""
Default cCustoCrd		:= ""
Default cItemDeb		:= ""
Default cItemCrd		:= ""
Default cClassDeb		:= ""
Default cClassCrd		:= ""
Default cIdent		:= ""
Default cTipo			:= ""
Default dData			:= CTOD("")
Default cMoeda		:= ""
Default nValor		:= 0
Default cTpSald		:= ""
Default lReproc 		:= .F.
Default lAtSldBase 	:= .T.
Default lZera			:= .F.
Default dDataLP		:= CTOD("")
Default lTrbProc  	:= .F.
Default cOperacao 	:= "+"
Default cFilMov		:= cFilAnt
Default aEntid		:= {}

If __lCTB180 == Nil
	__lCTB180 := ExistProc("CTB180")
	__lCTB181 := ExistProc("CTB181")
	__lCTB182 := ExistProc("CTB182")
	__lCTB183 := ExistProc("CTB183")
	//__lCTB184 := ExistProc("CTB180")
EndIf

cFilAnt := cFilMov

cLP	 := IIF(Empty(dDataLP),"N","Z")

If cArqBase == "CT1"
	dbSelectArea("CQ0")
	dbSelectArea("CQ1")
	CQ0->(dbSetOrder(1)) //CQ0_FILIAL+DTOS(CQ0_DATA)+CQ0_CONTA+CQ0_MOEDA+CQ0_TPSALD+CQ0_LP
	CQ1->(dbSetOrder(1)) //CQ1_FILIAL+DTOS(CQ1_DATA)+CQ1_CONTA+CQ1_MOEDA+CQ1_TPSALD+CQ1_LP
	aArq[1] := "CQ0"
	aArq[2] := "CQ1"
ElseIf cArqBase == "CTT"
	dbSelectArea("CQ2")
	dbSelectArea("CQ3")
	CQ2->(dbSetOrder(1)) //CQ2_FILIAL+DTOS(CQ2_DATA)+CQ2_CCUSTO+CQ2_CONTA+CQ2_MOEDA+CQ2_TPSALD+CQ2_LP
	CQ3->(dbSetOrder(1)) //CQ3_FILIAL+DTOS(CQ3_DATA)+CQ3_CCUSTO+CQ3_CONTA+CQ3_MOEDA+CQ3_TPSALD+CQ3_LP
	aArq[1] := "CQ2"
	aArq[2] := "CQ3"
ElseIf cArqBase == "CTD"
	dbSelectArea("CQ4")
	dbSelectArea("CQ5")
	CQ4->(dbSetOrder(1)) //CQ4_FILIAL+DTOS(CQ4_DATA)+CQ4_ITEM+CQ4_CCUSTO+CQ4_CONTA+CQ4_MOEDA+CQ4_TPSALD+CQ4_LP
	CQ5->(dbSetOrder(1)) //CQ5_FILIAL+DTOS(CQ5_DATA)+CQ5_ITEM+CQ5_CCUSTO+CQ5_CONTA+CQ5_MOEDA+CQ5_TPSALD+CQ5_LP
	aArq[1] := "CQ4"
	aArq[2] := "CQ5"
ElseIf cArqBase == "CTH"
	dbSelectArea("CQ6")
	dbSelectArea("CQ7")
	CQ6->(dbSetOrder(1)) //CQ6_FILIAL+DTOS(CQ6_DATA)+CQ6_CLVL+CQ6_ITEM+CQ6_CCUSTO+CQ6_CONTA+CQ6_MOEDA+CQ6_TPSALD+CQ6_LP
	CQ7->(dbSetOrder(1)) //CQ7_FILIAL+DTOS(CQ7_DATA)+CQ7_CLVL+CQ7_ITEM+CQ7_CCUSTO+CQ7_CONTA+CQ7_MOEDA+CQ7_TPSALD+CQ7_LP
	aArq[1] := "CQ6"
	aArq[2] := "CQ7"
ElseIf cArqBase == "CTU"
	dbSelectArea("CQ7")
	dbSelectArea("CQ8")
	CQ7->(dbSetOrder(1)) //CQ8_FILIAL+DTOS(CQ8_DATA)+CQ8_IDENT+CQ8_CODIGO+CQ8_MOEDA+CQ8_TPSALD+CQ8_LP
	CQ8->(dbSetOrder(1)) //CQ9_FILIAL+DTOS(CQ9_DATA)+CQ9_IDENT+CQ9_CODIGO+CQ9_MOEDA+CQ9_TPSALD+CQ9_LP
	aArq[1] := "CQ8"
	aArq[2] := "CQ9"
	If lEntidad05 .And. cIdent $ "CV0/QL6/QL7"
		cIdent := "CV0"
		nLenEnt05 := Len(CQ8->CQ8_CODIGO)
	EndIf
ElseIf lEntidad05 .And. cArqBase $ "CV0/QL6/QL7"
	cArqBase := "QL6"
	nLenEnt05 := Len(QL6->QL6_ENT05)
	dbSelectArea("QL6")
	dbSelectArea("QL7")
	QL6->(dbSetOrder(1)) //QL6_FILIAL+DTOS(QL6_DATA)+QL6_ENT05+QL6_CLVL+QL6_ITEM+QL6_CCUSTO+QL6_CONTA+QL6_MOEDA+QL6_TPSALD+QL6_LP
	QL7->(dbSetOrder(1)) //QL7_FILIAL+DTOS(QL7_DATA)+QL7_ENT05+QL7_CLVL+QL7_ITEM+QL7_CCUSTO+QL7_CONTA+QL7_MOEDA+QL7_TPSALD+QL7_LP
	aArq[1] := "QL6"
	aArq[2] := "QL7"
EndIf

If (nValor > 0 .and. !lRedStorn) .OR. (nValor <> 0 .and. lRedStorn)
	For nTabela:= 1 to 2
		If nTabela == 1
			cArquivo := aArq[1]
			dDataChv:= LastDay(dData)
		Else
			cArquivo := aArq[2]
			dDataChv:= dData
		EndIf

		For nX := 1 TO If(cTipo=='3', 2, 1)
			If cTipo == '3'
				If nX == 1
					cConta 	:= cContaDeb
					cCusto  	:= cCustoDeb
					cItem  	:= cItemDeb
					cClasse 	:= cClassDeb
					cTipoAux 	:= '1'
				Else
					cConta 	:= cContaCrd
					cCusto  	:= cCustoCrd
					cItem  	:= cItemCrd
					cClasse 	:= cClassCrd
					cTipoAux := '2'
				EndIf
			Else

				If cTipo == '1'
					cConta 	:= cContaDeb
					cCusto  	:= cCustoDeb
					cItem  	:= cItemDeb
					cClasse 	:= cClassDeb
					cTipoAux := '1'
				Else
					cConta 	:= cContaCrd
					cCusto  	:= cCustoCrd
					cItem  	:= cItemCrd
					cClasse 	:= cClassCrd
					cTipoAux := '2'
				EndIf
			EndIf

			If lEntidad05 .And. cArqBase == "QL6" .Or. (cArqBase == "CTU" .And. cIdent == "CV0")
				// Array de c๓digos de entidad 05 debe tener 2 elementos.
				// Si cTipo "1" = {"d้bito",""}, "2" = {"","cr้dito"}, "3" = {"d้bito","cr้dito"}
				If Len(aEntid) == 2
					cEnt05 :=LEFT( aEntid[Val(cTipoAux)] , nLenEnt05 ) 
					If Len(cEnt05) < nLenEnt05
						cEnt05 :=PADR( aEntid[Val(cTipoAux)] , nLenEnt05," " ) 
					Endif
				Else
					cEnt05 := ""
				EndIf
			EndIf

			If cArqBase == "CT1"
				If Empty(cConta)
					Loop
				EndIf

				cChave	:= xFilial(cArquivo)+Dtos(dDataChv)+cConta+cMoeda+cTpSald+cLp
			ElseIf cArqBase == "CTT"
				If Empty(cCusto)
					Loop
				EndIf
				cChave	:= xFilial(cArquivo)+Dtos(dDataChv)+cCusto+cConta+cMoeda+cTpSald+cLp
			ElseIf cArqBase == "CTD"
				If Empty(cItem)
					Loop
				EndIf
				cChave	:= xFilial(cArquivo)+Dtos(dDataChv)+cItem+cCusto+cConta+cMoeda+cTpSald+cLp
			ElseIf cArqBase == "CTH"
				If Empty(cClasse)
					Loop
				EndIf
				cChave	:= xFilial(cArquivo)+Dtos(dDataChv)+cClasse+cItem+cCusto+cConta+cMoeda+cTpSald+cLp
			ElseIf lEntidad05 .And. cArqBase == "QL6"
				If Empty(cEnt05)
					Loop
				EndIf
				cChave	:= xFilial(cArquivo)+Dtos(dDataChv)+cEnt05+cClasse+cItem+cCusto+cConta+cMoeda+cTpSald+cLp
			ElseIf cArqBase == "CTU"
				If cIdent == "CTT"
					cCodigo := cCusto
				ElseIf cIdent == "CTD"
					cCodigo := cItem
				ElseIf cIdent == "CTH"
					cCodigo := cClasse
				ElseIf lEntidad05 .And. cIdent == "CV0"
					cCodigo := cEnt05
				EndIf

				If Empty(cCodigo)
					Loop
				EndIf

				cChave	:= xFilial(cArquivo)+Dtos(dDataChv)+cIdent+cCodigo+cMoeda+cTpSald+cLp
			EndIf

			If (cArquivo)->(!MsSeek(cChave))
				lInclui	:= .T.
			Else
				lInclui := .F.
				//Se nao for lancamento de zeramento e posicionar no saldo de zeramento.
				//Devera ser incluido um novo registro.
				If Empty(dDataLP) .And. (cArquivo)->&(cArquivo+"_LP") == 'Z'
					lInclui := .T.
				EndIf
			EndIf

			BEGIN TRANSACTION
				// Nao ha registro para o dia -> cria!!
				If lInclui
					RecLock( cArquivo, .t. )

					&(cArquivo+"->"+cArquivo+"_FILIAL")		:= xFilial(cArquivo)
					&(cArquivo+"->"+cArquivo+"_MOEDA")			:= cMoeda
					&(cArquivo+"->"+cArquivo+"_TPSALD")		:= cTpSald
					&(cArquivo+"->"+cArquivo+"_DATA")			:= dDataChv
					&(cArquivo+"->"+cArquivo+"_STATUS")		:= '1'
					&(cArquivo+"->"+cArquivo+"_LP")				:= cLp
					&(cArquivo+"->"+cArquivo+"_DTLP")			:= dDataLP
					//Entidades
					If cArqBase != "CTU"
						&(cArquivo+"->"+cArquivo+"_CONTA")			:= cConta
						If lEntidad05 .And. cArqBase == 'QL6'
							&(cArquivo+"->"+cArquivo+"_ENT05")	:= cEnt05
							&(cArquivo+"->"+cArquivo+"_CCUSTO")	:= cCusto
							&(cArquivo+"->"+cArquivo+"_ITEM")	:= cItem
							&(cArquivo+"->"+cArquivo+"_CLVL")	:= cClasse
						ElseIf cArqBase== 'CTH'
							&(cArquivo+"->"+cArquivo+"_CLVL")		:= cClasse
							&(cArquivo+"->"+cArquivo+"_ITEM")		:= cItem
							&(cArquivo+"->"+cArquivo+"_CCUSTO")	:= cCusto
						ElseIf cArqBase== 'CTD'
							&(cArquivo+"->"+cArquivo+"_ITEM")		:= cItem
							&(cArquivo+"->"+cArquivo+"_CCUSTO")	:= cCusto
						ElseIf cArqBase == 'CTT'
							&(cArquivo+"->"+cArquivo+"_CCUSTO")	:= cCusto
						EndIf
					Else
						&(cArquivo+"->"+cArquivo+"_IDENT")			:= cIdent
						&(cArquivo+"->"+cArquivo+"_CODIGO")		:= cCodigo
					EndIf
				Else
					RecLock( cArquivo, .f. )
					//Se o programa for CTBA360, devo zerar os movimentos
					If lZera
						If cTipoAux == "1"
							&(cArquivo+"->"+cArquivo+"_DEBITO")	:= 0
						ElseIf cTipoAux == "2"
							&(cArquivo+"->"+cArquivo+"_CREDIT")	:= 0
						EndIf
					EndIf
				EndIf

				// Grava valores atuais
				// Soma valores aos ja existentes
				If cTipoAux == "1"
					If cOperacao == "-" .And. (cArquivo)->&(cArquivo+"_DEBITO") < nValor .and. !lRedStorn   //se for tirar e o resultado for negativo zera
						&(cArquivo+"->"+cArquivo+"_DEBITO") := 0
					Else
						&(cArquivo+"->"+cArquivo+"_DEBITO")	:= (&(cArquivo+"->"+cArquivo+"_DEBITO") + If(cOperacao=="+",nValor,nValor*-1) )
					EndIf
				ElseIf cTipoAux == "2"
					If cOperacao == "-" .And. (cArquivo)->&(cArquivo+"_CREDIT") < nValor .and. !lRedStorn    //se for tirar e o resultado for negativo zera
						&(cArquivo+"->"+cArquivo+"_CREDIT") := 0
					Else
						&(cArquivo+"->"+cArquivo+"_CREDIT")	:= (&(cArquivo+"->"+cArquivo+"_CREDIT")+ If(cOperacao=="+",nValor,nValor*-1) )
					EndIf

				EndIf
				//Atualiza flag de saldo basico.
				&(cArquivo+"->"+cArquivo+"_SLBASE"):= "S"
				MsUnlock()

				If cOperacao == '-'
					(cArquivo)->(dbCommit())

					//Se na exclusao, zerar os valores de mov. debito e credito, deleta o registro no
					//arquivo de saldos, pois no reprocessamento nao refaz os saldos que nao tenham
					//lancamentos no CT2, e da dIferenca no balancete.
					If &(cArquivo+"->"+cArquivo+"_CREDIT") == 0  .And. (cArquivo)->&(cArquivo+"_DEBITO") == 0
						RecLock(cArquivo,.F.,.T.)
						(cArquivo)->(dbDelete())
						(cArquivo)->(MsUnlock())
						(cArquivo)->(dbSkip())
						lDeletSald := .T.
					EndIf
				EndIf

			END TRANSACTION


		Next nX
	Next nY

	// Grava o Saldo por entidade
	If lEntidad05
		If cArqBase == "CTT" .Or. cArqBase == "CTD" .Or. cArqBase == "CTH" .Or. cArqBase == "QL6"
			GRAVACQ("CTU",nOpc,cContaDeb,cContaCrd,cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClassDeb,cClassCrd,cArqBase,;
				cTipo,dData,cMoeda,nValor,cTpSald,lReproc,lAtSldBase,lZera,dDataLP,lTrbProc,cOperacao,,aEntid)
		EndIf
	ElseIf cArqBase == "CTT" .Or. cArqBase == "CTD" .Or. cArqBase == "CTH"
		GRAVACQ("CTU",nOpc,cContaDeb,cContaCrd,cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClassDeb,cClassCrd,cArqBase,;
			cTipo,dData,cMoeda,nValor,cTpSald,lReproc,lAtSldBase,lZera,dDataLP,lTrbProc,cOperacao)
	EndIf
EndIf


RestArea(aSaveArea)

cFilAnt := cFilX

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBXFUN   บAutor  ณEdson Maricate      บ Data ณ  01/16/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica็ใo de atualiza็ใo de saldos MV_ATUSAL = N          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AtuCv7Date(cTipoSld,cMoeda,dData)
Local aArea	:= GetArea()

If !__lChkCV7
	__lChkCV7 := .T.
EndIf

dbSelectArea("CV7")
If !(CV7->(xFilial('CV7'))+cMoeda+cTipoSLD == __aCache[1])
	CV7->(dbSetOrder(1))
	If CV7->(dbSeek(xFilial('CV7')+cMoeda+cTipoSld))
		__aCache[1] := CV7->(xFilial('CV7'))+cMoeda+cTipoSLD
		__aCache[2] := CV7->(Recno())
	EndIf 
Else
	CV7->(MsGoto(__aCache[2]))
Endif
IF CV7->(!Eof())
	If CV7->CV7_DATA > dData-1
		RecLock("CV7",.F.)
		CV7->CV7_DATA := dData - 1
		MsUnlock()
	EndIf
Else
	RecLock("CV7",.T.)
	CV7->CV7_FILIAL	:= xFilial("CV7")
	CV7->CV7_MOEDA	:= cMoeda
	CV7->CV7_DATA 	:= ctod("01/01/80")
	CV7->CV7_TPSALD	:= cTipoSld
	MsUnlock()
	__aCache[1] := CV7->(xFilial('CV7'))+cMoeda+cTipoSLD
	__aCache[2] := CV7->(Recno())
EndIf

RestArea(aArea)
aSize(aArea,0)
aArea := nil 
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBXFUN   บAutor  ณEdson Maricate      บ Data ณ  01/16/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica็ใo de atualiza็ใo de saldos MV_ATUSAL = N          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GetCv7Date(cTipoSld,cMoeda)
Local aArea	:= GetArea()
Local dRet := STOD("19800101")

If !__lChkCV7
	__lChkCV7 := .T.
EndIf

dbSelectArea("CV7")
If !(CV7->(xFilial('CV7'))+cMoeda+cTipoSLD == __aCache[1])
	CV7->(dbSetOrder(1))
	If CV7->(dbSeek(xFilial('CV7')+cMoeda+cTipoSld))
		__aCache[2] := CV7->(Recno())
		__aCache[1] := CV7->(xFilial('CV7'))+cMoeda+cTipoSLD
	EndIf
Else
	CV7->(MsGoto(__aCache[2]))
Endif

IF CV7->(!Eof())
	dRet := CV7->CV7_DATA
EndIf

RestArea(aArea)
aSize(aArea,0)
aArea := nil 
Return dRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBXFUN   บAutor  ณEdson Maricate      บ Data ณ  01/16/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica็ใo de atualiza็ใo de saldos MV_ATUSAL = N          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PutCv7Date(cTipoSld,cMoeda,dData)
Local aArea	:= GetArea()
Local dRet := CTOD("")

If !__lChkCV7
	__lChkCV7 := .T.
EndIf

dbSelectArea("CV7")
If !(xFilial('CV7')+cMoeda+cTipoSLD == __aCache[1])
	CV7->(dbSetOrder(1))
	IF CV7->(dbSeek(xFilial()+cMoeda+cTipoSld))
		__aCache[2] := CV7->(Recno())
		__aCache[1] := CV7->(xFilial('CV7'))+cMoeda+cTipoSLD
	EndIf 
Else
	CV7->(MsGoto(__aCache[2]))
Endif
IF CV7->(!Eof())
	dRet := CV7->CV7_DATA
	RecLock("CV7",.F.)
	CV7->CV7_DATA := dData
	MsUnlock()
Else
	RecLock("CV7",.T.)
	CV7->CV7_FILIAL	:= xFilial("CV7")
	CV7->CV7_MOEDA	:= cMoeda
	CV7->CV7_DATA 	:= dData
	CV7->CV7_TPSALD	:= cTipoSld
	__aCache[1] := CV7->(xFilial('CV7'))+cMoeda+cTipoSLD
	__aCache[2] := CV7->(Recno())
	MsUnlock()
EndIf

RestArea(aArea)
aSize(aArea,0)
aArea := nil 
Return dRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออหออออออัออออออออออออออปฑฑ
ฑฑบPrograma  ณ CtbHistRat บAutor  ณGustavo Henrique บ Data ณ  17/02/06    บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออสออออออฯออออออออออออออนฑฑ
ฑฑบDescricao ณ Grava informacoes de historico do rateio off-line.         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ EXPC1 - Codigo do rateio                                   บฑฑ
ฑฑบ          ณ EXPC2 - Numero do lote do lancamento (CT2)                 บฑฑ
ฑฑบ          ณ EXPC3 - Numero do sub-lote do lancamento (CT2)             บฑฑ
ฑฑบ          ณ EXPC4 - Numero do documento do lanc. (CT2)                 บฑฑ
ฑฑบ          ณ EXPC5 - Data do lancamento (CT2)                           บฑฑ
ฑฑบ          ณ EXPC6 - Rotina de chamada para gerar o historico do rateio บฑฑ
ฑฑบ          ณ EXPC7 - Alias da tabela CTQ                                บฑฑ
ฑฑบ          ณ EXPC8 - aHeader da tabela TMP. Somente usado quando cRotinaบฑฑ
ฑฑบ          ณ         igual a "CTBA270"                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Rateio Off-Line                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CtbHistRat( cRateio, cLote, cSubLote, cDoc, dData, cRotina, cAlias, aHeader )

Local aArea			:= GetArea()
Local aAreaAlias    := (cAlias)->(GetArea())
Local aCposEqv		:= {}
Local nTotCpos		:= 0
Local nCpo			:= 0
Local nCont			:= 0
Local lGeraHis		:= .F.
Local cRevisao		:= ""
Local cMV_CTBHRAT	:= CT270HRAT()

Default cLote		:= ""
Default cSubLote	:= ""
Default cDoc		:= ""
Default dData		:= CtoD( "  /  /  " )
Default cRotina		:= ""

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Somente gera historico se o parametro MV_CTBHRAT estiver ativo ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If cMV_CTBHRAT != "0" //SuperGetMV( "MV_CTBHRAT", .F., .F. )

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica se houve alteracao em alguma linha do rateio atualmente posicionado ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If cRotina == "CTBA270" .AND. cMV_CTBHRAT $ "1/3"

		(cAlias)->( dbSetOrder(1))

		TMP->( dbGoTop() )

		Do While TMP->( ! EoF() )
			(cAlias)->( MsSeek( xFilial(cAlias) + cRateio + TMP->CTQ_SEQUEN ) )
			For nCont := 1 To (cAlias)->(fCount())
				nAscan := aScan(aHeader,{|e| Upper(AllTrim(e[2])) == Upper(AllTrim((cAlias)->(FieldName(nCont))))})
				If nAscan > 0 .And. (cAlias)->(FieldPos(TMP->(FieldName(nCont)))) > 0
					If ! lGeraHis .And. TMP->( FieldGet(nCont) ) # (cAlias)->(FieldGet(nCont))
						lGeraHis := .T.
						Exit
					EndIf
				EndIf
			Next nCont
			TMP->( dbSkip() )
		EndDo

	Else

		lGeraHis := IIF(cMV_CTBHRAT $ "2/3",.T.,.F.)

	EndIf

	If lGeraHis

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Busca o primeiro ou o proximo numero de revisao do rateio para gravar o historico ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		CV9->(dbSetOrder(1))

		If ! CV9->(MsSeek( xFilial("CV9") + cRateio ))
			cRevisao := StrZero( 1, TamSX3("CV9_REVISA")[1] )
		Else
			Do While CV9->( ! EoF() .And. CV9_FILIAL+CV9_RATEIO == xFilial("CV9")+cRateio )
				cRevisao := CV9->CV9_REVISA
				CV9->(dbSkip())
			EndDo
			cRevisao := Soma1(cRevisao)
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Gera array com os nomes de campos equivalentes entre a tabela CV9 e CTQ ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		nTotCpos := (cAlias)->(fCount())

		For nCpo := 1 To nTotCpos
			cNomeCpo := (cAlias)->( FieldName(nCpo) )
			AAdd( aCposEqv, { cNomeCpo, "CV9" + SubStr( cNomeCpo, 4, Len(cNomeCpo) ) } )
		Next nCpo

		(cAlias)->( dbSetOrder(1))
		(cAlias)->( MsSeek( xFilial(cAlias) + cRateio ) )

		Do While (cAlias)->( ! EoF() .And. CTQ_FILIAL+CTQ_RATEIO == xFilial(cAlias)+cRateio )

			GravaCV9(cRevisao, cRotina, cLote, cSubLote, cDoc, dData, aCposEqv,nTotCpos,cAlias)

			(cAlias)->( dbSkip() )

		EndDo

	EndIf

EndIf

RestArea(aArea)
RestArea(aAreaAlias)

Return cRevisao


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณProgram   ณCriaSP169 ณ Autor ณ Totvs                 ณ Data ณ 11.12.08 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Cria a procedure CTB169 dinamicamente                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ CriaSP169()                                                ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ .T. / .F.                                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Generico                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function CriaSP169()
	Local lRet 		:= .T.
	Local cRet		:= ""
	Local cQry		:= ""
	Local lBlind	:= IsBlind()

	Local cAssinat	:= cVerSP169A
	Local cData		:= "20081211"
	Local cHora		:= "000000"
	Local cVersao	:= "P11"

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณlimpa o banco de dados para criacao da procedureณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	CSP169Limpa()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณcria a procedureณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cQry += "CREATE PROCEDURE CTB169A_" + cEmpAnt + " ( " + CRLF
	cQry += "   @IN_FILIAL Char( " + Str( IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) ) + " )," + CRLF
	cQry += "   @IN_DATADE Char( 08 )," + CRLF
	cQry += "   @IN_DATAATE Char( 08 )," + CRLF
	cQry += "   @IN_LMOEDAESP Char( 01 )," + CRLF
	cQry += "   @IN_MOEDA Char( 02 )," + CRLF
	cQry += "   @IN_TPSALDO Char( 01 )," + CRLF
	cQry += "   @IN_INTEGRIDADE Char( 01 )," + CRLF
	cQry += "   @IN_MVCTB190D Char( 01 )," + CRLF
	cQry += "   @OUT_RESULTADO Char( 01 ) OutPut" + CRLF
	cQry += ") AS" + CRLF
	cQry += "BEGIN" + CRLF
	cQry += "    Select @OUT_RESULTADO = '0'" + CRLF
	cQry += "    If @IN_MVCTB190D = '1' " + CRLF
	cQry += "	 Begin" + CRLF
	cQry += "        If @IN_INTEGRIDADE = '1' " + CRLF
	cQry += "		 Begin" + CRLF
	cQry += "            UPDATE " + RetSqlName( "CVO" ) + " SET D_E_L_E_T_  = '*' WHERE R_E_C_N_O_ IN" + CRLF
	cQry += "               (SELECT CVO.R_E_C_N_O_ FROM " + RetSqlName( "CVO" ) + " CVO, " + RetSqlName( "CT2" ) + " CT2" + CRLF
	cQry += "                    WHERE CVO_FILIAL  = '" + xFilial( "CVO" ) + "' " + CRLF
	cQry += "                            AND CT2_FILIAL  = '" + xFilial( "CT2" ) + "' " + CRLF
	cQry += "                            AND CVO_DATA  BETWEEN @IN_DATADE AND @IN_DATAATE" + CRLF
	cQry += "                            AND CT2_TPSALD = @IN_TPSALDO" + CRLF
	cQry += "                            AND ( @IN_LMOEDAESP  <> '1' OR ( ( CVO_MOEDA = @IN_MOEDA OR CT2_MOEDLC = @IN_MOEDA ) AND @IN_LMOEDAESP = '1' ) )" + CRLF
	cQry += "                            AND CVO_DATA      = CT2_DATA" + CRLF
	cQry += "                            AND CVO_LOTE      = CT2_LOTE" + CRLF
	cQry += "                            AND CVO_SBLOTE    = CT2_SBLOTE" + CRLF
	cQry += "                            AND CVO_DOC       = CT2_DOC" + CRLF
	cQry += "                            AND CVO_LINHA     = CT2_LINHA" + CRLF
	cQry += "                            AND CT2.D_E_L_E_T_ = ' '" + CRLF
	cQry += "                            AND CVO.D_E_L_E_T_ = ' ' )" + CRLF

	cQry += "            UPDATE " + RetSqlName( "CVO" ) + " SET D_E_L_E_T_  = '*' WHERE R_E_C_N_O_ IN" + CRLF
	cQry += "                (SELECT CVO.R_E_C_N_O_ FROM " + RetSqlName( "CVO" ) + " CVO, " + RetSqlName( "CT2" ) + " CT2" + CRLF
	cQry += "                        WHERE CVO_FILIAL  = '" + xFilial( "CVO" ) + "' " + CRLF
	cQry += "                            	 AND CT2_FILIAL  = '" + xFilial( "CT2" ) + "' " + CRLF
	cQry += "                                AND CVO_DATA  BETWEEN @IN_DATADE AND @IN_DATAATE" + CRLF
	cQry += "                                AND CT2_TPSALD = @IN_TPSALDO" + CRLF
	cQry += "                                AND ( @IN_LMOEDAESP <> '1' OR ( ( CVO_MOEDA = @IN_MOEDA OR CT2_MOEDLC = @IN_MOEDA ) AND @IN_LMOEDAESP = '1' ) )" + CRLF
	cQry += "                                AND CVO_DATA      = CT2_DATA" + CRLF
	cQry += "                                AND CVO_LOTE      = CT2_LOTE" + CRLF
	cQry += "                                AND CVO_SBLOTE    = CT2_SBLOTE" + CRLF
	cQry += "                                AND CVO_DOC       = CT2_DOC" + CRLF
	cQry += "                                AND CVO_LINHA     = CT2_LINHA" + CRLF
	cQry += "                                AND CT2.D_E_L_E_T_ = ' '" + CRLF
	cQry += "                                AND CVO.D_E_L_E_T_ = '*' )" + CRLF
	cQry += "       End" + CRLF
	cQry += "		Else" + CRLF
	cQry += "		Begin" + CRLF
	cQry += "            DELETE FROM " + RetSqlName( "CVO" ) + " WHERE R_E_C_N_O_ IN" + CRLF
	cQry += "                (SELECT CVO.R_E_C_N_O_ FROM " + RetSqlName( "CVO" ) + " CVO, " + RetSqlName( "CT2" ) + " CT2" + CRLF
	cQry += "                        WHERE CVO_FILIAL  = '" + xFilial( "CVO" ) + "' " + CRLF
	cQry += "                            	 AND CT2_FILIAL  = '" + xFilial( "CT2" ) + "' " + CRLF
	cQry += "                                AND CVO_DATA  BETWEEN @IN_DATADE AND @IN_DATAATE" + CRLF
	cQry += "                                AND CT2_TPSALD = @IN_TPSALDO" + CRLF
	cQry += "                                AND ( @IN_LMOEDAESP <> '1' OR ( ( CVO_MOEDA = @IN_MOEDA OR CT2_MOEDLC = @IN_MOEDA ) AND @IN_LMOEDAESP = '1' ) )" + CRLF
	cQry += "                                AND CVO_DATA      = CT2_DATA" + CRLF
	cQry += "                                AND CVO_LOTE      = CT2_LOTE" + CRLF
	cQry += "                                AND CVO_SBLOTE    = CT2_SBLOTE" + CRLF
	cQry += "                                AND CVO_DOC       = CT2_DOC" + CRLF
	cQry += "                                AND CVO_LINHA     = CT2_LINHA" + CRLF
	cQry += "                                AND CT2.D_E_L_E_T_ = ' '" + CRLF
	cQry += "                                AND CVO.D_E_L_E_T_ = ' ' )" + CRLF
	cQry += "        End" + CRLF
	cQry += "    End" + CRLF
	cQry += "	Else" + CRLF
	cQry += "	Begin" + CRLF
	cQry += "        UPDATE " + RetSqlName( "CVO" ) + " SET D_E_L_E_T_ = '*' WHERE R_E_C_N_O_ IN" + CRLF
	cQry += "           (SELECT CVO.R_E_C_N_O_ FROM " + RetSqlName( "CVO" ) + " CVO, " + RetSqlName( "CT2" ) + " CT2" + CRLF
	cQry += "                  WHERE CVO_FILIAL  = '" + xFilial( "CVO" ) + "' " + CRLF
	cQry += "                      	 AND CT2_FILIAL  = '" + xFilial( "CT2" ) + "' " + CRLF
	cQry += "                        AND CVO_DATA BETWEEN @IN_DATADE AND @IN_DATAATE" + CRLF
	cQry += "                        AND CT2_TPSALD = @IN_TPSALDO" + CRLF
	cQry += "                        AND ( @IN_LMOEDAESP <> '1' OR ( ( CVO_MOEDA = @IN_MOEDA OR CT2_MOEDLC = @IN_MOEDA ) AND @IN_LMOEDAESP = '1' ) )" + CRLF
	cQry += "                        AND CVO_DATA      = CT2_DATA" + CRLF
	cQry += "                        AND CVO_LOTE      = CT2_LOTE" + CRLF
	cQry += "                        AND CVO_SBLOTE    = CT2_SBLOTE" + CRLF
	cQry += "                        AND CVO_DOC       = CT2_DOC" + CRLF
	cQry += "                        AND CVO_LINHA     = CT2_LINHA" + CRLF
	cQry += "                        AND CT2.D_E_L_E_T_ = ' '" + CRLF
	cQry += "                        AND CVO.D_E_L_E_T_ = ' ' )" + CRLF
	cQry += "    End" + CRLF
	cQry += "    Select @OUT_RESULTADO = '1'" + CRLF
	cQry += "End" + CRLF

	cQry := MsParse( cQry, AllTrim( TcGetDB() ) )

	If !Empty( MsParseError() )
		If !lBlind
			MsgAlert( STR0048 + " " + MsParseError() )  //'Erro na criacao da procedure'
		EndIf
		lRet := .F.
	Else
		cRet := TcSqlExec( cQry )
		If cRet <> 0
			If !lBlind
				MsgAlert( STR0048 + " " + TcSQLError() )  //'Erro na criacao da procedure'
			EndIf
			lRet := .F.
		EndIf
	EndIf

	cStatement:= "INSERT INTO TOP_SP ( SP_NOME, SP_VERSAO, SP_DATA, SP_HORA, SP_ASSINAT ) "
	cStatement+= "     VALUES ( 'CTB169A_" + cEmpAnt + "', '"+cVersao+"', '"+cData+"', '"+cHora+"', '"+cAssinat+"' )"
	TCSqlExec( cStatement )

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณProgram   ณCriaSP150Aณ Autor ณ Totvs                 ณ Data ณ 11.12.08 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Cria a procedure CTB169 dinamicamente                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ CriaSP150A()                                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ .T. / .F.                                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Generico                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function CriaSP150A()
	Local lRet 		:= .T.

	Local cRet		:= ""
	Local cQry		:= ""
	Local lBlind	:= IsBlind()

	Local cAssinat	:= cVerSP150A
	Local cData		:= "20081211"
	Local cHora		:= "000000"
	Local cVersao	:= "P11"
	Local aCampos   := CVO->(DbStruct())
	Local nPos      := 0
	Local cCTB150 	:= xProcedure( IIF(FindFunction("GetSPName"), GetSPName("CTB150","04"), "CTB150"))
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณlimpa o banco de dados para criacao da procedureณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	CSP150ALimpa()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณcria a procedureณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cQry += "CREATE PROCEDURE CTB150A_" + cEmpAnt + " ( " + CRLF
	cQry += "    @IN_FILIAL CHAR( " + Str( IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) ) + " ), " + CRLF
	cQry += "    @OUT_RESULT CHAR( 01 )  OUTPUT ) AS " + CRLF

	cQry += "DECLARE @CCFILCVO CHAR ( " + Str( IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) ) + " ) " + CRLF
	nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CVO_LOTE" })
	cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
	cQry += "DECLARE @CLOTE "+cTipo+ CRLF
	nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CVO_SBLOTE" })
	cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
	cQry += "DECLARE @CSBLOTE "+cTipo+ CRLF
	nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CVO_DOC" })
	cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
	cQry += "DECLARE @CDOC "+cTipo+ CRLF
	cQry += "DECLARE @CDATA CHAR ( 8 ) " + CRLF
	nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CVO_LINHA" })
	cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
	cQry += "DECLARE @CLINHA "+cTipo+ CRLF
	cQry += "DECLARE @COPCR CHAR ( 1 ) " + CRLF
	cQry += "DECLARE @CSOMA CHAR ( 1 ) " + CRLF
	cQry += "DECLARE @CFLAG CHAR ( 10 ) " + CRLF
	cQry += "DECLARE @IRECNO INTEGER " + CRLF
	cQry += "DECLARE @ICOUNT INTEGER " + CRLF
	cQry += "DECLARE @REC_COUNT INTEGER " + CRLF
	cQry += "DECLARE @CFKINUSE CHAR ( 1 ) " + CRLF
	nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CVO_MOEDA" })
	cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
	cQry += "DECLARE @CMOEDA "+cTipo+ CRLF
	nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CVO_FILIAL" })
	cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
	cQry += "DECLARE @CCODFIL "+cTipo+ CRLF
	cQry += "DECLARE @FIM_CUR INTEGER " + CRLF

	cQry += "DECLARE @CRESULT CHAR(2) " + CRLF
	cQry += "DECLARE @OUT_RESULT2 CHAR(1) " + CRLF
	cQry += "DECLARE @CRETURN CHAR(1) " + CRLF
	cQry += "DECLARE @CFILIAL CHAR(" + Str( IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) ) + ") " + CRLF

	cQry += "BEGIN " + CRLF
	cQry += "	SELECT @OUT_RESULT    = '0'  " + CRLF
	cQry += "	SELECT @OUT_RESULT2   = '0' " + CRLF
	cQry += "	SELECT @ICOUNT        = 1 " + CRLF
	cQry += "	SELECT @REC_COUNT     = 0 " + CRLF
	cQry += "	SELECT @CRETURN	      = '0' " + CRLF
	cQry += "	SELECT @CFILIAL	      = '" + xFilial( "CT2" ) + "' " + CRLF

	cQry += "	BEGIN  " + CRLF
	cQry += "		DECLARE CTB_CVO INSENSITIVE CURSOR FOR  " + CRLF
	cQry += "			SELECT R_E_C_N_O_, CVO_LOTE, CVO_SBLOTE, CVO_DOC, CVO_DATA, CVO_LINHA, CVO_OPCR, CVO_SOMA, CVO_MOEDA, CVO_CODFIL, CVO_FLAG, CVO_FKINUS " + CRLF
	cQry += "			FROM  " + RetSqlName( "CVO" ) + " " + CRLF
	cQry += "			WHERE CVO_FILIAL = @IN_FILIAL AND D_E_L_E_T_ = ' ' " + CRLF
	cQry += "			ORDER BY CVO_LOTE, CVO_SBLOTE, CVO_DOC, CVO_DATA, CVO_LINHA, CVO_OPCR " + CRLF
	cQry += "		FOR READ ONLY  " + CRLF

	cQry += "		OPEN CTB_CVO " + CRLF
	cQry += "		FETCH CTB_CVO " + CRLF

	cQry += "		INTO @IRECNO, @CLOTE, @CSBLOTE, @CDOC, @CDATA, @CLINHA, @COPCR, @CSOMA, @CMOEDA, @CCODFIL, @CFLAG, @CFKINUSE " + CRLF

	cQry += "		WHILE ( ( @@FETCH_STATUS  = 0 ) ) " + CRLF
	cQry += "		BEGIN " + CRLF
//	cQry += "			BEGIN TRAN " + CRLF
	cQry += "				UPDATE " + RetSqlName( "CVO" ) + " SET CVO_TPSLDA = 'I' WHERE R_E_C_N_O_ = @IRECNO " + CRLF
	cQry += "				EXEC "+cCTB150+ " @IN_FILIAL, @CLOTE, @CSBLOTE, @CDOC, @CDATA, @COPCR, @CSOMA, @CLINHA, @CMOEDA, @CFLAG, @CFKINUSE, @OUT_RESULT2 OUTPUT " + CRLF

	cQry += "				SELECT @CRETURN = @OUT_RESULT2 " + CRLF

	cQry += "				DELETE FROM " + RetSqlName( "CVO" ) + " WHERE R_E_C_N_O_ = @IRECNO " + CRLF
//	cQry += "			COMMIT TRAN " + CRLF

	cQry += "			FETCH CTB_CVO INTO @IRECNO, @CLOTE, @CSBLOTE, @CDOC, @CDATA, @CLINHA, @COPCR, @CSOMA, @CMOEDA, @CCODFIL, @CFLAG, @CFKINUSE " + CRLF

	cQry += "		END  " + CRLF
	cQry += "		CLOSE CTB_CVO " + CRLF
	cQry += "		DEALLOCATE CTB_CVO " + CRLF
	cQry += "    END  " + CRLF

	cQry += "   SELECT @OUT_RESULT = @CRETURN " + CRLF
	cQry += "END  " + CRLF
	cQry := MsParse( cQry, AllTrim( TcGetDB() ) )

	If !Empty( MsParseError() )
		If !lBlind
			MsgAlert( STR0048 + " " + MsParseError() )  //'Erro na criacao da procedure'
		EndIf
		lRet := .F.
	Else
		cRet := TcSqlExec( cQry )
		If cRet <> 0
			If !lBlind
				MsgAlert( STR0048 + " " + TcSQLError() )  //'Erro na criacao da procedure'
			EndIf
			lRet := .F.
		EndIf
	EndIf

	cStatement:= "INSERT INTO TOP_SP ( SP_NOME, SP_VERSAO, SP_DATA, SP_HORA, SP_ASSINAT ) "
	cStatement+= "     VALUES ( 'CTB150A_" + cEmpAnt + "', '"+cVersao+"', '"+cData+"', '"+cHora+"', '"+cAssinat+"' )"
	TCSqlExec( cStatement )

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณProgram   ณCSP169Limpa ณ Autor ณ Totvs               ณ Data ณ 03.12.08 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Limpa a procedure da base.                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Generico                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function CSP169Limpa()
	Local cGetDB 		:= TCGetDB()
	Local cTOP400Alias 	:= ""
	Local cSP169A		:= xProcedure( "CTB169A" )

	If cGetDB == "AS400" .or. cGetDB == "DB2/400"  // remover posteriormente "AS400"
		// Identifica nome do Schema ( Alias )
		cTOP400Alias := GetSrvProfString('DBALIAS','')
		If empty(cTOP400Alias)
			cTOP400Alias := GetSrvProfString('TOPALIAS','')
		Endif
		If empty(cTOP400Alias)
			cTOP400Alias := GetPvProfString('TOTVSDBACCESS','ALIAS','',GetAdv97())
		Endif
		If empty(cTOP400Alias)
			cTOP400Alias := GetPvProfString('TOPCONNECT','ALIAS','',GetAdv97())
		Endif

		TCSqlExec("DROP PROCEDURE " + cTOP400Alias + "." + cSP169A )
		TCSqlExec("DELETE FROM  " + cTOP400Alias + ".TOP_SP WHERE SP_NOME LIKE 'CTB169A%'")
	Else
		TCSqlExec("DROP PROCEDURE " + cSP169A )
		TCSqlExec("DELETE FROM TOP_SP WHERE SP_NOME LIKE 'CTB169A%'")
	Endif
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณProgram   ณCSP150ALimpaณ Autor ณ Totvs               ณ Data ณ 03.12.08 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Limpa a procedure da base.                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Generico                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function CSP150ALimpa()
	Local cGetDB 		:= TCGetDB()
	Local cTOP400Alias 	:= ""
	Local cSP150A		:= xProcedure( "CTB150A" )

	If cGetDB == "AS400" .or. cGetDB == "DB2/400"  // remover posteriormente "AS400"
		// Identifica nome do Schema ( Alias )
		cTOP400Alias := GetSrvProfString('DBALIAS','')
		If empty(cTOP400Alias)
			cTOP400Alias := GetSrvProfString('TOPALIAS','')
		Endif
		If empty(cTOP400Alias)
			cTOP400Alias := GetPvProfString('TOTVSDBACCESS','ALIAS','',GetAdv97())
		Endif
		If empty(cTOP400Alias)
			cTOP400Alias := GetPvProfString('TOPCONNECT','ALIAS','',GetAdv97())
		Endif

		TCSqlExec("DROP PROCEDURE " + cTOP400Alias + "." + cSP150A )
		TCSqlExec("DELETE FROM  " + cTOP400Alias + ".TOP_SP WHERE SP_NOME LIKE 'CTB150A%'")
	Else
		TCSqlExec("DROP PROCEDURE " + cSP150A )
		TCSqlExec("DELETE FROM TOP_SP WHERE SP_NOME LIKE 'CTB150A%'")
	Endif
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtAgrupSldบAutor  ณMarcos S. Lobo      บ Data ณ  01/08/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CtAgrupSld(aAtuSaldos,aGrupSld)

Local nL			:= 0
Local lMoedaFato	:= .F.

If __lConOutR == Nil
	__lConOutR := FindFunction("CONOUTR")
EndIf
If __lConOutR
	ConOutR("*CTBGRV*|INI AGLUT ARRAY")
EndIf

DEFAULT aAtuSaldos	 := {}

If Len(aAtuSaldos) == 0			///1บ incremento nao precisa procurar
	For nL := 1 to Len(aGrupSld)
		aAdd(aAtuSaldos,aClone(aGrupSld[nL]))
	Next
	Return		//Retorna o aAtuSaldo
EndIf

If Len(aAtuSaldos[1]) >= 46 .and. Len(aGrupSld[1]) > 46
	lMoedaFato := .T.
Endif

/*
//  1  				2				3				4				  5				  6           	 7      		 8               9               10
{	"-"				,				,				,				 ,				 ,TMP->CT2_DC	 ,cMoeda		 ,TMP->CT2_DEBITO,TMP->CT2_CREDIT,TMP->CT2_CCD,;
	TMP->CT2_CCC	,TMP->CT2_ITEMD ,TMP->CT2_ITEMC	,TMP->CT2_CLVLDB ,TMP->CT2_CLVLCR,NVALOR	 	 ,TMP->CT2_TPSALD,nOpcAlt		 ,CT2->CT2_DEBITO,CT2->CT2_CREDIT,;
	CT2->CT2_CCD	,CT2->CT2_CCC	,CT2->CT2_ITEMD	,CT2->CT2_ITEMC  ,CT2->CT2_CLVLDB,CT2->CT2_CLVLCR,nValorAnt		 ,CT2->CT2_DC	 ,CT2->CT2_TPSALD,cMoeda,;
	,				,				,				,				 ,				 ,CT2->CT2_DTLP }
//  1  				2				3				4				  5				  6            	 7      		 8               9               10
{	"+"				,				,				,				 ,				 ,TMP->CT2_DC	 ,cMoeda		 ,TMP->CT2_DEBITO,TMP->CT2_CREDIT,TMP->CT2_CCD,;
	TMP->CT2_CCC	,TMP->CT2_ITEMD ,TMP->CT2_ITEMC	,TMP->CT2_CLVLDB ,TMP->CT2_CLVLCR,nValor		 ,TMP->CT2_TPSALD,nOpcAlt		 ,CT2->CT2_DEBITO,CT2->CT2_CREDIT,;
	CT2->CT2_CCD	,CT2->CT2_CCC	,CT2->CT2_ITEMD	,CT2->CT2_ITEMC	 ,CT2->CT2_CLVLDB,CT2->CT2_CLVLCR,nValorAnt		 ,CT2->CT2_DC	 ,CT2->CT2_TPSALD,cMoeda,;
	,				,				,				,				 ,				 ,TMP->CT2_DTLP }
*/
For nL := 1 to Len(aGrupSld)
	nPosAglut := aScan(	aAtuSaldos,{|x| x[1] == aGrupSld[nL,1] .and. ;
									x[6] == aGrupSld[nL,6] .and.;
									x[7] == aGrupSld[nL,7] .and.;
									x[8] == aGrupSld[nL,8] .and.;
									x[9] == aGrupSld[nL,9] .and.;
									x[10] == aGrupSld[nL,10] .and.;
									x[11] == aGrupSld[nL,11] .and.;
									x[12] == aGrupSld[nL,12] .and.;
									x[13] == aGrupSld[nL,13] .and.;
									x[14] == aGrupSld[nL,14] .and.;
									x[15] == aGrupSld[nL,15] .and.;
									x[17] == aGrupSld[nL,17] .and.;
									x[18] == aGrupSld[nL,18] .and.;
									x[19] == aGrupSld[nL,19] .and.;
									x[20] == aGrupSld[nL,20] .and.;
									x[21] == aGrupSld[nL,21] .and.;
									x[22] == aGrupSld[nL,22] .and.;
									x[23] == aGrupSld[nL,23] .and.;
									x[24] == aGrupSld[nL,24] .and.;
									x[25] == aGrupSld[nL,25] .and.;
									x[26] == aGrupSld[nL,26] .and.;
									x[28] == aGrupSld[nL,28] .and.;
									x[29] == aGrupSld[nL,29] .and.;
									x[30] == aGrupSld[nL,30] .and.;
									x[36] == aGrupSld[nL,36] .and.;
									x[37] == aGrupSld[nL,37] .and.;
									CtbaDiff(x[41], aGrupSld[nL,41]) .and.;
									CtbaDiff(x[42], aGrupSld[nL,42]) .and.;
									If(lMoedaFato,(x[43] == aGrupSld[nL,43] .and. x[44] == aGrupSld[nL,44] .and. x[45] == aGrupSld[nL,45] .and. x[46]) == aGrupSld[nL,46], .T.) })

	If nPosAglut > 0
		aAtuSaldos[nPosAglut,16] += aGrupSld[nL,16]	// nValor
		aAtuSaldos[nPosAglut,27] += aGrupSld[nL,27]	// nValorAnt
	Else
		aAdd(aAtuSaldos,aClone(aGrupSld[nL]))
	EndIf
Next

If __lConOutR
	ConOutR("*CTBGRV*|END AGLUT ARRAY")
EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbaDiff  บAutor  ณMicrosiga           บ Data ณ  12/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Compara os array contendo entidade 05 ate 09 com os ja     บฑฑ
ฑฑบ          ณ armazenado                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CtbaDiff(aEntid1, aEntid2)
Local lRetorno := .T.
Local nX, nZ

lRetorno := ( Len(aEntid1) == Len(aEntid2) )  // os array tem q ser igual para ser comparado os conteudos
If lRetorno
	For nX := 1 TO Len(aEntid1)
		If Len(aEntid1[nX]) != Len(aEntid2[nX])  // os array tem q ser igual para ser comparado os conteudos
			lRetorno := .F.
			Exit
		Else
			For nZ := 1 TO Len(aEntid1[nX])
				If aEntid1[nX,nZ] != aEntid2[nX,nZ]  //compara as entidades a credito e a debito
					lRetorno := .F.
					Exit
				EndIf
			Next
			If ! lRetorno
				Exit
			EndIf
		EndIf
	Next
EndIf

Return(lRetorno)

//---------------------------------------------------------------------------------
/*/{Protheus.doc} CtbQLHis
Contagem de linhas do historico digitado para gravacao do tipo 4 - cont. historico
@author Totvs
@since 11/04/2016
@version P11

/*/
//---------------------------------------------------------------------------------

Function CtbQLHis(cTexto,nTamHist,nPasso)
Default nPasso := 1
Return( CtbQLinHis(cTexto,nTamHist, @nPasso) )



//---------------------------------------------------------------------------------
/*/{Protheus.doc} CtbCSQDel
Exclusao da tabela de indicador de lan็amento extemporaneo
@author Totvs
@since 25/04/2016
@version P12

/*/
//---------------------------------------------------------------------------------
Static Function CtbCSQDel()
Local aArea := GetArea()
Local lFound  := .F.

//Tabela CT2-Mov.Contabeis tem que estar posicionado
If AliasIndic("CSQ")

	CSQ->(dbSetOrder(1))
	lFound  :=  CSQ->(dbSeek(CT2->CT2_FILIAL+DTOS(CT2->CT2_DATA)+CT2->CT2_LOTE+CT2->CT2_SBLOTE+CT2->CT2_DOC+CT2->CT2_LINHA+CT2->CT2_EMPORI+CT2->CT2_FILORI))

	If lFound
		Reclock("CSQ", .F., .T. )
		CSQ->( DbDelete() )
		MsUnlock()
	EndIf

EndIf	

RestArea(aArea)

Return

//---------------------------------------------------------------------------------
/*/{Protheus.doc} CtbCQWDel
Exclusao da tabela de indicador de lan็amento de Transferencia de Saldo
@author Totvs
@since 25/04/2016
@version P12

/*/
//---------------------------------------------------------------------------------
Static Function CtbCQWDel()
Local aArea := GetArea()
Local lFound  := .F.

//Tabela CT2-Mov.Contabeis tem que estar posicionado
If AliasIndic("CQW")

	CQW->(dbSetOrder(1))
	lFound  :=  CQW->(dbSeek(CT2->CT2_FILIAL+DTOS(CT2->CT2_DATA)+CT2->CT2_LOTE+CT2->CT2_SBLOTE+CT2->CT2_DOC+CT2->CT2_LINHA))

	While lFound
			Reclock("CQW", .F., .T. )
			CQW->( DbDelete() )
			MsUnlock()
		lFound  :=  CQW->(dbSeek(CT2->CT2_FILIAL+DTOS(CT2->CT2_DATA)+CT2->CT2_LOTE+CT2->CT2_SBLOTE+CT2->CT2_DOC+CT2->CT2_LINHA))
	EndDo

EndIf	

RestArea(aArea)

Return

//---------------------------------------------------------------------------------
/*/{Protheus.doc} CtbInc_Lot
Incrementa numero do lote na tabela 09 da SX5
@author Totvs
@since 02/07/2021
@version P12

/*/
//---------------------------------------------------------------------------------
Function CtbInc_Lot(cLotInc, cModERP, lForceCTB)
Local cLote := cLotInc
Local cTabela := "09"
Local cChave  := Space(3)
Local cTxtGrv := Space(4)
Local aRetLote := {}

Default lForceCTB := .F. 

If cLotInc == NIL
	Help(" ",1,"LOTE_ERR1",, STR0051 ,3,0 ) // "Erro - Lote/Modulo nao informado para incremento da numera็ใo. N๚mero de Lote nใo incrementado."

ElseIf cModERP == NIL
	Help(" ",1,"LOTE_ERR2",, STR0051 ,3,0 ) // "Erro - Lote/Modulo nao informado para incremento da numera็ใo. N๚mero de Lote nใo incrementado."

Else
	If lForceCTB .And. cModERP == "CTB" // CTBA103, CTBA211, CTBA220, CTBA410, CTBXSEM
		cChave := "CTB"
		cLote := Soma1(cLote)
		cTxtGrv := Substr(cLote,3,4)
		aRetLote := FWGetSX5(cTabela,cChave)

		If len(aRetLote) > 0
			FwPutSX5(/*cFlavour*/, cTabela/*cTabela*/, cChave/*cChave*/, cTxtGrv/*cTextoPor*/, cTxtGrv/*cTextoEng*/, cTxtGrv/*cTextoEsp*/, /*cTextoAlt*/)
		Endif
 
	Else
	
		If cModERP=="CTB"
			cChave := "CON"
		Else
			cChave := cModERP
		EndIf

		cLote   := SOMA1(cLote)
		cTxtGrv := Substr(cLote,3,4)
		FwPutSX5(/*cFlavour*/, cTabela/*cTabela*/, cChave/*cChave*/, cTxtGrv/*cTextoPor*/, cTxtGrv/*cTextoEng*/, cTxtGrv/*cTextoEsp*/, /*cTextoAlt*/)

	Endif
EndIf

Return(cLote)

/** Atualiza็๕es referente ao novo processo de procedures **/

//-------------------------------------------------------------------
/*/{Protheus.doc} EngPre06Compile
Processo 06 - ATUALIZAรรO DE SALDOS ONLINE (MV_CTBSALD = '2')
Funรงรตes executadas antes da compilaรงรฃo da procedure. ('Pre-Compile')
Cria as tabelas temporรกrias dos processos
IMPORTANTE: 
- Esse tipo de funรงรฃo deverรก ser desenvolvida pelas รกreas donas dos processos.
- Essas funรงรตes nรฃo podem ter interface alguma, nem interaรงรฃo com usuรกrio.
- Todo e qualquer erro retornado deverรก ser armazenado na variรกvel "cError" que
  รฉ enviada por referรชncia.

@return cAssinatura
@author  TOTVS
@since   13/12/2021
@version 12
/*/
//-------------------------------------------------------------------
// Processo 06 - ATUALIZAรรO DE SALDOS ONLINE (MV_CTBSALD = '2')
Function EngPre06Compile(cProcesso as character, cEmpresa as character, cError as character)
Local cNomeTab := "0_SP"

	If TcCanOpen("TRW"+cEmpresa+cNomeTab)
		TcDelFile("TRW"+cEmpresa+cNomeTab)
	EndIf

	EngSPSWorkTable("CT2","TRW"+cEmpresa+cNomeTab,{},.F.)

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} EngOn06Compile
Processo 06 - ATUALIZAรรO DE SALDOS ONLINE (MV_CTBSALD = '2')
Funรงรตes executadas durante a compilaรงรฃo da procedure.('On Compile')
Faz a adaptaรงรฃo do cรณdigo original da procedure, substituindo as tags '###' pela 
sequรชncia especรญfica de acordo com a regra de negรณcio da รกrea responsรกvel pelo
processo.
IMPORTANTE: 
- Esse tipo de funรงรฃo deverรก ser desenvolvida pelas รกreas donas dos processos.
- Essas funรงรตes nรฃo podem ter interface alguma, nem interaรงรฃo com usuรกrio.
- Todo e qualquer erro retornado deverรก ser armazenado na variรกvel "cError" que
  รฉ enviada por referรชncia.

@return cAssinatura
@author  TOTVS
@since   13/12/2021
@version 12
/*/
//-------------------------------------------------------------------
// Processo 06 - ATUALIZAรรO DE SALDOS ONLINE (MV_CTBSALD = '2')
Function EngOn06Compile(cProcesso as character, cEmpresa as character, cProcName as character, cBuffer as character, cError as character)
Local cNomeTab := "0_SP"

	// Faz a troca das tags "###" nos nomes de tabelas especรญficas do processo
	cBuffer := StrTran( cBuffer, "TRW###", "TRW"+cEmpresa+cNomeTab )

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} EngSPS06Signature
Processo 06 - ATUALIZAรรO DE SALDOS ONLINE (MV_CTBSALD = '2')
Fun็๕es executadas durante a exibi็ใo de informa็๕es detalhadas 
do processo na interface de gestใo de procedures.
Faz a execu็ใo de fun็๕es STATIC proprietแrias das rotinas donas 
dos processos.

@return cAssinatura
@author  TOTVS
@since   13/12/2021
@version 12
/*/
//-------------------------------------------------------------------
// Processo 06 - ATUALIZAรรO DE SALDOS ONLINE (MV_CTBSALD = '2')
Function EngSPS06Signature(cProcess as character)
Local cAssinatura as character

cAssinatura := STATICCALL(CTBXATU,VERIDPROC3)

Return cAssinatura

/*/{Protheus.doc} EngSPS06Delete
// Processo 06 - ATUALIZAรรO DE SALDOS ONLINE (MV_CTBSALD = '2')
Funรงรตes executadas durante a desinstalaรงรฃo dos processos ('On Uninstall')
Faz a exclusรฃo das tabelas da classe "TR". Essas tabelas recebem nomes distintos 
e sรฃo usadas apenas por alguns processos.

IMPORTANTE: 
- Esse tipo de funรงรฃo deverรก ser desenvolvida pelas รกreas donas dos processos.
- Essas funรงรตes nรฃo podem ter interface alguma, nem interaรงรฃo com usuรกrio.
- Todo e qualquer erro retornado deverรก ser armazenado na variรกvel "cError" que
  รฉ enviada por referรชncia.

@return cAssinatura
@author  TOTVS
@since   13/12/2021
@version 12
/*/
//-------------------------------------------------------------------

// Processo 06 - ATUALIZAรรO DE SALDOS ONLINE (MV_CTBSALD = '2')
Function EngSPS06Delete(cProcesso as character, cEmpresa as character, cError as character)
Local cNomeTab   as character

	cNomeTab   := "0_SP"

	If TcCanOpen("TRW"+cEmpresa+cNomeTab)
		TcDelFile("TRW"+cEmpresa+cNomeTab)
	EndIf

Return .T.

/*{Protheus.doc} CtbCpoUID
Retorna campo UUID da tabela enviada

@author: TOTVS
@since 05/01/2022
@version 1.0
*/
Function CtbCpoUID(cTabela) 
Local cCampoUID  := "" 
Local nPosUID    := 0 
Local aCpoStruct := {}
Local cKeyUUID   := cEmpAnt+cTabela

Default cTabela := ""

If __oCTBUID == nil 
	__oCTBUID := JsonObject():New()
EndIf 

If !Empty(cTabela)	
	If (cCampoUID:= __oCTBUID[cKeyUUID]) == nil 
		cCampoUID  := "" 
		aCpoStruct := FWSX3Util():GetListFieldsStruct(cTabela, .F.)
		If ValType(aCpoStruct) == "A" .And. Len(aCpoStruct) > 0 .And.;
			(nPosUID := aScan(aCpoStruct, {|x| "_MSUIDT" $ x[1]})) > 0
			cCampoUID := AllTrim(aCpoStruct[nPosUID][1])
		EndIf
		//- irแ grava o conteudo localizado ou vazio caso nใo exista
		__oCTBUID[cKeyUUID] := cCampoUID
		aSize(aCpoStruct,0)
		aCpoStruct := nil 
	EndIf 
EndIf
Return cCampoUID

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBRetIDO
Retorna o conte๚do dos campos UUID para uso no conciliador 

@author Squad Control
@since 13/09/2021
@version 12
@param cTabOrigem
@return cRet
/*/
//-------------------------------------------------------------------
Function CTBRetIDO(cTabOrigem)
Local cRet := ""
Local cFieldUID := ""
Local lMSUID    := .F.

DEFAULT cTabOrigem := ""

If !Empty(cTabOrigem)
	If __cTbOrAux <> cTabOrigem		
		__cAliasTb := CTBAliasTb(cTabOrigem)									
		__cTbOrAux := cTabOrigem			
	EndIf
	
	cFieldUID := CtbCpoUID(cTabOrigem)
	lMSUID  := !Empty(cFieldUID)

	If lMSUID
		cRet := (cTabOrigem)->(FieldGet(FieldPos(cFieldUID)))
	EndIf	
EndIf

Return cRet
//-------------------------------------------------------------------
/*/{Protheus.doc} CTBAliasTb
Retorna o prefixo da tabela concatenar com os campos 
Exemplo: cTabela = SE1 -> retornarแ -> cAliasRet = E1

@author Squad Control
@since 13/09/2021
@version 12
@param cTabela
@return cAliasRet
/*/
//-------------------------------------------------------------------
Static Function CTBAliasTb(cTabela)
Local cAliasRet := ""
DEFAULT cTabela := ""

If !Empty(cTabela)
	cAliasRet := IIf(&(cTabela+'->(FieldPos("'+cTabela+'_FILIAL"))') > 0, cTabela, Right(cTabela,2))
EndIf

Return cAliasRet
