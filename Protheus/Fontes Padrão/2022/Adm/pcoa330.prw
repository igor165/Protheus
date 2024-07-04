#INCLUDE "PCOA330.ch"
#INCLUDE "protheus.ch"

//Tradu็ใo PTG 20080721

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Pcoa330  บAutor  ณ Gustavo / Bruno    บ Data ณ  20/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Contabilizar os lancamentos do CT3, gerando tabela de      บฑฑ
ฑฑบ          ณ lancamentos realizados (AKD).                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Planejamento e Controle Orcamentario                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static lPLogIni  := FindFunction('PROCLOGINI')
Static lPLogAtu  := FindFunction('PROCLOGATU')

Function Pcoa330()
Local lEnd 			:= .F.
Local aMV_Par   	:= {}
Local nOpca			:= 0
Local aSays			:= {}
Local aButtons		:= {}
Local cFunction		:= "PCOA330"
Local cPerg			:= "PCO330"
Local cTitle		:= STR0001	//"Geracao de saldos orcamentarios a partir da contabilidade"
Local cDescription	:= STR0002 + CRLF +;		//"  Este programa tem como objetivo gerar as movimentacoes no PCO em base aos  "
					   STR0003 + CRLF + CRLF+;	//"  registros contabeis diarios por conta e por conta mais centro de custo. "
					   STR0014 + CRLF +;		//"  Tambem podera ser gerado movimentos por conta + item contabil ou por "
					   STR0015 + CRLF + CRLF+;	//"  conta + classe de valor."
					   STR0004 + CRLF +;		//"  Utilizado no caso de querer refletir os saldos contabeis de uma conta ou de "
					   STR0005					//"  um grupo de contas no modulo de planejamento orcamentario."
					   
Local bProcess		:= { |oSelf| A330PreProc(oSelf) }

Private cCadastro := STR0001 //"Geracao de saldos orcamentarios a partir da contabilidade"

Pergunte(cPerg,.F. )

If IsBlind()

		ProcLogIni( aButtons )

	aMV_Par	:=	{mv_par01,mv_par02,mv_par03,mv_par04,mv_par05,mv_par06,mv_par07,"",mv_par09}
		ProcLogAtu("INICIO")
  	If mv_par09 == 1
		BatchProcess(cCadastro,STR0002+STR0003+STR0004+STR0005,"PCO330",{ || Processa({|| ProcLancCTB(aMV_Par) })})
	ElseIf mv_par09 == 2
		//aqui por saldo por conta/Item Contabil
		BatchProcess(cCadastro,STR0002+STR0003+STR0004+STR0005,"PCO330",{ || Processa({|| ProcCT4Lanc(aMV_Par) })})
	ElseIf mv_par09 == 3
		//aqui por saldo por conta/classe de valor
		BatchProcess(cCadastro,STR0002+STR0003+STR0004+STR0005,"PCO330",{ || Processa({|| ProcCTILanc(aMV_Par) })})
	EndIf	
		ProcLogAtu("FIM")

Else

	tNewProcess():New( cFunction, cTitle, bProcess, cDescription, cPerg )
    
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณProcLancCTB บAutor  ณ Gustavo / Bruno    บ Data ณ  21/10/05 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Grava os lancamentos realizados na tabela AKD              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Planejamento e Controle Orcamentario                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ProcLancCTB(aMV_Par,oSelf)
                                                                   
local cDataIni  := DToS(aMv_par[01])
local cDataFim  := DToS(aMv_par[02])
Local cQuery	:=	""
Local cConta	:=	""
Local cEmpTmp	:= 	"" 
Local nTotCC 	:= 0       
Local nLen	    := 0
Local nFils     := 0
Local nDias		:= 0
Local nX		:= 0
Local cFiliais	:=	""
Local cFiltro	:=	""
Local cDbMs	 	:= UPPER(TcGetDb())
Local lNotBlind	:= !IsBlind()
Local aFils		:= {}
Local aSelFil   := {}
Local __cFilAnt := cFilAnt

Private nTotCT7	:= 0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Busca todas as filiais do sigamat para utilizar na query ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cEmpTmp  := SM0->M0_CODIGO
aFils    := GetPCOFils(cEmpTmp,aMV_PAR[03],aMV_PAR[04])
cFiliais := StrTran(aFils[1] ,"'","")
nFils    := aFils[2] 

aSelFil := StrTokArr2( StrTran( cFiliais, "'", "" ) , ',', .F. ) 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVariavel para utilizar no lancamento de saldo de CONTA.                ณ
//ณEsta variavel tem o saldo do CQ1 - os saldos de CQ3 por CC.            ณ
//ณEstes sao contabilizados primeiro e o CQ1 deve ser contabilizado depoisณ
//ณExemplo:                                                               ณ
//ณCQ1_CONTA  CQ3_CCUSTO            VALOR A LANCAR                        ณ
//ณ001        	X1                              5                       ณ
//ณ001			X2                             10                        	ณ
//ณ001			X3                             30                         	ณ
//ณ001			NULL       			  60-(30+10+5) == nTotCT7             	ณ
//ณ002			NULL                	   	100-0 == nTotCT7              		ณ
//ณ003			NULL                    	200-0 == nTotCT7              		ณ
//ณ004          X1                             10                        ณ
//ณ004			X2                             20                          ณ
//ณ005			X2                             50                          ณ
//ณ005			NULL                      	 80-0 == nTotCT7               ณ
//ณ                                                                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lNotBlind
	oSelf:SetRegua1( nFils * (aMv_par[02]-aMv_par[01])+1 )
EndIf	


cQuery	:= "SELECT CQ3.*, CQ1.*, CQ1.R_E_C_N_O_ CQ1_RECNO, CQ3.R_E_C_N_O_ CQ3_RECNO, CT1.R_E_C_N_O_ CT1_RECNO "
cQuery  += " FROM  "+RetSqlName('CT1')+" CT1,  "+RetSqlName('CQ1')+" CQ1  "
If cDbMs == "INFORMIX"
	cQuery += ", "+ RetSqlName("CQ3") + " CQ3 "
ElseIf cDbMs $ "DB2/MYSQL/CTREESQL" .Or. "MSSQL" $ cDbMs
	cQuery += " LEFT OUTER JOIN "+ RetSqlName("CQ3") + " CQ3 ON "
	cQuery  += " CQ3_FILIAL = CQ1_FILIAL "
	cQuery  += " AND CQ3_DATA = CQ1_DATA "
	cQuery  += " AND CQ3_CONTA = CQ1_CONTA"
	cQuery  += " AND CQ3_MOEDA = '"+aMV_Par[07]+"'"
	cQuery  += " AND CQ3_TPSALD = '1'"
	cQuery  += " AND CQ3.D_E_L_E_T_ <>'*' "
Else
	cQuery += ", "+ RetSqlName("CQ3") + " CQ3 "
Endif

If "," $ cFiliais  
	cQuery  += " WHERE CQ1_FILIAL " + GetRngFil( aSelFil, "CQ1" ) + " "
Else
	cQuery  += " WHERE CQ1_FILIAL = '"+xFilial("CQ1",cFiliais)+"' " 
EndIf

//CT1 compartilhado
If PCOCompart("CT1")
	cQuery  += " AND CT1_FILIAL = '"+xFilial("CT1")+"' "
//CQ1 exclusivo e o CT1 exclusivo 
ElseIf !PCOCompart("CQ1")
	cQuery  += " AND CT1_FILIAL = CQ1_FILIAL "
//Nao pode existir CQ1 compartilhado e CT1 exclusivo	
Endif

cQuery  += " AND CT1_CONTA = CQ1_CONTA "
cQuery  += " AND CQ1_MOEDA = '"+aMV_Par[07]+"'"
cQuery  += " AND CQ1_TPSALD = '1'"
cQuery  += " AND CQ1_DATA BETWEEN '"+cDataIni+"' AND '"+cDataFim+"'"
cQuery  += " AND CQ1_CONTA BETWEEN '"+aMv_par[05]+"' AND '"+aMv_par[06]+"'"
If !Empty(aMV_Par[08])
	cFiltro := PcoParseFil(aMV_Par[08],"CT1")             
	If !Empty(cFiltro)                                         
		cQuery  += " AND ("+cFiltro+")"                         
	Endif                                                      
Endif
cQuery  += " AND CQ1.D_E_L_E_T_ <>'*' " 
cQuery  += " AND CT1.D_E_L_E_T_ <>'*' " 
If cDbMs == "ORACLE"
	cQuery  += " AND CQ3_FILIAL(+) = CQ1_FILIAL "
	cQuery  += " AND CQ3_DATA(+) = CQ1_DATA "
	cQuery  += " AND CQ3_CONTA(+) = CQ1_CONTA"
	cQuery  += " AND CQ3_MOEDA(+) = '"+aMV_Par[07]+"'"
	cQuery  += " AND CQ3_TPSALD(+) = '1'"
	cQuery  += " AND CQ3.D_E_L_E_T_(+) <>'*' "
ElseIf cDbMs $ "INFORMIX/POSTGRES" .Or. ("DB2/400" $ cDbMs) .or. "CTREESQL" $ cDbMs
	cQuery  += " AND CQ3_FILIAL = CQ1_FILIAL "
	cQuery  += " AND CQ3_DATA = CQ1_DATA "
	cQuery  += " AND CQ3_CONTA = CQ1_CONTA"
	cQuery  += " AND CQ3_MOEDA = '"+aMV_Par[07]+"'"
	cQuery  += " AND CQ3_TPSALD = '1'"
	cQuery  += " AND CQ3.D_E_L_E_T_ <>'*' "
ElseIf !(cDbMs $ "DB2/MYSQL") .and. !("MSSQL" $ cDbMs)  .And. !("DB2/400" $ cDbMs)
	cQuery  += " AND CQ1_FILIAL *= CQ3_FILIAL "
	cQuery  += " AND CQ1_DATA *= CQ3_DATA "
	cQuery  += " AND CQ1_CONTA *= CQ3_CONTA"
	cQuery  += " AND CQ3_MOEDA = '"+aMV_Par[07]+"'"
	cQuery  += " AND CQ3_TPSALD = '1'"
	cQuery  += " AND CQ3.D_E_L_E_T_ <>'*' "
Endif

cQuery  += " ORDER BY CQ1_FILIAL,CQ1.CQ1_DATA,CQ1.CQ1_CONTA"
cQuery 	:= ChangeQuery(cQuery)     

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB",.T.,.T.)

aStruct	:= CQ1->(DbStruct())
nLen    := Len(aStruct)
For nX:= 1 To nLen
	If aStruct[nX,2] <> "C"
		TcSetField("TRB",aStruct[nX,1],aStruct[nX,2],aStruct[nX,3],aStruct[nX,4])
    Endif
Next nX

aStruct	:= CQ3->(DbStruct())
nLen    := Len(aStruct)
For nX:= 1 To nLen
	If aStruct[nX,2] <> "C"
		TcSetField("TRB",aStruct[nX,1],aStruct[nX,2],aStruct[nX,3],aStruct[nX,4])
    Endif
Next nX       
        
CQ3->( dbSetOrder( 1 ) )
CQ1->( dbSetOrder( 1 ) )

cConta   	:= TRB->CQ1_CONTA
cData		:= Dtos(TRB->CQ1_DATA) 
cFilProc	:= TRB->CQ1_FILIAL
cFilPrev 	:= TRB->CQ1_FILIAL
nTotCC   	:= 0       
nTotCT7  	:= 0                     
dDataAnt 	:= TRB->CQ1_DATA-1
lFirst		:=	.T.

If TRB->( ! EoF() )

	Do While TRB->( ! EoF() )
		If lFirst .Or. (Year(TRB->CQ1_DATA)<>Year(dDataAnt) .Or.  Month(TRB->CQ1_DATA)<>Month(dDataAnt)) ;
				.Or. cFilPrev<>TRB->CQ1_FILIAL
			cFilAnt := TRB->CQ1_FILIAL
			If !lFirst
				If lNotBlind
					oSelf:SetRegua2(2)
					oSelf:IncRegua2(STR0010+cFilPrev+STR0011+StrZero(Month(dDataAnt),2)+"/"+Str(Year(dDataAnt),4))//"Gravando empresa "###" no mes "
					PCOFinLan("000255")
					oSelf:IncRegua2(STR0010+cFilPrev+STR0011+StrZero(Month(dDataAnt),2)+"/"+Str(Year(dDataAnt),4))//"Gravando empresa "###" no mes "						
				Else
					PCOFinLan("000255")
				EndIf		
	    	Endif
			PCOIniLan("000255")
			cFilPrev:= 	TRB->CQ1_FILIAL
		Endif
		If lNotBlind .And. dDataAnt <> 	TRB->CQ1_DATA
			nDias	:= (TRB->CQ1_DATA - dDataAnt)
			For nX:= 1 To nDias
				oSelf:IncRegua1(STR0012+cFilPrev+STR0013+DtoC(TRB->CQ1_DATA))
			Next                                        
		Endif
		dDataAnt 	:= 	TRB->CQ1_DATA
		lFirst		:=	.F.
	
		If Empty(cFiltro) .And. !Empty(aMV_Par[08])                                         
			CT1->(MsGoTo(TRB->CT1_RECNO))
			If !TRB->(&(aMV_Par[08]))
				TRB->(dbSkip())
				Loop
			Endif
		Endif
	
		If TRB->CQ1_CONTA+dtos(TRB->CQ1_DATA)+TRB->CQ1_FILIAL <> cConta + cData +cFilProc
			nTotCC  	:= 0       
			cConta	:=	TRB->CQ1_CONTA                         
			cData		:=	Dtos(TRB->CQ1_DATA) 
			cFilProc	:=	TRB->CQ1_FILIAL
		Endif               
	
		CQ1->( MsGoto(TRB->CQ1_RECNO)) 
		If !Empty( TRB->CQ3_CCUSTO )            
			CQ3->( MsGoto(TRB->CQ3_RECNO)) 
			nTotCC    += TRB->CQ3_CREDIT-TRB->CQ3_DEBITO
			PCODetLan("000255","01","PCOA330")
		ElseIf Empty( TRB->CQ3_CCUSTO )
			nTotCT7   := (TRB->CQ1_CREDIT-TRB->CQ1_DEBITO) - nTotCC
			PCODetLan("000255","02","PCOA330")
		EndIf
		TRB->(dbSkip())
	EndDo
	If lNotBlind
		oSelf:SetRegua2(2)
		oSelf:IncRegua2(STR0010+cFilPrev+STR0011+StrZero(Month(dDataAnt),2)+"/"+Str(Year(dDataAnt),4))//"Gravando empresa "###" no mes "
		PCOFinLan("000255")
		oSelf:IncRegua2(STR0010+cFilPrev+STR0011+StrZero(Month(dDataAnt),2)+"/"+Str(Year(dDataAnt),4))//"Gravando empresa "###" no mes "
	Else
		PCOFinLan("000255")
	EndIf	
	
EndIf	

DbSelectArea('TRB')
DbCloseArea()
DbSelectArea('SX1')
cFilAnt := __cFilAnt 
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณProcCTILanc บAutor  ณ Gustavo/Bruno/Pauloบ Data ณ  18/04/07 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Grava os lancamentos realizados na tabela AKD              บฑฑ
ฑฑบ          ณ baseado na tabela de saldos contabeis p/ classe valor (CTI)บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Planejamento e Controle Orcamentario                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ProcCTILanc(aMV_Par,oSelf)

local cDataIni  := DToS(aMv_par[01])
local cDataFim  := DToS(aMv_par[02])
Local cQuery	:=	""
Local cConta	:=	""
Local cEmpTmp	:= 	"" 
Local nTotClVl 	:= 0       
Local nLen	    := 0
Local nFils    	:= 0
Local nDias		:= 0
Local nX		:= 0
Local cFiliais	:=	""
Local cFiltro	:=	""
Local cDbMs	 	:= UPPER(TcGetDb())
Local lNotBlind	:= !IsBlind()
Local aFils		:= {}
Local aSelFil   := {}
Local __cFilAnt := cFilAnt

Private nTotCT7 := 0


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Busca todas as filiais do sigamat para utilizar na query ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cEmpTmp  := SM0->M0_CODIGO
aFils    := GetPCOFils(cEmpTmp,aMV_PAR[03],aMV_PAR[04])
cFiliais := StrTran(aFils[1] ,"'","") 
nFils 	 := aFils[2] 

aSelFil  := StrTokArr2( cFiliais, ',', .F. )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVariavel para utilizar no lancamento de saldo de CONTA.                ณ
//ณEsta variavel tem o saldo do CQ1 - os saldos de CQ7 por Cl. Valor      ณ
//ณEstes sao contabilizados primeiro e o CQ1 deve ser contabilizado depoisณ
//ณExemplo:                                                               ณ
//ณCQ1_CONTA  CQ7_CLVL                 VALOR A LANCAR                     ณ
//ณ001        	X1                              5                         ณ
//ณ001			X2                             10                         ณ
//ณ001			X3                             30                         ณ
//ณ001			NULL       			  60-(30+10+5) == nTotCT7             ณ
//ณ002			NULL                	   	100-0 == nTotCT7              ณ
//ณ003			NULL                    	200-0 == nTotCT7              ณ
//ณ004          X1                             10                         ณ
//ณ004			X2                             20                         ณ
//ณ005			X2                             50                         ณ
//ณ005			NULL                      	 80-0 == nTotCT7              ณ
//ณ                                                                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lNotBlind
	oSelf:SetRegua1( nFils * (aMv_par[02]-aMv_par[01])+1 )
EndIf	

cQuery	:= "SELECT CQ7.*, CQ1.*, CQ1.R_E_C_N_O_  CQ1_RECNO, CQ7.R_E_C_N_O_ CQ7_RECNO, CT1.R_E_C_N_O_ CT1_RECNO "                             
cQuery  += " FROM  "+RetSqlName('CT1')+" CT1,  "+RetSqlName('CQ1')+" CQ1  "
If cDbMs == "INFORMIX"
	cQuery += ", "+ RetSqlName("CQ7") + " CQ7 "
ElseIf cDbMs $ "DB2/MYSQL/CTREESQL" .Or. "MSSQL" $ cDbMs
	cQuery += " LEFT OUTER JOIN "+ RetSqlName("CQ7") + " CQ7 ON "
	cQuery  += " CQ7_FILIAL = CQ1_FILIAL "
	cQuery  += " AND CQ7_DATA = CQ1_DATA "
	cQuery  += " AND CQ7_CONTA = CQ1_CONTA"
	cQuery  += " AND CQ7_MOEDA = '"+aMV_Par[07]+"'"
	cQuery  += " AND CQ7_TPSALD = '1'"
	cQuery  += " AND CQ7.D_E_L_E_T_ <>'*' "
Else
	cQuery += ", "+ RetSqlName("CQ7") + " CQ7 "
Endif
If "," $ cFiliais 
	cQuery  += " WHERE CQ1_FILIAL " + GetRngFil( aSelFil, "CQ1" ) + " "
Else
   cQuery  += " WHERE CQ1_FILIAL = '" + cFiliais + "' "
EndIf
//CT1 compartilhado
If PCOCompart('CT1')
	cQuery  += " AND CT1_FILIAL = '"+xFilial("CT1")+"' "
//CQ1 exclusivo e o CT1 exclusivo 
ElseIf !PCOCompart('CQ1')
	cQuery  += " AND CT1_FILIAL = CQ1_FILIAL "
//Nao pode existir CQ1 compartilhado e CT1 exclusivo	
Endif
cQuery  += " AND CT1_CONTA = CQ1_CONTA "
cQuery  += " AND CQ1_MOEDA = '"+aMV_Par[07]+"'"
cQuery  += " AND CQ1_TPSALD = '1'"
cQuery  += " AND CQ1_DATA BETWEEN '"+cDataIni+"' AND '"+cDataFim+"'"
cQuery  += " AND CQ1_CONTA BETWEEN '"+aMv_par[05]+"' AND '"+aMv_par[06]+"'"
If !Empty(aMV_Par[08])
	cFiltro := PcoParseFil(aMV_Par[08],"CT1")             
	If !Empty(cFiltro)                                         
		cQuery  += " AND ("+cFiltro+")"                         
	Endif                                                      
Endif
cQuery  += " AND CQ1.D_E_L_E_T_ <>'*' " 
cQuery  += " AND CT1.D_E_L_E_T_ <>'*' " 
If cDbMs == "ORACLE"
	cQuery  += " AND CQ7_FILIAL(+) = CQ1_FILIAL "
	cQuery  += " AND CQ7_DATA(+) = CQ1_DATA "
	cQuery  += " AND CQ7_CONTA(+) = CQ1_CONTA"
	cQuery  += " AND CQ7_MOEDA(+) = '"+aMV_Par[07]+"'"
	cQuery  += " AND CQ7_TPSALD(+) = '1'"
	cQuery  += " AND CQ7.D_E_L_E_T_(+) <>'*' "
ElseIf cDbMs $ "INFORMIX/POSTGRES" .Or. ("DB2/400" $ cDbMs) .or. "CTREESQL" $ cDbMs
	cQuery  += " AND CQ7_FILIAL = CQ1_FILIAL "
	cQuery  += " AND CQ7_DATA = CQ1_DATA "
	cQuery  += " AND CQ7_CONTA = CQ1_CONTA"
	cQuery  += " AND CQ7_MOEDA = '"+aMV_Par[07]+"'"
	cQuery  += " AND CQ7_TPSALD = '1'"
	cQuery  += " AND CQ7.D_E_L_E_T_ <>'*' "
ElseIf !(cDbMs $ "DB2/MYSQL") .and. !("MSSQL" $ cDbMs) .And. !("DB2/400" $ cDbMs)
	cQuery  += " AND CQ1_FILIAL *= CQ7_FILIAL "
	cQuery  += " AND CQ1_DATA *= CQ7_DATA "
	cQuery  += " AND CQ1_CONTA *= CQ7_CONTA"
	cQuery  += " AND CQ7_MOEDA = '"+aMV_Par[07]+"'"
	cQuery  += " AND CQ7_TPSALD = '1'"
	cQuery  += " AND CQ7.D_E_L_E_T_ <>'*' "
Endif

cQuery  += " ORDER BY CQ1_FILIAL,CQ1.CQ1_DATA,CQ1.CQ1_CONTA"
cQuery 	:= ChangeQuery(cQuery)     

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB",.T.,.T.)

aStruct	:= CQ1->(DbStruct())
nLen    := Len(aStruct)
For nX:= 1 To nLen
	If aStruct[nX,2] <> "C"
		TcSetField("TRB",aStruct[nX,1],aStruct[nX,2],aStruct[nX,3],aStruct[nX,4])
    Endif
Next nX

aStruct	:= CQ7->(DbStruct())
nLen    := Len(aStruct)
For nX:= 1 To nLen
	If aStruct[nX,2] <> "C"
		TcSetField("TRB",aStruct[nX,1],aStruct[nX,2],aStruct[nX,3],aStruct[nX,4])
    Endif
Next nX       
        
CQ7->( dbSetOrder( 1 ) )
CQ1->( dbSetOrder( 1 ) )

cConta   	:= TRB->CQ1_CONTA
cData		:= Dtos(TRB->CQ1_DATA) 
cFilProc	:= TRB->CQ1_FILIAL
cFilPrev 	:= TRB->CQ1_FILIAL
nTotClVl   	:= 0       
nTotCT7  	:= 0                     
dDataAnt 	:= TRB->CQ1_DATA-1
lFirst		:=	.T.

If TRB->( ! EoF() )

	Do While TRB->( ! EoF() )
		If lFirst .Or. (Year(TRB->CQ1_DATA)<>Year(dDataAnt) .Or.  Month(TRB->CQ1_DATA)<>Month(dDataAnt)) ;
				.Or. cFilPrev<>TRB->CQ1_FILIAL
			cFilAnt := TRB->CQ1_FILIAL
			If !lFirst
				If lNotBlind
					oSelf:SetRegua2(2)
					oSelf:IncRegua2(STR0010+cFilPrev+STR0011+StrZero(Month(dDataAnt),2)+"/"+Str(Year(dDataAnt),4)) //"Gravando empresa "###" no mes "
					PCOFinLan("000255")
					oSelf:IncRegua2(STR0010+cFilPrev+STR0011+StrZero(Month(dDataAnt),2)+"/"+Str(Year(dDataAnt),4)) //"Gravando empresa "###" no mes "
				Else
					PCOFinLan("000255")
				EndIf		
	    	Endif
			PCOIniLan("000255")
			cFilPrev:= 	TRB->CQ1_FILIAL
		Endif
		If lNotBlind .And. dDataAnt <> 	TRB->CQ1_DATA
			nDias	:= (TRB->CQ1_DATA - dDataAnt)
			For nX:= 1 To nDias                 
   				oSelf:IncRegua1(STR0012+cFilPrev+STR0013+DtoC(TRB->CQ1_DATA))	//'Processando empresa '###" na data "
			Next                                        
		Endif
		dDataAnt 	:= 	TRB->CQ1_DATA
		lFirst		:=	.F.
	
		If Empty(cFiltro) .And. !Empty(aMV_Par[08])                                         
			CT1->(MsGoTo(TRB->CT1_RECNO))
			If !TRB->(&(aMV_Par[08]))
				TRB->(dbSkip())
				Loop
			Endif
		Endif
	
		If TRB->CQ1_CONTA+dtos(TRB->CQ1_DATA)+TRB->CQ1_FILIAL <> cConta + cData +cFilProc
			nTotClVl  	:= 0       
			cConta		:=	TRB->CQ1_CONTA                         
			cData		:=	Dtos(TRB->CQ1_DATA) 
			cFilProc	:=	TRB->CQ1_FILIAL
		Endif               
	
		CQ1->( MsGoto(TRB->CQ1_RECNO)) 
		If !Empty( TRB->CQ7_CLVL )            
			CQ7->( MsGoto(TRB->CQ7_RECNO)) 
			nTotClVl    += TRB->CQ7_CREDIT-TRB->CQ7_DEBITO
			PCODetLan("000255","04","PCOA330")
		ElseIf Empty( TRB->CQ7_CLVL )
			nTotCT7   := (TRB->CQ1_CREDIT-TRB->CQ1_DEBITO) - nTotClVl
			PCODetLan("000255","02","PCOA330")
		EndIf
		TRB->(dbSkip())
	EndDo
	If lNotBlind
		oSelf:SetRegua2(2)
		oSelf:IncRegua2(STR0010+cFilPrev+STR0011+StrZero(Month(dDataAnt),2)+"/"+Str(Year(dDataAnt),4))	//"Gravando empresa "###" no mes "
		PCOFinLan("000255")
		oSelf:IncRegua2(STR0010+cFilPrev+STR0011+StrZero(Month(dDataAnt),2)+"/"+Str(Year(dDataAnt),4))	//"Gravando empresa "###" no mes "
	Else
		PCOFinLan("000255")
	EndIf	
	
EndIf	

DbSelectArea('TRB')
DbCloseArea()
DbSelectArea('SX1')
cFilAnt := __cFilAnt 
Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณProcCT4Lanc บAutor  ณ Gustavo/Bruno/Pauloบ Data ณ  18/04/07 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Grava os lancamentos realizados na tabela AKD              บฑฑ
ฑฑบ          ณ baseado na tabela de saldos contabeis p/ classe valor (CT4)บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Planejamento e Controle Orcamentario                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ProcCT4Lanc(aMV_Par,oSelf)
                                                                   
local cDataIni  := DToS(aMv_par[01])
local cDataFim  := DToS(aMv_par[02])
Local cQuery	:=	""
Local cConta	:=	""
Local cEmpTmp	:= 	"" 
Local nTotITEM 	:= 0       
Local nLen	    := 0
Local nFils    	:= 0
Local nDias		:= 0
Local nX		:= 0
Local cFiliais	:=	""
Local cFiltro	:=	""
Local cDbMs	 	:= UPPER(TcGetDb())
Local lNotBlind	:= !IsBlind()
Local aFils		:= {}
Local aSelFil   := {}
Local __cFilAnt := cFilAnt

Private nTotCT7 := 0


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Busca todas as filiais do sigamat para utilizar na query ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cEmpTmp  := SM0->M0_CODIGO
aFils    := GetPCOFils(cEmpTmp,aMV_PAR[03],aMV_PAR[04])
cFiliais := StrTran(aFils[1] ,"'","") 
nFils 	 := aFils[2] 

aSelFil := StrTokArr2( cFiliais, ',', .F. )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVariavel para utilizar no lancamento de saldo de CONTA.                ณ
//ณEsta variavel tem o saldo do CQ1 - os saldos de CQ5 por It.Contabil    ณ
//ณEstes sao contabilizados primeiro e o CQ1 deve ser contabilizado depoisณ
//ณExemplo:                                                               ณ
//ณCQ1_CONTA  CQ5_ITEM                 VALOR A LANCAR                     ณ
//ณ001        	X1                              5                         ณ
//ณ001			X2                             10                         ณ
//ณ001			X3                             30                         ณ
//ณ001			NULL       			  60-(30+10+5) == nTotCT7             ณ
//ณ002			NULL                	   	100-0 == nTotCT7              ณ
//ณ003			NULL                    	200-0 == nTotCT7              ณ
//ณ004          X1                             10                         ณ
//ณ004			X2                             20                         ณ
//ณ005			X2                             50                         ณ
//ณ005			NULL                      	 80-0 == nTotCT7              ณ
//ณ                                                                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lNotBlind
	oSelf:SetRegua1( nFils * (aMv_par[02]-aMv_par[01])+1 )
EndIf	

cQuery	:= "SELECT CQ5.*, CQ1.*, CQ1.R_E_C_N_O_ CQ1_RECNO, CQ5.R_E_C_N_O_ CQ5_RECNO, CT1.R_E_C_N_O_ CT1_RECNO "                             
cQuery  += " FROM  "+RetSqlName('CT1')+" CT1,  "+RetSqlName('CQ1')+" CQ1  "
If cDbMs == "INFORMIX"
	cQuery += ", "+ RetSqlName("CQ5") + " CQ5 "
ElseIf cDbMs $ "DB2/MYSQL/CTREESQL" .Or. "MSSQL" $ cDbMs
	cQuery += " LEFT OUTER JOIN "+ RetSqlName("CQ5") + " CQ5 ON "
	cQuery  += " CQ5_FILIAL = CQ1_FILIAL "
	cQuery  += " AND CQ5_DATA = CQ1_DATA "
	cQuery  += " AND CQ5_CONTA = CQ1_CONTA"
	cQuery  += " AND CQ5_MOEDA = '"+aMV_Par[07]+"'"
	cQuery  += " AND CQ5_TPSALD = '1'"
	cQuery  += " AND CQ5.D_E_L_E_T_ <>'*' "
Else
	cQuery += ", "+ RetSqlName("CQ5") + " CQ5 "
Endif
If "," $ cFiliais
	cQuery  += " WHERE CQ1_FILIAL " + GetRngFil( aSelFil, "CQ1" ) + " "
Else
   cQuery  += " WHERE CQ1_FILIAL = '" + cFiliais + "' " 
EndIf
//CT1 compartilhado
If PCOCompart('CT1')
	cQuery  += " AND CT1_FILIAL = '"+xFilial("CT1")+"' "
//CQ1 exclusivo e o CT1 exclusivo 
ElseIf !PCOCompart('CQ1')
	cQuery  += " AND CT1_FILIAL = CQ1_FILIAL "
//Nao pode existir CQ1 compartilhado e CT1 exclusivo	
Endif
cQuery  += " AND CT1_CONTA = CQ1_CONTA "
cQuery  += " AND CQ1_MOEDA = '"+aMV_Par[07]+"'"
cQuery  += " AND CQ1_TPSALD = '1'"
cQuery  += " AND CQ1_DATA BETWEEN '"+cDataIni+"' AND '"+cDataFim+"'"
cQuery  += " AND CQ1_CONTA BETWEEN '"+aMv_par[05]+"' AND '"+aMv_par[06]+"'"
If !Empty(aMV_Par[08])
	cFiltro := PcoParseFil(aMV_Par[08],"CT1")             
	If !Empty(cFiltro)                                         
		cQuery  += " AND ("+cFiltro+")"                         
	Endif                                                      
Endif
cQuery  += " AND CQ1.D_E_L_E_T_ <>'*' " 
cQuery  += " AND CT1.D_E_L_E_T_ <>'*' " 
If cDbMs == "ORACLE"
	cQuery  += " AND CQ5_FILIAL(+) = CQ1_FILIAL "
	cQuery  += " AND CQ5_DATA(+) = CQ1_DATA "
	cQuery  += " AND CQ5_CONTA(+) = CQ1_CONTA"
	cQuery  += " AND CQ5_MOEDA(+) = '"+aMV_Par[07]+"'"
	cQuery  += " AND CQ5_TPSALD(+) = '1'"
	cQuery  += " AND CQ5.D_E_L_E_T_(+) <>'*' "
ElseIf cDbMs $ "INFORMIX/POSTGRES" .Or. ("DB2/400" $ cDbMs) .or. "CTREESQL" $ cDbMs
	cQuery  += " AND CQ5_FILIAL = CQ1_FILIAL "
	cQuery  += " AND CQ5_DATA = CQ1_DATA "
	cQuery  += " AND CQ5_CONTA = CQ1_CONTA"
	cQuery  += " AND CQ5_MOEDA = '"+aMV_Par[07]+"'"
	cQuery  += " AND CQ5_TPSALD = '1'"
	cQuery  += " AND CQ5.D_E_L_E_T_ <>'*' "
ElseIf !(cDbMs $ "DB2/MYSQL") .and. !("MSSQL" $ cDbMs) .And. !("DB2/400" $ cDbMs)
	cQuery  += " AND CQ1_FILIAL *= CQ5_FILIAL "
	cQuery  += " AND CQ1_DATA *= CQ5_DATA "
	cQuery  += " AND CQ1_CONTA *= CQ5_CONTA"
	cQuery  += " AND CQ5_MOEDA = '"+aMV_Par[07]+"'"
	cQuery  += " AND CQ5_TPSALD = '1'"
	cQuery  += " AND CQ5.D_E_L_E_T_ <>'*' "
Endif

cQuery  += " ORDER BY CQ1_FILIAL,CQ1.CQ1_DATA,CQ1.CQ1_CONTA"
cQuery 	:= ChangeQuery(cQuery)     

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB",.T.,.T.)

aStruct	:= CQ1->(DbStruct())
nLen    := Len(aStruct)
For nX:= 1 To nLen
	If aStruct[nX,2] <> "C"
		TcSetField("TRB",aStruct[nX,1],aStruct[nX,2],aStruct[nX,3],aStruct[nX,4])
    Endif
Next nX

aStruct	:= CQ5->(DbStruct())
nLen    := Len(aStruct)
For nX:= 1 To nLen
	If aStruct[nX,2] <> "C"
		TcSetField("TRB",aStruct[nX,1],aStruct[nX,2],aStruct[nX,3],aStruct[nX,4])
    Endif
Next nX       
        
CQ5->( dbSetOrder( 1 ) )
CQ1->( dbSetOrder( 1 ) )

cConta   	:= TRB->CQ1_CONTA
cData		:= Dtos(TRB->CQ1_DATA) 
cFilProc	:= TRB->CQ1_FILIAL
cFilPrev 	:= TRB->CQ1_FILIAL
nTotITEM   	:= 0       
nTotCT7  	:= 0                     
dDataAnt 	:= TRB->CQ1_DATA-1
lFirst		:=	.T.

If TRB->( ! EoF() )

	Do While TRB->( ! EoF() )
		If lFirst .Or. (Year(TRB->CQ1_DATA)<>Year(dDataAnt) .Or.  Month(TRB->CQ1_DATA)<>Month(dDataAnt)) ;
				.Or. cFilPrev<>TRB->CQ1_FILIAL
			cFilAnt := TRB->CQ1_FILIAL
			If !lFirst
				If lNotBlind
					oSelf:SetRegua2(2)
					oSelf:IncRegua2(STR0010+cFilPrev+STR0011+StrZero(Month(dDataAnt),2)+"/"+Str(Year(dDataAnt),4)) //"Gravando empresa "###" no mes "
					PCOFinLan("000255")
					oSelf:IncRegua2(STR0010+cFilPrev+STR0011+StrZero(Month(dDataAnt),2)+"/"+Str(Year(dDataAnt),4)) //"Gravando empresa "###" no mes "
				Else
					PCOFinLan("000255")
				EndIf		
	    	Endif
			PCOIniLan("000255")
			cFilPrev:= 	TRB->CQ1_FILIAL
		Endif
		If lNotBlind .And. dDataAnt <> 	TRB->CQ1_DATA
			nDias	:= (TRB->CQ1_DATA - dDataAnt)
			For nX:= 1 To nDias
   				oSelf:IncRegua1(STR0012+cFilPrev+STR0013+DtoC(TRB->CQ1_DATA))	//'Processando empresa '###" na data "
			Next                                        
		Endif
		dDataAnt 	:= 	TRB->CQ1_DATA
		lFirst		:=	.F.
	
		If Empty(cFiltro) .And. !Empty(aMV_Par[08])                                         
			CT1->(MsGoTo(TRB->CT1_RECNO))
			If !TRB->(&(aMV_Par[08]))
				TRB->(dbSkip())
				Loop
			Endif
		Endif
	
		If TRB->CQ1_CONTA+dtos(TRB->CQ1_DATA)+TRB->CQ1_FILIAL <> cConta + cData +cFilProc
			nTotITEM  	:= 0       
			cConta		:=	TRB->CQ1_CONTA                         
			cData		:=	Dtos(TRB->CQ1_DATA) 
			cFilProc	:=	TRB->CQ1_FILIAL
		Endif               
	
		CQ1->( MsGoto(TRB->CQ1_RECNO)) 
		If !Empty( TRB->CQ5_ITEM )            
			CQ5->( MsGoto(TRB->CQ5_RECNO)) 
			nTotITEM    += TRB->CQ5_CREDIT-TRB->CQ5_DEBITO
			PCODetLan("000255","03","PCOA330")
		ElseIf Empty( TRB->CQ5_ITEM )
			nTotCT7   := (TRB->CQ1_CREDIT-TRB->CQ1_DEBITO) - nTotITEM
			PCODetLan("000255","02","PCOA330")
		EndIf
		TRB->(dbSkip())
	EndDo
	If lNotBlind                                             
		oSelf:SetRegua2(2)
		oSelf:IncRegua2(STR0010+cFilPrev+STR0011+StrZero(Month(dDataAnt),2)+"/"+Str(Year(dDataAnt),4)) //"Gravando empresa "###" no mes "
		PCOFinLan("000255")
		oSelf:IncRegua2(STR0010+cFilPrev+STR0011+StrZero(Month(dDataAnt),2)+"/"+Str(Year(dDataAnt),4)) //"Gravando empresa "###" no mes "
	Else
		PCOFinLan("000255")
	EndIf	
	
EndIf	

DbSelectArea('TRB')
DbCloseArea()
DbSelectArea('SX1')
cFilAnt := __cFilAnt 
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PCOA330  บ Autor ณ Gustavo Henrique   บ Data ณ  13/12/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Executa validacoes, filtro do usuario e as rotinas de      บฑฑ
ฑฑบ          ณ processamento dos lancamentos, quando nao for chamado via  บฑฑ
ฑฑบ          ณ Job.                                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ EXPO1 - Objeto TNewProcess()                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCO                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A330PreProc( oSelf )

Local aRet		:= {""}
Local lRet		:= .T.

aMV_Par	:= {mv_par01,mv_par02,mv_par03,mv_par04,mv_par05,mv_par06,mv_par07,"",mv_par09}

If mv_par08 == 1
	lRet := ParamBox({{7,STR0006,"CT1","",".T."}},STR0007,aRet ) //"Filtro contas contabeis"###"Parametros"
Endif 

If lRet	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Atualiza o log de processamento   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oSelf:SaveLog(STR0016)	//"Processamento iniciado."
	
	aMV_PAR[08] := aRet[1]
	If mv_par09 == 1
		ProcLancCTB(aMV_Par, oSelf)		
	ElseIf mv_par09 == 2
		//por saldo por conta/item contabil
		ProcCT4Lanc(aMV_Par, oSelf)
	ElseIf mv_par09 == 3
		//por saldo por conta/classe de valor
		ProcCTILanc(aMV_Par, oSelf)
	EndIf			
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Atualiza o log de processamento   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oSelf:SaveLog(STR0017)	//"Processamento finalizado."
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOCompartบAutor  ณAlvaro Camillo Neto บ Data ณ  19/02/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se a tabela ้ compartilhada                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PCOCompart(cAlias)
Local lCompartilhada := .F.

If FindFunction("FwModeAccess")
	If FwModeAccess(cAlias,3) == "C"
		lCompartilhada := .T.
	EndIf 
Else
	If Empty(xFilial(cAlias))
		lCompartilhada := .T.		
	EndIf
EndIf
 
Return lCompartilhada

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetPCOFils บAutor  ณAlvaro Camillo Neto บ Data ณ  19/02/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBusca todas as filiais do sigamat para utilizar na query    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCOA330                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GetPCOFils(cEmpTmp,cFilDe,cFilAte)
Local aRet := {"",0}
Local aSM0			:= AdmAbreSM0()
Local nContFil		:= 0
Local cFiliais    := ""
Local nFils			:= 0 
                        
// Se nao preencheu range de filiais, considera todas.
If Empty( cFilDe ) .And. Empty( cFilAte )
	cFilAte := Replicate( "Z", Len( aSM0[1,2] ) )
EndIf

For nContFil := 1 to Len(aSM0)
	If aSM0[nContFil][SM0_CODFIL] >= cFilDe .And. aSM0[nContFil][SM0_CODFIL] <= cFilAte .And. aSM0[nContFil][SM0_GRPEMP] == cEmpTmp  
		cFiliais += "'" + aSM0[nContFil][SM0_CODFIL] + "',"
		nFils++	
	EndIf
Next nContFil 

cFiliais := AllTrim(Left(cFiliais,Len(cFiliais)-2))

If !("," $ cFiliais) // Existe apenas uma filial
	cFiliais := STRTRAN  (cFiliais,"'","")
EndIf
 

aRet[1] := cFiliais 
aRet[2] := nFils 

Return aRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณAdmAbreSM0ณ Autor ณ Orizio                ณ Data ณ 22/01/10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณRetorna um array com as informacoes das filias das empresas ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Generico                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function AdmAbreSM0()
Local aArea			:= SM0->( GetArea() )
Local aAux			:= {}
Local aRetSM0		:= {}
Local lFWLoadSM0	:= FindFunction( "FWLoadSM0" )
Local lFWCodFilSM0 	:= FindFunction( "FWCodFil" )

If lFWLoadSM0
	aRetSM0	:= FWLoadSM0()
Else
	DbSelectArea( "SM0" )
	SM0->( DbGoTop() )
	While SM0->( !Eof() )
		aAux := { 	SM0->M0_CODIGO,;
					IIf( lFWCodFilSM0, FWGETCODFILIAL, SM0->M0_CODFIL ),;
					"",;
					"",;
					"",;
					SM0->M0_NOME,;
					SM0->M0_FILIAL }

		aAdd( aRetSM0, aClone( aAux ) )
		SM0->( DbSkip() )
	End
EndIf

RestArea( aArea )
Return aRetSM0

