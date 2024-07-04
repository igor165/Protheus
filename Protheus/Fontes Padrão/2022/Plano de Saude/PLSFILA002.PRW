#INCLUDE "PLSA720.ch"
#INCLUDE "PLSMGER.CH"
#INCLUDE "PLSMCCR.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE __aCdCri032 {"540",STR0001} //"Erro controlado SIGAPLS."
#DEFINE __aCdCri049 {"020",STR0002} //"O valor contratato e diferente do valor informado/apresentado."
#DEFINE __aCdCri051 {"025",STR0012} //"Para este procedimento necessita Auditoria."
#DEFINE __aCdCri070 {"536",STR0003} //"Existem campos obrigatorios que nao foram informados para esta GIH."
#DEFINE __aCdCri091 {"057",STR0007} //"Usuario importado invalido. Deve ser alterado o usuario para o correto ou glosada a nota."
#DEFINE __aCdCri097 {"061",STR0008} //"Glosa de taxa administrativa, devido a data limite para recebimento de faturas de intercambio."
#DEFINE __aCdCri109 {"066",STR0009} //"Evento de alto custo. O valor a ser cobrado/pago deve ser analisado."
#DEFINE __aCdCri110 {"067",STR0010} //"Evento de alto custo. NF de Entrada nao foi localizada. O valor a ser cobrado/pago deve ser atualizado manualmente."
#DEFINE __aCdCri111 {"068",STR0011} //"Evento de alto custo. Valor ja foi pago atraves da NF de Entrada."
#DEFINE __aCdCri166 {"094",STR0113} //"Incluido bloqueado pelo Resumo de internação"
#DEFINE __aCdCri169 {"097",STR0114} //"Bloqueio de pagamento e cobrança, participação não informada"
#DEFINE __aCdCri098 {"062","Procedimento não existente na liberação de origem."}
#DEFINE __aCdCri178 {"09E",STR0118} //"Bloqueio de pagamento ou exclusao da composicao ao negar sub-item."
#DEFINE __aCdCri179 {"09F",STR0119} //"Bloqueio de pagamento, composicao nao autorizada no Atendimento...... "
#DEFINE __aCdCri09Z {"09Z",STR0132} //"Guia Juridica - Esta guia não será submetida aos critérios de validação do sistema!"
#DEFINE __aCdCri226 {"591",STR0013} //"Bloq. em funcao de glosa pagto"
#DEFINE __aCdCri222 {"593",STR0140} //"Bloqueio de pagamento evento generico" 
#DEFINE __aCdCri223 {"590",STR0141} //"Unidade com bloqueio automático pela BD3."
#DEFINE __aCdCri227 {"592",STR0142} //"Bloqueio da cobranca da PF, porque o pagamento sera feito diretamente a RDA"
#DEFINE __aCdCri230 {"594","Unidade com vigência fechada BD4."} 
#DEFINE __aCdCri231 {"0A4","Redução de custo."} 
#DEFINE __aCdCri016 {"513","Rede de atendimento sem especialidade cadastrada"}
#DEFINE __aCdCri084 {"048","Local de Atendimento bloqueado para esta RDA."}
#DEFINE __aCdCri232 {"595","Unidade com bloqueio automático pela B4R (Exceçao de US)."} 
#DEFINE __aCdCri233 {"596","Bloqueio em função de todas as unidades estarem bloqueadas"}
#DEFINE __aCdCri234 {"597","Unidade não existe na composição do evento"} 
#DEFINE __aCdCri235 {"598","Bloqueio não definido no motivo de bloqueio"}
#DEFINE __aCdCri087 {"053",STR0004} //"A quantidade autorizada e diferente da quantidade apresentada/cobrada pela operadora destino."
#DEFINE __aCdCri088 {"054",STR0005} //"O usuario autorizado e diferente do usuario que esta sendo cobrado pela operadora destino."
#DEFINE __aCdCri089 {"055",STR0006} //"A Data/Hora autorizada e diferente da Data/Hora apresentada/cobrada pela operadora destino."
#DEFINE __aCdCri099 {"063",STR0133} //"Participacao de servico informada invalida."
#DEFINE __aCdCri215 {"09B",STR0139} //"Participacao informada nao existe para este procedimento"
#DEFINE __aCdCri09S {"09S","Quantidade de dias permitido para execução da guia foi ultrapassado"}

#DEFINE __cBLODES	__aCdCri109[1] + '|' + __aCdCri110[1] + '|' + __aCdCri111[1] + '|' + __aCdCri230[1] + '|' +;					
					__aCdCri169[1] + '|' + __aCdCri233[1] + '|' + __aCdCri227[1] + '|' + __aCdCri091[1] + '|' +;
					__aCdCri234[1]

#DEFINE VAR_CHAVE	1
#DEFINE VAR_STATUS	2     
#DEFINE VAR_COUNT	3
#DEFINE VAR_REG		4

#DEFINE K_Cancel   8
#DEFINE K_Bloqueio 9
#DEFINE K_Desbloq  10

#DEFINE MUDFASGUIA  "1"
#DEFINE MUDFASEPEG  "2"
#DEFINE RETORNAFASE "3"

#DEFINE DIGITACAO 	"1"
#DEFINE CONFERENC 	"2"
#DEFINE PRONTA 		"3"
#DEFINE FATURADA 	"4"

#DEFINE G_CONSULTA  "01"
#DEFINE G_SADT_ODON "02"
#DEFINE G_SOL_INTER "03"
#DEFINE G_REEMBOLSO "04"
#DEFINE G_RES_INTER "05"
#DEFINE G_HONORARIO "06"
#DEFINE G_ANEX_QUIM "07"
#DEFINE G_ANEX_RADI "08"
#DEFINE G_ANEX_OPME "09"
#DEFINE G_REC_GLOSA "10"
#DEFINE G_PROR_INTE "11"

#DEFINE K_Cancel   8
#DEFINE K_Bloqueio 9
#DEFINE K_Desbloq  10
#DEFINE K_Bloqueio 9

STATIC aCampBD7  		:= {'BD7_VLRBPF','BD7_VLRBPR','BD7_VLRGLO','BD7_VLRMAN','BD7_VLRPAG','BD7_VLRTPF'}
STATIC aCampBD6  		:= {'BD6_VLRBPF','BD6_VLRBPR','BD6_VLRGLO','BD6_VLRMAN','BD6_VLRPAG','BD6_VLRPF','BD6_VLRTPF'}
STATIC aCpVrInfo 		:= LancFtCpo(1) // Info de valores de co-participacao
STATIC aTpVrInfo 		:= LancFtCpo(2) // Info de valores de taxa-copart
STATIC aCoVrInfo 		:= LancFtCpo(3) // Info de valores de custo operacional
STATIC aToVrInfo 		:= LancFtCpo(4) // Info de valores de taxa-custo
STATIC __aLanBXZ 		:= {}
STATIC __aLanFil 		:= {}
STATIC aRetAnx			:= {}
STATIC cconcateZ	:= IIF( AllTrim( TCGetDB() ) $ "ORACLE/DB2" , '||', '+')

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSGUIA001

@author PLS TEAM
@since  03/07/2019
@version P12
/*/
function PLSGUIA001(oFila)
Local aRetFun 	 := { .T., {} }
Local cAlias 	 := ''
Local cCodOpe 	 := PLSINTPAD() //'0001' //PLSINTPAD()
Local aArea		 := {}
Local aInfRed 	 := {}
local cMV_PLFTMP :=  GetNewPar("MV_PLFTMP","")

BCL->(dbsetOrder(1))
BCI->(dbSetOrder(1))
BD5->(dbSetOrder(1))
BE4->(dbSetOrder(1))
BD6->(dbSetOrder(1))

If oFila:cTipGui == "05" .or. oFila:cTipGui == "03"
	cAlias := "BE4"
else
	cAlias := "BD5"
endIf

BCL->(MsSeek(xfilial("BCL") + cCodOpe + oFila:cTipGui ))
BCI->(Msseek(xfilial("BCI") + cCodOpe + oFila:cCodLdp + oFila:cCodPeg))
(cAlias)->(Msseek(xfilial(cAlias) + cCodOpe + oFila:cCodLdp + oFila:cCodPeg + oFila:cNumGui))
BD6->(Msseek(xfilial("BD6") + cCodOpe + oFila:cCodLdp + oFila:cCodPeg + oFila:cNumGui))

IF (cAlias)->&( cAlias + "_FASE" ) <> "1"
	return
endIf

aArea := BD6->(GetArea())
PL720GMF(FaseBD6(BD6->BD6_CODOPE, BD6->BD6_CODLDP, BD6->BD6_CODPEG, BD6->BD6_NUMERO), "", nil, cAlias, BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV), .T., nil, .F.)
BD6->(restarea(aArea))

//Bloqueio pagamento conforme PE + parametro
PLS63DUP(@aRetFun, "2", BD6->BD6_CODOPE, BD6->BD6_CODLDP, BD6->BD6_CODPEG, BD6->BD6_NUMERO, BD6->BD6_CODRDA, .t.)

If Len(aRetFun[2]) > 0
	PL720GMF(IIF(AllTrim(BD6->BD6_CODRDA) $ cMV_PLFTMP .OR. cMV_PLFTMP == "ALL", "3","2"), "", aRetFun[2], cAlias, BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV), .T., nil, .F.)
endif

//******* Redutor de Custo
//Executo Redução de Custo, caso parâmetro esteja true e a PEG/Guia Pronta e Ativa
lNLocDig := iIf( (cAlias)->&( cAlias + "_CODLDP" ) $ iIf( PLSOBRPRDA( (cAlias)->&( cAlias + "_CODRDA" ) ),PLSRETLDP(9),PLSRETLDP(5) ), .t., .f.)

//Se paga pelo apresentado, não roda redução de custo
if ! lNLocDig .and. (cAlias)->&( cAlias + "_FASE" ) == "3" .and.;
   (cAlias)->&( cAlias + "_SITUAC" ) == "1"  .and. getTPCALC((cAlias)->&( cAlias + "_CODRDA" )) <> "3" .AND. ;
   PLSPOSGLO(PLSINTPAD(),__aCdCri231[1],__aCdCri231[2],"1")
		
	aAdd(aInfRed, { (cAlias)->&( cAlias + "_CODRDA" ) })
	aAdd(aInfRed, { (cAlias)->&( cAlias + "_CODOPE" ) })
	aAdd(aInfRed, { (cAlias)->&( cAlias + "_CODEMP" ) })
	aAdd(aInfRed, { (cAlias)->&( cAlias + "_MATRIC" ) })
	aAdd(aInfRed, { (cAlias)->&( cAlias + "_TIPREG" ) })
	aAdd(aInfRed, { (cAlias)->&( cAlias + "_CODPEG" ) })
	aAdd(aInfRed, { (cAlias)->&( cAlias + "_NUMERO" ) })
	aAdd(aInfRed, { (cAlias)->&( cAlias + "_DATPRO" ) })
	aAdd(aInfRed, { (cAlias)->&( cAlias + "_CODLDP" ) })

	PLSM250Pro("PLSM250   ", .t., "2", aInfRed, .f.)

endIf

//atualiza o cabecalho da guia
PLGUITOT(cAlias, BD6->BD6_CODOPE + BD6->BD6_CODLDP + BD6->BD6_CODPEG + BD6->BD6_NUMERO + BD6->BD6_ORIMOV, {}, .f.,nil,nil,.T.)

//Para guias estornadas, a mudanca de fase bloqueia a mesma após o termino
if &(cAlias)->(fieldPos(cAlias+"_GUESTO")) > 0 .and. ! empty( (cAlias)->&( cAlias + "_GUESTO" )) .and. (cAlias)->&( cAlias + "_FASE" ) <> '2'
	
	aFiles := PLSA500Fil(BCL->BCLCODOPE,BCL->BCL_TIPGUI)
	
	PLSA500STA("3",(cAlias)->&( cAlias + "_CODOPE" ), (cAlias)->&( cAlias + "_CODLDP" ), (cAlias)->&( cAlias + "_CODPEG" ), (cAlias)->&( cAlias + "_NUMERO" ),(cAlias)->&( cAlias + "_ORIMOV" ),aFiles,BCL->BCL_FUNGRV,K_Bloqueio,BCL->BCL_TIPGRV,BCL->BCL_ALIAS,getNewPar("MV_PLGUIES","123"))
	
endIf
	
return

//-------------------------------------------------------------------
/*/{Protheus.doc} FaseBD6
Pega a fase do bd6
@author PLS TEAM
@since  03/07/2019
@version P12
/*/
static function FaseBD6(cCodOpe, cCodLdp, cCodPEG, CNUMERO)

Local cfase := ""
Local cSql := ""

csql += " Select BD6_FASE from " + RetsqlName("BD6") + " BD6 "
cSql += " Where BD6_FILIAL = '" + xfilial("BD6") + "' "
cSql += " AND BD6_CODOPE = '" + cCodOpe + "' "
csql += " AND BD6_CODLDP = '" + cCodLdp + "' "
cSql += " AND BD6_CODPEG = '" + cCodPEG + "' "
cSql += " AND BD6_NUMERO = '" + cNumero + "' "
cSql += " AND D_E_L_E_T_ = ' ' "
cSql += " ORDER By BD6_FASE "

dbUseArea(.T.,"TOPCONN",tcGenQry(,,cSql),"FaseBD6",.F.,.T.)

cFase := FaseBD6->BD6_FASE

FaseBD6->(DbcloseArea())

return cFase 
