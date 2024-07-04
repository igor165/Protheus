#include "protheus.ch"
#include "msGraphi.ch"
#include "QDOP030.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ QDOP030  ³ Autor ³ Leandro S. Sabino     ³ Data ³08/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Painel de Gestao -  Pendencia por Documento                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                 											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAQDO                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDOP030()    
Local aRetPanel    := {} //Array com os dados que serão exibidos no painel
Private aDadosPen  := {} //Array com os dados ref. aos Doc. Pendentes 
Private aDadosAvi  := {} //Array com os dados ref. aos Avisos Pendentes
Private nMv_par01  
Private nMv_par02  
Private dMv_par03
Private dMv_par04

DbSelectArea("QD1")                   	
DbSelectArea("QDH")
DbSelectArea("QDS") 

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carregar a Query que sera exibida no PG ao clicar na Combo Doc. Pendentes por Fase³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
QDOGerQryPen()
If Len(aDadosPen) > 0
	aAdd(aRetPanel,{STR0001,{}})//"Pendentes por Fase"
	aAdd(aRetPanel[1][2],{STR0002,Transform(aDadosPen[1][1],"@E 99999"),CLR_GREEN,Nil})//"Aprovacao"
	aAdd(aRetPanel[1][2],{STR0003,Transform(aDadosPen[1][2],"@E 99999"),CLR_GREEN,Nil})//"Digitacao"
	aAdd(aRetPanel[1][2],{STR0004,Transform(aDadosPen[1][3],"@E 99999"),CLR_GREEN,Nil})//"Digitacao c/Critica"
	aAdd(aRetPanel[1][2],{STR0005,Transform(aDadosPen[1][4],"@E 99999"),CLR_GREEN,Nil})//"Elaboracao"
	aAdd(aRetPanel[1][2],{STR0006,Transform(aDadosPen[1][5],"@E 99999"),CLR_GREEN,Nil})//"Elaboracao c/Critica"
	aAdd(aRetPanel[1][2],{STR0007,Transform(aDadosPen[1][6],"@E 99999"),CLR_GREEN,Nil})//"Homologacao"
	aAdd(aRetPanel[1][2],{STR0008,Transform(aDadosPen[1][7],"@E 99999"),CLR_GREEN,Nil})//"Distribuicao"
	aAdd(aRetPanel[1][2],{STR0009,Transform(aDadosPen[1][8],"@E 99999"),CLR_GREEN,Nil})//"Leitura"
	aAdd(aRetPanel[1][2],{STR0010,Transform(aDadosPen[1][9],"@E 99999"),CLR_GREEN,Nil})//"Revisao"
Else
	aAdd(aRetPanel,{STR0001,{}})//"Pendentes por Fase"  
	aAdd(aRetPanel[1][2],{STR0002,Transform("0","@E 999.99"),CLR_GREEN,Nil})//"Aprovacao"
	aAdd(aRetPanel[1][2],{STR0003,Transform("0","@E 999.99"),CLR_GREEN,Nil})//"Digitacao"
	aAdd(aRetPanel[1][2],{STR0004,Transform("0","@E 999.99"),CLR_GREEN,Nil})//"Digitacao c/Critica"
	aAdd(aRetPanel[1][2],{STR0005,Transform("0","@E 999.99"),CLR_GREEN,Nil})//"Elaboracao"
	aAdd(aRetPanel[1][2],{STR0006,Transform("0","@E 999.99"),CLR_GREEN,Nil})//"Elaboracao c/Critica"
	aAdd(aRetPanel[1][2],{STR0007,Transform("0","@E 999.99"),CLR_GREEN,Nil})//"Homologacao"
	aAdd(aRetPanel[1][2],{STR0008,Transform("0","@E 999.99"),CLR_GREEN,Nil})//"Distribuicao"
	aAdd(aRetPanel[1][2],{STR0009,Transform("0","@E 999.99"),CLR_GREEN,Nil})//"Leitura"
	aAdd(aRetPanel[1][2],{STR0010,Transform("0","@E 999.99"),CLR_GREEN,Nil})//"Revisao"
Endif

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carregar a Query que sera exibida no PG ao clicar na Combo Avisos Pendentes 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
QDOGerQryAvi()
If Len(aDadosAvi) > 0
	aAdd(aRetPanel,{STR0011,{}})//"Avisos Pendentes "  
	aAdd(aRetPanel[2][2],{STR0012,Transform(aDadosAvi[1][1],"@E 99999"),CLR_GREEN,Nil})//"Solicitacoes"
	aAdd(aRetPanel[2][2],{STR0013,Transform(aDadosAvi[1][2],"@E 99999"),CLR_GREEN,Nil})//"Doc. Vencidos"
	aAdd(aRetPanel[2][2],{STR0014,Transform(aDadosAvi[1][3],"@E 99999"),CLR_GREEN,Nil})//"Doc. Cancelados"
	aAdd(aRetPanel[2][2],{STR0015,Transform(aDadosAvi[1][4],"@E 99999"),CLR_GREEN,Nil})//"Doc. Referenciado"
	aAdd(aRetPanel[2][2],{STR0016,Transform(aDadosAvi[1][5],"@E 99999"),CLR_GREEN,Nil})//"Necessidade de Treinamento"
	aAdd(aRetPanel[2][2],{STR0017,Transform(aDadosAvi[1][6],"@E 99999"),CLR_GREEN,Nil})//"Agendamento de Treinamento"
	aAdd(aRetPanel[2][2],{STR0018,Transform(aDadosAvi[1][7],"@E 99999"),CLR_GREEN,Nil})//"Ausencia Temporaria"
	aAdd(aRetPanel[2][2],{STR0019,Transform(aDadosAvi[1][8],"@E 99999"),CLR_GREEN,Nil})//"Questionario"
Else
	aAdd(aRetPanel,{STR0011,{}})//"Avisos Pendentes " 
	aAdd(aRetPanel[2][2],{STR0012,Transform("0","@E 999.99"),CLR_GREEN,Nil})//"Solicitacoes"
	aAdd(aRetPanel[2][2],{STR0013,Transform("0","@E 999.99"),CLR_GREEN,Nil})//"Doc. Vencidos"
	aAdd(aRetPanel[2][2],{STR0014,Transform("0","@E 999.99"),CLR_GREEN,Nil})//"Doc. Cancelados"
	aAdd(aRetPanel[2][2],{STR0015,Transform("0","@E 999.99"),CLR_GREEN,Nil})//"Doc. Referenciado"
	aAdd(aRetPanel[2][2],{STR0016,Transform("0","@E 999.99"),CLR_GREEN,Nil})//"Necessidade de Treinamento"
	aAdd(aRetPanel[2][2],{STR0017,Transform("0","@E 999.99"),CLR_GREEN,Nil})//"Agendamento de Treinamento"
	aAdd(aRetPanel[2][2],{STR0018,Transform("0","@E 999.99"),CLR_GREEN,Nil})//"Ausencia Temporaria"
	aAdd(aRetPanel[2][2],{STR0019,Transform("0","@E 999.99"),CLR_GREEN,Nil})//"Questionario"
Endif
	
Return aRetPanel


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³QDOGerQryPen³ Autor ³ Leandro S. Sabino   ³ Data ³08/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Gera os dados do painel de gestao Pendencia de Documentos  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                 											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAQDO                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDOGerQryPen()
Local cAliasQry := GetNextAlias()
Local cWhere    := ""
Local nApr		:= 0
Local nDig		:= 0
Local nDigC		:= 0
Local nElab		:= 0
Local nElabC	:= 0
Local nHomol	:= 0
Local nDistr	:= 0
Local nLeit		:= 0
Local nRev 		:= 0

Pergunte("QDOP30",.F.)

/*//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega as variaves dos parametros para variaveis publicas para serem usadas na funcao QDOGerQryAvi ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
nMv_par01:= mv_par01
nMv_par02:= mv_par02
dMv_par03:= DtoS(mv_par03)
dMv_par04:= DtoS(mv_par04)
        
MakeSqlExpr("QDOP30")

cWhere    :='% '
cWhere    += " QD1.QD1_MAT    BETWEEN '"+ nMv_par01 +"' AND '"+ nMv_par02 +"' AND "
cWhere    += " QD1.QD1_DTGERA BETWEEN '"+ dMv_par03 +"' AND '"+ dMv_par04 +"' AND "		
cWhere    +=' %'

//Selecionando as tabelas para garantir
//que elas existam antes da execucao da query
dbSelectArea("QDH")
dbSelectArea("QD1")

BeginSql Alias cAliasQry
	SELECT QD1.QD1_TPPEND PEND
 	FROM %table:QD1% QD1 	
       JOIN %table:QDH% QDH
        	ON QDH.QDH_FILIAL=QD1.QD1_FILIAL AND 
			QDH.QDH_DOCTO=QD1.QD1_DOCTO AND 
			QDH.QDH_RV=QD1.QD1_RV AND 
			QDH.%notDel% And QDH.QDH_OBSOL = 'N'
		WHERE QD1.QD1_FILIAL = %xFilial:QD1% AND 
			%Exp:cWhere%
			QD1.%notDel% AND QD1.QD1_PENDEN = 'P' AND QD1.QD1_SIT <> 'I' 
EndSql

dbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	While !(cAliasQry)->(Eof())
		DO CASE 
			CASE AllTrim(&(cAliasQry+"->PEND")) == "A"
			 	nApr:= nApr + 1
			CASE AllTrim(&(cAliasQry+"->PEND")) == "D"
				nDig:= nDig + 1
			CASE AllTrim(&(cAliasQry+"->PEND")) == "DC"
				nDigC:= nDigC + 1
			CASE AllTrim(&(cAliasQry+"->PEND")) == "E"
				nElab:= nElab + 1
			CASE AllTrim(&(cAliasQry+"->PEND")) == "EC"
				 nElabC:= nElabC +1
			CASE AllTrim(&(cAliasQry+"->PEND")) == "H"
				 nHomol:= nHomol + 1
			CASE AllTrim(&(cAliasQry+"->PEND")) == "I"
				 nDistr:= nDistr + 1
			CASE AllTrim(&(cAliasQry+"->PEND")) == "L"
				 nLeit:= nLeit + 1
			CASE AllTrim(&(cAliasQry+"->PEND")) == "R"
				 nRev:= nRev + 1
		EndCASE
	(cAliasQry)->(DbSkip())
	EndDo
	aAdd(aDadosPen,{nApr,nDig,nDigC,nElab,nElabC,nHomol,nDistr,nLeit,nRev})
EndIf

(cAliasQry)->(DbCloseArea())

Return 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³QDOGerQryAvi ³ Autor ³ Leandro S. Sabino  ³ Data ³08/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Gera os dados do painel de gestao Avisos Pendentes          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                 											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAQDO                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDOGerQryAvi()
Local cAliasQry := GetNextAlias()
Local cWhere    := ""
Local nSid		:= 0
Local nVen		:= 0
Local nCan		:= 0
Local nRef		:= 0
Local nTre		:= 0
Local nTI		:= 0
Local nTmp		:= 0
Local nQue		:= 0

cWhere    :='% '
cWhere    += " QDS.QDS_MAT BETWEEN '"+ nMv_par01 +"' AND '"+ nMv_par02 +"' AND "
cWhere    += " QDS.QDS_DTGERA BETWEEN '"+ dMv_par03 +"' AND '"+ dMv_par04 +"' AND "		
cWhere    +=' %'

BeginSql Alias cAliasQry
		SELECT QDS.QDS_TPPEND TPPEND
		FROM %table:QDS% QDS 
		WHERE                              
			QDS.QDS_FILIAL = %xFilial:QDS% AND
			%Exp:cWhere%
			QDS.QDS_PENDEN='P' AND 	QDS.D_E_L_E_T_ <> '*'  	
EndSql

dbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	While !(cAliasQry)->(Eof())
		DO CASE 
			CASE AllTrim(&(cAliasQry+"->TPPEND")) == "SID" .OR. AllTrim(&(cAliasQry+"->TPPEND")) == "SAD"
			 	nSid:= nSid + 1
			CASE AllTrim(&(cAliasQry+"->TPPEND")) == "VEN"
				nVen:= nVen + 1
			CASE AllTrim(&(cAliasQry+"->TPPEND")) == "CAN"
				nCan:= nCan + 1
			CASE AllTrim(&(cAliasQry+"->TPPEND")) == "REF"
				nRef:= nRef + 1
			CASE AllTrim(&(cAliasQry+"->TPPEND")) == "TRE"
				 nTre:= nTre +1
			CASE AllTrim(&(cAliasQry+"->TPPEND")) == "TI"
				 nTI:= nTI + 1
			CASE AllTrim(&(cAliasQry+"->TPPEND")) == "TMP"
				 nTmp:= nTmp + 1
			CASE AllTrim(&(cAliasQry+"->TPPEND")) == "QUE"
				 nQue:= nQue + 1
		EndCASE
	(cAliasQry)->(DbSkip())
	EndDo
	aAdd(aDadosAvi,{nSid,nVen,nCan,nRef,nTre,nTI,nTmp,nQue})
EndIf

(cAliasQry)->(DbCloseArea())

Return