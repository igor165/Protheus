#INCLUDE "plsa475.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSMGER.CH"

#DEFINE K_Fase     5
#DEFINE K_RetFas   6
#DEFINE K_RevPag   7
#DEFINE K_RetCob   8
#DEFINE K_RetCP    9

STATIC __cLasttime := ""

/*/{Protheus.doc} PLSA475
Mudanca de fase por lote
@type function
@author PLSTEAM
@since 11.03.2003
@version 1.0
/*/
function PLSA475
local aSays    := {}
local aButtons := {}
local cCadastro:= STR0001 //"Processamento de Guias por Lote"

private cPerg    := "PLS475"
private cOpeDe   
private cOpeAte
private cLocDe
private cLocAte
private cPegDe
private cPegAte
private cRDADe
private cRDAAte
private cAnoDe
private cAnoAte
private cMesDe
private cMesAte     
private nTipo       
private cCodEmpDe
private cCodEmpAte
private cContDe
private cContAte
private cSubConDe
private cSubConAte
private cGruCobDe
private cGruCobAte
private lRegCad
private cDataDe
private cDataAte
private cLocAtDe
private cLocAtAte                                        
private cClaRDA
private nOnlyZero
private nDifUs    
private nVlrDifUs 
private cGrpPagDe
private cGrpPagAte

if PLVLDBLQCO(dDataBase, {"PLS005"}, .t. ) //se a data do sistema esta no periodo bloqueado pela contabilidade, não pode executar a ação 

	aadd(aSays,STR0002) //"Esta opcao permite realizar em um conjunto de PEGS as seguintes opcoes"
	aadd(aSays,STR0003) //"Mudar a Fase - Mudar a fase das guias que estao em fase digitacao"
	aadd(aSays,STR0004) //"Retornar a Fase - Retornar a fase das guias que estao em fase digit. ou em confer."
	aadd(aSays,STR0005) //"Revalorizar pagto - Revalorizar o pagto de guias ainda nao pagas e fase pronta"
	aadd(aSays,STR0006) //"Revalorizar cobranca - Revalorizar a cobranca de guias nao cobradas e prontas ou pagas"
	aadd(aSays,STR0007) //"Revalorizar pagamento e cobranca - Revalorizacao de Cobranca e Pagamento"

	//Monta botoes para janela de processamento                               
	aadd(aButtons, { 5,.t.,{|| pergunte(cPerg,.t. )  } } )
	aadd(aButtons, { 1,.t.,{|| PLSA475PRO(cPerg) } } )
	aadd(aButtons, { 2,.t.,{|| FechaBatch()          } } )

	//Exibe janela de processamento                                           
	formBatch( cCadastro, aSays, aButtons,,250 )

endIf

return

/*/{Protheus.doc} PLSA475PRO
Processa a mudanca de fase por lote...  
@type function
@author PLSTEAM
@since 11.03.2003
@version 1.0
/*/
function PLSA475PRO(cPerg)
local cSQL          := ""   
local aFiltro		:= {}
local cHoraIniT 	:= time()
local aRetRes		:= {}
local nfor          := 0  
local lFlag     	:= .f.
local cTitulo		:= ''
local nTotReg   	:= 0
local nTotEventos 	:= 0
local nQtd      	:= 0
local nRecAtu		:= 0
local aThreads 		:= {}
local nThreads 		:= getNewPar("MV_PLSMFNT",1)
local nCont         := 0     
local aRegs    		:= {}
local nPosVet		:= 0
local nQtdPorT      := 0           
local nAux			:= 0
local nLastrec		:= 0
local lSaida 		:= .f.
local aRestTot 		:= {}
local oBrowseSta	:= nil
local otimer        := nil      	                                                             
local otimeOut		:= nil
local oSay          := nil                            
local aBCL    		:= {}
local cOriMov 		:= ""                         
local nTotGerEv 	:= 0
local cAliasPri		:= ""
local lProcesso 	:= .f.
local cNameBAU  	:= BAU->(retSQLName("BAU"))
local cNameBCI		:= BCI->(retSQLName("BCI"))
local cNameBD5		:= BD5->(retSQLName("BD5"))
local cNameBE4		:= BE4->(retSQLName("BE4"))
local cFilBAU   	:= BAU->(xFilial("BAU"))
local cFilBCI   	:= BCI->(xFilial("BCI"))
local cFilBD5   	:= BD5->(xFilial("BD5"))
local cFilBE4   	:= BE4->(xFilial("BE4"))
local lField		:= .F.

if nThreads > 15
   nThreads := 15
endIf  
 
pergunte(cPerg,.f.)

cOpeDe     := mv_par01
cOpeAte    := mv_par02
cLocDe     := mv_par03
cLocAte    := mv_par04
cPegDe     := mv_par05
cPegAte    := mv_par06
cRDADe     := mv_par07
cRDAAte    := mv_par08
cAnoDe     := mv_par09
cAnoAte    := mv_par10
cMesDe     := mv_par11
cMesAte    := mv_par12
nTipo      := mv_par13
cCodEmpDe  := mv_par14
cCodEmpAte := mv_par15
cContDe    := mv_par16
cContAte   := mv_par17
cSubConDe  := mv_par18
cSubConAte := mv_par19
lRegCad    := (mv_par20 == 2)
cGruCobDe  := mv_par21
cGruCobAte := mv_par22
cDataDe    := mv_par23
cDataAte   := mv_par24
cLocAtDe   := mv_par25
cLocAtAte  := mv_par26                           
cClaRDA    := allTrim(mv_par27)
nOnlyZero  := mv_par28
nDifUs	   := mv_par29
nVlrDifUs  := mv_par30
cGrpPagDe  := mv_par31
cGrpPagAte := mv_par32

aFiltro := { 	 cOpeDe,;  		//[1]
				 cOpeAte,;		//[2]	
				 cCodEmpDe,;	//[3]
				 cCodEmpAte,;	//[4]
				 cContDe,;		//[5]
				 cContAte,;		//[6]
				 cSubConDe,;	//[7]
				 cSubConAte,;	//[8] 
				 cGruCobDe,;	//[9]
				 cGruCobAte,;	//[10]
				 cDataDe,;		//[11]
				 cDataAte,;		//[12]
				 cLocAtDe,;		//[13]
				 cLocAtAte,;	//[14]
				 cClaRDA ,;		//[15]
				 nOnlyZero,;	//[16]
				 cGrpPagDe,;	//[17]
				 cGrpPagAte}	//[18]
				 
//Pede confirmacao...                                                 
if nTipo == 1
	
	if ! msgYesNo(STR0017) //"Confirma a mudanca de fase dos PEGS de acordo com os parametros informados ?"
		return
	endIf 
	  
elseIf nTipo == 2
      
	if ! msgYesNo(STR0018) //"Confirma o retorno de fase dos PEGS de acordo com os parametros informados ?"
		return
	endIf
	   
elseIf nTipo == 3
	
	if ! msgYesNo(STR0019) //"Confirma a revalorizacao de pagamento das PEGS de acordo com os parametros informados ?"
		return
	endIf
	   
elseIf nTipo == 4
	
	if ! msgYesNo(STR0020) //"Confirma a revalorizacao de cobranca das PEGS de acordo com os parametros informados ?"
		return
	endIf
	   
elseIf nTipo == 5
	
	if ! msgYesNo(STR0021) //"Confirma a revalorizacao de pagamento e cobranca das PEGS de acordo com os parametros informados ?"
		return
	endIf
	   
endIf

//Atualiza status da PEG                                              
//somente a revalorizacao de cobranca (nTipo ==4) nao e necessario reprocessar as Pegs
//Se for a mesma Operadorado no De/Ate, utilizo ela diretamente
if cOpeDe == cOpeAte .and. nTipo <> 4      
	
	PLSM190Pro(,.f.,cOpeDe,cLocDe,cLocAte,cPegDe,cPegAte,cAnoDe,cMesDe,cAnoAte,cMesAte)
	
//Foi utilizado o De Para com operadoras diferentes
elseIf nTipo <> 4     
	
	BA0->(dbSetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT    

	if empty(cOpeDe) .or. !BA0->(msSeek(xFilial("BA0")+cOpeDe)) //Se nao encontrei a operadora ou o parametro 'De' veio vazio, posiciono no topo
		BA0->(dbGoTop())
	endIf
		
	while !BA0->(eof()) //Rodo todas as operadoras que tenho na BA0 a verificar se os parametros De/Para sao atendidos
		
		if BA0->BA0_CODIDE >= subStr(cOpeDe,1,1) .and. BA0->BA0_CODINT >= subStr(cOpeDe,2,3) .and. ;
	   	   BA0->BA0_CODIDE <= subStr(cOpeAte,1,1) .and. BA0->BA0_CODINT <= subStr(cOpeAte,2,3)   
	   	   
	   		PLSM190Pro(,.f.,BA0->(BA0_CODIDE+BA0_CODINT),cLocDe,cLocAte,cPegDe,cPegAte,cAnoDe,cMesDe,cAnoAte,cMesAte)   
	    endIf  
	     
	    BA0->(dbSkip())
	endDo
	
endIf   

//Monta query...                                                      
cSQL := "SELECT DISTINCT BCI.R_E_C_N_O_ AS REGBCI, BCI_FILIAL, BCI_CODOPE, BCI_CODLDP, BCI_CODPEG, BCI_FASE, BCI_SITUAC  "
cSQL += " FROM " + cNameBCI + " BCI "  

if ! empty(cClaRDA) 
	cSQL += " INNER JOIN " + cNameBAU + " BAU " 
	cSQL += "   ON BAU_FILIAL = '" + cFilBAU + "' "
	cSQL += "  AND BAU_CODIGO = BCI_CODRDA "
	cSQL += "  AND BAU_TIPPRE IN ('" + strTran(cClaRDA,",","','") + "') "
	cSQL += "  AND BAU.D_E_L_E_T_ = ' ' "
endIf

cSQL += " LEFT JOIN " + cNameBD5 + " BD5 "
cSQL += "    ON BD5_FILIAL = '" + cFilBD5 + "' "
cSQL += "   AND BD5_CODOPE = BCI_CODOPE "
cSQL += "   AND BD5_CODLDP = BCI_CODLDP "
cSQL += "   AND BD5_CODPEG = BCI_CODPEG "
cSQL += "   AND BD5_CODRDA = BCI_CODRDA "

if nTipo == 1
	cSQL += " AND BD5_FASE = '1' "
elseIf nTipo == 2
	cSQL += " AND BD5_FASE <> '4' "
endIf

cSQL += "   AND BD5.D_E_L_E_T_ = ' ' "

cSQL += " LEFT JOIN " + cNameBE4 + " BE4 "
cSQL += "    ON BE4_FILIAL = '" + cFilBE4 + "' "
cSQL += "   AND BE4_CODOPE = BCI_CODOPE "
cSQL += "   AND BE4_CODLDP = BCI_CODLDP "
cSQL += "   AND BE4_CODPEG = BCI_CODPEG "
cSQL += "   AND BE4_CODRDA = BCI_CODRDA "

if nTipo == 1
	cSQL += " AND BE4_FASE = '1' "
elseIf nTipo == 2
	cSQL += " AND BE4_FASE <> '4' "
endIf

cSQL += "   AND BE4.D_E_L_E_T_ = ' ' "

cSQL += " WHERE BCI_FILIAL = '" + cFilBCI + "' "
cSQL += "   AND BCI_CODOPE BETWEEN '" + cOpeDe   + "' AND '" + cOpeAte + "' "
cSQL += "   AND BCI_CODLDP BETWEEN '" + cLocDe   + "' AND '" + cLocAte + "' "
cSQL += "   AND BCI_CODPEG BETWEEN '" + cPegDe   + "' AND '" + cPegAte + "' "
cSQL += "   AND BCI_CODRDA BETWEEN '" + cRdaDe   + "' AND '" + cRdaAte + "' "
cSQL += "   AND ( BCI_ANO || BCI_MES  >='" + cAnoDe  + "' || '" + cMesDe + "' ) " 
cSQL += "   AND ( BCI_ANO || BCI_MES  <='" + cAnoAte + "' || '" + cMesAte + "') " 
cSQL += "   AND BCI.D_E_L_E_T_ = ' ' "

//Ponto de Entrada solicitado pela CAPESESP para filtrar a seleção das PEG´s 
if existBlock("PL475FIL")
	cSQL += execBlock("PL475FIL",.f.,.f.,{cSQL}) 
endIf

cSQL += " ORDER BY BCI_FILIAL,BCI_CODOPE,BCI_CODLDP,BCI_CODPEG,BCI_FASE,BCI_SITUAC "

dbUseArea(.t.,"TOPCONN",tcGenQry(,,changeQuery(cSql)),"PLS475",.f.,.t.)

BCL->(dbSetOrder(1))

while ! PLS475->( eof() )

       BCI->( dbGoTo( PLS475->REGBCI ) )
       
       nPosVet := aScan(aBCL, {|x| x[2] == BCI->BCI_TIPGUI } )
       
       if nPosVet == 0
       
          BCL->( msSeek( xFilial("BCL") + BCI->(BCI_CODOPE+BCI_TIPGUI) ) )
          
          aadd(aBCL,{BCI->BCI_TIPGUI,BCL->BCL_CDORIT,BCL->BCL_ALIAS} )
          
          nPosVet := len(aBCL)
          
       endIf
          
       cOriMov   := aBCL[nPosVet,2]
       cAliasPri := aBCL[nPosVet,3]
       
       if (cAliasPri $ "BD5|BE4|BD6|BD7|B0R") 
	       lField    := &(cAliasPri)->(FieldPos(cAliasPri+"_STAFAT")) > 0
	       
	       cSQL := " SELECT SUM(" + cAliasPri + "_QTDEVE ) QTDEVE FROM " + retSqlName(cAliasPri) + ", " + cNameBAU 
	       cSQL += "  WHERE " + cAliasPri + "_FILIAL = '" + xFilial(cAliasPri) + "' "
	       cSQL += "    AND " + cAliasPri + "_CODOPE = '" + BCI->BCI_CODOPE + "' "
	       cSQL += "    AND " + cAliasPri + "_CODLDP = '" + BCI->BCI_CODLDP + "' "
	       cSQL += "    AND " + cAliasPri + "_CODPEG = '" + BCI->BCI_CODPEG + "' "  
	       cSQL += "    AND " + cAliasPri + "_ORIMOV = '" + cOriMov + "' "    
	       cSQL += "    AND " + cAliasPri + "_SITUAC = '1' "'
	       cSQL += "    AND " + cAliasPri + "_DATPRO BETWEEN '" + dtos(cDataDe) + "' AND '" + iIf( ! empty(cDataAte),dtos(cDataAte),replicate('Z',len(dtos(cDataAte)))) + "' "
		   cSQL += "    AND " + cAliasPri + "_CODEMP BETWEEN '" + cCodEmpDe     + "' AND '" + cCodEmpAte + "' "
		   cSQL += "    AND " + cAliasPri + "_CONEMP BETWEEN '" + cContDe       + "' AND '" + cContAte + "' "
		   cSQL += "    AND " + cAliasPri + "_SUBCON BETWEEN '" + cSubConDe     + "' AND '" + cSubConAte + "' "
		   cSQL += "    AND " + cAliasPri + "_LOCAL  BETWEEN '" + cLocAtDe      + "' AND '" + cLocAtAte + "' "
		   
		   //mudar a fase somente as pegs de digitacao...
	       if nTipo == 1               
				
				cSQL += "    AND " + cAliasPri + "_FASE   = '1' "
				
				if cAliasPri $ 'B0R|BE4'
					cSQL += "    AND " + cAliasPri + "_DTALTA <> '' "
				endIf	  
				
		   //Retorno de Fase	  
	       elseIf nTipo == 2 
	            
	            cSQL += "    AND " + cAliasPri + "_FASE IN ('3','2') "  
	            cSQL += "    AND " + cAliasPri + "_SEQEST = '' "
		        cSQL += "    AND " + cAliasPri + "_PODRFS <> '0' "  
	            
	       //Revalorização de pagamento          
	       elseIf nTipo == 3       
	              
				cSQL += "    AND " + cAliasPri + "_FASE = '3' "
				
	       //Revalorização de cobranca //Revalorização de pagamento e cobrança       
	       elseIf nTipo == 4 .or. nTipo == 5 
	              
	            cSQL += "    AND " + cAliasPri + "_FASE IN ('3','4') "
	              
	       endIf       
	
	       if nTipo <> 3 .and. lField                                  
	          	cSQL += "    AND " + cAliasPri + "_STAFAT <> '0' "  
	       endIf              
	       
	       if nOnlyZero == 2
	          	cSQL += "    AND " + cAliasPri + "_VLRPAG = 0 "  
	       endIf   
	       
	       cSQL += "    AND " + retSqlName(cAliasPri) + ".D_E_L_E_T_ = ' ' "
	       
	       cSQL += "    AND BAU_FILIAL = '" + cFilBAU  + "' "
	       cSQL += "    AND BAU_CODIGO = " + cAliasPri + "_CODRDA "
	       cSQL += "    AND BAU_GRPPAG BETWEEN '" + cGrpPagDe + "' AND '" + cGrpPagAte + "' "
	       cSQL += "    AND " + cNameBAU + ".D_E_L_E_T_ = ' ' "
	
	       dbUseArea(.t.,"TOPCONN",tcGenQry(,,changeQuery(cSql)),"TrbNotas",.f.,.t.)
	       
	       nTotEventos := TrbNotas->QTDEVE
	       nTotGerEv += nTotEventos
	       
	       aadd(aRegs,{PLS475->REGBCI,nTotEventos})
	       nTotReg ++
	       
	       TrbNotas->(dbCloseArea())
		EndIf
       
PLS475->(dbSkip())
endDo

PLS475->(dbCloseArea())

aRegs := aSort(aRegs,,,{|x,y| x[2] > Y[2] })

for nCont := 1 to nThreads

    aadd(aThreads,{{},;                        		//01-array com os Recnos das Pegs
                   "ThrPls" + strZero(nCont,3),; 	//02-Codigo ad Theard
                   "Não",;                     		//03-Aberta Sim Ou Nao
                   0,;                         		//04-Total de Eventos
                   0,;                         		//05-% concluido
                   "",;                        		//06-Hora Inicio
                   "",;                        		//07-Hora Fim
                   "",;                        		//08-Tempo Total
                   "ThrPlsSta" + strZero(nCont,3),; //09-Status do Processo...
                   "BR_VERMELHO",; 					//10-Imagem Browse
                   "Perc" + strZero(nCont,3),;		//11-Percentual concluido variavel
                   nil,; 							//12-uso livre
                   "ThrSPRO" + strZero(nCont,3),; 	//13-status do processo
                   "EvProc" + strZero(nCont,3),;	//14-
                   0,; 								//15-
                   "EvDes" + strZero(nCont,3),;		//16-
                   0,;								//17-
                   STR0034,; 						//18-"Normal"
                   0,;								//19-
                   0,;								//20-
                   .f.})                        	//21-
                   
next    

nQtdPorT := nTotGerEv / nThreads

nLastrec := 1                     
nTotEvT  := 0

for nCont := 1 to len(aThreads) 

    for nAux := nLastrec to len(aRegs)
    
        nTotEvT += aRegs[nAux,2]
    
        if nTotEvT >= nQtdPorT
    
           aadd(aThreads[nCont,1],aRegs[nAux,1])
    
           aThreads[nCont,4] += aRegs[nAux,2]
    
           nTotEvT := 0     
    
           nLastrec := nAux+1
    
           exit
    
        else                                     
    
           if nTotEvT >= nQtdPorT
              
              aadd(aThreads[nCont,1],aRegs[nAux,1])
              
              aThreads[nCont,4] += aRegs[nAux,2]
              
              nTotEvT := 0
              
           else
              
              if aRegs[nAux,2] > 0
                
                 aadd(aThreads[nCont,1],aRegs[nAux,1])
                 aThreads[nCont,4] += aRegs[nAux,2]
                 
              endIf
                 
           endIf
              
        endIf
               
    next
    
next

for nCont := 1 to len(aThreads)
    
    if aThreads[nCont,4] > 0
    
       putGlbvalue(aThreads[nCont,2], "0" )
	   glbUnLock()

       putGlbvalue(aThreads[nCont,9], "0" )
	   glbUnLock()

       putGlbvalue(aThreads[nCont,11], "0" )
	   glbUnLock()

       putGlbvalue(aThreads[nCont,13], "0" )
	   glbUnLock()

       putGlbvalue(aThreads[nCont,14], "0" )
	   glbUnLock()

       putGlbvalue(aThreads[nCont,16], "0" )
	   glbUnLock()

       aThreads[nCont,6] :=	 time()
       
       startJob("PLSPEGBATH",getEnvServer(),.f.,cEmpAnt,cFilAnt,aThreads,nQtd,nTotReg,nTipo,@cTitulo,aRetRes,aFiltro,lRegCad,nCont,cHoraIniT,aBCL,cUserName,cDataDe,cDataAte)
       
       lProcesso := .t.
    
    endIf
       
next

if lProcesso

   	statusProc(aThreads,aRestTot,.f.,oBrowseSta,oDlg,oSay,cHoraIniT,"1")

   	DEFINE MSDIALOG oDlg TITLE STR0035 FROM 008.2,000 to 028,ndColFin OF GetWnddefault()  //"Status do Processamento"
   
   	oDlg:lEscClose := .f.

   	@ 018,005 Say oSay PROMPT STR0036  SIZE 220,010 OF oDlg PIXEL //"Tempo de Processamento: "
   
   	oBrowseSta := TcBrowse():New( 030, 008, 378, 090,,,, oDlg,,,,,,,,,,,, .f.,, .t.,, .f., )

   	oBrowseSta:AddColumn(TcColumn():New("",nil,nil,nil,nil,nil,015,.t.,.f.,nil,nil,nil,.t.,nil))
	oBrowseSta:ACOLUMNS[1]:BDATA := { || LoadBitmap( GetResources(), aRestTot[oBrowseSta:nAt,1]) }
	
   	oBrowseSta:AddColumn(TcColumn():New(STR0037,nil,nil,nil,nil,nil,040,.f.,.f.,nil,nil,nil,.t.,nil))//"Processo"
	oBrowseSta:ACOLUMNS[2]:BDATA := { || aRestTot[oBrowseSta:nAt,2] }
	
   	oBrowseSta:AddColumn(TcColumn():New(STR0038,nil,nil,nil,nil,nil,030,.f.,.f.,nil,nil,nil,.t.,nil))//"Aberta"
	oBrowseSta:ACOLUMNS[3]:BDATA := { || aRestTot[oBrowseSta:nAt,3] }

   	oBrowseSta:AddColumn(TcColumn():New(STR0039,nil,nil,nil,nil,nil,050,.f.,.f.,nil,nil,nil,.t.,nil))//"Eventos Lidos"
	oBrowseSta:ACOLUMNS[4]:BDATA := { || allTrim(str(aRestTot[oBrowseSta:nAt,4],10)) }

	oBrowseSta:AddColumn(TcColumn():New(STR0040,nil,nil,nil,nil,nil,070,.f.,.f.,nil,nil,nil,.t.,nil))//"Eventos Processados"
	oBrowseSta:ACOLUMNS[5]:BDATA := { || aRestTot[oBrowseSta:nAt,10] }

   	oBrowseSta:AddColumn(TcColumn():New(STR0041,nil,nil,nil,nil,nil,070,.f.,.f.,nil,nil,nil,.t.,nil)) //"Eventos Desconsiderados"
	oBrowseSta:ACOLUMNS[6]:BDATA := { || aRestTot[oBrowseSta:nAt,11] }

   	oBrowseSta:AddColumn(TcColumn():New(STR0042,nil,nil,nil,nil,nil,040,.f.,.f.,nil,nil,nil,.t.,nil))//"Inicio"
	oBrowseSta:ACOLUMNS[7]:BDATA := { || aRestTot[oBrowseSta:nAt,5] }

   	oBrowseSta:AddColumn(TcColumn():New(STR0024,nil,nil,nil,nil,nil,040,.f.,.f.,nil,nil,nil,.t.,nil))//"% Concluído"
	oBrowseSta:ACOLUMNS[8]:BDATA := { || aRestTot[oBrowseSta:nAt,8] }

   	oBrowseSta:AddColumn(TcColumn():New(STR0043,nil,nil,nil,nil,nil,040,.f.,.f.,nil,nil,nil,.t.,nil))//"Fim"
	oBrowseSta:ACOLUMNS[9]:BDATA := { || aRestTot[oBrowseSta:nAt,6] }

   	oBrowseSta:AddColumn(TcColumn():New(STR0044,nil,nil,nil,nil,nil,070,.f.,.f.,nil,nil,nil,.t.,nil))//"Tempo Decorrido/Total"
	oBrowseSta:ACOLUMNS[10]:BDATA := { || aRestTot[oBrowseSta:nAt,7] }

   	oBrowseSta:AddColumn(TcColumn():New(STR0045,nil,nil,nil,nil,nil,070,.f.,.f.,nil,nil,nil,.t.,nil))//"Status do Processo"
	oBrowseSta:ACOLUMNS[11]:BDATA := { || aRestTot[oBrowseSta:nAt,9] }

   oBrowseSta:setArray(aRestTot)

   //Atualização de 10 em 10 segundos do status do processamento....
   otimer := Ttimer():New( 10000 ,{ || StatusProc(aThreads,aRestTot,.t.,oBrowseSta,oDlg,oSay,cHoraIniT,"1") },oDlg)	
   otimer:Activate()
   
   //Se em 10 minutos nao houver uma resposta da theard e encarado como time-out
   otimeOut := Ttimer():New( GetNewPar("MV_PLTMOUT",300000) ,{ || statusProc(aThreads,aRestTot,.t.,oBrowseSta,oDlg,oSay,cHoraIniT,"2") },oDlg)	
   otimeOut:Activate()
   
   ACTIVATE MSDIALOG oDlg CENTER ON INIT EnChoiceBar(oDlg,{ || TestaFecha(oDlg,aThreads) },{|| TestaFecha(oDlg,aThreads) },.f.)
   
else
   help("",1,"REGNOIS")
endIf

return

/*/{Protheus.doc} PLSPEGBATH
Roda processo theard.    
@type function
@author PLSTEAM
@since 11.03.2003
@version 1.0
/*/
function PLSPEGBATH(cEmp,cFil,aThreads,nQtd,nTotReg,nTipo,cTitulo,aRetRes,aFiltro,lRegCad,nCont,cHoraIniT,aBCL,cNameUsr,cDataDe,cDataAte)
local nFor		 := 0
local nFor2		 := 0
local nRecAtu	 := 0
local lFlag  	 := .f.                 
local aGuias 	 := aThreads[nCont,1]                                   
local nPos		 := 0
local cOriMov 	 := ""
local nDifUs 	 := 0                                                                                  
local nVlrDifUs  := 0   
local aPLS475    := {}    
private aRotina	 := {}

default aBCL 	 := {}
default cNameUsr := ""
default cDataDe  := ""
default cDataAte := ""

RpcSetType(3)

RpcSetEnv(cEmp, cFil,,,'PLS')

putGlbvalue(aThreads[nCont,2], "1" )
glbUnLock()

BCL->(dbSetOrder(1))

for nFor2 := 1 to len(aGuias)

    nRecAtu := aGuias[nFor2]

    //Posiciona no peg...                                                 
    BCI->( dbGoTo(nRecAtu) )

    lFlag := .t.
    
    nPos := aScan(aBCL,{|x| x[1] == BCI->BCI_TIPGUI})
    
    if nPos > 0
       cOriMov := aBCL[nPos,2]
    else
       
       BCL->( msSeek( xFilial("BCL") + BCI->(BCI_CODOPE + BCI_TIPGUI) ) )
       
       cOriMov := BCL->BCL_CDORIT
       
    endIf
    
    //Alimenta array utilizado para filtro de datas   			        
    aadd(aPLS475,.t.)
    aadd(aPLS475,cDataDe)
    aadd(aPLS475,cDataAte)

    //Mudar a Fase
    if nTipo == 1 
    
           PLSA175FAS("BCI",nRecAtu,K_Fase,nil,.f.,aFiltro,lRegCad,aThreads[nCont,4],aThreads,nCont,cNameUsr,aPLS475)
    
           cTitulo := STR0054 //"Mudança de fase das PEGS concluída."
    
    //Retorno de Fase
    elseIf nTipo == 2                                     

           PLSA175RGR("BCI",nRecAtu,K_RetFas,nil,.f.,aFiltro,aThreads[nCont,4],aThreads,nCont,cOriMov,cNameUsr,"1",nil,nil,aPLS475)
		   
	       cTitulo := STR0055 //"Retorno de fase das PEGS concluída."
           
    //Revalorizar Pagamento
    elseIf nTipo == 3 
    
           PLSA175RGR("BCI",nRecAtu,K_RevPag,nil,.f.,aFiltro,aThreads[nCont,4],aThreads,nCont,cOriMov,cNameUsr,"2",nDifUs,nVlrDifUs,aPLS475)
           
           cTitulo := STR0056 //"Revalorização de Pagamento das PEGS concluída."
    
    //Revalorizar Cobranca
    elseIf nTipo == 4 
    
           PLSA175RGR("BCI",nRecAtu,K_RetCob,nil,.f.,aFiltro,aThreads[nCont,4],aThreads,nCont,cOriMov,cNameUsr,"3",nil,nil,aPLS475)
           
           cTitulo := STR0057 //"Revalorização de Cobranca das PEGS concluída."
           
    //Revalorizar Cobranca e Cobranca
    elseIf nTipo == 5
     
           PLSA175RGR("BCI",nRecAtu,K_RetCP,nil,.f.,aFiltro,aThreads[nCont,4],aThreads,nCont,cOriMov,cNameUsr,"4",nDifUs,nVlrDifUs,aPLS475)
           
           cTitulo := STR0058 //"Revalorização de Cobrança e Pagamento das PEGS concluída."
           
    endIf  
               
next

putGlbvalue(aThreads[nCont,9], "1" )
glbUnLock()

return

/*/{Protheus.doc} PLSATUVGL
Atualiza dados das therads...  
@type function
@author PLSTEAM
@since 11.03.2003
@version 1.0
/*/
function PLSATUVGL(aThreads,nCont,nTotEventos,cTipo,nQtdEve,clocalAnalise,cAlias,cChave)
local nAuxTot  := val(getGlbvalue(aThreads[nCont,14]))+nQtdEve
local nAuxTot2 := val(getGlbvalue(aThreads[nCont,16]))+nQtdEve
local lGerarLog:= GetNewPar("MV_PLSLAMF","0") == "1"
local cFileLog := "PLSLGAMF.LOG"
local cTextoLog:= ""

default clocalAnalise 	:= ""                                                            
default cAlias 			:= ""
default cChave 			:= ""

if lGerarLog

   cTextoLog := "[" + aThreads[nCont,2] + "] " +;
   				if(cTipo == "1","[ Processado ]","[ Desconsid. ]")+;
                " Alias [" + cALias + "] Chave [" + cChave + "]"+;
                " Eventos Guia ["+ strZero(nQtdEve,6) + "]"+;
                " Eventos Totais ["+ strZero(if(cTipo=="1",nAuxTot,nAuxTot2),6) + "]" +;
                " Análise [" + clocalAnalise + "]"
                
   PlsLogFil(cTextoLog,cFileLog)
   
endIf   

//Somar nos processados
if cTipo == "1"    
                
   putGlbvalue(aThreads[nCont,14],allTrim(str(nAuxTot,10)))
   
//Somar nos desconsiderados
else 

   putGlbvalue(aThreads[nCont,16],allTrim(str(nAuxTot2,10)))
   
endIf

nAuxTot  := val(getGlbvalue(aThreads[nCont,14]))
nAuxTot2 := val(getGlbvalue(aThreads[nCont,16]))

putGlbvalue(aThreads[nCont,11], allTrim(str(((nAuxTot+nAuxTot2)*100)/nTotEventos,10)))
glbUnLock()

return

/*/{Protheus.doc} StatusProc
Analisa status do processamento e atualiza em tela.   
@type function
@author PLSTEAM
@since 11.03.2003
@version 1.0
/*/
static function StatusProc(aThreads,aRestTot,lrefresh,oBrowseSta,oDlg,oSay,cHoraIniT,cTipo)
local lSaida     := .t.   
local nCont  
local ltime      := .f.
default cTipo    := "1"

//cTipo == "1" - Temporizador de estatistica do processo em execucao
//cTipo == "2" - Temporizador para verificar se algum processo caiu (erro de conexao, erro fatal error.log)

if cTipo == "2"

   if empty(__cLasttime)
   
      FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0059+time()+"]" , 0, 0, {})//"Analisando status das Threads... ["

      __cLasttime := time()
   
   else
      FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0060+__cLasttime+STR0061+time()+"]" , 0, 0, {})//"Analisando status das Threads... Ultima execução em ["###"] Agora ["
   endIf  
    
endIf   

for nCont := 1 to len(aThreads)

    if aThreads[nCont,4] > 0

       if cTipo == "1" 

	      if getGlbvalue(aThreads[nCont,13]) == "1" //Theard houve algum problema em execucao
	         
	         aviso(STR0062,STR0063+aThreads[nCont,2]+STR0064,{STR0065},2) //"Problema na execução de Theard"###"Ocorreu algum problema na execução da Thread "###". Analise o console do Protheus para maiores informações"###"Ok"
	         aThreads[nCont,18] := STR0066 //"Cancelado"
	         
	      endIf   
	       
	      if getGlbvalue(aThreads[nCont,2]) == "1"
	         aThreads[nCont,3] := STR0050 //"Sim"
	      endIf
	         
	      if getGlbvalue(aThreads[nCont,9]) == "1" 
	      
	         aThreads[nCont,3] := STR0050 //"Sim"
	      
	         if empty(aThreads[nCont,7])
	      
	            aThreads[nCont,7]  := time()
	            aThreads[nCont,8]  := elaptime(aThreads[nCont,6],aThreads[nCont,7])
	            aThreads[nCont,10] := "BR_VERDE"
	            aThreads[nCont,5]  := getGlbvalue(aThreads[nCont,11])
	            aThreads[nCont,15] := getGlbvalue(aThreads[nCont,14])
	            aThreads[nCont,17] := getGlbvalue(aThreads[nCont,16])
	            
	            if lrefresh .and. ! ltime
	               oSay:cCaption := STR0036+aThreads[nCont,8] //"Tempo de Processamento: "
	               oSay:refresh()        
	               ltime := .t.
	            endIf
	               
	         endIf
	                                                                          
	      else
	      
	         lSaida := .f.
	      
	         aThreads[nCont,8] 	:= elaptime(aThreads[nCont,6],time())             
	         aThreads[nCont,5] 	:= getGlbvalue(aThreads[nCont,11])
	         aThreads[nCont,15] := getGlbvalue(aThreads[nCont,14])   
	         aThreads[nCont,17] := getGlbvalue(aThreads[nCont,16])
	         
	         if lrefresh .and. ! ltime
	         
	            oSay:cCaption 	:= STR0036 + elaptime(cHoraIniT,time())              //"Tempo de Processamento: "
	            ltime 			:= .t.
	            oSay:refresh()
	            
	         endIf
	            
	      endIf   
	      
	   else        
	    
          if val(aThreads[nCont,5]) < 100
          
             if aThreads[nCont,19] == 0 .and. aThreads[nCont,20] == 0 .and. ! aThreads[nCont,21]
                aThreads[nCont,19] := val(aThreads[nCont,15])                            
                aThreads[nCont,20] := val(aThreads[nCont,17])                                    
                aThreads[nCont,21] := .t.
                
             else
             
                if ( aThreads[nCont,19] == val(aThreads[nCont,15]) ) .and. ( aThreads[nCont,20] == val(aThreads[nCont,17]) )
                    putGlbvalue(aThreads[nCont,13], "1" ) //Nao foi atualizada e gerou time-out
                    aThreads[nCont,18] := STR0066 //"Cancelado"
                endIf    
                
             endIf
                
          endIf
             
	   endIf
	      
	endIf
	   
next           

aRestTot := {}

for nCont := 1 to len(aThreads)

    if aThreads[nCont,4] > 0
    
       aadd(aRestTot,{aThreads[nCont,10],;
                     aThreads[nCont,2],;
                     aThreads[nCont,3],;
                     aThreads[nCont,4],;
                     aThreads[nCont,6],;
                     aThreads[nCont,7],;
                     aThreads[nCont,8],;
                     aThreads[nCont,5],;
                     aThreads[nCont,18],; //era 13
                     aThreads[nCont,15],;
                     aThreads[nCont,17]})
                     
    endIf           
          
next          

if lrefresh
   oBrowseSta:setArray(aRestTot)        
   oBrowseSta:refresh()
endIf   

return(lSaida)

/*/{Protheus.doc} TestaFecha
Verifica se e possivel fechar a janela ou nao.   
@type function
@author PLSTEAM
@since 11.03.2003
@version 1.0
/*/
static function TestaFecha(oDlg,aThreads)
local nFor
local lFlag := .t.

for nfor := 1 to len(aThreads)

    if aThreads[nFor,4] > 0 .and. aThreads[nFor,10] <> "BR_VERDE" .and. allTrim(aThreads[nFor,18]) <> STR0066 
       lFlag := .f.
    endIf
    
next

if ! lFlag 
   msgStop(STR0068) //"Existem Threads Pendentes a Rotina não poderá ser finalizada."
else
   oDlg:End()
endIf
       
return