#INCLUDE "TBICONN.CH"
#INCLUDE "MATA712.CH"
#INCLUDE "PROTHEUS.CH"


/*-------------------------------------------------------------------------//
//Programa:	A712JobC1 
//Autor:		Ricardo Prandi 
//Data:		24/09/2013
//Descricao:	Job para processamento de solicitacoes de compra - SC1
//Parametros:	cEmp     	- Empresa                                           
//	          	cFil     	- Filial                                            
//          	aParamJob	- Array com parametros para JOB                    
//				nTentativa	- Numero da tentativa para chamada do JOB
//				cFileJob	- Nome do arquivo de JOB
//Parametros JOB:
//          	[1]  - Numero do calculo de MRP                          
//	          	[2]  - Tipo de calculo MRP   
//	          	[3]  - Array com os periodos 
//				[4]  - Array com as perguntas                           
// 	         	[5]  - String com tipos a serem processados            
//       	    [6]  - String com grupos a serem processados           
//				[7]  - Alias da tabela a ser processada                
//				[8]  - Almoxarifado de (utilizado para filtro) 
//				[9]  - Almoxarifado ate(utilizado para filtro)                      
//				[10] - Query para filtragem de produtos no SB1                      
//        		[11] - Indica a existencia de P.E. na filtragem (SQL)                
//	         	[12] - Opcional vazio                                                
//		        [13] - Revisao vazio                                     
//		        [14] - Indica se gera log                                
//				[15] - Considera pre req. - MV_MRPSCRE 				   
//				[16] - Indica se filtra locais da tabela CZINNR
//				[17] - Data final para filtras os dados
//              [18] - Tabela CZINNR concatenado com cEmpAnt e cFilAnt
//Uso: 		MATA712
//-------------------------------------------------------------------------*/
Function A712JobC1(cEmp,cFil,aParamJob,nTentativa,cFileJob)
Local cQuery		:= ""
Local cA710Fil		:= ""
Local nRecno		:= 0              
Local nHd			:= 0
Local c711NumMRP	:= aParamJob[1]
Local nTipo     	:= aParamJob[2]
Local aPeriodos 	:= aParamJob[3]
Local aPergs711 	:= aParamJob[4]
Local cStrTipo  	:= aParamJob[5]
Local cStrGrupo 	:= aParamJob[6]
Local cAliasTop 	:= aParamJob[7]
Local cAlmoxd   	:= aParamJob[8]
Local cAlmoxa   	:= aParamJob[9]
Local cQueryB1  	:= aParamJob[10]
Local lA710Sql  	:= aParamJob[11]
Local cOpc711Vaz	:= aParamJob[12]
Local cRev711Vaz	:= aParamJob[13]
Local lLogMRP   	:= aParamJob[14]
Local lConsPreRe	:= aParamJob[15]
Local aAlmoxNNR		:= aParamJob[16]
Local dDatFim    	:= aParamJob[17]
Local cNomCZINNR    := aParamJob[18]
Local lConsSusp     := aPergs711[13] == 1
Local lConsSacr     := aPergs711[14] == 1

PRIVATE nQuantPer := Len(aPeriodos)
PRIVATE cAliasCZJ := "CZJ"
PRIVATE cAliasCZK := "CZK"

nHd := FCreate(cFileJob)

//STATUS 1 - Iniciando execucao do Job
PutGlbValue("A712JobC1","1")
GlbUnLock()
           
//Seta job para nao consumir licensas
RpcSetType(3)

//Seta job para empresa filial desejada
RpcSetEnv(cEmp,cFil,,,'PCP')

Private  lPCPREVATU	:= FindFunction('PCPREVATU')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)

//STATUS 2 - Conexao efetuada com sucesso
PutGlbValue("A712JobC1","2")
GlbUnLock()

//Processando thread
//Conout(STR0147+" A712JobC1 "+StrZero(nTentativa,2,0)) 

cQuery := " SELECT SC1.C1_FILIAL, " +;
                 " SC1.C1_PRODUTO, " +;
                 " SC1.C1_OP, " +;
                 " SC1.C1_DATPRF, " +;
                 " SC1.C1_NUM, " +;
                 " SC1.C1_ITEM, " +;
                 " SC1.C1_QUANT, " +;
                 " SC1.C1_QUJE, " +;
                 " SC1.R_E_C_N_O_ C1REC " +;
            " FROM " + RetSqlName("SC1") + " SC1, " + RetSqlName("SB1") + " SB1 " +;
           " WHERE ((SC1.C1_FILIAL  = '" + xFilial("SC1") + "' " +;
             " AND  (SC1.C1_FILENT  = '" + xFilial("SC1") + "' " +;
             "  OR   SC1.C1_FILENT  = '')) " +;
             "  OR  (SC1.C1_FILIAL <> '" + xFilial("SC1") + "' " +;
             " AND   SC1.C1_FILENT  = '" + xFilial("SC1") + "')) " +;
             " AND SC1.C1_LOCAL    >= '" + cAlmoxd + "' " +;
             " AND SC1.C1_LOCAL    <= '" + cAlmoxa + "' " +;
             " AND SC1.C1_RESIDUO   = '" + CriaVar("C1_RESIDUO",.F.) + "' " +;
             " AND SC1.C1_DATPRF   <= '" + Dtos(dDatFim) + "' " +;
             " AND SC1.C1_QUANT     > SC1.C1_QUJE " +;
             " AND SC1.D_E_L_E_T_   = ' ' " +;
             " AND SC1.C1_PRODUTO   = SB1.B1_COD " 

If !lConsPreRe
	cQuery += "AND SC1.C1_ORIGEM <> 'MATA106' "
EndIf

If aAlmoxNNR # Nil
	cQuery += " AND SC1.C1_LOCAL IN (SELECT NR_LOCAL FROM " +cNomCZINNR +") "
EndIf

If !lConsSusp .Or. !lConsSacr
	cQuery += " AND (SC1.C1_OP = ' ' "
	cQuery +=  " OR  SC1.C1_OP NOT IN ( " + MT712QNOC2(lConsSusp, lConsSacr) + ") )"
EndIf

cQuery += cQueryB1

If lA710SQL
	cA710Fil := ExecBlock("A710SQL", .F., .F., {"SC1", cQuery})
	If ValType(cA710Fil) == "C"
		cQuery := cA710Fil
	Endif
Endif	

cQuery += " ORDER BY " + SqlOrder(SC1->(IndexKey(2)))
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
aEval(SC1->(dbStruct()), {|x| If(x[2] <> "C" .And. FieldPos(x[1]) > 0, TcSetField(cAliasTop,x[1],x[2],x[3],x[4]),Nil)})

dbSelectArea(cAliasTop)

While !Eof()
	nRecno := C1REC
	
	//Avalia o LOG do MRP para o evento 006 - Documento planejado em atraso
	A712CriaLOG("006",C1_PRODUTO,{C1_DATPRF,C1_NUM,C1_ITEM,"SC1"},lLogMRP,c711NumMRP)
	
	//Marca o semaforo
	MATA712LCK(.T.)
	
	//Cria os registros nas tabelas
	A712CriCZI(A712NextUtil(C1_DATPRF,aPergs711),C1_PRODUTO,cOpc711Vaz,cRev711Vaz,"SC1",nRecno,C1_NUM,C1_ITEM,C1_OP,Max(0,C1_QUANT-C1_QUJE),"2",.F.,/*13*/,/*14*/,.F.,.T.,aPeriodos,nTipo,c711NumMRP,cStrTipo,cStrGrupo,/*22*/,/*23*/,/*24*/,/*25*/,/*26*/)
	
	//Libera semaforo
	UnLockByName("CZIUSO"+cEmpAnt+cFilAnt,.T.,.T.,.T.)
	
	dbSelectArea(cAliasTop)
	dbSkip()
End

dbSelectArea(cAliasTop)
dbCloseArea()

//STATUS 3 - Processamento efetuado com sucesso
PutGlbValue("A712JobC1","3")
GlbUnLock()

FClose(nHd)
FErase(cFileJob)

Return

/*------------------------------------------------------------------------//
//Programa:	A712JobC7 
//Autor:		Ricardo Prandi 
//Data:		25/09/2013
//Descricao:	Job para processamento de pedidos de compra - SC7
//Parametros:	cEmp     	- Empresa                                           
//	          	cFil     	- Filial                                            
//          	aParamJob	- Array com parametros para JOB                    
//				nTentativa	- Numero da tentativa para chamada do JOB
//				cFileJob	- Nome do arquivo de JOB
//Parametros JOB:
//          	[1]  - Numero do calculo de MRP                          
//	          	[2]  - Tipo de calculo MRP   
//	          	[3]  - Array com os periodos 
//				[4]  - Array com as perguntas                           
// 	         	[5]  - String com tipos a serem processados            
//            [6]  - String com grupos a serem processados           
//				[7]  - Alias da tabela a ser processada                
//				[8]  - Almoxarifado de (utilizado para filtro) 
//				[9]  - Almoxarifado ate(utilizado para filtro)                      
//				[10] - Query para filtragem de produtos no SB1                      
//        		[11] - Indica a existencia de P.E. na filtragem (SQL)                
//	         	[12] - Opcional vazio                                                
//		       [13] - Revisao vazio                                     
//		       [14] - Indica se gera log                                
//				[15] - Indica se filtra locais da tabela CZINNR 
//				[16] - Data final para filtras os dados
//              [17] - Tabela CZINNR concatenado com cEmpAnt e cFilAnt
//Uso: 		MATA712
//------------------------------------------------------------------------*/
Function A712JobC7(cEmp,cFil,aParamJob,nTentativa,cFileJob)
Local cQuery		:= ""
Local cA710Fil	:= ""
Local nRecno		:= 0
Local nHd			:= 0
Local c711NumMRP	:= aParamJob[1]
Local nTipo     	:= aParamJob[2]
Local aPeriodos 	:= aParamJob[3]
Local aPergs711 	:= aParamJob[4]
Local cStrTipo  	:= aParamJob[5]
Local cStrGrupo 	:= aParamJob[6]
Local cAliasTop 	:= aParamJob[7]
Local cAlmoxd   	:= aParamJob[8]
Local cAlmoxa   	:= aParamJob[9]
Local cQueryB1  	:= aParamJob[10]
Local lA710Sql  	:= aParamJob[11]
Local cOpc711Vaz 	:= aParamJob[12]
Local cRev711Vaz	:= aParamJob[13]
Local lLogMRP   	:= aParamJob[14]
Local aAlmoxNNR     := aParamJob[15]
Local dDatFim		:= aParamJob[16]
Local cNomCZINNR    := aParamJob[17]
Local lConsSusp     := aPergs711[13] == 1
Local lConsSacr     := aPergs711[14] == 1

PRIVATE nQuantPer	:= Len(aPeriodos)
PRIVATE cAliasCZJ	:= "CZJ"
PRIVATE cAliasCZK	:= "CZK"

nHd := FCreate(cFileJob)

//STATUS 1 - Iniciando execucao do Job
PutGlbValue("A712JobC7","1")
GlbUnLock()

//Seta job para nao consumir licensas
RpcSetType(3)

//Seta job para empresa filial desejada
RpcSetEnv(cEmp,cFil,,,'PCP')
Private  lPCPREVATU	:= FindFunction('PCPREVATU')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)
//STATUS 2 - Conexao efetuada com sucesso
PutGlbValue("A712JobC7","2")
GlbUnLock()

//Processando thread
//Conout(STR0147+" A712JobC7 "+StrZero(nTentativa,2,0)) 

cQuery := " SELECT SC7.C7_FILIAL, " +;
                 " SC7.C7_PRODUTO, " +;
                 " SC7.C7_OP, " +;
                 " SC7.C7_DATPRF, " +;
                 " SC7.C7_NUM, " +;
                 " SC7.C7_ITEM, " +;
                 " SC7.C7_QUANT, " +;
                 " SC7.C7_QUJE, " +;
                 " SC7.R_E_C_N_O_ C7REC " +;
            " FROM " + RetSqlName("SC7")+ " SC7, " + RetSqlName("SB1") + " SB1 " +;
           " WHERE ((SC7.C7_FILIAL  = '" + xFilial("SC7") + "' " +;
             " AND  (SC7.C7_FILENT  = '" + xFilial("SC7") + "' " +;
             "  OR   SC7.C7_FILENT  = '')) " +;
             "  OR  (SC7.C7_FILIAL <> '" + xFilial("SC7") + "' " +;
             " AND   SC7.C7_FILENT  = '" + xFilial("SC7") + "')) " +;
             " AND SC7.C7_LOCAL    >= '" + cAlmoxd + "' " +;
             " AND SC7.C7_LOCAL    <= '" + cAlmoxa + "' " +;
             " AND SC7.C7_DATPRF   <= '" + Dtos(dDatFim) + "' " +;
             " AND SC7.C7_QUJE      < SC7.C7_QUANT " +;
             " AND SC7.C7_RESIDUO   = '" + CriaVar("C7_RESIDUO", .F.) + "' " +;
             " AND SC7.D_E_L_E_T_   = ' ' " +;
             " AND SC7.C7_PRODUTO   = SB1.B1_COD " 

If aAlmoxNNR # Nil
	cQuery += " AND SC7.C7_LOCAL IN (SELECT NR_LOCAL FROM " +cNomCZINNR +") "
EndIf

If !lConsSusp .Or. !lConsSacr
	cQuery += " AND (SC7.C7_OP = ' ' "
	cQuery +=  " OR  SC7.C7_OP NOT IN ( " + MT712QNOC2(lConsSusp, lConsSacr) + ") )"
EndIf

cQuery += cQueryB1

If lA710SQL
	cA710Fil := ExecBlock("A710SQL", .F., .F., {"SC7", cQuery})
	If ValType(cA710Fil) == "C"
		cQuery := cA710Fil
	Endif
EndIf

cQuery += " ORDER BY " + SqlOrder(SC7->(IndexKey(2)))
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
aEval(SC7->(dbStruct()), {|x| If(x[2] <> "C" .And. FieldPos(x[1]) > 0, TcSetField(cAliasTop,x[1],x[2],x[3],x[4]),Nil)})

dbSelectArea(cAliasTop)
While !Eof()
	nRecno := C7REC
	
	//Avalia o LOG do MRP para o evento 006 - Documento planejado em atraso
	A712CriaLOG("006",C7_PRODUTO,{C7_DATPRF,C7_NUM,C7_ITEM,"SC7"},lLogMRP,c711NumMRP)
	
	//Marca o semaforo
	MATA712LCK(.T.)
	
	//Cria os registros nas tabelas
	A712CriCZI(A712NextUtil(C7_DATPRF,aPergs711),C7_PRODUTO,cOpc711Vaz,cRev711Vaz,"SC7",nRecno,C7_NUM,C7_ITEM,C7_OP,Max(0,C7_QUANT-C7_QUJE),"2",.F.,/*13*/,/*14*/,.F.,.T.,aPeriodos,nTipo,c711NumMRP,cStrTipo,cStrGrupo,/*22*/,/*23*/,/*24*/,/*25*/,/*26*/)
	
	//Libera semaforo
	UnLockByName("CZIUSO"+cEmpAnt+cFilAnt,.T.,.T.,.T.)
	
	dbSelectArea(cAliasTop)
	dbSkip()
End

dbSelectArea(cAliasTop)
dbCloseArea()

//STATUS 3 - Processamento efetuado com sucesso
PutGlbValue("A712JobC7","3")
GlbUnLock()

FClose(nHd)
FErase(cFileJob)

Return

/*------------------------------------------------------------------------//
//Programa:	A712JobC2 
//Autor:		Ricardo Prandi 
//Data:		25/09/2013
//Descricao:	Job para processamento de ordens de producao - SC2
//Parametros:	cEmp     	- Empresa                                           
//	          	cFil     	- Filial                                            
//          	aParamJob	- Array com parametros para JOB                    
//				nTentativa	- Numero da tentativa para chamada do JOB
//				cFileJob	- Nome do arquivo de JOB
//				lUsaMOpc	- Parâmetro de utilização de opcionais
//Parametros JOB:
//          	[1]  - Numero do calculo de MRP                          
//	          	[2]  - Tipo de calculo MRP   
//	          	[3]  - Array com os periodos 
//				[4]  - String com tipos a serem processados                          
// 	         	[5]  - String com grupos a serem processados             
//				[6]  - Alias da tabela a ser processada             
//				[7]  - Almoxarifado de (utilizado para filtro)
//				[8]  - Almoxarifado ate(utilizado para filtro)                      
//				[9]  - Query para filtragem de produtos no SB1                      
//        		[10] - Indica a existencia de P.E. na filtragem (SQL)                
//		       [11] - Indica se considera OPs suspensas                                
//		       [12] - Indica se considera OPs sacramentadas                              
//				[13] - Indica se gera log
//				[14] - Array com as perguntas 
//				[15] - Indica se filtra locais da tabela CZINNR 
//				[16] - Data final para filtras os dados
//              [17] - Tabela CZINNR concatenado com cEmpAnt e cFilAnt   
//Uso: 		MATA712
//------------------------------------------------------------------------*/
Function A712JobC2(cEmp,cFil,aParamJob,nTentativa,cFileJob,lUsaMOpc)
Local cQuery		:= ""
Local cA710Fil	:= ""
Local mOpc			:= ""
Local cOpc			:= ""
Local nRecno		:= 0               
Local nHd			:= 0
Local lPerdInf 	:= .F.
Local c711NumMRP	:= aParamJob[1]
Local nTipo    	 := aParamJob[2]
Local aPeriodos	 := aParamJob[3]
Local cStrTipo 	 := aParamJob[4]
Local cStrGrupo	 := aParamJob[5]
Local cAliasTop	 := aParamJob[6]
Local cAlmoxd  	 := aParamJob[7]
Local cAlmoxa  	 := aParamJob[8]
Local cQueryB1 	 := aParamJob[9]
Local lA710Sql 	 := aParamJob[10]
Local lConsSusp	 := aParamJob[11]
Local lConsSacr	 := aParamJob[12]
Local lLogMRP  	 := aParamJob[13]
Local aPergs711	 := aParamJob[14]
Local aAlmoxNNR	 := aParamJob[15]
Local dDatFim	 := aParamJob[16]
Local cNomCZINNR := aParamJob[17]

Local aAreaC2 := {}

PRIVATE nQuantPer	:= Len(aPeriodos)
PRIVATE cAliasCZJ	:= "CZJ"
PRIVATE cAliasCZK	:= "CZK"

nHd := FCreate(cFileJob)

//STATUS 1 - Iniciando execucao do Job
PutGlbValue("A712JobC2","1")
GlbUnLock()

//Seta job para nao consumir licensas
RpcSetType(3)

//Seta job para empresa filial desejada
RpcSetEnv( cEmp, cFil,,,'PCP')
Private  lPCPREVATU	:= FindFunction('PCPREVATU')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)
PRIVATE  lMopcGRV	:= SuperGetMv("MV_MOPCGRV",.F.,.F.) // Parametro criado para definir se gravas os opcionais somente no Produto Pai ( Seq pai igual a branco/vazio).

//STATUS 2 - Conexao efetuada com sucesso
PutGlbValue("A712JobC2","2")
GlbUnLock()

//Processando thread
//Conout(STR0147+" A712JobC2 "+StrZero(nTentativa,2,0))  

cQuery := " SELECT SC2.C2_FILIAL, " +;
                 " SC2.C2_DATRF, " +;
                 " SC2.C2_LOCAL, " +;
                 " SC2.C2_PRODUTO, " +;
                 " SC2.C2_STATUS, " +;
                 " SC2.C2_DATPRF, " +;
                 " SC2.C2_OPC, " +;
                 " SC2.C2_NUM, " +;
                 " SC2.C2_ITEM, " +;
                 " SC2.C2_SEQUEN, " +;
                 " SC2.C2_ITEMGRD, " +;
                 " SC2.C2_PEDIDO, " +; 
                 " SC2.C2_ITEMPV, " +;
                 " SC2.C2_QUANT, " +;
                 " SC2.C2_QUJE, " +;
                 " SC2.C2_PERDA, " +;
                 " SC2.C2_REVISAO, " +;
                 " SC2.R_E_C_N_O_ C2REC " +;
            " FROM " + RetSqlName("SC2")+" SC2, " + RetSqlName("SB1") + " SB1 " +;
           " WHERE SC2.C2_FILIAL  = '" + xFilial("SC2") + "' " +;
             " AND SC2.C2_DATRF   = '" + Space(Len(DTOS(SC2->C2_DATRF))) + "' " +;
             " AND SC2.C2_LOCAL  >= '" + cAlmoxd + "' " +;
             " AND SC2.C2_LOCAL  <= '" + cAlmoxa + "' " +;
             " AND SC2.C2_DATPRF <= '" + Dtos(dDatFim) + "' " +;
             " AND SC2.D_E_L_E_T_ = ' ' " +;
             " AND SC2.C2_PRODUTO = SB1.B1_COD "

//Inclui condicao se nao considera OPs Suspensas
If !lConsSusp
	cQuery += " AND SC2.C2_STATUS <> 'U' "
EndIf

//Inclui condicao se nao considera OPs Sacramentadas
If !lConsSacr
	cQuery += " AND SC2.C2_STATUS <> 'S' "
EndIf

If aAlmoxNNR # Nil
	cQuery += " AND SC2.C2_LOCAL IN (SELECT NR_LOCAL FROM " +cNomCZINNR +") "
EndIf

cQuery += cQueryB1

If lA710SQL
	cA710Fil := ExecBlock("A710SQL", .F., .F., {"SC2", cQuery})
	If ValType(cA710Fil) == "C"
		cQuery := cA710Fil
	Endif
Endif		

cQuery += " ORDER BY " + SqlOrder(SC2->(IndexKey(2)))
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
aEval(SC2->(dbStruct()), {|x| If(x[2] <> "C" .And. FieldPos(x[1]) > 0, TcSetField(cAliasTop,x[1],x[2],x[3],x[4]),Nil)})

dbSelectArea(cAliasTop)

lPerdInf := SuperGetMV("MV_PERDINF",.F.,.F.)

While !Eof()
	nRecno := C2REC
	
	//Avalia o LOG do MRP para o evento 006 - Documento planejado em atraso
	A712CriaLOG("006",C2_PRODUTO,{C2_DATPRF,C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD,"","SC2"},lLogMRP,c711NumMRP)
	
	SC2->(DbGoTo(nRecno))
	
	If ! lMopcGRV
		mOpc := SC2->C2_MOPC
		cOpc := SC2->C2_OPC
	Else
	
	cOpc := SC2->C2_OPC
	
		If !Empty(SC2->C2_SEQPAI) .AND. (SC2->C2_SEQPAI) <> '000'
			aAreaC2 := SC2->(GetArea())
			Dbselectarea("SC2")
			SC2->(DbSetOrder(1))
			If SC2->(dbSeek(xFilial("SC2")+SC2->C2_NUM+SC2->C2_ITEM))
				mOpc := SC2->C2_MOPC
			EndIf
			SC2->(RestArea(aAreaC2))
		Else
			mOpc := SC2->C2_MOPC
		EndIf
	
	Endif

	//Marca o semaforo
	MATA712LCK(.T.)
	
	//Cria os registros nas tabelas
	A712CriCZI(A712NextUtil(C2_DATPRF,aPergs711),C2_PRODUTO,cOpc,C2_REVISAO,"SC2",nRecno,C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD,/*08*/,If(!Empty(C2_PEDIDO),C2_PEDIDO+"/"+C2_ITEMPV,""),Max(0,C2_QUANT-C2_QUJE-If(lPerdInf,0,C2_PERDA)),"2",.F.,.T.,/*14*/,.F.,.T.,aPeriodos,nTipo,c711NumMRP,cStrTipo,cStrGrupo,/*22*/,/*23*/,/*24*/,mOpc,/*26*/)
	
	//Libera semaforo
	UnLockByName("CZIUSO"+cEmpAnt+cFilAnt,.T.,.T.,.T.)
	
	dbSelectArea(cAliasTop)
	dbSkip()
End

dbSelectArea(cAliasTop)
dbCloseArea()

//STATUS 3 - Processamento efetuado com sucesso
PutGlbValue("A712JobC2","3")
GlbUnLock()

FClose(nHd)
FErase(cFileJob)

Return

/*------------------------------------------------------------------------//
//Programa:	A712JobD4 
//Autor:		Ricardo Prandi 
//Data:		26/09/2013
//Descricao:	Job para processamento de empenhos - SD4 
//Parametros:	cEmp     	- Empresa                                           
//	          	cFil     	- Filial                                            
//          	aParamJob	- Array com parametros para JOB                    
//				nTentativa	- Numero da tentativa para chamada do JOB
//				cFileJob	- Nome do arquivo de JOB
//Parametros JOB:
//          	[1]  - Numero do calculo de MRP                          
//	          	[2]  - Tipo de calculo MRP   
//	          	[3]  - Array com os periodos 
//				[4]  - Array com as perguntas
//				[5]  - String com tipos a serem processados                          
// 	         	[6]  - String com grupos a serem processados
//				[7]  - Alias da tabela a ser processada             
//				[8]  - Almoxarifado de (utilizado para filtro)
//				[9]  - Almoxarifado ate(utilizado para filtro)                      
//				[10] - Query para filtragem de produtos no SB1                      
//        		[11] - Indica a existencia de P.E. na filtragem (SQL)
//				[12] - Revisao vazio             
//				[13] - Indica se gera log
//				[14] - Indica se filtra locais da tabela CZINNR 
//				[14] - Indica se filtra locais da tabela CZINNR
//				[15] - Array de grupos selecionados em tela
//				[16] - Valor do parâemtro MV_MRPCINQ
//				[17] - Data final para filtras os dados
//              [18] - Tabela CZINNR concatenado com cEmpAnt e cFilAnt 
//Uso: 		MATA712
//------------------------------------------------------------------------*/
Function A712JobD4(cEmp,cFil,aParamJob,nTentativa,cFileJob)
Local cQuery     := ""
Local cTmp       := ""
Local nRecno     := 0              
Local nHd        := 0
Local c711NumMRP := aParamJob[1]
Local nTipo      := aParamJob[2]
Local aPeriodos  := aParamJob[3]
Local aPergs711  := aParamJob[4]
Local cStrTipo   := aParamJob[5]
Local cStrGrupo  := aParamJob[6]
Local cAliasTop  := aParamJob[7]
Local cAlmoxd    := aParamJob[8]
Local cAlmoxa    := aParamJob[9]
Local cQueryB1   := aParamJob[10]
Local lA710Sql   := aParamJob[11]
Local cRev711Vaz := aParamJob[12]
Local lLogMRP    := aParamJob[13]
Local aAlmoxNNR	 := aParamJob[14]
Local A711Grupo	 := aParamJob[15]
Local lMRPCINQ	 := aParamJob[16]
Local dDatFim	 := aParamJob[17]
Local cNomCZINNR := aParamJob[18]
Local lAllGrp    := Ascan(A711Grupo,{|x| x[1] == .F.}) == 0
Local lConsSusp  := aPergs711[13] == 1
Local lConsSacr  := aPergs711[14] == 1
Local aAreaC2A   := {}

PRIVATE nQuantPer	:= Len(aPeriodos)
PRIVATE cAliasCZJ	:= "CZJ"
PRIVATE cAliasCZK	:= "CZK"

nHd := FCreate(cFileJob)

//STATUS 1 - Iniciando execucao do Job
PutGlbValue("A712JobD4","1")
GlbUnLock()

//Seta job para nao consumir licensas
RpcSetType(3)

//Seta job para empresa filial desejada
RpcSetEnv(cEmp,cFil,,,'PCP')
Private  lPCPREVATU	:= FindFunction('PCPREVATU')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)
PRIVATE  lMopcGRV	:= SuperGetMv("MV_MOPCGRV",.F.,.F.) // Parametro criado para definir se gravas os opcionais somente no Produto Pai ( Seq pai igual a branco/vazio).

If  lMopcGRV
 	mOpc := ""
Endif

//STATUS 2 - Conexao efetuada com sucesso
PutGlbValue("A712JobD4","2")
GlbUnLock()

//Conout(STR0147+" A712JobD4 "+StrZero(nTentativa,2,0))  //"Processando thread"

cQuery := " SELECT SD4.D4_FILIAL, " +;
                 " SD4.D4_COD, " +;
                 " SD4.D4_OP, " +;
                 " SD4.D4_OPORIG, " +;
                 " SD4.D4_DATA, " +;
                 " SD4.D4_TRT, " +;
                 " SD4.D4_QUANT, " +;
                 " SB1.B1_GRUPO, " +;
                 " SD4.R_E_C_N_O_ D4REC " +;
            " FROM " + RetSqlName("SD4")+" SD4, " + RetSqlName("SB1")+" SB1 " +;
           " WHERE SD4.D4_FILIAL  = '" + xFilial("SD4") + "' " +;
             " AND SD4.D4_QUANT  <> 0 " +;
             " AND SD4.D4_LOCAL  >= '" + cAlmoxd + "' " +;
             " AND SD4.D4_LOCAL  <= '" + cAlmoxa + "' " +;
             " AND SD4.D4_DATA   <= '" + Dtos(dDatFim) + "' " +;
             " AND SD4.D_E_L_E_T_ = ' ' " +;
             " AND SD4.D4_COD     = SB1.B1_COD "

If !(aPergs711[13]==1)
	cQuery += " AND (SD4.D4_QUANT-SD4.D4_QSUSP) <> 0 "
EndIf

If !lConsSusp .Or. !lConsSacr
	cQuery += " AND SD4.D4_OP NOT IN ( " + MT712QNOC2(lConsSusp, lConsSacr) + ") "
EndIf

If aAlmoxNNR # Nil
	cQuery += " AND SD4.D4_LOCAL IN (SELECT NR_LOCAL FROM " +cNomCZINNR +") "
EndIf

cQuery += cQueryB1

If lA710SQL
	cA710Fil := ExecBlock("A710SQL", .F., .F., {"SD4", cQuery})
	If ValType(cA710Fil) == "C"
		cQuery := cA710Fil
	Endif
Endif	

cQuery += " ORDER BY " + SqlOrder(SD4->(IndexKey(1)))
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
aEval(SD4->(dbStruct()), {|x| If(x[2] <> "C" .And. FieldPos(x[1]) > 0, TcSetField(cAliasTop,x[1],x[2],x[3],x[4]),Nil)})
dbSelectArea(cAliasTop)

While !Eof()
	If (!lAllGrp .And. !lMRPCINQ .And. !(cAliasTop)->B1_GRUPO $ cStrGrupo)
		dbSkip()
		Loop
	Else
		nRecno := D4REC
	EndIf
	
	//Posiciona na OP geradora do EMPENHO
	If !Empty((cAliasTop)->D4_OPORIG)
		SC2->(dbSetOrder(1))
		SC2->(dbSeek(xFilial("SC2")+(cAliasTop)->D4_OPORIG))
	Else
		SC2->(dbSetOrder(1))
		SC2->(dbSeek(xFilial("SC2")+(cAliasTop)->D4_OP))
	EndIf
	dbSelectArea(cAliasTop)
	
	//Avalia o LOG do MRP para o evento 006 - Documento planejado em atraso em atraso
	A712CriaLOG("006",D4_COD,{D4_DATA,D4_OP,D4_TRT,"SD4"},lLogMRP,c711NumMRP)
	
	If  lMopcGRV
	 	If !Empty(SC2->C2_SEQPAI) .AND. (SC2->C2_SEQPAI) <> '000'
			aAreaC2A := SC2->(GetArea()) 
			Dbselectarea("SC2")
			SC2->(DbSetOrder(1))
			If SC2->(dbSeek(xFilial("SC2")+SC2->C2_NUM+SC2->C2_ITEM))
				cmOpc := SC2->C2_MOPC
			EndIf
			SC2->(RestArea(aAreaC2A))
		Else
			cmOpc := SC2->C2_MOPC
		EndIf
	EndIF

	//Marca o semaforo
	MATA712LCK(.T.)
	
	//Cria os registros nas tabelas
	A712CriCZI(A712NextUtil(D4_DATA,aPergs711),D4_COD,/*03*/,If(!Empty(D4_OPORIG) .And. !(SC2->(Eof())),SC2->C2_REVISAO,cRev711Vaz),If(D4_QUANT>0,"SD4","ENG"),nRecno,D4_OP,/*08*/,D4_OP,Abs(D4_QUANT),If(D4_QUANT>0,"3","2"),.F.,.T.,/*14*/,.F.,.T.,aPeriodos,nTipo,c711NumMRP,cStrTipo,cStrGrupo,/*22*/,/*23*/,/*24*/,IIF(lMopcGRV,cMopc,SC2->C2_MOPC),/*26*/)
	//Libera semaforo
	UnLockByName("CZIUSO"+cEmpAnt+cFilAnt,.T.,.T.,.T.)
	
	dbSelectArea(cAliasTop)
	dbSkip()
End

dbSelectArea(cAliasTop)
dbCloseArea()

Ferase(cTmp+OrdBagExt())

//STATUS 3 - Processamento efetuado com sucesso
PutGlbValue("A712JobD4","3")
GlbUnLock()

FClose(nHd)
FErase(cFileJob)

Return

/*------------------------------------------------------------------------//
//Programa:		A712JobC6 
//Autor:		Ricardo Prandi 
//Data:			26/09/2013
//Descricao:	Job para processamento de pedidos de venda - SC6    
//Parametros:	cEmp     	- Empresa                                           
//	          	cFil     	- Filial                                            
//          	aParamJob	- Array com parametros para JOB                    
//				nTentativa	- Numero da tentativa para chamada do JOB
//				cFileJob	- Nome do arquivo de JOB
//				lUsaMOpc	- Parâmetro de utilização de opcionais
//Parametros JOB:
//  	      	[1]  - Numero do calculo de MRP                          
//	   			[2]  - Tipo de calculo MRP                               
//          	[3]  - Array com os periodos                             
//          	[4]  - Array com as perguntas                            
//          	[5]  - String com tipos a serem processados              
//          	[6]  - String com grupos a serem processados             
//          	[7]  - Alias da tabela a ser processada                  
//          	[8]  - Almoxarifado de (utilizado para filtro)           
//          	[9]  - Almoxarifado ate(utilizado para filtro)                       
//          	[10] - Query para filtragem de produtos no SB1                       
//          	[11] - Indica a existencia de P.E. na filtragem (SQL)                
//          	[12] - Considera pedido de venda bloqueado credito                   
//          	[13] - Dados para bloqueio 1                                         
//          	[14] - Dados para bloqueio 2                             
//          	[15] - Indica se processa dados do SC4                   
//          	[16] - Revisao vazio                                                 
//          	[17] - Indica se gera log                                
//          	[18] - Indica se considera pedidos de venda no MRP       
//				[19] - Indica se filtra locais da tabela CZINNR 
//				[20] - Data final para filtras os dados
//              [21] - Tabela CZINNR concatenado com cEmpAnt e cFilAnt
//Uso: 			MATA712
//------------------------------------------------------------------------*/
Function A712JobC6(cEmp,cFil,aParamJob,nTentativa,cFileJob,lUsaMOpc)   
Local cQuery 		:= ""
Local cA710Fil 		:= ""
Local mOpc 			:= ""
Local nRecno 		:= 0
Local i 			:= 0
Local nHd 			:= 0
Local aPedidosAc 	:= {{}} 
Local nAchouPed 	:= 0
Local nQtdPed 		:= 0
Local c711NumMRP 	:= aParamJob[1]
Local nTipo 		:= aParamJob[2]
Local aPeriodos 	:= aParamJob[3]
Local aPergs711 	:= aParamJob[4]
Local cStrTipo		:= aParamJob[5]
Local cStrGrupo 	:= aParamJob[6]
Local cAliasTop		:= aParamJob[7]
Local cAlmoxd		:= aParamJob[8]
Local cAlmoxa		:= aParamJob[9]
Local cQueryB1		:= aParamJob[10]
Local lA710Sql		:= aParamJob[11]
Local lPedBloc		:= aParamJob[12]
Local cComp1		:= aParamJob[13]
Local cComp2		:= aParamJob[14]
Local lProcSC4		:= aParamJob[15]
Local cRev711Vaz	:= aParamJob[16]
Local lLogMRP		:= aParamJob[17]
Local lCarteira 	:= aParamJob[18]
Local aAlmoxNNR		:= aParamJob[19]
Local dDatFim		:= aParamJob[20]
Local cNomCZINNR    := aParamJob[21]
Local aOpc          := {}
Local cQueryDef   := ""
Local lValido       := .T.

PRIVATE nQuantPer	:= Len(aPeriodos)
PRIVATE cAliasCZJ	:= "CZJ"
PRIVATE cAliasCZK	:= "CZK"

nHd := FCreate(cFileJob)

//STATUS 1 - Iniciando execucao do Job
PutGlbValue("A712JobC6","1")
GlbUnLock()

//Seta job para nao consumir licensas
RpcSetType(3)

//Seta job para empresa filial desejada
RpcSetEnv(cEmp,cFil,,,'PCP')
Private  lPCPREVATU	:= FindFunction('PCPREVATU')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)
//STATUS 2 - Conexao efetuada com sucesso
PutGlbValue("A712JobC6","2")
GlbUnLock()

//Conout(STR0147+" A712JobC6 "+StrZero(nTentativa,2,0))  //"Processando thread"

cQuery := " SELECT SC6.C6_BLQ, " +;
                 " SC6.C6_ITEM, " +;
                 " SC6.C6_FILIAL, " +;
                 " SC6.C6_QTDVEN, " +;
                 " SC6.C6_QTDENT, " +;
                 " SC6.C6_LOCAL, " +;
                 " SC6.C6_PRODUTO, " +;
                 " SC6.C6_TES, " +;
                 " SC6.C6_ENTREG, " +;
                 " SC6.C6_NUM, " +;
                 " SC6.C6_OP, " +;
                 " SC6.C6_OPC, " +;
                 " SC6.C6_REVISAO, " +;
                 " SC6.C6_DATFAT, " +;
                 " SC6.R_E_C_N_O_ C6REC " +;
            " FROM " + RetSqlName("SC6") + " SC6, " + RetSqlName("SB1") + " SB1," + RetSqlName("SF4") + " SF4 " +;
           " WHERE SC6.C6_FILIAL  = '" + xFilial("SC6") + "' " +;
             " AND SC6.C6_LOCAL  >= '" + cAlmoxd + "' " +;
             " AND SC6.C6_LOCAL  <= '" + cAlmoxa + "' " +;
             " AND (SC6.C6_BLQ    = '" + cComp1 + "' " +;
             "  OR  SC6.C6_BLQ    = '" + cComp2 + "') " +;
             " AND SC6.C6_ENTREG <= '" + Dtos(dDatFim) + "' " +;
			 " AND SC6.C6_ENTREG <> ' ' " +;
             " AND SC6.D_E_L_E_T_ = ' ' " +;
             " AND SC6.C6_PRODUTO = SB1.B1_COD " +;
             " AND SF4.F4_FILIAL  = '" + xFilial("SF4") + "' " +;
             " AND SF4.F4_CODIGO  = SC6.C6_TES " +;
             " AND SF4.F4_ESTOQUE = 'S' " +;
             " AND SF4.D_E_L_E_T_ = ' ' "

//If !lCarteira
//	cQuery += " AND SC6.C6_QTDENT > 0 "
//EndIf
//
//If aPergs711[30] == 2 .Or. lCarteira
//	cQuery += " AND SC6.C6_QTDENT < SC6.C6_QTDVEN "
//EndIf
		
If !lPedBloc
	cQuery += " AND SC6.C6_OP <> '02' "
EndIf

If aAlmoxNNR # Nil
	cQuery += " AND SC6.C6_LOCAL IN (SELECT NR_LOCAL FROM " +cNomCZINNR +") "
EndIf
		
cQuery += cQueryB1


cQueryDef := cQuery

cQuery += " AND SC6.C6_QTDENT < SC6.C6_QTDVEN "

If lCarteira
   cQuery += " AND SC6.C6_ENTREG <= '" + Dtos(dDatFim) + "' "
Else
   If !Empty(aPergs711[5]) .And. !Empty(aPergs711[6])
      cQuery += "AND (SC6.C6_ENTREG >= '"+Dtos(aPergs711[5])+"' AND SC6.C6_ENTREG <= '"+Iif(aPergs711[6]<dDatFim,Dtos(aPergs711[6]),Dtos(dDatFim))+"')"
   ElseIf Empty(aPergs711[5]) .And. !Empty(aPergs711[6])
      cQuery += "AND SC6.C6_ENTREG <= '"+Iif(aPergs711[6]<dDatFim,Dtos(aPergs711[6]),Dtos(dDatFim))+"'"
   ElseIf !Empty(aPergs711[5]) .And. Empty(aPergs711[6])
      cQuery += "AND (SC6.C6_ENTREG >= '"+Dtos(aPergs711[5])+"' AND SC6.C6_ENTREG <= '"+Dtos(dDatFim)+"')"
   Else
      cQuery += "AND SC6.C6_ENTREG <= '"+Dtos(dDatFim)+"'"
   EndIf
EndIf

cQuery += "AND SC6.C6_ENTREG <> ' ' " 

If aPergs711[30] == 1
   cQuery += "UNION"
   cQuery += cQueryDef

   If !Empty(aPergs711[33]) .And. !Empty(aPergs711[34])
      cQuery += "AND (SC6.C6_DATFAT >= '"+Dtos(aPergs711[33])+"' AND SC6.C6_DATFAT <= '"+Iif(aPergs711[34]<dDatFim,Dtos(aPergs711[34]),Dtos(dDatFim))+"')"
   ElseIf Empty(aPergs711[33]) .And. !Empty(aPergs711[34])
      cQuery += "AND SC6.C6_DATFAT <= '"+Iif(aPergs711[34]<dDatFim,Dtos(aPergs711[34]),Dtos(dDatFim))+"'"
   ElseIf !Empty(aPergs711[33]) .And. Empty(aPergs711[34])
      cQuery += "AND (SC6.C6_DATFAT >= '"+Dtos(aPergs711[33])+"' AND SC6.C6_DATFAT <= '"+Dtos(dDatFim)+"')"
   Else
      cQuery += "AND SC6.C6_DATFAT <= '"+Dtos(dDatFim)+"'"
   EndIf

   cQuery += " AND SC6.C6_QTDENT = SC6.C6_QTDVEN "

EndIf

If lA710SQL
	cA710Fil := ExecBlock("A710SQL", .F., .F., {"SC6", cQuery})
	If ValType(cA710Fil) == "C"
		cQuery := cA710Fil
	Endif
Endif

cQuery += " ORDER BY " + SqlOrder(SC6->(IndexKey(2)))
cQuery := ChangeQuery(cQuery)	

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
aEval(SC6->(dbStruct()), {|x| If(x[2] <> "C" .And. FieldPos(x[1]) > 0, TcSetField(cAliasTop,x[1],x[2],x[3],x[4]),Nil)})
dbSelectArea(cAliasTop)

While !(cAliasTop)->(Eof())
	nRecno := C6REC

	//Avalia o LOG do MRP para o evento 006 - Documento planejado em atraso em atraso
	If lCarteira .And. C6_QTDENT < C6_QTDVEN
		A712CriaLOG("006",C6_PRODUTO,{C6_ENTREG,C6_NUM,C6_ITEM,"SC6"},lLogMRP,c711NumMRP)
		
		SC6->(DbGoTo(nRecno))
		mOpc := SC6->C6_MOPC
	
		aOpc := {C6_OPC,SC6->C6_MOPC}
		
		A712OpcDft(C6_PRODUTO,@aOpc)
		
		//Marca o semaforo
		MATA712LCK(.T.)
		
		//Cria os registros nas tabelas
		A712CriCZI(A712NextUtil(C6_ENTREG,aPergs711),C6_PRODUTO,aOpc[1],C6_REVISAO,"SC6",nRecno,C6_NUM,C6_ITEM,/*09*/,Max(0,C6_QTDVEN-C6_QTDENT),"3",.F.,.T.,/*14*/,.F.,.T.,aPeriodos,nTipo,c711NumMRP,cStrTipo,cStrGrupo,/*22*/,/*23*/,/*24*/,aOpc[2],/*26*/)
		
		//Libera semaforo
		UnLockByName("CZIUSO"+cEmpAnt+cFilAnt,.T.,.T.,.T.)
	EndIf
	
	dbSelectArea(cAliasTop)
	
	lValido := .T.
	If aPergs711[30] == 1
		If C6_QTDENT > 0
        	If C6_QTDENT < C6_QTDVEN
            	If !Empty(aPergs711[33]) .And. !Empty(aPergs711[34])
                	If !((cAliasTop)->(C6_DATFAT) >= aPergs711[33] .And. (cAliasTop)->(C6_DATFAT) <= Iif(aPergs711[34]<dDatFim,aPergs711[34],dDatFim))
                    	lValido := .F.
                  	EndIf 
               	EndIf
               	If !Empty(aPergs711[33]) .And. Empty(aPergs711[34])
                	If !((cAliasTop)->(C6_DATFAT) >= aPergs711[33] .And. (cAliasTop)->(C6_DATFAT) <= dDatFim)
                    	lValido := .F.
                  	EndIf 
               	EndIf
               	If Empty(aPergs711[33]) .And. !Empty(aPergs711[34])
                	If !((cAliasTop)->(C6_DATFAT) <= Iif(aPergs711[34]<dDatFim,aPergs711[34],dDatFim))
                    	lValido := .F.
                  	EndIf 
               	EndIf
            EndIf
		Else
        	lValido := .F.
        EndIf
	EndIf

	
	//Array utilizado na integracao com previsao de venda - Subtrai quantidade dos pedidos ja colocados								
	If lProcSC4
		//Incrementa array com totais de pedidos por periodo
		If Len(aPedidosAc[Len(aPedidosAc)]) > 4095
			AADD(aPedidosAc,{})
		EndIf
		
		nQtdPed := 0
		
		If aPergs711[17] == 1 //Se subtrai os pedidos de venda colocados da previsão.
			nQtdPed += C6_QTDVEN-C6_QTDENT
		EndIf
		
		//Se subtrai os pedidos de venda faturados da previsão E 
		//o pedido está em uma data válida para subtrair (parâmetros 33 e 34).
		If aPergs711[30] == 1 .And. lValido 
			nQtdPed += C6_QTDENT
		EndIf
		
		SC6->(DbGoTo(nRecno))
			
		For i := 1 to Len(aPedidosAc)
			nAchouPed := ASCAN(aPedidosAc[i],{ |x| x[1] == C6_PRODUTO+Iif(Empty(SC6->C6_MOPC),SC6->C6_OPC,SC6->C6_MOPC) .And. x[2] == A650DTOPER(C6_ENTREG,aPeriodos,nTipo)})
			
			If nAchouPed != 0
				aPedidosAc[i,nAchouPed,3] += nQtdPed
				Exit
			EndIf
		Next i
		
		If nAchouPed ==0
			AADD(aPedidosAc[Len(aPedidosAc)],{C6_PRODUTO+Iif(Empty(SC6->C6_MOPC),SC6->C6_OPC,SC6->C6_MOPC),A650DTOPER(C6_ENTREG,aPeriodos,nTipo),nQtdPed})
		EndIf
	EndIf
	
	(cAliasTop)->(dbSkip())
End

dbSelectArea(cAliasTop)
dbCloseArea()

//Processa em conjunto PREVISAO DE VENDAS
If lProcSC4
	cAliasTop := "BUSCASC4" 
	A712JobC4(cEmp,cFil,{c711NumMRP,nTipo,aPeriodos,cStrTipo,cStrGrupo,cAliasTop,cAlmoxd,cAlmoxa,cQueryB1,ACLONE(aPergs711),.F.,aPedidosAC,cRev711Vaz,aAlmoxNNR,lA710Sql,dDatFim,cNomCZINNR},nTentativa,,lUsaMOpc)
EndIf

//STATUS 3 - Processamento efetuado com sucesso
PutGlbValue("A712JobC6","3") 
GlbUnLock()

FClose(nHd)
FErase(cFileJob)

ProcLogAtu("FIM")

Return


/*------------------------------------------------------------------------//
//Programa:	A712JobC4 
//Autor:		Ricardo Prandi 
//Data:		26/09/2013
//Descricao:	Job para processamento de previsoes de venda - SC4  
//Parametros:	cEmp     	- Empresa                                           
//	          	cFil     	- Filial                                            
//          	aParamJob	- Array com parametros para JOB                    
//				nTentativa	- Numero da tentativa para chamada do JOB
//				cFileJob	- Nome do arquivo de JOB
//				lUsaMOpc	- Parâmetro de utilização de opcionais
//Parametros JOB:
//  	      	[1]  - Numero do calculo de MRP                          
//            [2]  - Tipo de calculo MRP                               
//            [3]  - Array com os periodos                             
//            [4]  - String com tipos a serem processados              
//            [5]  - String com grupos a serem processados             
//            [6]  - Alias da tabela a ser processada                  
//            [7]  - Almoxarifado de (utilizado para filtro)           
//            [8]  - Almoxarifado ate(utilizado para filtro)                       
//            [9]  - Query para filtragem de produtos no SB1                       
//            [10] - Array com perguntas utilizadas                                
//            [11] - Indica se a chamada ocorreu atraves de JOB                    
//            [12] - Array com dados dos pedidos existentes                        
//            [13] - Revisao vazio                                                 
//				[14] - Indica se filtra locais da tabela CZINNR
//				[15] - Indica a existencia de P.E. na filtragem (SQL)
//				[16] - Data final para filtras os dados
//              [17] - Tabela CZINNR concatenado com cEmpAnt e cFilAnt
//Uso: 		M712JCTB
//				MATA712
//------------------------------------------------------------------------*/
Function A712JobC4(cEmp,cFil,aParamJob,nTentativa,cFileJob,lUsaMOpc)
Local cQuery		:= ""
Local cA710Fil	:= ""
Local mOpc 		:= ""
Local nRecno		:= 0
Local nHd			:= 0
Local i			:= 0
Local nAchouPed	:= 0
Local nQuantPrev	:= 0
Local c711NumMRP := aParamJob[1]
Local nTipo      := aParamJob[2]
Local aPeriodos  := aParamJob[3]
Local cStrTipo   := aParamJob[4]
Local cStrGrupo  := aParamJob[5]
Local cAliasTop  := aParamJob[6]
Local cAlmoxd    := aParamJob[7]
Local cAlmoxa    := aParamJob[8]
Local cQueryB1   := aParamJob[9]
Local aPergs711  := aParamJob[10]
Local lInJob     := aParamJob[11]
Local aPedidosAC := aParamJob[12]
Local cRev711Vaz := aParamJob[13]
Local aAlmoxNNR	 := aParamJob[14]
Local lA710SQL 	 := aParamJob[15]
Local dDatFim	 := aParamJob[16]
Local cNomCZINNR := aParamJob[17]
Local aOpc          := {}

PRIVATE nQuantPer	:= Len(aPeriodos)
PRIVATE cAliasCZJ	:= "CZJ"
PRIVATE cAliasCZK	:= "CZK"

// So inicializa ambiente se foi acionado por job
// So atualiza status de variavel global se foi acionado por job
If lInJob
	nHd := FCreate(cFileJob)
	
	//STATUS 1 - Iniciando execucao do Job
	PutGlbValue("A712JobC4","1")
	GlbUnLock()
	
	//Seta job para nao consumir licensas
	RpcSetType(3)
	
	//Seta job para empresa filial desejada
	RpcSetEnv( cEmp, cFil,,,'PCP')
	Private  lPCPREVATU	:= FindFunction('PCPREVATU')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)
	//STATUS 2 - Conexao efetuada com sucesso
	PutGlbValue("A712JobC4","2")
	GlbUnLock()
EndIf
	
//Conout(STR0147+" A712JobC4 "+StrZero(nTentativa,2,0)) //"Processando thread"

cQuery := " SELECT SC4.C4_FILIAL, " +;
                 " SC4.C4_QUANT, " +;
                 " SC4.C4_PRODUTO, " +;
                 " SC4.C4_DATA, " +;
                 " SC4.C4_OPC, " +;
                 " SC4.C4_REVISAO, " +;
                 " SC4.C4_DOC, " +;
                 " SC4.R_E_C_N_O_ C4REC " +;
            " FROM " + RetSqlName("SC4") + " SC4, " + RetSqlName("SB1") + " SB1 " +;
           " WHERE SC4.C4_FILIAL  = '" + xFilial("SC4") + "' " +;
             " AND SC4.C4_DATA   >= '" + DTOS(aPergs711[05]) + "' " +;
             " AND SC4.C4_DATA   <= '" + DTOS(aPergs711[06]) + "' " +;
             " AND SC4.C4_LOCAL  >= '" + cAlmoxd + "' " +;
             " AND SC4.C4_LOCAL  <= '" + cAlmoxa + "' " +;
             " AND SC4.C4_DOC    >= '" + aPergs711[23] + "' " +;
             " AND SC4.C4_DOC    <= '" + aPergs711[24] + "' " +;
             " AND SC4.C4_DATA   <= '" + Dtos(dDatFim) + "' " +;
             " AND SC4.D_E_L_E_T_ = ' ' " +;
             " AND SC4.C4_PRODUTO = SB1.B1_COD "

If aAlmoxNNR # Nil
	cQuery += " AND SC4.C4_LOCAL IN (SELECT NR_LOCAL FROM " +cNomCZINNR +") "
EndIf

cQuery += cQueryB1

If lA710SQL
	cA710Fil := ExecBlock("A710SQL", .F., .F., {"SC4", cQuery})
	If ValType(cA710Fil) == "C"
		cQuery := cA710Fil
	Endif
Endif

cQuery += " ORDER BY " + SqlOrder(SC4->(IndexKey(1)))
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
aEval(SC4->(dbStruct()), {|x| If(x[2] <> "C" .And. FieldPos(x[1]) > 0, TcSetField(cAliasTop,x[1],x[2],x[3],x[4]),Nil)})
dbSelectArea(cAliasTop)

While !Eof() 
	nRecno := C4REC
	
	//Quantidade Original da previsao de vendas
	nQuantPrev := C4_QUANT				
	
	//Subtrai quantidade dos pedidos ja colocados ou faturados
	If aPergs711[17] == 1 .Or. aPergs711[30] == 1
		nAchouPed := 0
		SC4->(dbGoto(nRecno))
		For i := 1 to Len(aPedidosAc)
			nAchouPed:=ASCAN(aPedidosAc[i],{ |x| x[1] == C4_PRODUTO+Iif(Empty(SC4->C4_MOPC),SC4->C4_OPC,SC4->C4_MOPC) .And. x[2] == A650DTOPER(C4_DATA,aPeriodos,nTipo)})
			If nAchouPed != 0
				Exit
			EndIf
		Next i
		
		If nAchouPed > 0
			If aPedidosAc[i,nAchouPed,3] > nQuantPrev
				aPedidosAc[i,nAchouPed,3]-=nQuantPrev
				nQuantPrev:=0
			Else
				nQuantPrev:=nQuantPrev - aPedidosAc[i,nAchouPed,3]
				aPedidosAc[i,nAchouPed,3]:=0
			EndIf	
		EndIf
	EndIf
	
	If nQuantPrev > 0
		SC4->(dbGoto(nRecno))
		mOpc := SC4->C4_MOPC
		
		aOpc := {C4_OPC,SC4->C4_MOPC}
		A712OpcDft(C4_PRODUTO,@aOpc)
		
		//Marca o semaforo
		MATA712LCK(.T.)
	
		//Cria os registros nas tabelas
		A712CriCZI(A712NextUtil(C4_DATA,aPergs711),C4_PRODUTO,aOpc[1],If(A712TrataRev(),C4_REVISAO,cRev711Vaz),"SC4",nRecno,C4_DOC,/*08*/,/*09*/,nQuantPrev,"3",.F.,.T.,/*14*/,.F.,.T.,aPeriodos,nTipo,c711NumMRP,cStrTipo,cStrGrupo,/*22*/,/*23*/,/*24*/,aOpc[2],/*26*/)
		
		//Libera semaforo
		UnLockByName("CZIUSO"+cEmpAnt+cFilAnt,.T.,.T.,.T.)
	EndIf
	
	dbSelectArea(cAliasTop)
	dbSkip()
End

dbSelectArea(cAliasTop)
dbCloseArea()

//So atualiza status de variavel global se foi acionado por job
If lInJob
	//STATUS 3 - Processamento efetuado com sucesso
	PutGlbValue("A712JobC4","3")
	GlbUnLock()
	
	FClose(nHd)
	FErase(cFileJob)
EndIf

Return   

/*------------------------------------------------------------------------//
//Programa:	A712JobAFJ 
//Autor:		Ricardo Prandi 
//Data:		26/09/2013
//Descricao:	Job para processamento de empenhos para projeto - AFJ  
//Parametros:	cEmp     	- Empresa                                           
//	          	cFil     	- Filial                                            
//          	aParamJob	- Array com parametros para JOB                    
//				nTentativa	- Numero da tentativa para chamada do JOB
//				cFileJob	- Nome do arquivo de JOB
//Parametros JOB:
//  	      	[1]  - Numero do calculo de MRP                          
//            [2]  - Tipo de calculo MRP                               
//            [3]  - Array com os periodos                             
//            [4]  - String com tipos a serem processados              
//            [5]  - String com grupos a serem processados             
//            [6]  - Alias da tabela a ser processada                  
//            [7]  - Query para filtragem de produtos no SB1                       
//            [8]  - Indica a existencia de P.E. na filtragem (SQL)                
//            [9]  - Opcional vazio                                                
//            [10] - Revisao vazio                                                 
//            [11] - Indica se gera log                                
//            [12] - Array com as perguntas
//				[13] - Data final para filtras os dados
//Uso: 		MATA712
//------------------------------------------------------------------------*/
Function A712JobAFJ(cEmp,cFil,aParamJob,nTentativa,cFileJob)
Local nRecno		:= 0              
Local nHd			:= 0
Local c711NumMRP	:= aParamJob[1]
Local nTipo     	:= aParamJob[2]
Local aPeriodos 	:= aParamJob[3]
Local cStrTipo  	:= aParamJob[4]
Local cStrGrupo 	:= aParamJob[5]
Local cAliasTop 	:= aParamJob[6]
Local cQueryB1  	:= aParamJob[7]
Local lA710Sql  	:= aParamJob[8] 
Local cOpc711Vaz	:= aParamJob[9]
Local cRev711Vaz	:= aParamJob[10]
Local lLogMRP   	:= aParamJob[11]
Local aPergs711 	:= aParamJob[12]
Local dDatFim		:= aParamJob[13]

PRIVATE nQuantPer	:= Len(aPeriodos)
PRIVATE cAliasCZJ	:= "CZJ"
PRIVATE cAliasCZK	:= "CZK"

nHd := FCreate(cFileJob)

//STATUS 1 - Iniciando execucao do Job
PutGlbValue("A712JobAFJ","1")
GlbUnLock()
                      
//Seta job para nao consumir licensas
RpcSetType(3)

//Seta job para empresa filial desejada
RpcSetEnv(cEmp,cFil,,,'PCP')
Private  lPCPREVATU	:= FindFunction('PCPREVATU')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)
//STATUS 2 - Conexao efetuada com sucesso
PutGlbValue("A712JobAFJ","2")
GlbUnLock()

//Conout(STR0147+" A712JobAFJ "+StrZero(nTentativa,2,0))  //"Processando thread"

cQuery := " SELECT AFJ.AFJ_FILIAL, " +;
                 " AFJ.AFJ_COD, " +;
                 " AFJ.AFJ_DATA, " +;
                 " AFJ.AFJ_PROJET, " +;
                 " AFJ.AFJ_QEMP, " +;
                 " AFJ.AFJ_QATU, " +;
                 " AFJ.R_E_C_N_O_ AFJREC" +;
            " FROM " + RetSqlName("AFJ") + " AFJ, " + RetSqlName("SB1") + " SB1 " +;
           " WHERE AFJ.AFJ_FILIAL  = '" + xFilial("AFJ") + "' " +;
             " AND AFJ.AFJ_QATU    < AFJ.AFJ_QEMP " +;
             " AND AFJ.AFJ_DATA   <= '" + Dtos(dDatFim) + "' " +;
             " AND AFJ.D_E_L_E_T_  = ' ' " +;
             " AND AFJ.AFJ_COD     = SB1.B1_COD "
cQuery += cQueryB1

If lA710SQL
	cA710Fil := ExecBlock("A710SQL", .F., .F., {"AFJ", cQuery})
	If ValType(cA710Fil) == "C"
		cQuery := cA710Fil
	Endif
Endif	

cQuery += " ORDER BY " + SqlOrder(AFJ->(IndexKey(2)))
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
aEval(AFJ->(dbStruct()), {|x| If(x[2] <> "C" .And. FieldPos(x[1]) > 0, TcSetField(cAliasTop,x[1],x[2],x[3],x[4]),Nil)})
dbSelectArea(cAliasTop)

While !Eof()
	nRecno := AFJREC
	
	//Avalia o LOG do MRP para o evento 006 - Documento planejado em atraso
	A712CriaLOG("006",AFJ_COD,{AFJ_DATA,AFJ_PROJET,"","AFJ"},lLogMRP,c711NumMRP)
	
	//Marca o semaforo
	MATA712LCK(.T.)
	
	//Cria os registros nas tabelas
	A712CriCZI(A712NextUtil(AFJ_DATA,aPergs711),AFJ_COD,cOpc711Vaz,cRev711Vaz,"AFJ",nRecno,AFJ_PROJET,/*08*/,/*09*/,AFJ_QEMP-AFJ_QATU,"3",.F.,/*13*/,/*14*/,.F.,.T.,aPeriodos,nTipo,c711NumMRP,cStrTipo,cStrGrupo,/*22*/,/*23*/,/*24*/,/*25*/,/*26*/)
	
	//Libera semaforo
	UnLockByName("CZIUSO"+cEmpAnt+cFilAnt,.T.,.T.,.T.)
	
	dbSelectArea(cAliasTop)	
	dbSkip()
End

dbSelectArea(cAliasTop)
dbCloseArea()

//STATUS 3 - Processamento efetuado com sucesso
PutGlbValue("A712JobAFJ","3")
GlbUnLock()

FClose(nHd)
FErase(cFileJob)

Return

/*------------------------------------------------------------------------//
//Programa:	A712JobHC 
//Autor:		Ricardo Prandi 
//Data:		27/09/2013
//Descricao:	Job para processamento de plano mestre de producao - SHC
//Parametros:	cEmp     	- Empresa                                           
//	          	cFil     	- Filial                                            
//          	aParamJob	- Array com parametros para JOB                    
//				nTentativa	- Numero da tentativa para chamada do JOB
//				cFileJob	- Nome do arquivo de JOB
//				lUsaMOpc	- Parâmetro de utilização de opcionais
//Parametros JOB:
//  	      	[1]  - Numero do calculo de MRP                          
//            [2]  - Tipo de calculo MRP                               
//            [3]  - Array com os periodos                             
//            [4]  - String com tipos a serem processados              
//            [5]  - String com grupos a serem processados             
//            [6]  - Query para filtragem de produtos no SB1                       
//            [7]  - Alias da tabela a ser processada                  
//            [8]  - Array com perguntas utilizadas                                               
//            [9]  - Revisao vazio  
//				[10] - Data final para filtras os dados
//Uso: 		MATA712
//------------------------------------------------------------------------*/
Function A712JobHC(cEmp,cFil,aParamJob,nTentativa,cFileJob,lUsaMOpc)
Local nRecno		:= 0               
Local nHd			:= 0
Local c711NumMRP	:= aParamJob[1]
Local nTipo     	:= aParamJob[2]
Local aPeriodos 	:= aParamJob[3]
Local cStrTipo  	:= aParamJob[4]
Local cStrGrupo 	:= aParamJob[5]
Local cAliasTop 	:= aParamJob[6]
Local cQueryB1  	:= aParamJob[7]
Local aPergs711 	:= aParamJob[8]
Local cRev711Vaz	:= aParamJob[9]
Local dDatFim		:= aParamJob[10]
Local mOpc 		:= ""  
Local aOpc      := {}

PRIVATE nQuantPer	:= Len(aPeriodos)
PRIVATE cAliasCZJ	:= "CZJ"
PRIVATE cAliasCZK	:= "CZK"

nHd := FCreate(cFileJob)

//STATUS 1 - Iniciando execucao do Job
PutGlbValue("A712JobHC","1")
GlbUnLock()

//Seta job para nao consumir licensas
RpcSetType(3)

//Seta job para empresa filial desejada
RpcSetEnv( cEmp, cFil,,,'PCP')
Private  lPCPREVATU	:= FindFunction('PCPREVATU')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)
//STATUS 2 - Conexao efetuada com sucesso
PutGlbValue("A712JobHC","2")
GlbUnLock()

//Conout(STR0147+" A712JobHC "+StrZero(nTentativa,2,0))  //"Processando thread"

cQuery := " SELECT SHC.HC_FILIAL, " +;
                 " SHC.HC_DATA, " +;        
                 " SHC.HC_PRODUTO, " +;
                 " SHC.HC_REVISAO, " +;
                 " SHC.HC_DOC, " +;
                 " SHC.HC_QUANT, " +;
                 " SHC.HC_OPC, " +;
                 " SB1.B1_COD, " +;
                 " SB1.B1_MRP, " +;
                 " SHC.R_E_C_N_O_ HCREC " +;
            " FROM " + RetSqlName("SHC") + " SHC, " + RetSqlName("SB1") + " SB1 " +;
           " WHERE SHC.HC_FILIAL  = '" + xFilial("SHC") + "' " +;
             " AND SHC.HC_STATUS  = '" + Space(LEN(SHC->HC_STATUS)) + "' " +;
             " AND SHC.HC_OP      = '" + Space(Len(SHC->HC_OP)) + "' " +;
             " AND SHC.HC_DATA   >= '" + DTOS(aPergs711[05]) + "' " +;
             " AND SHC.HC_DATA   <= '" + DTOS(aPergs711[06]) + "' " +;
             " AND SHC.HC_DATA   <= '" + DTOS(dDatFim) + "' " +;
             " AND SHC.HC_DOC    >= '" + aPergs711[23] + "' " +;
             " AND SHC.HC_DOC    <= '" + aPergs711[24] + "' " +;
             " AND SHC.D_E_L_E_T_ = ' ' " +;
             " AND SHC.HC_PRODUTO = SB1.B1_COD "
cQuery += cQueryB1
cQuery += " ORDER BY " + SqlOrder(SHC->(IndexKey(1)))
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
aEval(SHC->(dbStruct()), {|x| If(x[2] <> "C" .And. FieldPos(x[1]) > 0, TcSetField(cAliasTop,x[1],x[2],x[3],x[4]),Nil)})
dbSelectArea(cAliasTop)

While !Eof()
	If !(RetFldProd((cAliasTop)->HC_PRODUTO,"B1_MRP",cAliasTop) $ " S")
		(cAliasTop)->(dbSkip())
		Loop
	EndIf
	
	nRecno := HCREC
	
	SHC->(dbGoTo(nRecno))
	mOpc := SHC->HC_MOPC
	
	aOpc := {HC_OPC,SHC->HC_MOPC}
	A712OpcDft(HC_PRODUTO,@aOpc)
	
	//Marca o semaforo
	MATA712LCK(.T.)
	
	//Cria os registros nas tabelas
	A712CriCZI(A712NextUtil(HC_DATA,aPergs711),HC_PRODUTO,aOpc[1],If(A712TrataRev(),HC_REVISAO,cRev711Vaz),"SHC",nRecno,HC_DOC,/*08*/,/*09*/,HC_QUANT,"2",.F.,.T.,/*14*/,.F.,.T.,aPeriodos,nTipo,c711NumMRP,cStrTipo,cStrGrupo,/*22*/,/*23*/,/*24*/,aOpc[2],/*26*/)
	
	//Libera semaforo
	UnLockByName("CZIUSO"+cEmpAnt+cFilAnt,.T.,.T.,.T.)
	
	dbSelectArea(cAliasTop)
	dbSkip()
End

dbSelectArea(cAliasTop)
dbCloseArea()

//STATUS 3 - Processamento efetuado com sucesso
PutGlbValue("A712JobHC","3")
GlbUnLock()

FClose(nHd)
FErase(cFileJob)

Return

/*------------------------------------------------------------------------//
//Programa:	A712JobB8 
//Autor:		Ricardo Prandi 
//Data:		27/09/2013
//Descricao:	Job para processamento de lotes vencidos
//Parametros:	cEmp     	- Empresa                                           
//	          	cFil     	- Filial                                            
//          	aParamJob	- Array com parametros para JOB                    
//				nTentativa	- Numero da tentativa para chamada do JOB
//				cFileJob	- Nome do arquivo de JOB
//Parametros JOB:
//  	      	[1]  - Numero do calculo de MRP                          
//            [2]  - Tipo de calculo MRP                               
//            [3]  - Array com os periodos                             
//            [4]  - String com tipos a serem processados              
//            [5]  - String com grupos a serem processados             
//            [6]  - Alias da tabela a ser processada                  
//            [7]  - Query para filtragem de produtos no SB1                       
//            [8]  - Array com perguntas utilizadas                                
//            [9]  - Revisao vazio
//				[10] - Indica se filtra locais da tabela CZINNR
//              [11] - Tabela CZINNR concatenado com cEmpAnt e cFilAnt
//Uso: 		MATA712
//------------------------------------------------------------------------*/
Function A712JobB8(cEmp,cFil,aParamJob,nTentativa,cFileJob)
Local nRecno		:= 0               
Local nHd			:= 0
Local c711NumMRP	:= aParamJob[1]
Local nTipo     	:= aParamJob[2]
Local aPeriodos 	:= aParamJob[3]
Local cStrTipo  	:= aParamJob[4]
Local cStrGrupo 	:= aParamJob[5]
Local cAliasTop 	:= aParamJob[6]
Local cQueryB1  	:= aParamJob[7]
Local aPergs711 	:= aParamJob[8]
Local cRev711Vaz	:= aParamJob[9]
Local aAlmoxNNR 	:= aParamJob[10]
Local cNomCZINNR 	:= aParamJob[11]

PRIVATE nQuantPer := Len(aPeriodos)
PRIVATE cAliasCZJ	:= "CZJ"
PRIVATE cAliasCZK	:= "CZK"

nHd := FCreate(cFileJob)

//STATUS 1 - Iniciando execucao do Job
PutGlbValue("A712JobB8","1")
GlbUnLock()

//Seta job para nao consumir licensas
RpcSetType(3)

//Seta job para empresa filial desejada
RpcSetEnv(cEmp,cFil,,,'PCP')
Private  lPCPREVATU	:= FindFunction('PCPREVATU')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)
//STATUS 2 - Conexao efetuada com sucesso
PutGlbValue("A712JobB8","2")
GlbUnLock()

//Conout(STR0147+" A712JobB8 "+StrZero(nTentativa,2,0))  //"Processando thread"

cQuery := " SELECT SB8.B8_FILIAL, " +;
                 " SB8.B8_DTVALID, " +;
                 " SB8.B8_PRODUTO, " +;
                 " SB8.B8_LOTECTL, " +;
                 " SB8.B8_NUMLOTE, " +;
                 " SB8.B8_SALDO, " +;
                 " SB8.R_E_C_N_O_ B8REC " +;
            " FROM " + RetSqlName("SB8") + " SB8, " + RetSqlName("SB1") + " SB1 " +;
           " WHERE SB8.B8_FILIAL  = '" + xFilial("SB8") + "' " +;
             " AND SB8.B8_SALDO   > 0 " +;
             " AND SB8.B8_LOCAL   >= '" + aPergs711[8] + "' " +;
             " AND SB8.B8_LOCAL   <= '" + aPergs711[9] + "' " +;
             " AND SB8.B8_LOCAL   <> '" + AlmoxCQ() + "' " +;
             " AND SB8.B8_DTVALID  < '" + DTOS(aPeriodos[Len(aPeriodos)])+ "' " +;
             " AND SB8.D_E_L_E_T_  = ' ' " +;
             " AND SB8.B8_PRODUTO  = SB1.B1_COD "

If aAlmoxNNR # Nil
	cQuery += " AND SB8.B8_LOCAL IN (SELECT NR_LOCAL FROM " +cNomCZINNR +") "
EndIf
		
cQuery += cQueryB1
cQuery += " ORDER BY " + SqlOrder(SB8->(IndexKey(1)))
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
aEval(SB8->(dbStruct()), {|x| If(x[2] <> "C" .And. FieldPos(x[1]) > 0, TcSetField(cAliasTop,x[1],x[2],x[3],x[4]),Nil)})
dbSelectArea(cAliasTop)

While !Eof()
	nRecno := B8REC

	//Marca o semaforo
	MATA712LCK(.T.)
	
	//Cria os registros nas tabelas
	A712CriCZI(A712NextUtil(B8_DTVALID+1,aPergs711),B8_PRODUTO,/*03*/,cRev711Vaz,"SB8",nRecno,If(Rastro(B8_PRODUTO,"L"),AllTrim(B8_LOTECTL),AllTrim(B8_LOTECTL)+"/"+AllTrim(B8_NUMLOTE)),/*08*/,/*09*/,B8_SALDO,/*11*/,.F.,.T.,/*14*/,.F.,.T.,aPeriodos,nTipo,c711NumMRP,cStrTipo,cStrGrupo,/*22*/,/*23*/,/*24*/,/*25*/,/*26*/)
	
	//Libera semaforo
	UnLockByName("CZIUSO"+cEmpAnt+cFilAnt,.T.,.T.,.T.)
	
	dbSelectArea(cAliasTop)
	dbSkip()
End

dbSelectArea(cAliasTop)
dbCloseArea()

//STATUS 3 - Processamento efetuado com sucesso
PutGlbValue("A712JobB8","3")
GlbUnLock()

FClose(nHd)
FErase(cFileJob)

Return

/*------------------------------------------------------------------------//
//Programa:	A712JobIni 
//Autor:		Ricardo Prandi 
//Data:		14/10/2013
//Descricao:	Funcao utilizada para carregar os registros de saldo inicial
//Parametros:	01.cEmp			- Empresa                             
//            02.cFil      		- Filial                               
//            03.aProdutos  	- Array com os itens a serem calculados                              
//            04.cJobFile   	- Nome do arquivo para controle do JOB              
//            05.cThread    	- Numero da Thread em execucao               
//            06.aBkPeriodos	- Array contendo os periodos a processar                         
//            07.aBkPergs711 	- Array contendo as perguntas selecionadas                                 
//            08.c711BkNumMrp	- Numero do MRP
//				09.cStrTipo  		- String dos tipos de itens
//				10.cStrGrupo		- String com os grupos de itens
//				11.cTxtEstSeg		- Mensagem do estoque de segunranca
//				12.cRev711Vaz		- Revisão vazio
//				13.lExistBB1		- Indica se existe BB1
//				14.lExistBB2		- Indica se existe BB2
//				15.lM710NOPC		- Indica se usa opcional
//				16.lLogMRP			- Indica se o log do mrp está ligado
//				17.cTxtPontPed	- Ponto de pedido
//				18.aAlmoxNNRl		- Array com os locais selecionados
//				19.nBkTipo			- Tipo de periodo
//				20.aPicture		- Array com as pictures
//				21.cSelOpc			- Indica o valor do parâmetro MV_SELEOPC                                                                                        
//Uso: 		MATA712
//------------------------------------------------------------------------*/
Function A712JobIni(cEmp,cFil,aProdutos,cJobFile,cThread,aBkPeriodos,aBkPergs711,c711BkNumMrp,cStrTipo,cStrGrupo,cTxtEstSeg,cRev711Vaz,lExistBB1,lExistBB2,lM710NOPC,lLogMRP,cTxtPontPed,aAlmoxNNRl,nBkTipo,aPicture,cSelOpc)
Local nHd1	  		:= 0
Local nX      	:= 0
Local nz        	:= 0
Local nSaldo   	:= 0
Local nEstSeg   	:= 0
Local nQtdAviso 	:= 0
Local cMsgAviso 	:= ""
Local nPontoPed 	:= 0
Local nQtdPontP 	:= 0
Local cMsgPontP 	:= ""
Local cArqSHA		:= ""
Local cQuery   	:= ""
Local cRevisao  	:= ""
Local aOpc			:= {}
 
//Variavels para valida opcionas default
Local lOpcOK		:= .T.
Local cProdx 		:= ""
Local cretx 		:= ""
Local aRetrOpcx 	:= {}
Local cProPaix 		:= ""
Local cProAntx 		:= ""
local lMrpEmax		:= .F. 

//Carrega Variaveis Private
Private aPeriodos 	:= aBkPeriodos
Private aPergs711 	:= aBkPergs711
Private aAlmoxNNR 	:= aAlmoxNNRl
Private aFilAlmox 	:= Nil
Private cAlmoxd	  	:= aPergs711[8]
Private cAlmoxa	  	:= aPergs711[9]
Private c711NumMrp	:= c711BkNumMrp
Private cMT710B2  	:= Nil
Private cAliasCZJ		:= "CZJ"
Private cAliasCZK		:= "CZK"
Private cPictLOCAL	:= aPicture[1]
Private cPictQATU 	:= aPicture[2]
Private cPictQNPT 	:= aPicture[3]
Private cPictQTNP 	:= aPicture[4]
Private cPictQTDE 	:= aPicture[5]
Private cPictSALDO	:= aPicture[6]
PRIVATE cPictB2Local := aPicture[1]
PRIVATE cPictB2Qatu  := aPicture[2]
PRIVATE cPictB2QNPT  := aPicture[3]
PRIVATE cPictB2QTNP  := aPicture[4]
PRIVATE cPictD7QTDE  := aPicture[5]
PRIVATE cPictDDSaldo := aPicture[6]
Private nTipo     	:= nBkTipo


//Apaga arquivo ja existente
If File(cJobFile)
	fErase(cJobFile)
EndIf

//Criacao do arquivo de controle de jobs
nHd1 := MSFCreate(cJobFile)

//STATUS 1 - Iniciando execucao do Job
PutGlbValue("c712P"+cEmp+cFil+cThread, "1" )
GlbUnLock()

//Seta job para nao consumir licensas
RpcSetType(3)

//Seta job para empresa filial desejada
RpcSetEnv(cEmp,cFil,,,'EST')
Private  lPCPREVATU	:= FindFunction('PCPREVATU')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)
//STATUS 2 - Conexao efetuada com sucesso
PutGlbValue("c712P"+cEmp+cFil+cThread, "2" )
GlbUnLock()

lMrpEmax	:= SUPERGETMV("MV_MRPEMAX",.F.,.F.)
//ConOut(dtoc(Date())+" "+Time()+" "+"MATA712: Iniciando job Saldo Inicial "+" - "+cJobFile)

//Processamento
For nX :=1 To Len(aProdutos)
	dbSelectArea("SB1")
	dbSetOrder(1)
	
	If MsSeek(xFilial("SB1")+aProdutos[nX])
		If lExistBB1
			aFilAlmox := RetExecBlock("A710FILALM",{SB1->B1_COD,cAlmoxd,cAlmoxa},"A",Nil,Nil,Nil,lExistBB1)
		EndIf
		
		If lExistBB2
			cMT710B2 := RetExecBlock("MT710B2",{SB1->B1_COD,cAlmoxd,cAlmoxa},"C", Nil,Nil,Nil,lExistBB2)
		EndIf

		If ValType(aFilAlmox) == "A" .And. aScan(aFilAlmox, {|z| ValType(z) # "C"}) > 0
			aFilAlmox := Nil
		EndIf

		//Inicializa variaveis de saldo
		nSaldo	:= 0
		nEstSeg:= 0
		
		//Obtem saldo e estoque de seguranca
		A712DSaldo(SB1->B1_COD,@nSaldo,@aFilAlmox,/*04*/,/*05*/,@nEstSeg,"SB1")

		//Ponto de Entrada MA710NOPC para indicar saldo por opcional                                           
		If lM710NOPC
			aOpc := ExecBlock('M710NOPC',.F.,.F.,{SB1->B1_COD,nSaldo})
			If ValType(aOpc) == 'A'
				For nz := 1 to Len(aOpc)
					//Avalia o LOG do MRP para o evento 001 - Saldo em estoque inicial menor que zero
					A712CriaLOG("001",SB1->B1_COD,{aOPc[nz,2]},lLogMRP,c711NumMrp)
					cRevisao := If(A712TrataRev() .And. Len(aOpc[nz]) >= 3, aOpc[nz, 3], cRev711Vaz)
					A712CriCZJ(SB1->B1_COD,/*02*/,cRevisao,/*04*/,"001",aOPc[nz,2],"1","SB1",/*09*/,cStrTipo,cStrGrupo,.F.,aOPc[nz,1])
				Next nz
			Else
				//Avalia o LOG do MRP para o evento 001 - Saldo em estoque inicial menor que zero
				A712CriaLOG("001",SB1->B1_COD,{nSaldo},lLogMRP,c711NumMrp)
				A712CriCZJ(SB1->B1_COD,IIF(cSelOpc == 'S',SB1->B1_OPC,CriaVar("B1_OPC")),cRev711Vaz,/*04*/,"001",nSaldo,"1","SB1",/*09*/,cStrTipo,cStrGrupo,.F.,IIF(cSelOpc == 'S',SB1->B1_MOPC,CriaVar("B1_MOPC")))
			EndIf
		Else
			// Avalia o LOG do MRP para o evento 001 - Saldo em estoque inicial menor que zero
			A712CriaLOG("001",SB1->B1_COD,{nSaldo},lLogMRP,c711NumMrp)
			A712CriCZJ(SB1->B1_COD,IIF(cSelOpc == 'S',SB1->B1_OPC,CriaVar("B1_OPC")),cRev711Vaz,/*04*/,"001",nSaldo,"1","SB1",/*09*/,cStrTipo,cStrGrupo,.F.,IIF(cSelOpc == 'S',SB1->B1_MOPC,CriaVar("B1_MOPC")))
		EndIf
		
		If aPergs711[31] == 1
			nPontoPed := RetFldProd(aProdutos[nX],"B1_EMIN")
		EndIf
		
		//Valida opcionais na estrutura e se tem opcionas default
			cProdx		:= SB1->B1_COD
			IF nEstSeg > 0 .OR. nPontoPed > 0
				lOpcOK	    := MT712VLOPC(cProdx, cretx, aRetrOpcx, cProPaix, cProAntx, , ,.F. , 1 )
			Else
				lOpcOK := .T. 
			EndIF

		//Checa informacoes para inclusao no tree
		nQtdAviso := 0
		cMsgAviso := ""
		
		//Caso o estoque de seguranca esteja preenchido
		If QtdComp(nEstSeg,.T.) > QtdComp(0,.T.)
			IF ! lOpcOK
					nQtdAviso := 0
				Else
					nQtdAviso := nEstSeg
					cMsgAviso := cTxtEstSeg
			EndIf
			
		EndIf

		// Checa informacoes para inclusao no tree
		nQtdPontP := 0
		cMsgPontP := ""
		
		//Caso o estoque de seguranca esteja preenchido
		If QtdComp(nPontoPed,.T.) > QtdComp(0,.T.)
				IF ! lOpcOK
					nQtdPontP := 0 
				Else
					nQtdPontP:= nPontoPed
					cMsgPontP:= cTxtPontPed
				EndIf
		EndIf

		//VALIDA ESTOQUE MAXIMA
			lMrpSeg :=  .T.
			nEstmax := 0
			If lMrpEmax  //Visualizar estoque Maximo 
				
				IF SB1->B1_EMAX > 0 
				 	nEstmax := SB1->B1_EMAX
								 			
				If nQtdAviso > 0 
				 	cMsgAviso := ALLTRIM(cMsgAviso) + " / Estoque Maximo"
				 	lMrpSeg := .F. 
				
				EndIf
				
				Endif
				 
			EndIF

		//Monta no Tree Saldo Negativo					
		If QtdComp(nSaldo,.T.) < QtdComp(0,.T.) .And. QtdComp((Abs(nSaldo)-(IF(nEstSeg>0,nEstSeg,0))),.T.) > QtdComp(0,.T.)
			IF ! EMPTY(SB1->(Recno()))
				A712CriCZI(aPeriodos[1],SB1->B1_COD,SB1->B1_OPC, IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU ),"SB2",SB1->(Recno()),STR0177,/*08*/,/*09*/,(Abs(nSaldo)-(IF(nEstSeg>0,nEstSeg,0))),/*11*/,.F.,.F.,"SB1",.F.,/*16*/,/*17*/,/*18*/,/*19*/,cStrTipo,cStrGrupo,/*22*/,/*23*/,/*24*/,SB1->B1_MOPC,/*26*/) //"Saldo Negativo"
			EndIF	
		EndIf						
		//Monta no tree
		If QtdComp(nQtdAviso,.T.) > QtdComp(0,.T.)
			A712CriCZI(aPeriodos[1],SB1->B1_COD,SB1->B1_OPC, IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU ),"SB1",SB1->(Recno()),cMsgAviso,/*08*/,/*09*/,nQtdAviso,/*11*/,.F.,.F.,"SB1",.F.,/*16*/,/*17*/,/*18*/,/*19*/,cStrTipo,cStrGrupo,/*22*/,/*23*/,/*24*/,SB1->B1_MOPC,/*26*/)
		EndIf

		// 	Monta no tree
		If QtdComp(nQtdPontP,.T.) > QtdComp(0,.T.)
			A712CriCZI(aPeriodos[1],SB1->B1_COD,SB1->B1_OPC, IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU ),"SB1",SB1->(Recno()),cMsgPontP,/*08*/,/*09*/,nQtdPontP,/*11*/,.F.,.F.,"SB1",.F.,/*16*/,/*17*/,/*18*/,/*19*/,cStrTipo,cStrGrupo,/*22*/,/*23*/,/*24*/,SB1->B1_MOPC,/*26*/)
		EndIf
	
		// Monta tree se tiver ESTOQUE MAXIMO
		If nEstmax > 0 .AND. lMrpEmax .AND. lMrpSeg
			A712CriCZI(aPeriodos[1],SB1->B1_COD,SB1->B1_OPC, IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU ),"SB1",SB1->(Recno()),"Estoque Maximo",/*08*/,/*09*/,0,/*11*/,.F.,.F.,"SB1",.F.,/*16*/,/*17*/,/*18*/,/*19*/,cStrTipo,cStrGrupo,/*22*/,/*23*/,/*24*/,SB1->B1_MOPC,/*26*/)
		EndIf
	
	EndIf
Next nX

//ConOut(dtoc(Date())+" "+Time()+" "+"MATA712: Termino job Saldo Inicial "+" - "+cJobFile)

//STATUS 3 - Processamento efetuado com sucesso
PutGlbValue("c712P"+cEmp+cFil+cThread,"3")
GlbUnLock()

Return

/*------------------------------------------------------------------------//
//Programa:	A712JobNes 
//Autor:		Ricardo Prandi 
//Data:		15/10/2013
//Descricao:	Funcao utilizada para executar o calculo da necessidade em mult-thread. 
//Parametros:	01.cEmp			- Empresa                             
//            02.cFil      		- Filial                               
//            03.aThreads	  	- Array com os itens a serem calculados                              
//            04.cJobFile   	- Nome do arquivo para controle do JOB              
//            05.cThread    	- Numero da Thread em execucao               
//            06.aBkPeriodos	- Array contendo os periodos a processar                         
//            07.aBkPergs711 	- Array contendo as perguntas selecionadas                                 
//            08.aAlmoxNNRl		- Array com os locais selecionados
//				09.c711BkNumMrp	- Numero do MRP                                            
//				10.aFilAlmoxl		- Array de PE de filtro de locais
//Uso: 		MATA712
//------------------------------------------------------------------------*/
Function A712JobNes(cEmp,cFil,aThreads,cJobFile,cThread,aBkPeriodos,aBkPergs711,aAlmoxNNRl,c711BkNumMrp,aFilAlmoxl)

Local nHd1	:= 0
Local nX  	:= 0

Private aPeriodos 	:= aBkPeriodos
Private aPergs711 	:= aBkPergs711
Private aAlmoxNNR 	:= aAlmoxNNRl
Private c711NumMrp	:= c711BkNumMrp
Private aFilAlmox 	:= aFilAlmoxl

//Apaga arquivo ja existente
If File(cJobFile)
	fErase(cJobFile)
EndIf

//Criacao do arquivo de controle de jobs
nHd1 := MSFCreate(cJobFile)

//STATUS 1 - Iniciando execucao do Job
PutGlbValue("c712P"+cEmp+cFil+cThread,"1")
GlbUnLock()

//Seta job para nao consumir licensas
RpcSetType(3)

//Seta job para empresa filial desejada
RpcSetEnv(cEmp,cFil,,,'EST')
Private  lPCPREVATU	:= FindFunction('PCPREVATU')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)
//STATUS 2 - Conexao efetuada com sucesso
PutGlbValue("c712P"+cEmp+cFil+cThread,"2")
GlbUnLock()

//ConOut(dtoc(Date())+" "+Time()+" "+"MATA712: Iniciando job Calculo Necessidade "+" - "+cJobFile)

//Processamento
For nX := 1 To Len(aThreads)
	MA712Recalc(aThreads[nX,1],aThreads[nX,2],aThreads[nX,3],/*04*/,/*05*/,/*06*/,.T.,aThreads[nX,4],aThreads[nX,5])
Next nX

//ConOut(dtoc(Date())+" "+Time()+" "+"MATA712: Termino job Calculo Necessidade "+" - "+cJobFile)

//STATUS 3 - Processamento efetuado com sucesso
PutGlbValue("c712P"+cEmp+cFil+cThread,"3")
GlbUnLock()

Return

/*------------------------------------------------------------------------//
//Programa:	A712JobTree 
//Autor:		Ricardo Prandi 
//Data:		15/10/2013
//Descricao:	Job para montagem da Tela do MRP       
//Parametros:	01.cEmp			- Empresa                             
//            02.cFil      		- Filial                               
//            03.aThreads	  	- Array com os itens a serem calculados                              
//            04.cJobFile   	- Nome do arquivo para controle do JOB              
//            05.cThread    	- Numero da Thread em execucao               
//            06.cFileTotal 	- Nome do arquivo de Total                            
//            07.cFileTree  	- Nome do arquivo da DbTree
//            08.lUsaMOpc  		- Indica se usa memo de opcionais
//Uso: 		MATA712
//------------------------------------------------------------------------*/
Function A712JobTree(cEmp,cFil,aThreads,cJobFile,cThread,cFileTotal,cFileTree,lUsaMOpc)
Local nHd1	   	 	:= 0
Local nHd2	    	:= 0
Local nHd3	    	:= 0
Local nX        	:= 0
Local i         	:= 0
Local nAchouTot 	:= 0
Local aDbTree   	:= {}
Local aTotais   	:= {{}}

Default lUsaMOpc:= .F.

//Apaga arquivo de Job ja existente
If File(cJobFile)
	fErase(cJobFile)
EndIf

//Apaga arquivo Total ja existente
If File(cFileTotal)
	fErase(cFileTotal)
EndIf

//Apaga arquivo da DbTree ja existente
If File(cFileTree)
	fErase(cFileTree)
EndIf

//Criacao do arquivo de controle de jobs
nHd1 := MSFCreate(cJobFile)

//STATUS 1 - Iniciando execucao do Job
PutGlbValue("c712T"+cEmp+cFil+cThread,"1")
GlbUnLock()

//Seta job para nao consumir licensas
RpcSetType(3)

//Seta job para empresa filial desejada
RpcSetEnv(cEmp,cFil,,,'EST')
Private  lPCPREVATU	:= FindFunction('PCPREVATU')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)
//STATUS 2 - Conexao efetuada com sucesso
PutGlbValue("c712T"+cEmp+cFil+cThread,"2")
GlbUnLock()

//ConOut(dtoc(Date())+" "+Time()+" "+"MATA712: Iniciando Montagem do Tree do MRP "+" - "+cJobFile)

For nX := 1 To Len(aThreads)  
	// Estrutura do array
	// Produto
	// Opcional
	// Revisao
	// Alias
	// Tipo
	// Documento
	// Recno
	// DocRev
	
	CZI->(dbGoTo(aThreads[nX,1]))

	AADD(aDbTree,{CZI->CZI_PROD,CZI->CZI_OPCORD,CZI->CZI_NRRV,CZI->CZI_ALIAS,CZI->CZI_TPRG,CZI->CZI_DOC,StrZero(CZI->(Recno()),12),CZI->CZI_DOCREV})
	
	//Adiciona registro em array totalizador utilizado no TREE  
	If Len(aTotais[Len(aTotais)]) > 4095
		AADD(aTotais,{})
	EndIf
	
	For i := 1 to Len(aTotais[1])
		if aTotais[1,i,1] == CZI->CZI_PROD+CZI->CZI_OPCORD+CZI->CZI_NRRV .And. aTotais[1,i,2] == CZI->CZI_PERMRP .And. aTotais[1,i,3] == CZI->CZI_ALIAS
			nAchouTot := i
		Else
			nAchouTot := 0
			loop
		EndIf
		If nAchouTot != 0
			aTotais[1,nAchouTot,4] += CZI->CZI_QUANT
			Exit
		EndIf
	Next i
	
	If nAchouTot ==0
		AADD(aTotais[Len(aTotais)],{CZI->CZI_PROD + CZI->CZI_OPCORD + CZI->CZI_NRRV,CZI->CZI_PERMRP,CZI->CZI_ALIAS,CZI->CZI_QUANT})		
	EndIf
End

//Atualiza arquivo com dados do Array aDbTree 
nHd2 := MSFCreate(cFileTree)
For nX := 1 to Len(aDbTree)
	fWrite(nHd2,aDbTree[nX][1]) 
	
	fWrite(nHd2,Padr(aDbTree[nX][2],TamSX3("CZI_OPCORD")[1]))  	
	
	fWrite(nHd2,aDbTree[nX][3]) 
	fWrite(nHd2,aDbTree[nX][4]) 
	fWrite(nHd2,aDbTree[nX][5]) 
	fWrite(nHd2,aDbTree[nX][6]) 
	fWrite(nHd2,aDbTree[nX][7]) 
	fWrite(nHd2,aDbTree[nX][8]) 
	fWrite(nHd2,CRLF)
Next nX	
fClose(nHd2)

//Atualiza arquivo com dados do Array aTotais
nHd3 := MSFCreate(cFileTotal)
For nX := 1 to Len(aTotais[1])
	fWrite(nHd3,aTotais[1][nX][1])			
	fWrite(nHd3,aTotais[1][nX][2])			
	fWrite(nHd3,aTotais[1][nX][3]) 		
	fWrite(nHd3,STR(aTotais[1][nX][4],18))	
	fWrite(nHd3,CRLF)
Next nX	
fClose(nHd3)

//ConOut(dtoc(Date())+" "+Time()+" "+"MATA712: Termino da Montagem do Tree do MRP "+" - "+cJobFile)

//STATUS 3 - Processamento efetuado com sucesso
PutGlbValue("c712T"+cEmp+cFil+cThread,"3")
GlbUnLock()

//Fecha arquivo de controle de semaforo
fClose(nHd1)

//Apaga arquivo de semaforo
If File(cJobFile)
	fErase(cJobFile)
EndIf

Return

/*-------------------------------------------------------------------------//
//Programa: A712IntPPI
//Autor:    Lucas Konrad França
//Data:     30/11/2015
//Descricao:   Job para integração das Ordens de produção geradas pelo MRP com o PC-Factory.
//Parametros:  cEmp        - Empresa
//             cFil        - Filial
//             cNumMrp     - Número de processamento do MRP.
//             cParInt     - Parâmetro de integração do PPI.
//             cUsuario    - Código do usuario que está processando o MRP.
//             aXml        - Array contendo os XMLs a serem processados.
//             lExclusao   - Indica que será processada a exclusão de registros. Necessário passar os
//                           XML's através do parâmetro aXml.
//Uso:      MATA712
//-------------------------------------------------------------------------*/
Function A712IntPPI(cEmp,cFil,cNumMRP,cParInt,cUsuario,aXml,lExclusao)

   Local cQuery    := ""
   Local cQueryCnt := ""
   Local cAliasC2  := "GETC2MRP"
   Local cFiltro   := ""
   Local nCount    := 0
   Local nTotal    := 0

   Default aXml      := {}
   Default lExclusao := .F.

   Private cIntgPPI := cParInt

   //Variáveis para tratar as exceções
   Private bError      := { |e| oError := e }
   Private bErrorBlock := ErrorBlock( bError )
   Private oError

   //STATUS 1 - Iniciando execucao do Job
   BEGIN SEQUENCE
   PutGlbValue("A712IntPPI"+cEmp+cFil,"1")
   GlbUnLock()
   END SEQUENCE
   If ValType(oError) != "U"
      //ConOut(Replicate("-",65))
      //ConOut("Erro ao iniciar a execucao do Job: A712IntPPI" + cEmp+cFil)
      //ConOut(oError:Description + oError:ErrorStack)
      //ConOut(Replicate("-",65))
      PutGlbValue("A712IntPPI"+cEmp+cFil, "10" )
      GlbUnLock()
      Return
   EndIf

   BEGIN SEQUENCE
   //Seta job para nao consumir licensas
   RpcSetType(3)

   //Seta job para empresa filial desejada
   RpcSetEnv(cEmp,cFil,,,'EST')
	Private  lPCPREVATU	:= FindFunction('PCPREVATU')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)
   //STATUS 2 - Conexao efetuada com sucesso
   PutGlbValue("A712IntPPI"+cEmp+cFil,"2")
   GlbUnLock()
   END SEQUENCE
   If ValType(oError) != "U"
      //ConOut(Replicate("-",65))
      //ConOut("Erro ao efetuar a conexão. Job: A712IntPPI" + cEmp+cFil)
      //ConOut(oError:Description + oError:ErrorStack)
      //ConOut(Replicate("-",65))
      PutGlbValue("A712IntPPI"+cEmp+cFil, "20" )
      GlbUnLock()
      Return
   EndIf

   BEGIN SEQUENCE
   //Carrega as variáveis private utilizadas.
   If lExclusao
      INCLUI    := .F.
      ALTERA    := .F.
   Else
      INCLUI    := .T.
      ALTERA    := .F.
   EndIf
   __cUserId := cUsuario
   SetFunName("MATA712")

	PutGlbValue("A712IntPPI"+cEmp+cFil+"COUNT", "0" )
	GlbUnLock()
	
   If lExclusao
      PutGlbValue("A712IntPPI"+cEmp+cFil+"TOTAL", cValToChar(Len(aXml)) )
      GlbUnLock()

      For nCount := 1 To Len(aXml)
         mata650PPI(aXml[nCount,1], aXml[nCount,2], .T., .T., .T., .F.)
         delClassIntF()
         PutGlbValue("A712IntPPI"+cEmp+cFil+"COUNT", cValToChar(nCount) )
         GlbUnLock()
      Next nCount
   Else
      //Verifica se existe algum filtro para a tabela na SOE
      dbSelectArea("SOE")
      SOE->(dbSetOrder(1))
      If SOE->(dbSeek(xFilial("SOE")+"SC2"))
         cFiltro := SOE->OE_FILTRO
         //Troca as aspas duplas por simples.
         cFiltro := StrTran(cFiltro,'"',"'")
      EndIf

      dbSelectArea("SC2")

      //Buscas as OP's que foram criadas pelo MRP.
      cQuery := " SELECT SC2.R_E_C_N_O_ RECSC2 "
      cQuery +=   " FROM " + RetSqlName("SC2") + " SC2 "
      cQuery +=  " WHERE SC2.D_E_L_E_T_ = ' ' "
      cQuery +=    " AND SC2.C2_FILIAL  = '" + xFilial("SC2") + "' "
      cQuery +=    " AND SC2.C2_SEQMRP  = '" + cNumMRP + "' "
      If !Empty(cFiltro)
         cQuery += " AND (" + AllTrim(cFiltro) + ") "
      EndIf

      cQuery := ChangeQuery(cQuery)

      cQueryCnt := " SELECT COUNT(*) TOTAL FROM (" + cQuery + ") t"
      cQueryCnt := ChangeQuery(cQueryCnt)
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryCnt),cAliasC2,.T.,.T.)
      nTotal := (cAliasC2)->(TOTAL)
      PutGlbValue("A712IntPPI"+cEmp+cFil+"TOTAL", cValToChar(nTotal) )
      GlbUnLock()
      (cAliasC2)->(dbCloseArea())

      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasC2,.T.,.T.)

      While (cAliasC2)->(!Eof())
         SC2->(dbGoTo((cAliasC2)->(RECSC2)))

         mata650PPI(, , .T., .T., .F., .F.)
         delClassIntF()
         nCount++
         PutGlbValue("A712IntPPI"+cEmp+cFil+"COUNT", cValToChar(nCount) )
         GlbUnLock()
         (cAliasC2)->(dbSkip())
      End

      (cAliasC2)->(dbCloseArea())
   EndIf

   END SEQUENCE
   If ValType(oError) != "U"
      //ConOut(Replicate("-",65))
      //ConOut("Erro ao efetuar o processamento do Job: A712IntPPI" + cEmp+cFil)
      //ConOut(oError:Description + oError:ErrorStack)
      //ConOut(Replicate("-",65))
      PutGlbValue("A712IntPPI"+cEmp+cFil, "30" )
      PutGlbValue("A712IntPPI"+cEmp+cFil+"ERRO", oError:Description + oError:ErrorStack )
      GlbUnLock()
      //Conout("Finalizando o processamento do Job A712IntPPI"+cEmp+cFil+" com erros.")
      Return
   EndIf

   //STATUS 3 - Processamento efetuado com sucesso
   PutGlbValue("A712IntPPI"+cEmp+cFil,"3")
   GlbUnLock()
   //Conout("Finalizando o processamento do Job A712IntPPI"+cEmp+cFil)
Return

/*/{Protheus.doc} MT712QNOC2
Retorna subquery padrão para desconsiderar ordens de produção suspensas e sacramentadas

@type  Function
@author lucas.franca
@since 16/04/2020
@version P12.1.30
@param lConsSusp, Logic, Parâmetro de tela indicando se considera ordens suspensas
@param lConsSacr, Logic, Parâmetro de tela indicando se considera ordens sacramentadas
@return cQryC2, Character, Query para desconsiderar as ordens
/*/
Function MT712QNOC2(lConsSusp, lConsSacr)
	Local cQryC2     := ""
	Local cConcatQry := "||"

	If !lConsSusp .Or. !lConsSacr
		If "MSSQL" $ Upper(TcGetDb())
			cConcatQry := "+"
		EndIf

		cQryC2 := " SELECT SC2.C2_NUM" + cConcatQry + "SC2.C2_ITEM" + cConcatQry + "SC2.C2_SEQUEN" + cConcatQry + "SC2.C2_ITEMGRD "
		cQryC2 +=   " FROM " + RetSqlName("SC2") + " SC2 "
		cQryC2 +=  " WHERE SC2.C2_FILIAL = '" + xFilial("SC2") + "' "
		cQryC2 +=    " AND SC2.D_E_L_E_T_ = ' ' "
		cQryC2 +=    " AND SC2.C2_STATUS IN( "
		If !lConsSusp
			cQryC2 +=                     " 'U' "
		EndIf
		If !lConsSacr
			cQryC2 += Iif(!lConsSusp, ",", " ") + " 'S' "
		EndIf
		cQryC2 += ")"
	EndIf

Return cQryC2