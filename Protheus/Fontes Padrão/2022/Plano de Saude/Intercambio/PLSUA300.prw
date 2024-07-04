#include "PLSMGER.CH"
#INCLUDE "PROTHEUS.CH"
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLSUA300  ╨Autor  ЁThiago Machado Correa ╨ Data Ё  22/06/04   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё PTU - A300 - Movimentacao Cadastral de Usuarios / Produtos   ╨╠╠
╠╠╨          Ё                                                              ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP6 - Pls                                                    ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function PLSUA300(lAuto)
LOCAL cDirNov 
LOCAL nX
LOCAL nVer
LOCAL nCri
LOCAL cAlert	 := ""
LOCAL aCriPla	 := {}
LOCAL lCont		 := .T.
LOCAL cKey		 := ""
LOCAL cCodLay	 := ""
PRIVATE cPerg    := "PLSU03"
PRIVATE cBA1Name := RetSQLName("BA1")
PRIVATE cBI3Name := RetSQLName("BI3")
PRIVATE cBF1Name := RetSQLName("BF1")
PRIVATE cBF4Name := RetSQLName("BF4")
PRIVATE cBT5Name := RetSQLName("BT5")
PRIVATE cBX1Name := RetSQLName("BX1")
PRIVATE cBX2Name := RetSQLName("BX2")
PRIVATE cDatBlo  := "        "
PRIVATE cNomArq
PRIVATE cQuery
PRIVATE cCodEmp
PRIVATE cCPF
PRIVATE cCPFTit
PRIVATE cChave1
PRIVATE cChave2
PRIVATE cTipPes
PRIVATE cR304
PRIVATE cR306
PRIVATE cSexo
PRIVATE cEstCiv
PRIVATE cGraDep
PRIVATE cCodTit
PRIVATE cSeq
PRIVATE cProxSeq
PRIVATE cUniOri
PRIVATE cUniDes
PRIVATE dDatIni
PRIVATE dDatFin
PRIVATE dDatBlo
PRIVATE cDatIncTit
PRIVATE cEmpIni
PRIVATE cEmpFin
PRIVATE cTipEnv
PRIVATE lEnvTit
PRIVATE cIdaLim
PRIVATE cCodDep
PRIVATE cCDepEx
PRIVATE cTipPla
PRIVATE cTipSeg   := ""
PRIVATE cQryPla   := ""
PRIVATE aTipPla   := {}
PRIVATE cVerPla
PRIVATE cDatIncEmp
PRIVATE cIncPla
PRIVATE cIncPro
PRIVATE nVlrMen
PRIVATE cCodAnt
PRIVATE cEmpres
PRIVATE cTpPess
PRIVATE cMatFam
PRIVATE cContra 
PRIVATE cSbCont 
PRIVATE cEnd
PRIVATE cBai
PRIVATE cCep
PRIVATE cMun
PRIVATE cEst
PRIVATE cCodMun
PRIVATE cEndTit
PRIVATE cBaiTit
PRIVATE cCepTit
PRIVATE cMunTit
PRIVATE cEstTit
PRIVATE cNumRes302  
PRIVATE aStru   := {}
PRIVATE aTipEnv := {"A","M","P"}
PRIVATE nTot302 := 0
PRIVATE nTot304 := 0
PRIVATE nTot306 := 0
PRIVATE cCnpjPC
PRIVATE cInsEstPC
PRIVATE cEndPriPC
PRIVATE cBairroPC
PRIVATE cCepPC
PRIVATE cCidadePC
PRIVATE cUfPC
PRIVATE cDddPC
PRIVATE cTelPC
PRIVATE cFaxPC
PRIVATE cTipAco
//Criada Variavel para nЦo apresentar erro no conteudo inicializador padrao ao exportar o arquivo
PRIVATE Inclui := .T.
PRIVATE lEstSC
PRIVATE lEnvRend := .F.
PRIVATE cAnoBenef  
PRIVATE lGerR302:=.F.
PRIVATE lBA1PIPAMA := BA1->(FieldPos("BA1_PIPAMA")) > 0
PRIVATE oTempTable  

if valtype(lAuto) <> 'L'
	lAuto := .f.
endif

BA0->(DBSetOrder(1)) // Operadora
BG9->(DBSetOrder(1)) // Empresa
BI3->(DBSetOrder(1)) // Produto
BT3->(DBSetOrder(1)) // Produtos relacionados
BRP->(DBSetOrder(1)) // Grau de Parentesco
BA1->(DBSetOrder(2)) // Usuario
BA3->(DBSetOrder(1)) // Familia
BM1->(DBSetOrder(3)) // Composicao da Cobranca
BF1->(DBSetOrder(1)) // Opcionais da Familia
BF4->(DBSetOrder(1)) // Opcionais do Usuario
BTS->(DBSetOrder(1)) // Vida
BT5->(DBSetOrder(1)) // Contrato
BQC->(DBSetOrder(1)) // Sub-Contrato
BN5->(DBSetOrder(1)) // Padroes de Conforto           
BX1->(DBSetOrder(1)) // Cabecalhos Log de Alteracoes  

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Cria arquivo temporario...				                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aadd(aStru,{"CODINT","C",04,0})
aadd(aStru,{"CODEMP","C",04,0})
aadd(aStru,{"MATRIC","C",06,0})
aadd(aStru,{"TIPREG","C",02,0})
aadd(aStru,{"DIGITO","C",01,0})
aadd(aStru,{"INCPRO","C",08,0})
aadd(aStru,{"TPPESS","C",01,0})
aadd(aStru,{"KEYBEN","C",19,0})
/*aadd(aStru,{"CODPRO","C",04,0})
aadd(aStru,{"VERPRO","C",03,0})*/
aadd(aStru,{"DTBLOP","C",08,0})
aadd(aStru,{"CONTRA","C",12,0}) //Contrato
aadd(aStru,{"SBCONT","C",09,0}) //Subcontrato

//--< CriaГЦo do objeto FWTemporaryTable >---
oTempTable := FWTemporaryTable():New( "Tmp" )
oTempTable:SetFields( aStru )
oTempTable:AddIndex( "INDTMP",{ "CODINT","CODEMP","MATRIC","TIPREG" } )

if( select( "Tmp" ) > 0 )
	TMP->( dbCloseArea() )
endIf

oTempTable:Create()

DbSelectArea("Tmp")
Tmp->(DbSetorder(1))
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁPergunta																							Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lAuto .or. Pergunte(cPerg,.T.)
	cUniOri := mv_par01 		  //Unimed Origem
	cUniDes := mv_par02 		  //Unimed Destino
	cEmpIni := mv_par03 		  //Empresa Inicial
	cEmpFin := mv_par04 		  //Empresa Final
	dDatIni := mv_par05			  //Movimento Inicial
	dDatFin := mv_par06 		  //Movimento Final
	cTipSeg := AllTrim(mv_par07)  //Cod. Edi
	cTipPla := mv_par08			  //Produto/Versao
	cTipEnv := aTipEnv[mv_par09] //Tipo de Envio
	cDirNov := mv_par10
	lEnvTit := Iif(mv_par11==1,.T.,.F.)
	cIdaLim := mv_par12
	cCodDep := StrTran(mv_par13,"'","")
	cCDepEx := StrTran(mv_par14,"'","")
	dDatBlo := mv_par15
	cCodLay := mv_par16
	lEstSC  := Iif(mv_par17==2,.T.,.F.)
	If AllTrim(cCodLay) >= "A300F"
		lEnvRend:= Iif(mv_par18==2,.T.,.F.)
	EndIf
    
	If Empty(cTipSeg)
		MsgInfo("и necessАrio preencher o cСdigo EDI para a geraГЦo do arquivo.")  
		if( select( "TMP" ) > 0 )
			oTempTable:Delete()
		endIf
		Return nil
	EndIf	
	
	//Tratamento dos produtos selecionados  
	If !Empty(cTipPla)
		aTipPla := StrTokArr(cTipPla,",")
		nVer := 1
		For nVer := 1 to Len(aTipPla)
			aTipPla[nVer] := StrTokArr(aTipPla[nVer],'/')
		Next nVer
		
		For nX := 1 to Len(aTipPla)
			If BI3->( MsSeek(xFilial("BI3")+cUniOri+padr(aTipPla[nX][1],TamSX3("BI3_CODIGO")[1])+padr(aTipPla[nX][2],TamSX3("BI3_VERSAO")[1])) )
				If AllTrim(BI3->BI3_TPREDI) == ""
					aAdd(aCriPla,"CСdigo PTU do Seguro nЦo cadastrado! - " + BI3->BI3_CODIGO+'/'+BI3->BI3_VERSAO)
					aAdd(aTipPla[nX]," ")
				Else
					aAdd(aTipPla[nX],SubStr(AllTrim(BI3->BI3_TPREDI)+" ",1,1))
				Endif
			Else
				aAdd(aCriPla,"Seguro nЦo encontrado - " + BI3->BI3_CODIGO+'/'+BI3->BI3_VERSAO)
				aAdd(aTipPla[nX]," ")
			Endif	
		Next nX
		
		//Insiro as informacoes dos produtos em uma string em formato Sql para a execucao da Query
		For nX := 1 to Len(aTipPla)
			cQryPla += aTipPla[nX][1] + ","
		Next nX
		//Removo a virgula do final da string
		cQryPla := Substr(cQryPla,1,Len(cQryPla)-1)
		
		cQryPla := FormatIN(cQryPla,",")
	Else
		BI3->(DbGoTop())
		While !BI3->(Eof())
	        If Alltrim(BI3->BI3_TPREDI) ==  Alltrim(cTipSeg)
	        	cQryPla += BI3->BI3_CODIGO + ","
	        EndIf	
	    	BI3->(DbSkip())
		Enddo  
		//Removo a virgula do final da string
		cQryPla := Substr(cQryPla,1,Len(cQryPla)-1)
		cQryPla := FormatIN(cQryPla,",")
	EndIf
	
	If Len(aCriPla) > 0
		For nCri := 1 to Len(aCriPla)
			cAlert += aCriPla[nCri]+CHR(13)+CHR(10)
		Next
		MsgAlert(cAlert)
		lCont := .F.
	Endif
	
	If lCont
		
		MsAguarde( {|| Plsua300Prep(lAuto) }, "Aguarde...","Preparando ambiente.", .T.)
		
		Tmp->(DbGoTop())
		
		If Tmp->(EOF())
			MsgStop("Nenhum registro encontrado para os parametros informados.")
		Else
			cEmpres := Tmp->CodEmp
			cTpPess := Tmp->TpPess
			cMatFam := Tmp->(CodInt+CodEmp+Matric)
			cContra := Tmp->Contra
			cSbCont := Tmp->SbCont
			
			cNomArq := cTipSeg + substr(dtos(dDatabase),7,2) + substr(dtos(dDatabase),5,2) + substr(dtos(dDatabase),3,2) + cSeq + "." + Substr(cUniOri,2,3)
			PlsPTU(mv_par16,cNomArq,cDirNov,!lAuto)
		EndIf
		
	EndIf
	
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fecha arquivo temporario...                                              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
if( select( "TMP" ) > 0 )
	oTempTable:Delete()
endIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Plsua300Prep

@author PLS TEAM
@since  07/12/2016
@version P11
/*/
//-------------------------------------------------------------------
Function Plsua300Prep(lAuto)
LOCAL nQtd 		:= 0
LOCAL lTemDep	:= .F.
LOCAL lBloInc   := .F.
LOCAL cDatTra   := ""
LOCAL lLoop		:= .F.
LOCAL lPLSPA300 := ExistBlock("PLSPA300")
//здддддддддддддддддддддддддддддд©
//Ё Cria a Query principal...    Ё
//юдддддддддддддддддддддддддддддды
cQuery := "  SELECT BA1_DATINC,BA1_DATBLO,BA1_TRAORI,BA1_DATTRA,BA1_CODINT,BA1_CODEMP,BA1_MATRIC,BA1_TIPREG,BA1_GRAUPA,BA1_DATNAS, "
cQuery += "          BA1_DIGITO,"+cBA1Name+".R_E_C_N_O_ AS BA1_RECNO, BA1_CONEMP CONTRA, BA1_SUBCON SBCONT, "
cQuery += "    		BF4_DATBAS, BF4_DATBLO, BF4_CODPRO, BF4_VERSAO   "
cQuery += "    FROM " + cBA1Name + ", " + cBF4Name
cQuery += "	  WHERE BA1_FILIAL = '" + xFilial("BA1") + "' "
cQuery += "		AND BA1_CODINT = '" + cUniOri + "' "
cQuery += "		AND BA1_CODEMP BETWEEN '" + cEmpIni + "' AND '" + cEmpFin + "' "
cQuery += "		AND " + cBA1Name + ".D_E_L_E_T_ = ' ' "
//здддддддддддддддддддддддддддддд©
//Ё Somente Ativos			     Ё
//юдддддддддддддддддддддддддддддды
If cTipEnv == "A"
	cQuery  += " AND ( BA1_DATBLO >= '"+ DtoS(dDatBlo) + "' OR BA1_DATBLO = '        ' )  "
EndIf
cQuery += "		AND BF4_FILIAL = '" + xFilial("BF4") + "' "
cQuery += "		AND BF4_CODINT = BA1_CODINT "
cQuery += "		AND BF4_CODEMP = BA1_CODEMP "
cQuery += "		AND BF4_MATRIC = BA1_MATRIC "
cQuery += "		AND BF4_TIPREG = BA1_TIPREG "
cQuery += "		AND BF4_CODPRO IN " + cQryPla
cQuery += "		AND BF4_A300 <> '0' "
cQuery += "		AND " + cBF4Name + ".D_E_L_E_T_ = ' ' "
//здддддддддддддддддддддддддддддд©
//Ё Somente Ativos			     Ё
//юдддддддддддддддддддддддддддддды
If cTipEnv == "A"
	cQuery  += " AND ( BF4_DATBLO >= '"+ DtoS(dDatBlo) + "' OR BF4_DATBLO = '        ' ) "
EndIf
cQuery += " ORDER BY BA1_CODINT, BA1_CODEMP, BA1_CONEMP, BA1_SUBCON, BA1_MATRIC, BA1_TIPREG "

If ExistBlock("PT300QRY")
	cQuery := ExecBlock("PT300QRY",.F.,.F.,{cQuery})
EndIf

cQuery    := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY",.F.,.T.)    

TCSetField("QRY","BA1_DATBLO", "D", 8,0)
TCSetField("QRY","BA1_DATNAS", "D", 8,0)
TCSetField("QRY","BF4_DATBAS", "D", 8,0)
TCSetField("QRY","BF4_DATBLO", "D", 8,0)
TCSetField("QRY","BA1_DATTRA", "D", 8,0)

cKey := QRY->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_GRAUPA+BA1_DIGITO)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alimenta arquivo principal...					                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
While ! QRY->(EOF())
	nQtd++

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Msg de Processamento										 			 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	if !lAuto
		MsProcTXT( "Proc. Usu.: "+Transform( QRY->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),"@R !!!!.!!!!.!!!!!!.!!-!" ) + "   Qtd.: " + StrZero(nQtd,5) )
		ProcessMessage()
	endif

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verfica se o registro ja existe								 			 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
	If cKey == QRY->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_GRAUPA+BA1_DIGITO) .And. lLoop
		QRY->(dbSkip())
		Loop
	Endif
    
    cKey := QRY->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_GRAUPA+BA1_DIGITO)
    
	If QRY->BA1_TIPREG == "00"	
		If !lEnvTit 				
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Se !lEnvTit = .T., so pode enviar titulares que possuam dependentes.     Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			cQuery  := " SELECT BA1_FILIAL, BA1_DATNAS, BA1_GRAUPA " 
			cQuery 	+= " FROM " + cBA1Name  + ", " + cBF4Name 
			cQuery  += " WHERE BA1_FILIAL = '" + xFilial("BA1")  + "' "
			cQuery  += "   AND BA1_CODINT = '" + QRY->BA1_CODINT + "' "
			cQuery  += "   AND BA1_CODEMP = '" + QRY->BA1_CODEMP + "' "
			cQuery  += "   AND BA1_MATRIC = '" + QRY->BA1_MATRIC + "' "
			cQuery  += "   AND BA1_TIPREG <> '00' "                    
			If cTipEnv == "P"
				cQuery  += "   AND BA1_DATINC >= '"+DtoS(dDatIni)+"' "
				cQuery  += "   AND BA1_DATINC <= '"+DtoS(dDatFin)+"' "
			Endif
			cQuery  += "   AND "+ cBA1Name +".D_E_L_E_T_ = ' ' "
			If cTipEnv == "A"
				cQuery  += " AND ( BA1_DATBLO >= '"+ DtoS(dDatBlo) + "' OR BA1_DATBLO = '        ' )  "
			EndIf                                        
			If !Empty(cCDepEx)
				cQuery  += " AND BA1_GRAUPA NOT IN ('" + AllTrim(StrTran(cCDepEx,",","','")) + "' ) "	
			EndIf
			cQuery += "		AND BF4_FILIAL = '" + xFilial("BF4") + "' "
			cQuery += "		AND BF4_CODINT = BA1_CODINT "
			cQuery += "		AND BF4_CODEMP = BA1_CODEMP "
			cQuery += "		AND BF4_MATRIC = BA1_MATRIC "
			cQuery += "		AND BF4_TIPREG = BA1_TIPREG "
			cQuery += "		AND BF4_CODPRO IN " + cQryPla
			cQuery += "		AND BF4_A300 <> '0' "
			cQuery += "		AND " + cBF4Name + ".D_E_L_E_T_ = ' ' "   
			//здддддддддддддддддддддддддддддд©
			//Ё Somente Ativos			     Ё
			//юдддддддддддддддддддддддддддддды
			If cTipEnv == "A"
				cQuery  += " AND ( BF4_DATBLO >= '"+ DtoS(dDatBlo) + "' OR BF4_DATBLO = '        ' ) "
			EndIf

			cQuery    := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"PLSTRB",.F.,.T.)
			
			TCSetField("PLSTRB","BA1_DATNAS", "D", 8,0)
					
			If PLSTRB->(Eof())
				PLSTRB->(DbCloseArea())
				QRY->(DbSkip())			
				Loop
			Else                          
				lTemDep := .F.
				If !Empty(cIdaLim) .And. Val(cIdaLim) > 0
					While ! PLSTRB->(Eof())					
				    	If PLSTRB->BA1_GRAUPA $ cCodDep .And. Int((dDataBase-PLSTRB->BA1_DATNAS)/365) > Val(cIdaLim)
						  	PLSTRB->( DbSkip() )	
						  	Loop
					   	Else
					   		lTemDep := .T.
					   		Exit
				       	EndIf
				 	EndDo
					If ! lTemDep               
						PLSTRB->(DbCloseArea())					
						QRY->(DbSkip())			
						Loop	
					EndIf	
				EndIf    	   			
			EndIF
			PLSTRB->(DbCloseArea())					
		EndIf
	Else  
		//зддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Checa idade limite para dependencia			    Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддды
	    If !Empty(cIdaLim) .And. Val(cIdaLim) > 0
	       If QRY->BA1_GRAUPA $ cCodDep .And. Int((dDataBase-QRY->BA1_DATNAS)/365) > Val(cIdaLim)
			  QRY->( DbSkip() )	
			  Loop
	       EndIf
	    EndIf
		//зддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Checa quais dependentes vao sair na exportacao	Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддды
		If !Empty(cCDepEx)
		    If QRY->BA1_GRAUPA $ cCDepEx 
			   QRY->( DbSkip() )	
			   Loop
		    EndIf
		EndIf    
	EndIf
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Ponto de Entrada ...                            Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддды
	If lPLSPA300
		If ExecBlock("PLSPA300",.F.,.F.)
			QRY->( DbSkip() )
			Loop
		Endif
	Endif       

	cIncPro := DtoS(QRY->BF4_DATBAS)	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica data de inclusao...						                     Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If Empty(cIncPro) .Or. StoD(cIncPro) > dDatFin
		QRY->( DbSkip() )
		Loop
	Endif
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Pula usuarios sem Inclusao, Exclusao ou Alteracao no Periodo...          Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If cTipEnv == "P"
	    lBloInc := .F.
		cDatBlo := Space(8)
		cDatTra := Space(8)
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Alimenta data de bloqueio do usuario...   							     Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If !Empty(QRY->BA1_DATBLO)
			cDatBlo := DtoS(QRY->BA1_DATBLO)
			lBloInc := .T.
		EndIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Alimenta data de bloqueio do usuario... pelo opcional				     Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Empty(cDatBlo) .And. !Empty(QRY->BF4_DATBLO)
			cDatBlo := DtoS(QRY->BF4_DATBLO)
			lBloInc := .T.
		EndIf
	
		//Se o bloqueio ocorreu fora do periodo solicitado, nao envio o registro.
		If  ! Empty(cDatBlo) .And. (cDatBlo < DtoS(dDatIni) .Or. cDatBlo > DtoS(dDatFin))
			QRY->( DbSkip() )
			Loop
		Endif  
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica se usuario foi transferido             	                     Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If !Empty(QRY->BA1_TRAORI) .And. !Empty(QRY->BA1_DATTRA)
		    cDatTra  := DtoS(QRY->BA1_DATTRA)
            If  ! Empty(cDatTra) .And. (cDatTra >= DtoS(dDatIni) .And. cDatTra <= DtoS(dDatFin))   
                lBloInc := .T.
            EndIf
		EndIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica se usuario foi incluido no periodo                              Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If (QRY->BA1_DATINC) >= DtoS(dDatIni) .And. (QRY->BA1_DATINC) <= DtoS(dDatFin)
		    lBloInc := .T.
		EndIf    
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica se usuario teve alteracao no periodo...	                     Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If StoD(QRY->BA1_DATINC) < dDatIni .Or. StoD(QRY->BA1_DATINC) > dDatFin
			cQryLog  := " SELECT COUNT(*) QTD FROM " + cBX1Name + "," + cBX2Name
			cQryLog  += " WHERE BX1_FILIAL = '" + xFilial("BX1") + "' "
			cQryLog  += "   AND BX2_FILIAL = '" + xFilial("BX2") + "' "         					
			cQryLog  += "   AND BX1_ALIAS  = 'BA1' "
			cQryLog  += "   AND BX1_TIPO   = 'A' "
			cQryLog  += "   AND BX1_DATA   >= '" + DtoS(dDatIni) + "' "
			cQryLog  += "   AND BX1_DATA   <= '" + DtoS(dDatFin) + "' "
			cQryLog  += "   AND BX1_RECNO  = '" + Strzero( QRY->( BA1_RECNO ),len(BX1->BX1_RECNO) ) + "' "
			cQryLog  += "   AND "+ cBX1name + ".D_E_L_E_T_ = ' ' "  
			cQryLog  += "   AND "+ cBX2name + ".D_E_L_E_T_ = ' ' "
			cQryLog  += "   AND "+ cBX1Name +".BX1_SEQUEN = "+cBX2Name+".BX2_SEQUEN"		
			cQryLog := ChangeQuery(cQryLog)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryLog),"QRYLOG",.F.,.T.)   
	        
			If !lBloInc .And. QRYLOG->QTD == 0
			    QRYLOG->(DbCloseArea())
				QRY->(DbSkip())
				Loop
			Endif
			QRYLOG->(DbCloseArea())
		Endif
	Endif
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona na familia													 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BA3->( MsSeek( xFilial("BA3")+QRY->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC) ) )
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Grava arquivo temporario...						                         Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Tmp->( Reclock("Tmp",.T.) )
	Tmp->CodInt := QRY->BA1_CODINT
	Tmp->CodEmp := QRY->BA1_CODEMP
	Tmp->Matric := QRY->BA1_MATRIC
	Tmp->TipReg := QRY->BA1_TIPREG
	Tmp->Digito := QRY->BA1_DIGITO
	Tmp->Contra := QRY->CONTRA
	Tmp->SbCont := QRY->SBCONT
	Tmp->IncPro := cIncPro
	Tmp->TpPess := BA3->BA3_TIPOUS
	Tmp->DtBlOp := DtoS(QRY->BF4_DATBLO)
	Tmp->KeyBen := cKey
	
	Tmp->( MsUnlock() )
	
	lLoop := .T.
	
	QRY->( DbSkip() )

Enddo
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fecha arquivo QRY									                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
QRY->( DbCloseArea() )
if !lAuto
	MsProcTXT("Montando Arquivo...")
	ProcessMessage()
endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alimenta sequencial para nome do arquivo...		                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If BA0->(MsSeek(xFilial("BA0")+cUniDes))
	
	cSeq := BA0->BA0_A300
	
	If substr(cSeq,1,8) == dtos(dDatabase)
		If val(substr(cSeq,9,1)) < 9
			cProxSeq := strzero(val(substr(cSeq,9,1))+1,1)
			cSeq     := cProxSeq
		Else
			cProxSeq := "0"
			cSeq     := "9"
		Endif
	Else
		cProxSeq := "1"
		cSeq     := cProxSeq
	Endif
	
	BA0->(Reclock("BA0",.F.))
	BA0->BA0_A300 := dtos(dDatabase) + cProxSeq
	BA0->(MsUnlock())
	
Else
	MsgAlert("Unimed Destino nao encontrada!")
	cSeq := "0"
Endif

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidaR302

@author PLS TEAM
@since  07/12/2016
@version P11
/*/
//-------------------------------------------------------------------
Function ValidaR302()
LOCAL lRetorno, nReg, lPosic
LOCAL aRet      := {} 
LOCAL aRetEmp   := {}
LOCAL lOKEmp    := .F.  
LOCAL lValidOld := .F.
LOCAL lCaepf    := BQC->(FieldPos("BQC_CAEPF")) > 0
Local cCAEPF    := ""
Local cCNPJCEI  := ""

BA3->(DbsetOrder(1))
BA1->(DbsetOrder(2))
BG9->(DbsetOrder(1))
BI3->(DbsetOrder(1))
BID->(DbsetOrder(2))

lRetorno := .T.
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona Grupo/Empresa...												 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ! BG9->( MsSeek( xFilial("BG9")+Tmp->(CodInt+CodEmp) ) )
	lRetorno := .F.
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona Familia...													 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !BA3->( MsSeek( xFilial("BA3")+Tmp->(CodInt+CodEmp+Matric) ) )
	lRetorno := .F.
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona Usuario...													 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ! BA1->( MsSeek( xFilial("BA1")+Tmp->(CodInt+CodEmp+Matric+TipReg) ) )
	lRetorno := .F.
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona Produto...							                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ! BI3->( MsSeek( xFilial("BI3")+BA1->(BA1_CODINT+BA1_CODPLA+BA1_VERSAO) ) )
	If ! BI3->( MsSeek( xFilial("BI3")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO) ) )
		lRetorno := .F.
	Endif
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona Produtos relacionados...				                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
lRetorno := A300VldOpc()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona Vida...								                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If  BTS->( MsSeek( xFilial("BTS")+BA1->BA1_MATVID ) )
	cNomCart := BTS->BTS_NOMCAR
	cNumCart := BTS->BTS_NRCRNA
Else
	lRetorno := .F.   
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se OK															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lRetorno
	lPosic := .F.
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Alimenta dados do usuario titular...	 							     Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If BA1->BA1_TIPREG <> "00"
		lPosic := .T.
		nReg   := BA1->( Recno() )
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Posiciona Usuario Titular...											 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If ! BA1->(MsSeek(xFilial("BA1")+Tmp->(CodInt+CodEmp+Matric)+"00"))
			lRetorno := .F.
		Endif
	Endif
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona Familia...													 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If ! BA3->( MsSeek( xFilial("BA3")+Tmp->(CodInt+CodEmp+Matric) ) )
		lRetorno := .F.
	Endif
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica se e Pessoa Juridica											 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If Tmp->TpPess == "2"
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Posiciona Contrato...							                         Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If !BT5->( MsSeek( xFilial("BT5")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON) ) )
			lRetorno := .F.
		EndIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Posiciona Sub-Contrato...						                         Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If !BQC->( MsSeek( xFilial("BQC")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB) ) )
			lRetorno := .F.
		Endif
	EndIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica se OK															 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If lRetorno
		If BN5->(MsSeek(xFilial("BN5")+ BI3->(BI3_CODINT + BI3_PADSAU))) .And. BN5->(FieldPos("BN5_CODPTU")) > 0    
			cTipAco := PadR(BN5->BN5_CODPTU,2) 
		Else
			cTipAco := Space(2)			 
		EndIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Retorno de registros do SA1 conforme forma de cobranca					 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If BG9->BG9_TIPO == "1" //Pessoa Fisica
			
			aRet := PLSRETNCB(BA1->BA1_CODINT,BA1->BA1_CODEMP,BA1->BA1_MATRIC,BA1->BA1_OPEORI)
			
			//Posiciona Operadora para buscar o endereco quando a empresa for tipo Pessoa Fisica
			BA0->(MsSeek(xFilial("BA0")+BA1->BA1_CODINT))
			
			cCnpjPC 	:= StrZero( Val(BA0->BA0_CGC),15 )
			cInsEstPC	:= StrZero( Val(BA0->BA0_INCEST),20 )
			cEndPriPC	:= PlRetponto(PadR(AllTrim(BA0->BA0_END)+Space(1)+AllTrim(BA0->BA0_NUMEND)+;
							Space(1)+AllTrim(BA0->BA0_COMPEN),40))
			cBairroPC	:= PlRetponto(AllTrim( BA0->BA0_BAIRRO )+Space( ( 30-Len(AllTrim(BA0->BA0_BAIRRO)) ) ))
			cCepPC		:= StrZero( Val(BA0->BA0_CEP),8 )
			cCidadePC	:= AllTrim( BA0->BA0_CIDADE )+Space( ( 30-Len(AllTrim(BA0->BA0_CIDADE)) ) )
			cUfPC		:= AllTrim( BA0->BA0_EST )+Space( ( 2-Len(AllTrim(BA0->BA0_EST)) ) )
			cDddPC		:= StrZero( Val(BA0->BA0_DDD),4 )
			cTelPC		:= StrZero( Val(SubStr(BA0->BA0_TELEF1,1,9)),9 )
			cFaxPC		:= StrZero( Val(SubStr(BA0->BA0_FAX1,1,9)),9 )
			cCodMun		:= StrZero( Val(BA0->BA0_CODMUN),7 )
			cNumRes302  := IIF(Empty(BA0->BA0_NUMEND),Padr("S/N",6),Padr(BA0->BA0_NUMEND,6)) 
			
		Else
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	   		//Ё Para PJ vou buscar um nivel de cobranca valido para posicionar no clienteЁ    
   	   		//Ё SA1 e extrair as informacoes  											 Ё	
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды   
			BQC->(DbSetOrder(1))
			BT5->(DbSetOrder(1))
			SA1->(DbSetOrder(1))
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	   		//Ё BQC - SubContrato		   												 Ё
	   		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If BQC->(DbSeek(xFilial("BQC")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB))) .And. BQC->BQC_COBNIV == "1" .And.  ! Empty(BQC->BQC_CODCLI)
				cCodCli := BQC->BQC_CODCLI
             	cLoja   := BQC->BQC_LOJA
             	lOKEmp  := .T.
            //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	   		//Ё BT5 - Contrato		  	 												 Ё
	   		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            ElseIf BT5->(MsSeek(xFilial("BT5")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON))) .And. BT5->BT5_COBNIV == "1" .And. !Empty(BT5->BT5_CODCLI)
             
            	If BT5->BT5_INTERC == "1" .And. AllTrim(BT5->BT5_TIPOIN) == GetNewPar("MV_PLSCDIE","1")// Eventual
                	BA0->(DbSetOrder(1))
                	If BA0->(MsSeek(xFilial("BA0")+cOpeOri)) .And. ! Empty(BA0->BA0_CODCLI)
                    	cCodCli := BA0->BA0_CODCLI
                   		cLoja   := BA0->BA0_LOJA
                   		lOKEmp  := .T.

                 	   BA0->(DbSetOrder(nOrdBA0))
                    	BA0->(DbGoTo(nRecBA0))
                	Endif
             	Else
	                cCodCli := BT5->BT5_CODCLI
	                cLoja   := BT5->BT5_LOJA
	                lOKEmp  := .T.
                EndIf 
            //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	   		//Ё BG9 - Grupo Empresa	  	 												 Ё
	   		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            ElseIf !Empty(BG9->BG9_CODCLI)
            	cCodCli := BG9->BG9_CODCLI
             	cLoja   := BG9->BG9_LOJA
             	lOKEmp  := .T.   
            //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	   		//Ё Se nao achou, faz a validacao antiga    								 Ё
	   		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды 	
            Else
            	aRet := PLSRETNCB(BA1->BA1_CODINT,BA1->BA1_CODEMP,BA1->BA1_MATRIC,BA1->BA1_OPEORI,.F.) 
			
            	BID->(MsSeek(xFilial("BID") + SA1->A1_MUN))                                  
			
				If aRet[1]
                    If lCaepf
                        cCnpjPC := StrZero( Val(IIF(!Empty(BQC->BQC_CAEPF),BQC->BQC_CAEPF,aRet[7])),15 )
					Else
                        cCnpjPC := StrZero( Val(IIF(!Empty(BQC->BQC_CNPJ),BQC->BQC_CNPJ,aRet[7])),15 )
                    EndIF
					cInsEstPC	:= StrZero( Val(aRet[8]),20 )
					cEndPriPC	:= AllTrim( aRet[9] ) +Space( ( 40-Len(AllTrim(aRet[9])) ) )
					cBairroPC	:= AllTrim( aRet[10] )+Space( ( 30-Len(AllTrim(aRet[10])) ) )
					cCepPC		:= StrZero( Val(aRet[11]),8 )
					cCidadePC	:= AllTrim( aRet[12] )+Space( ( 30-Len(AllTrim(aRet[12])) ) )
					cUfPC		:= AllTrim( aRet[13] )+Space( ( 2-Len(AllTrim(aRet[13])) ) )
					cDddPC		:= StrZero( Val(aRet[14]),4 )
					cTelPC		:= StrZero( Val(SubStr(aRet[15],1,9)),9 )
					cFaxPC		:= StrZero( Val(SubStr(aRet[16],1,9)),9 )
					cCodMun 	:= StrZero( Val(BID->BID_CODMUN),7)
					cNumRes302  := IIF(Empty(BQC->BQC_NUMERO),Padr("S/N",6),Padr(BQC->BQC_NUMERO,6))
				EndIf 
				lValidOld := .T.	
            EndIf 
      		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	   		//Ё Busca o cliente		  	 												 Ё
	   		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            cCNPJCEI := IIF(!Empty(BQC->BQC_CNPJ),BQC->BQC_CNPJ,IIF(!EMPTY(SA1->A1_CEINSS),SA1->A1_CEINSS,SA1->A1_CGC))            
            If lCaepf
                cCAEPF   := IIF(!EMPTY(BQC->BQC_CAEPF),BQC->BQC_CAEPF,cCNPJCEI)
            EndIF

            If lOKEmp .And. SA1->(MsSeek(xFilial("SA1")+cCodCli+cLoja))
            	BID->(MsSeek(xFilial("BID") + SA1->A1_MUN))
            	aRetEmp := {IIF(!Empty(cCAEPF),cCAEPF,cCNPJCEI),;
            				SA1->A1_INSCR,;
            				SA1->A1_END,;
            				SA1->A1_BAIRRO,;
            				SA1->A1_CEP,;
            				SA1->A1_MUN,;
      			   	   		SA1->A1_EST,;
      			   	   		SA1->A1_DDD,;
      			   	   		SA1->A1_TEL,;
      			   	   		SA1->A1_FAX}
            Else
      			aRetEmp := {Space(TamSx3("A1_CGC")[1]),;
      						Space(TamSx3("A1_INSCR")[1]),;
      						Space(TamSx3("A1_END")[1]),;
      						Space(TamSx3("A1_BAIRRO")[1]),;
      						Space(TamSx3("A1_CEP")[1]),;
      						Space(TamSx3("A1_MUN")[1]),;
      						Space(TamSx3("A1_EST")[1]),;
      						Space(TamSx3("A1_DDD")[1]),;
      						Space(TamSx3("A1_TEL")[1]),;
      						Space(TamSx3("A1_FAX")[1])}
            EndIf
   			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	   		//Ё Alimenta variaveis com as informacoes 									 Ё
	   		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   			If !lValidOld
	   			cCnpjPC 	:= StrZero( Val(aRetEmp[1]),15 )
				cInsEstPC	:= StrZero( Val(aRetEmp[2]),20 )
				cEndPriPC	:= AllTrim( aRetEmp[3] ) +Space( ( 40-Len(aRetEmp[3]) ) )
				cBairroPC	:= AllTrim( aRetEmp[4] )+Space( ( 30-Len(aRetEmp[4]) ) )
				cCepPC		:= StrZero( Val(aRetEmp[5]),8 )
				cCidadePC	:= AllTrim( aRetEmp[6] )+Space( ( 30-Len(aRetEmp[6]) ) )
			   	cUfPC		:= AllTrim( aRetEmp[7] )+Space( ( 2-Len(AllTrim(aRetEmp[7])) ) )
			  	cDddPC		:= StrZero( Val(aRetEmp[8]),4 )
			 	cTelPC		:= StrZero( Val(SubStr(aRetEmp[9],1,9)),9 )
			 	cFaxPC		:= StrZero( Val(SubStr(aRetEmp[10],1,9)),9 )
			 	cCodMun 	:= StrZero( Val(BID->BID_CODMUN),7)
			 	cNumRes302  := IIF(Empty(BQC->BQC_NUMERO),Padr("S/N",6),Padr(BQC->BQC_NUMERO,6))  
			EndIf
		Endif
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Alimenta endereco...												     Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		cEndTit := SubStr(AllTrim(PlRetponto(BA1->BA1_ENDERE))+Space(1)+AllTrim(PlRetponto(BA1->BA1_COMEND)) + Space(40),1,40)					
		cBaiTit := SubStr(PlRetponto(BA1->BA1_BAIRRO) + Space(30),1,30)
		cCepTit := StrZero(Val(BA1->BA1_CEPUSR),8)
		cMunTit := SubStr(PlRetponto(BA1->BA1_MUNICI) + Space(30),1,30)
		cEstTit := BA1->BA1_ESTADO
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Alimenta data de inclusao...										     Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		cDatIncTit := DtoS(BA1->BA1_DATINC)
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica a quantidade de anos caso seja solicitado a geracao do     	 Ё
	    //Ё registro TP_PRAZO_BENEFICIO (Estado Santa Catarina)                      Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lEstSC                                              
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Ponto de entrada para tratamento do TP_PRAZO_BENEFICIO   Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If  Existblock("PL300TPPRZ")
			    cAnoBenef := Execblock("PL300TPPRZ",.F.,.F.,{IIF(cDatIncTit <  "20110101",cAnoBenef := "05",cAnoBenef := "03")})
			    If Valtype(cAnoBenef) <> "C"
			    	IIF(cDatIncTit <  "20110101",cAnoBenef := "05",cAnoBenef := "03") 
			    Endif
			Else                     
				IIF(cDatIncTit <  "20110101",cAnoBenef := "05",cAnoBenef := "03") 
			Endif
        EndIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Alimenta CPF...												     		 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If VAL(BA1->BA1_CPFUSR) > 0
			cCPFTit := StrZero(Val(BA1->BA1_CPFUSR),15)
		Else
			cCPFTit := StrZero(Val(BA1->BA1_CPFPRE),15)
		Endif
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Alimenta codigo...									                     Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		cCodTit := BA1->(BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
	Endif
	
	If lPosic
		BA1->( DbGoTo(nReg) )
	Endif
	
	cIncPro := Tmp->IncPro
Endif

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} A300DatIncEmp

@author PLS TEAM
@since  07/12/2016
@version P11
/*/
//-------------------------------------------------------------------
Function A300DatIncEmp()
Local cCodEmp, cDatIncEmp

cCodEmp := BG9->BG9_CODIGO
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Busca inclusao do 1o. Contrato da Empresa...	                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cQuery := " SELECT MIN(BT5_DATCON) DATINC "
cQuery += "	FROM " + cBT5name
cQuery += " WHERE BT5_FILIAL = '" + xFilial("BT5") + "' "
cQuery += "   AND BT5_CODINT = '" + cUniOri + "' "
cQuery += "   AND BT5_CODIGO = '" + cCodEmp + "' "
cQuery += "   AND " + cBT5name + ".D_E_L_E_T_ <> '*' "
cQuery    := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"CON",.F.,.T.)

TCSetField("CON","DATINC", "D", 8,0)
cDatIncEmp := DtoS(CON->DATINC)
CON->(dbCloseArea())

Return cDatIncEmp

//-------------------------------------------------------------------
/*/{Protheus.doc} AcumulaA309
Acumula valores para registro A309	 
@author PLS TEAM
@since  07/12/2016
@version P11
/*/
//-------------------------------------------------------------------
Function AcumulaA309(cLayOut)

Do Case
	Case cLayOut == "302"
		nTot302++
	Case cLayOut == "304"
		nTot304++
	Case cLayOut == "306"
		nTot306++
EndCase
cEmpres := Tmp->CodEmp
cTpPess := Tmp->TpPess
cMatFam := Tmp->(CodInt+CodEmp+Matric)
cContra := Tmp->Contra
cSbCont := Tmp->SbCont

Return
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁVeVlrMens ╨Autor  ЁMicrosiga           ╨ Data Ё  07/07/11   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     ЁVerifica valor da Mensalidade                               ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function VeVlrMens(cCodInt, cEmpres, cMatric, cTipReg, cConEmp, cVerCon, cSubCon, cVerSub, cAno, cMes)
Local cChave, nValor
Local nValorBk	:= 0
Local nIdade 	:= Alltrim(Str(Round(((Msdate()-BA1->BA1_DATNAS)/365),0)))

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicializa variavel				                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

nValor := 0

cChave := ( cCodInt+cEmpres+cConEmp+cVerCon+cSubCon+cVerSub+cMatric+cTipReg+"101"+cAno+cMes )

If cTipSeg $ "W,D,O"
	
	BM1->(MsSeek(xFilial("BM1")+cChave))
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica Composicao de cobranca                                          Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	While ( BM1->(BM1_CODINT+BM1_CODEMP+BM1_CONEMP+BM1_VERCON+BM1_SUBCON+BM1_VERSUB+BM1_MATRIC+BM1_TIPREG+BM1_CODTIP+BM1_ANO+BM1_MES) == cChave ) .and. ! BM1->(Eof())
		If BM1->BM1_TIPO == "1"
			nValor += BM1->BM1_VALOR
		Else
			nValor -= BM1->BM1_VALOR
		Endif
		BM1->(DbSkip())
	Enddo
	
Endif         

If nValor = 0
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Se existe faixa no usuario ja le todas essas faixas...              Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cSQL := "SELECT * FROM "+RetSQLName("BDK")+" WHERE "
	cSQL += "BDK_FILIAL = '"+xFilial("BDK")+"' AND "
	cSQL += "BDK_CODINT = '"+cCodInt+"' AND "
	cSQL += "BDK_CODEMP = '"+cEmpres+"' AND "
	cSQL += "BDK_MATRIC = '"+cMatric+"' AND "
	cSQL += " "+nIdade+" BETWEEN BDK_IDAINI and BDK_IDAFIN  AND "
	cSQL += "BDK_TIPREG = '"+cTipReg+"' AND "
	
	cSQL += "BDK_VALOR > 0 AND "
	cSQL += "D_E_L_E_T_ = ' '"
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"PLSBUSFAI",.F.,.T.)
		
	nValor:=PLSBUSFAI->BDK_VALOR

	PLSBUSFAI->(DbCloseArea())

	If nValor = 0
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Busca as faixas etarias desta familia...                            Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		cSQL := "SELECT * FROM "+RetSQLName("BBU")+" WHERE "
		cSQL += "BBU_FILIAL = '"+xFilial("BBU")+"' AND "
		cSQL += "BBU_CODOPE = '"+cCodInt+"' AND "
		cSQL += "BBU_CODEMP = '"+cEmpres+"' AND "
		cSQL += "BBU_MATRIC = '"+cMatric+"' AND "
		cSQL += " "+nIdade+" BETWEEN BBU_IDAINI AND BBU_IDAFIN AND " 
		cSQL += "BBU_CODFOR = '"+'101'+"' AND "
		cSQL += "BBU_VALFAI > 0 AND "
		cSQL += "D_E_L_E_T_ = ' '"
		cSQL := ChangeQuery(cSQL)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"PLSBUSFAI",.F.,.T.)
			                                
		nValor:=PLSBUSFAI->BBU_VALFAI
	
		PLSBUSFAI->(DbCloseArea())
	
	Endif
Endif

If nValor < 0
	nValor := 0
Endif


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ponto de entrada para tratamento do valor da mensalidade Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

If  Existblock("PLS300VLR")
	nValorBk :=nValor

    nValor := Execblock("PLS300VLR",.F.,.F.,{nValor,cChave})
    If Valtype(nValor) <> "N"
    	nValor:=nValorBk
    Endif
Endif                     

Return nValor              


//-------------------------------------------------------------------
/*/{Protheus.doc} A300IdentificaDep
IdentificaГЦo de dependente

@author  Lucas Nonato
@version P11
@since   22/09/16
/*/
//------------------------------------------------------------------- 
Function A300IdentificaDep()
Local cRet

cRet := "00" 

If A100CodDep(BA1->BA1_TIPREG, BA1->BA1_GRAUPA) == "10" .Or. A100CodDep(BA1->BA1_TIPREG, BA1->BA1_GRAUPA) == "70" .Or. A100CodDep(BA1->BA1_TIPREG, BA1->BA1_GRAUPA) == "75"
	If Calc_Idade(dDatFin,BA1->BA1_DATNAS) >= 18
		If BTS->BTS_UNIVER == "1"
			cRet := "01"
		Else
			If BTS->BTS_DEFFIS == "1"
				cRet := "02"
			Else
				cRet := "99" 
			Endif
		Endif
	Else
		cRet := "99" 
	Endif
Endif


Return cRet

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLSPESDEP  Ё Autor ЁAlexander          Ё Data Ё 06.02.2006 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Exibe dependentes								          Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё F3 BRP                                                     Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ Padrao do mBrowse                                          Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSPESDEP(cDado)
LOCAL oDlg
LOCAL oCritica
LOCAL cSQL
LOCAL nInd
LOCAL cPar
LOCAL aArea     := GetArea()
//LOCAL K_OK      := 0 comentado pois essa И uma constante e nЦo pode ser atribuido valor
LOCAL aCritica 	:= {}
LOCAL nOpca     := 0
LOCAL bOK       := { || nOpca := K_OK, oDlg:End() }
LOCAL bCancel   := { || oDlg:End() }

cDado    := AllTrim(cDado)

cSQL := " SELECT BRP_CODIGO,BRP_DESCRI FROM "+RetSQLName("BRP")
cSQL += "  WHERE BRP_FILIAL = '"+xFilial("BRP")+"' "
cSQL += "    AND " + RetSQLName("BRP") + ".D_E_L_E_T_ = ' ' "
cSQL += " ORDER BY BRP_FILIAL,BRP_DESCRI "
cSQL   := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TrbBAQ",.F.,.T.)

While ! TrbBAQ->(Eof())
	aadd(aCritica,{TrbBAQ->BRP_CODIGO,TrbBAQ->BRP_DESCRI,If(TrbBAQ->BRP_CODIGO$cDado,.T.,.F.)})
	TRBBAQ->(DbSkip())
Enddo
TrbBAQ->(DbCloseArea())
RestArea(aArea)

DEFINE MSDIALOG oDlg TITLE "Graus de Parentesco" FROM 10,10 TO 36,99 OF GetWndDefault()

oCritica := TcBrowse():New( 035, 012, 330, 150,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )

oCritica:AddColumn(TcColumn():New(" ",{ || IF(aCritica[oCritica:nAt,3],LoadBitmap( GetResources(), "LBOK" ),LoadBitmap( GetResources(), "LBNO" )) },;
"@!",nil,nil,nil,015,.T.,.T.,nil,nil,nil,.T.,nil))

oCritica:AddColumn(TcColumn():New("Codigo",{ || OemToAnsi(aCritica[oCritica:nAt,1]) },;
"@!",nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))

oCritica:AddColumn(TcColumn():New("Descricao",{ || OemToAnsi(aCritica[oCritica:nAt,2]) },;
"@!",nil,nil,nil,200,.F.,.F.,nil,nil,nil,.F.,nil))

oCritica:SetArray(aCritica)
oCritica:bLDblClick := { || aCritica[oCritica:nAt,3] := IF(aCritica[oCritica:nAt,3],.F.,.T.) }

ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,{})

If nOpca == K_OK
	cDado := "'"
	For nInd := 1 To Len(aCritica)
		If aCritica[nInd,3]
			cDado += aCritica[nInd,1]+"','"
		Endif
	Next
	cDado := Substr(cDado,1,Len(cDado)-2)
Endif

cPar  := ReadVar()
&cPar := cDado

Return(cDado)

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLSPRODF3  Ё Autor Ё Victor            Ё Data Ё 30.11.2012 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Exibe produtos									          Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё F3 PRODUTO                                                 Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ Padrao do mBrowse                                          Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PU300PRF3(cDado)
LOCAL oDlg
LOCAL nOpca     := 0
LOCAL bOK       := { || nOpca := K_OK, oDlg:End() }
LOCAL bCancel   := { || oDlg:End() }
LOCAL cCodEdi	:= ""
LOCAL oProd
LOCAL cSQL
LOCAL aSize	 	:= MsAdvSize()
LOCAL aProd  	:= {}
LOCAL nInd                     
LOCAL nIteMar

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Coloca virgula no comeco (caso tenha inicializador padrao)               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cDado  := AllTrim(cDado)   
If Subs(cDado,Len(cDado),1) != "," .AND. cDado != ""
	cDado += ","
Endif

If !Empty(mv_par07)
	cCodEdi := mv_par07
Else
	cCodEdi := "%%"
Endif

cSQL := "SELECT BI3_CODIGO, BI3_VERSAO, BI3_DESCRI FROM "+RetSQLName("BI3")+" WHERE "
cSQL += "BI3_FILIAL = '"+xFilial("BI3")+"' AND BI3_GRUPO IN ('002','003') "
cSQL += "AND BI3_TPREDI = '"+cCodEdi+"' AND D_E_L_E_T_ = '' "
cSQL += "ORDER BY BI3_FILIAL, BI3_DESCRI, BI3_VERSAO"

cSQL   := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TrbBI3",.F.,.T.)

While ! TrbBI3->(Eof())
     
      aAdd(aProd,{Alltrim(TrbBI3->BI3_CODIGO),AllTrim(TrbBI3->BI3_DESCRI),Iif((AllTrim(TrbBI3->BI3_CODIGO)) +'/'+ (AllTrim(TrbBI3->BI3_VERSAO)) $ cDado,.T.,.F.),(AllTrim(TrbBI3->BI3_VERSAO))})

TrbBI3->(DbSkip())
Enddo

TrbBI3->(DbCloseArea())


oDlg:= MSDIALOG():New(000,000,420,530,"Produtos",,,,,,,,,.T.)

@ 040,012 SAY oSay PROMPT "Selecione o(s) produto(s)" SIZE 100,010 OF oDlg PIXEL COLOR CLR_HBLUE

oProd := TcBrowse():New( 055, 012, 250, 150,,,,oDlg,,,,,,,,,,,, .T.,, .T.,, .F., )
                                            
oProd:AddColumn(TcColumn():New(" ",{ || IF(aProd[oProd:nAt,3],LoadBitmap( GetResources(), "LBOK" ),LoadBitmap( GetResources(), "LBNO" )) },;
         "@!",nil,nil,nil,015,.T.,.T.,nil,nil,nil,.T.,nil))     

oProd:AddColumn(TcColumn():New("Codigo",{ || OemToAnsi(aProd[oProd:nAt,1]) },;
         "@!",nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))     

oProd:AddColumn(TcColumn():New("VersЦo",{ || OemToAnsi(aProd[oProd:nAt,4]) },;
         "@!",nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))  

oProd:AddColumn(TcColumn():New("DescriГЦo",{ || OemToAnsi(aProd[oProd:nAt,2]) },;
         "@!",nil,nil,nil,240,.F.,.F.,nil,nil,nil,.F.,nil))        

oProd:SetArray(aProd)         
oProd:bLDblClick := { || aProd[oProd:nAt,3] := Eval( { || nIteMar := 0, aEval(aProd, {|x| IIf(x[3], nIteMar++, )}), IIf(nIteMar < 12 .Or. aProd[oProd:nAt, 3],IF(aProd[oProd:nAt,3],.F.,.T.),.F.) })}

EnChoiceBar(oDlg,bOK,bCancel,.F.,{})

oDlg:lCentered := .T.
oDlg:Activate()

If nOpca == K_OK
                  
   cDado := ""
   For nInd := 1 To Len(aProd)
       If aProd[nInd,3]
          cDado += aProd[nInd,1]+"/"+aProd[nInd,4]+","
       Endif 
   Next

Endif
                                  
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Tira a virgula do final                                                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Subs(cDado,Len(cDado),1) == ","
	cDado := Subs(cDado,1,Len(cDado)-1)
Endif                

mv_par08 := cDado

Return .T. 
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLUA300Edi╨Autor  ЁVictor              ╨ Data Ё  21/12/12   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Funcao de validacao dos produtos por tipo informado no     ╨╠╠
╠╠╨          Ё campo Cod Edi (BI3_GERPTU)                                 ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё PLSUA300                                                   ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function PLUA300Edi(cProVer)
Local lRet 		:= .T.
Local aPro	 	:= {}
Local aProVer 	:= {}
Local cSql 		:= ""
Local cTxtCri 	:= ""
Local nAux 		

cSQL := "SELECT BI3_CODIGO, BI3_VERSAO, BI3_DESCRI, BI3_TPREDI FROM "+RetSQLName("BI3")+" WHERE "
cSQL += "BI3_FILIAL = '"+xFilial("BI3")+"' AND BI3_GRUPO IN ('002','003') "
cSQL += "AND BI3_TPREDI = '"+mv_par07+"' AND D_E_L_E_T_ = '' "
cSQL += "ORDER BY BI3_FILIAL, BI3_CODIGO, BI3_VERSAO"

cSQL   := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TpVldPro",.F.,.T.)

aPro:= StrTokArr(cProVer,",")

For nAux := 1 to Len(aPro)
	aAdd(aProVer,{aPro[nAux],.F.})
Next

If Len(aProVer) > 0
	For nAux := 1 to Len(aProVer)
		While !TpVldPro->(Eof())
			If aProVer[nAux][1] == Alltrim(TpVldPro->BI3_CODIGO) + '/' + Alltrim(TpVldPro->BI3_VERSAO)
				aProVer[nAux][2] := .T.
				Exit
			Endif
			TpVldPro->(dbSkip())
		Enddo
		TpVldPro->(dbGoTop())
	Next
Endif

cTxtCri := "O(s) seguinte(s) produto(s) nЦo pertence(m) ao Cod Edi informado:"+ CRLF + CRLF
For nAux := 1 to Len(aProVer)
	If !aProVer[nAux][2]
		cTxtCri += aProVer[nAux][1]+CRLF
		lRet:= .F.
	Endif
Next

If !lRet .And. !Empty(cProVer)
	MsgAlert(cTxtCri,"AtenГЦo!")
Endif

TpVldPro->(dbCloseArea())

Return lRet
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁZeraTotal ╨Autor  ЁMicrosiga           ╨ Data Ё  05/27/11   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     ЁZera Total dos contadores                                   ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function ZeraTotal()

nTot302 := 0
nTot304 := 0
nTot306 := 0

Return
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁA300VldOpc╨Autor  ЁVictor Ferreira     ╨ Data Ё  28/02/13   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     ЁFuncao utilizada para validar os produtos na BT3            ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё PLSUA300                                                   ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function A300VldOpc()
Local lRet       := .T.
Local lPL300BT3  := Existblock("PL300BT3")
Local cSql		 := ""
Local nTamCODINT := TamSX3("BA1_CODINT")[1]
Local nTamCODEMP := TamSX3("BA1_CODEMP")[1]
Local nTamMATRIC := TamSX3("BA1_MATRIC")[1]
Local nTamTIPREG := TamSX3("BA1_TIPREG")[1]
Local nTamGRAUPA := TamSX3("BA1_GRAUPA")[1]
Local nTamDIGITO := TamSX3("BA1_DIGITO")[1]

cSql := " SELECT BF4_CODPRO, BF4_VERSAO, BF4_DATBAS, BF4_DATBLO"

cSql += " FROM " + cBA1Name

cSql += " JOIN " + cBF4Name
cSql += "		ON BF4_FILIAL = '" + xFilial("BF4") + "' "
cSql += "		AND BF4_CODINT = BA1_CODINT "
cSql += "		AND BF4_CODEMP = BA1_CODEMP "
cSql += "		AND BF4_MATRIC = BA1_MATRIC "
cSql += "		AND BF4_TIPREG = BA1_TIPREG "
cSql += "		AND BF4_CODPRO IN " + cQryPla
cSql += "		AND BF4_A300 <> '0' "
cSql += "		AND " + cBF4Name + ".D_E_L_E_T_ = ' ' "
//здддддддддддддддддддддддддддддд©
//Ё Somente Ativos			     Ё
//юдддддддддддддддддддддддддддддды
If cTipEnv == "A"
	cSql  += " AND ( BF4_DATBLO >= '"+ DtoS(dDatBlo) + "' OR BF4_DATBLO = '        ' ) "
EndIf
cSql += " WHERE BA1_FILIAL = '" + xFilial("BA1") + "' "
//здддддддддддддддддддддддддддддд©
//Ё Somente Ativos			     Ё
//юдддддддддддддддддддддддддддддды
If cTipEnv == "A"
	cSql += " AND ( BA1_DATBLO >= '"+ DtoS(dDatBlo) + "' OR BA1_DATBLO = '        ' )  "
EndIf
//cSql += "		AND BA1_CODINT || BA1_CODEMP || BA1_MATRIC || BA1_TIPREG || BA1_GRAUPA || BA1_DIGITO = '" + Tmp->KeyBen + "'"   
cSql += "	    AND BA1_CODINT = '" +SubStr(Tmp->KeyBen ,1,nTamCODINT)+"' "
cSql += "	    AND BA1_CODEMP = '" +SubStr(Tmp->KeyBen ,nTamCODINT+1,nTamCODEMP)+"' "
cSql += "	    AND BA1_MATRIC = '" +SubStr(Tmp->KeyBen ,nTamCODINT+nTamCODEMP+1,nTamMATRIC)+"' "   
cSql += "	    AND BA1_TIPREG = '" +SubStr(Tmp->KeyBen ,nTamCODINT+nTamCODEMP+nTamMATRIC+1,nTamTIPREG)+"' "  
cSql += "	    AND BA1_GRAUPA = '" +SubStr(Tmp->KeyBen ,nTamCODINT+nTamCODEMP+nTamMATRIC+nTamTIPREG+1,nTamGRAUPA)+"' " 
cSql += "	    AND BA1_DIGITO = '" +SubStr(Tmp->KeyBen ,nTamCODINT+nTamCODEMP+nTamMATRIC+nTamTIPREG+nTamGRAUPA+1,nTamDIGITO)+"' "
cSql += "		AND BA1_CODINT = '" + cUniOri + "' "
cSql += "		AND BA1_CODEMP BETWEEN '" + cEmpIni + "' AND '" + cEmpFin + "' "
cSql += "		AND " + cBA1Name + ".D_E_L_E_T_ = ' ' "

cSql += " ORDER BY BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG "

cSql    := ChangeQuery(cSql)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TmpVldOp",.F.,.T.)    

TCSetField("TmpVldOp","BF4_DATBAS", "D", 8,0)
TCSetField("TmpVldOp","BF4_DATBLO", "D", 8,0)

While !TmpVldOp->(Eof())
	If  lPL300BT3
		If ! BT3->( MsSeek(xFilial("BT3")+BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO)+TmpVldOp->(BF4_CODPRO+BF4_VERSAO) ) )  
		    lRet := Execblock("PL300BT3",.F.,.F.,{TmpVldOp->(BF4_CODPRO),TmpVldOp->(BF4_VERSAO),.F.})
		    If Valtype(lRet) <> "L"
		   		lRet := .F.
			Endif
		Else
		    lRet := Execblock("PL300BT3",.F.,.F.,{TmpVldOp->(BF4_CODPRO),TmpVldOp->(BF4_VERSAO),.T.})
		    If Valtype(lRet) <> "L"
		   		lRet := .F.
			Endif		    
		Endif
	Else
		If ! BT3->( MsSeek(xFilial("BT3")+BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO)+TmpVldOp->(BF4_CODPRO+BF4_VERSAO) ) )  
	   		lRet := .F.
	    Endif
	EndIf
	
	If lRet
		Exit
	Endif
	
	TmpVldOp->(dbSkip())
Enddo

TmpVldOp->(dbCloseArea())

Return lRet

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLPT300PIS╨Autor  ЁMicrosiga           ╨ Data Ё  12/02/13   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     ЁVerifica o PIS/PASEP do usuario ou da mae                   ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function PLPT300PIS()
Local cRet := ""
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se e dependedente menor de idade, nesse caso envia PIS da mae     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If A100CodDep(BA1->BA1_TIPREG, BA1->BA1_GRAUPA) <> "00" .And. Calc_Idade(dDataBase, BA1->BA1_DATNAS) < 18 .And. lBA1PIPAMA
	cRet := Strzero(Val(BA1->BA1_PIPAMA),11)
Else
	BTS->(DbSetOrder(1))//BTS_FILIAL + BTS_MATVID
	If BTS->(DbSeek(xFilial("BTS")+BA1->BA1_MATVID))
		cRet := Strzero(Val(BTS->BTS_PISPAS),11) 
	EndIf
EndIf

If Empty(cRet)
	cRet := Replicate("0",11)
EndIf

Return(cRet)
