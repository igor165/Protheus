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

#DEFINE __cBLODES	__aCdCri109[1] + '|' + __aCdCri110[1] + '|' + __aCdCri111[1] + '|' + __aCdCri230[1] + '|' +;
					__aCdCri232[1] + '|' + __aCdCri223[1] + '|' + __aCdCri226[1] + '|' + __aCdCri178[1] + '|' +;
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

STATIC aCampBD7  		:= {'BD7_VLRBPF','BD7_VLRBPR','BD7_VLRGLO','BD7_VLRMAN','BD7_VLRPAG','BD7_VLRTPF'}
STATIC aCampBD6  		:= {'BD6_VLRBPF','BD6_VLRBPR','BD6_VLRGLO','BD6_VLRMAN','BD6_VLRPAG','BD6_VLRPF','BD6_VLRTPF'}
STATIC aCpVrInfo 		:= LancFtCpo(1) // Info de valores de co-participacao
STATIC aTpVrInfo 		:= LancFtCpo(2) // Info de valores de taxa-copart
STATIC aCoVrInfo 		:= LancFtCpo(3) // Info de valores de custo operacional
STATIC aToVrInfo 		:= LancFtCpo(4) // Info de valores de taxa-custo
STATIC __aLanBXZ 		:= {}
STATIC __aLanFil 		:= {}
STATIC lMVPLFAUTP 		:= getNewPar("MV_PLFAUTP",.f.) //forca validacao na autp (plsxaut) caso o cabecalho da guia nao seja valida. Ex.: Usuario bloqueiado.
STATIC cMVPLSCPFB		:= getNewPar("MV_PLSCPFB","0")
STATIC cMVPLSCHMP		:= getNewPar("MV_PLSCHMP","HM,PPM,HMR")
STATIC cMVPLSCHMA		:= getNewPar("MV_PLSCHMA","PA,PAP,PAR")
STATIC lAnyGlosa		:= IsInCallStack('PLSA500RCB') .or. IsInCallStack('PLSA500GML') .or. IsInCallStack('PLSA500ACT')
STATIC lGlosa 			:= IsInCallStack('PLSA500RCB') .or. IsInCallStack('PLSA500GML')
STATIC aRetAnx			:= {}

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSPEG001
Validação de erro controlado
@author PLS TEAM
@since  03/07/2019
@version P12
/*/
function PLSPEG001(oFila) 

Local lValido := .t.
Local lErroCont := .F.
Local cTipoGuia	:= oFila:cTipGui
Local cAlias	:= ""
Local cOriMov   := "" 
Local aRetCom	:= {}
Local aAreaBD6	:= {} //BD6->(GetArea())
local aSuperRecno := {} //{ cAlias, (cAlias)->(recno()), {}, {} }
Local cTipPe	:= ""
Local cChaveGui	:= ""
Local cCodOpe	:= PLSINTPAD() //"0001" // PLSINTPAD()
Local aBD6		:= {}
Local cMatricUsr:= ""
Local cMatAnt	:= ""
Local aRetAux	:= {}
Local nX		:= 0

if cTipoGuia == "05" .or. cTipoGuia=="03"
	cAlias :="BE4"
else
	cAlias :="BD5"
endif 	

cOriMov := (cAlias)->&( cAlias + "_ORIMOV" )

BCL->(dbsetOrder(1))
BCI->(dbSetOrder(1))
BD5->(dbSetOrder(1))
BE4->(dbSetOrder(1))
BD6->(dbSetOrder(1))
BR8->(dbsetOrder(1))

BCL->(MsSeek(xfilial("BCL") + cCodOpe + oFila:cTipGui ))

BCI->(Msseek(xfilial("BCI") + cCodOpe + oFila:cCodLdp + oFila:cCodPeg))

//BD5->(Msseek(xfilial("BD5") + cCodOpe + oFila:cCodLdp + oFila:cCodPeg + oFila:cNumGui))
(cAlias)->(Msseek(xfilial(cAlias) + cCodOpe + oFila:cCodLdp + oFila:cCodPeg + oFila:cNumGui))
cOriMov := (cAlias)->&( cAlias + "_ORIMOV" )

BD6->(Msseek(xfilial("BD6") + cCodOpe + oFila:cCodLdp + oFila:cCodPeg + oFila:cNumGui))
if FWAliasInDic("B6A", .F.)
	PLSB6ADEL(BD6->BD6_CODOPE, BD6->BD6_CODLDP, BD6->BD6_CODPEG, BD6->BD6_NUMERO, cAlias)
endif
aAreaBD6	:= BD6->(GetArea())
aSuperRecno := { cAlias, (cAlias)->(recno()), {}, {} }

cMatricUsr	:= BD6->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG+BD6_DIGITO)
cMatAnt		:= BD6->BD6_MATANT
aRetAux := PLSDADUSR(cMatricUsr,"1",.f., BD6->BD6_DATPRO, BD6->BD6_CODPAD, BD6->BD6_CODPRO, nil, nil)
if !aRetAux[1] .and. !empty(cMatAnt)
	aRetAux := PLSDADUSR(cMatAnt,"2",.f., BD6->BD6_DATPRO, BD6->BD6_CODPAD, BD6->BD6_CODPRO, nil, nil)
endif

if !aRetAux[1] 	
	for nX := 1 to len(aRetAux[2])
		aadd(aRetCom,{{aRetAux[2][nX][1],aRetAux[2][nX][2],"",BCT->BCT_NIVEL,BCT->BCT_TIPO,"","","",""}})		
		lErroCont := .t.
	next	
endif

aadd(aBD6,{ BD6->(recno()),BD6->BD6_SEQUEN,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_QTDPRO,BD6->BD6_HORPRO, BD6->BD6_FADENT,BD6->BD6_DENREG,{}})

cChaveGui := BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV)

while ! BD6->(eof()) .and. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) == xFilial("BD6") + cChaveGui
	
	aadd(aBD6,{ BD6->(recno()),BD6->BD6_SEQUEN,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_QTDPRO,BD6->BD6_HORPRO, BD6->BD6_FADENT,BD6->BD6_DENREG,{}})
	
	aadd(aSuperRecno[3],BD6->(recno()))
	
	plTRBBD7("TRBBD7", BD6->BD6_CODOPE, BD6->BD6_CODLDP, BD6->BD6_CODPEG, BD6->BD6_NUMERO, BD6->BD6_ORIMOV, BD6->BD6_SEQUEN)
			
	if ! TRBBD7->(eof())		
		
		aBD7 := {}
		
		while ! TRBBD7->(eof())
			
			BD7->( dbGoTo( TRBBD7->REC ) )
			
			aadd(aSuperRecno[4], TRBBD7->REC )
			
			if empty(cTipPe)
			
				aAreaBAU := BAU->(getArea())
				
				BAU->( dbSetOrder(1) )
				BAU->( msSeek(xFilial("BAU") + BD7->BD7_CODRDA ) )
				
				cTipPe := BAU->BAU_TIPPE
				
				BAU->(restArea(aAreaBAU))
				
			endIf
			
			//eu pego a especialidade do BD7_CODESP pois nem sempre no xml vem a especialidade do executante dai la no xaut ele so tava tratando o contratado		   	   															
			aadd(aBd7,{	BD7->BD7_CODUNM} )																																						//[1] - UNIDADE									
			aadd(aBd7[len(aBd7)],{BD7->BD7_CODRDA,iIf(empty(BD7->BD7_CODESP),BD6->BD6_CODESP,BD7->BD7_CODESP),iIf(empty(BD7->BD7_CODLOC),BD6->BD6_CODLOC,BD7->BD7_CODLOC) ,cTipPe  ,	'C'}) 	//[4] - CONTRATADO e ESPECIALIDADE e local e TIPO F/J
			aadd(aBd7[len(aBd7)],{BD7->BD7_CDPFPR,iIf(empty(BD7->BD7_ESPEXE),BD7->BD7_CODESP,BD7->BD7_ESPEXE),''			   											  ,'F'	   ,	'E'})	//[2] - EXECUTANTE e ESPECIALIDADE E local (ainda nao existe local do executante, na tiss 3.0 vai ter) e TIPO F/J
			aadd(aBd7[len(aBd7)],{BD6->BD6_CDPFSO,iIf(empty(BD7->BD7_ESPSOL),BD7->BD7_CODESP,BD7->BD7_ESPSOL),''			   											  ,'F'	   ,	'S'})	//[3] - SOLICITANTE e ESPECIALIDADE E local (ainda nao existe local do solicitante, na tiss 3.0 vai ter) e TIPO F/J
				
		TRBBD7->(dbSkip())
		endDo

		aBD6[ len(aBD6), 9 ] := aClone(aBD7)
		
	endIf		
	TRBBD7->(dbCloseArea())
	
	BD6->(dbSkip())
endDo

BD6->(restArea(aAreaBD6))

// Executa rotina de analise geral das guias...
if getNewPar("MV_PLSINTE","0") == "1"

	if len(aSuperRecno[3]) == 0
	
		PLSPOSGLO(cCodOpe,__aCdCri032[1],__aCdCri032[2],"2")
		
		aadd(aRetCom,{{__aCdCri032[1],STR0029,"",BCT->BCT_NIVEL,BCT->BCT_TIPO,"","","",""}}) //"Nao existem eventos (BD6) para esta guia"
		
		lValido := .f.
		
	endIf

	if len(aSuperRecno[4]) == 0
	
		PLSPOSGLO(cCodOpe,__aCdCri032[1],__aCdCri032[2],"2")
		
		aadd(aRetCom,{{__aCdCri032[1],STR0030,"",BCT->BCT_NIVEL,BCT->BCT_TIPO,"","","",""}}) //"Nao existem subitens (BD7) para esta guia"
		
		lValido := .f.
		
	endIf
	
	If lValido
		PLSAnaCM(aSuperRecno,.f.,.f., subs(cChaveGui,1,len(cChaveGui)-1),cOriMov,aRetCom,,cTipoGuia)
	else
		lErroCont := .t.
	EndIF
	
	if len(aRetCom) > 0
		lErroCont := .t.
		lValido   := .f.
	endIf
	
endIf

if lErroCont
	PLSGRVB6A(BD6->BD6_CODOPE, BD6->BD6_CODLDP, BD6->BD6_CODPEG, BD6->BD6_NUMERO, aRetCom, cAlias)
endif

Return lErroCont

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSGRVB6A
Grava tabela de erro controlado
@author Lucas Nonato
@since  01/10/2019
@version P12
/*/
function PLSGRVB6A(cCodOpe, cCodLdp, cCodPeg, cNumero, aRetCom, cAlias)
local lGrv 	as logical
local nX 	as numeric

(cAlias)->(reclock(cAlias,.f.))
(cAlias)->&(cAlias+"_ERRO") := "1"
(cAlias)->(msunlock())
//B6A_FILIAL+B6A_CODOPE+B6A_CODLDP+B6A_CODPEG+B6A_NUMERO+B6A_SEQUEN+B6A_CODUNM+B6A_CODCRI+B6A_DESCRI                                                             
if PLSALIASEX("B6A")//Adicionado em 09/2019 12.1.25 remover na próxima release.
	B6A->(dbsetorder(1))
	for nX:=1 to len(aRetCom)
		cSequen := padr(aRetCom[nX][1][8],3)
		cCodUnm	:= padr(aRetCom[nX][1][9],3)

		lGrv := !(B6A->(msseek(xfilial("B6A")+cCodOpe+cCodLdp+cCodPeg+cNumero+cSequen+cCodUnm+aRetCom[nX][1][1]+aRetCom[nX][1][2])))
		B6A->(reclock("B6A",lGrv))
		B6A->B6A_FILIAL := xfilial("B6A")
		B6A->B6A_CODOPE := cCodOpe
		B6A->B6A_CODLDP := cCodLdp
		B6A->B6A_CODPEG := cCodPeg
		B6A->B6A_NUMERO := cNumero
		B6A->B6A_CODPAD := aRetCom[nX][1][6]
		B6A->B6A_CODPRO := aRetCom[nX][1][7]
		B6A->B6A_SEQUEN := cSequen
		B6A->B6A_CODUNM := cCodUnm
		B6A->B6A_CODCRI	:= aRetCom[nX][1][1]
		B6A->B6A_DESCRI	:= aRetCom[nX][1][2]		
		B6A->(msunlock())
	next
endif

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSB6ADEL
Exclui tabela de erro controlado
@author Lucas Nonato
@since  01/10/2019
@version P12
/*/
function PLSB6ADEL(cCodOpe, cCodLdp, cCodPeg, cNumero, cAlias)
local cSql as char

cSql := " DELETE FROM " + RetSqlName("B6A") + " "
cSql += " WHERE B6A_FILIAL = '" + xfilial("B6A") +"'"
cSql += " AND B6A_CODOPE = '" + cCodOpe +"'"
cSql += " AND B6A_CODLDP = '" + cCodLdp +"'"
cSql += " AND B6A_CODPEG = '" + cCodPeg +"'"
cSql += " AND B6A_NUMERO = '" + cNumero +"'"
cSql += " AND D_E_L_E_T_ = ' ' "

PLSCOMMIT(cSql)

(cAlias)->(reclock(cAlias,.f.))
(cAlias)->&(cAlias+"_ERRO") := "0"
(cAlias)->(msunlock())

return
