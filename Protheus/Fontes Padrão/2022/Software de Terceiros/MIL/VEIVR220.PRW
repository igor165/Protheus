#Include "Protheus.ch"
#Include "Folder.ch"
#Include "Fileio.ch"  
#Include "VEIVR220.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VEIVR220 º Autor ³ Manoel             º Data ³  22/06/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Lista Estoque de Veiculos Semi-Novos               		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Concessionarias                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVR220()

Private cFunJEst := GetMv("MV_FUNJEST") // Nome da Funcao que Calcula o Juros de Estoque

Private cAlias    := "VV1"
Private cDesc1    := STR0001   //Precos de Venda de Veiculos Semi-Novos
Private cDesc2    := ""
Private cDesc3    := ""
Private aRegistros:= {}
Private nLin      := 0
Private cTamanho  := "P"          // P/M/G
Private Tamanho   := "P"          // P/M/G
Private Limite    := 80           // 80/132/220
Private cTitulo   := STR0001    //Precos de Venda de Veiculos Semi-Novos
Private Titulo    := STR0001    //Precos de Venda de Veiculos Semi-Novos
Private cNomeProg := "VEIVR220"
Private cNomeRel  := "VEIVR220"
Private nLastKey  := 0
Private nCaracter := 18
Private cabec1    := ""
Private cabec2    := ""
Private lAbortPrint := .f.
Private cString  := "VV1"
Private Li       := 80
Private m_Pag    := 1
Private wnRel    := "VEIVR220"
Private nPos     := 0
Private ni       := 0
Private aReturn  := { OemToAnsi(STR0002), 1,OemToAnsi(STR0003), 1, 1, 1, "",2 }		//1-ZEBRADO,2-,3-ADMINISTRACAO,4-1:COMPACTA,2:NAO,5-MIDIA 1:DISCO,6-CRYSTAL,7-,8-ORDEM

cPerg := Padr("PVR220",len(SX1->X1_GRUPO))

//ValidPerg()

If !pergunte(cPerg,.t.)
	Return
Else
	Processa( {|| FS_Imprime() } )
Endif

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_IMPRIMEº Autor ³ Manoel             º Data ³  22/06/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Impressao dos Dados de Estoque de Veiculos Semi-Novos	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Concessionarias                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_Imprime()

// Armazena dados da impressao

Local _i_ := 0
Local ni  := 0
Private cQAlVV1 := "SQLVV1"
Private cQuery := ""
nTotVei   := 0
nTotCus   := 0
aVetorFF := {} // Vetor para Veiculos em Faturamento Futuro
//  1o. Elemento - Status
//  2o. Elemento - Dias de Estoque
//  3o. Elemento - Nro NF Entrada
//  4o. Elemento - Data da Entrada
//  5o. Elemento - Marca + Modelo + Descricao do Modelo
//  6o. Elemento - Ano / Modelo
//  7o. Elemento - Combustivel
//  8o. Elemento - Cor
//  9o. Elemento - Placa
// 10o. Elemento - Situacao Documental
// 11o. Elemento - Localizacao do Veiculo
// 12o. Elemento - Custo do Veiculo
// 13o. Elemento - Despesas do Veiculo
// 14o. Elemento - Custo+Despesas * % Incremento
// 15o. Elemento - Valor Sugerido de Venda
// 16o. Elemento - Custo+Despesas sem % Incremento
// 17o. Elemento - Data do Repasse do Veiculo

aVetorPE := {} // Vetor para Veiculos Pendentes
//  1o. Elemento - Data da Entrada
//  2o. Elemento - Marca + Modelo + Descricao do Modelo
//  3o. Elemento - Placa
//  4o. Elemento - Observacao para relatar a pendencia do veiculo
//  5o. Elemento - Status

aVetor   := {}
//  1o. Elemento - Status
//  2o. Elemento - Dias de Estoque
//  3o. Elemento - Nro NF Entrada
//  4o. Elemento - Data da Entrada
//  5o. Elemento - Marca + Modelo + Descricao do Modelo
//  6o. Elemento - Ano / Modelo
//  7o. Elemento - Combustivel
//  8o. Elemento - Cor
//  9o. Elemento - Placa
// 10o. Elemento - Situacao Documental
// 11o. Elemento - Localizacao do Veiculo
// 12o. Elemento - Custo do Veiculo
// 13o. Elemento - Despesas do Veiculo
// 14o. Elemento - Custo+Despesas * % Incremento
// 15o. Elemento - Valor Sugerido de Venda
// 16o. Elemento - Custo+Despesas sem % Incremento
aTotUs := {}
Cabec1 := ""
Cabec2 := ""


wnrel:= "VEIVR220"
wnrel:=SetPrint(cString,wnrel,,@titulo,cDesc1,cDesc2,cDesc3,.F.,,.T.,Tamanho)

If nLastKey == 27
	Set Filter to
	Return
Endif

Set Printer to &wnrel
Set Printer On
Set Device  to Printer

SetDefault(aReturn,cString)

If nLastKey == 27
	Set Filter To
	Return
Endif

SX3->(DbSetOrder(2))

li         := 80
m_pag      := 1
If Mv_Par02 == 2 // Listagem para Vendedor
	Tamanho    := "P"
Else	// Listagem para Gerente
	Tamanho    := "M"
Endif	
limite     := 80
nTipo      := 18
nCaracter  := 18
nomeprog := "VEIVR220"

Titulo  := STR0001 //Precos de Venda de Veiculos Semi-Novos

nValTab1 := 0
nValTab2 := 0
nValTab3 := 0

// Lista Estoque de Veiculos
//dbSelectArea("VV1")
//DbSetOrder(4)
//dbseek(xFilial("VV1")+"0")
//nTot := RecCount()
//ProcRegua( nTot )     
cQuery := "SELECT VV1.VV1_SITVEI , VV1.VV1_ESTVEI , VV1.VV1_TRACPA , VV1.VV1_NUMTRA , VV1.VV1_CHASSI , VV1.VV1_CODMAR , VV1.VV1_MODVEI , VV1.VV1_CORVEI , VV1.VV1_DTHRES , VV1.VV1_DTHVAL , VV1.VV1_FABMOD , VV1.VV1_PLAVEI, VV1.VV1_STATUS, VV1.VV1_CHAINT , VV1.VV1_SITDOC , VV1.VV1_SUGVDA, VV1.VV1_COMVEI , VV1.VV1_DATREP "
cQuery += "FROM "+RetSqlName("VV1")+" VV1 WHERE VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_SITVEI IN ('0','2','3','4','6') AND VV1.D_E_L_E_T_=' ' ORDER BY VV1.VV1_SITVEI , VV1.VV1_CODMAR , VV1.VV1_MODVEI , VV1.VV1_CORVEI "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV1 , .F., .T. )
//SetRegua( ( cQAlVV1 )->( RecCount() ) )
Do While !( cQAlVV1 )->( Eof() )


//while !eof() .and. VV1->VV1_FILIAL == xFilial("VV1")

	 IncProc(STR0004)		// Aguarde... Lendo Estoque de Veiculos Semi-Novos...
	 
    If !( cQAlVV1 )->VV1_SITVEI $ "043" // Estoque / Consignado / Remessa
    	 ( cQAlVV1 )->( DbSkip() )
    	 Loop
    Endif  
    
    If !( cQAlVV1 )->VV1_ESTVEI == "1"
    	 ( cQAlVV1 )->( DbSkip() )
    	 Loop
    Endif  

   If ( cQAlVV1 )->VV1_STATUS == "PE"
    	 ( cQAlVV1 )->( DbSkip() )
    	 Loop
    Endif  

    If Mv_Par02 == 2 // Listagem para Vendedor
	    If ( cQAlVV1 )->VV1_STATUS $ "FF/IC"
	    	 ( cQAlVV1 )->( DbSkip() )
	    	 Loop
	    Endif  
    Endif  

	 DbSelectArea("VVF")
	 DbSetOrder(1)
	 DbSeek(xFilial("VVF")+( cQAlVV1 )->VV1_TRACPA)
	 DbSelectArea("VVG")
	 DbSetOrder(1)
	 DbSeek(xFilial("VVG")+( cQAlVV1 )->VV1_TRACPA+( cQAlVV1 )->VV1_CHAINT)
	 dbSelectArea("VV2")
	 DbSetOrder(1)
	 dbseek(xFilial("VV2")+( cQAlVV1 )->VV1_CODMAR+( cQAlVV1 )->VV1_MODVEI)
	 dbSelectArea("VVC")
	 DbSetOrder(1)
	 dbseek(xFilial("VVC")+( cQAlVV1 )->VV1_CODMAR+( cQAlVV1 )->VV1_CORVEI)                            
	 cCombus := FS_Combust()                                                                                                             
	 cAnoMod := subs(( cQAlVV1 )->VV1_FABMOD,3,2)+"/"+subs(( cQAlVV1 )->VV1_FABMOD,7,2)                                                                   
	 dbSelectArea("VAE")
	 DbSetOrder(1)
	 dbseek(xFilial("VAE")+( cQAlVV1 )->VV1_STATUS)                            
	 If ( cQAlVV1 )->VV1_SITVEI == "3" // Remessa
	    cStatus := "REMESSA"+Space(23)
	 Else   
	    cStatus := VAE->VAE_DESCRI
	 Endif   

    nDiaEst := dDataBase - VVF->VVF_DATMOV
    cSitDoc := If(( cQAlVV1 )->VV1_SITDOC=="1","OK ","   ")
    SX3->(DbSeek("VV1_SITVEI"))
    cLocali := AllTrim(strzero(VAL(( cQAlVV1 )->VV1_SITVEI),1))
    
    If cLocali == "0"//Estoque
       cLocali := "E" 
    ElSeIf cLocali == "2"
       cLocali := "T" //Transito
    ElSeIf cLocali == "3"
       cLocali := "R"
    ElSeIf cLocali == "4" //Consignado
       cLocali := "C"
    ElSeIf cLocali == "5" //Transferido
       cLocali := "TR"  
    ElSeIf cLocali == "6" //Reservado
       cLocali := "RS"          
    EndIf
    // Juros de Estoque
	 cTipFat := ( cQAlVV1 )->VV1_ESTVEI
//	 SE2->(dbSetOrder(1))
//	 if SE2->(dbSeek(xFilial("SE2")+VVF->VVF_SERNFI+VVF->VVF_NUMNFI))
	 SE2->(dbSetOrder(6))
	 if SE2->(dbSeek(xFilial("SE2")+VVF->VVF_CODFOR+VVF->VVF_LOJA+VVF->VVF_SERNFI+VVF->VVF_NUMNFI))
	 	 if SE2->E2_BAIXA # ctod("  /  /  ") .and. (dDataBase - SE2->E2_BAIXA) > 0  //baixado
		    If ExistBlock(cFunJEst)   // Se existir este PRW, entao ele sera usado
				 M->VVA_JUREST := ExecBlock(cFunJEst,.f.,.f.,{( cQAlVV1 )->VV1_TRACPA,( cQAlVV1 )->VV1_CHAINT,SE2->E2_BAIXA,dDataBase,'V'})
			 Else	
				 M->VVA_JUREST := FG_JurEst(( cQAlVV1 )->VV1_TRACPA,( cQAlVV1 )->VV1_CHAINT,SE2->E2_BAIXA,dDataBase,"V")
			 Endif	
   	 elseif SE2->E2_BAIXA = ctod("  /  /  ") //aberto
	  		 M->VVA_JUREST := 0
		 endif
	 else // nao encontrei titulo
	    If ExistBlock(cFunJEst)   // Se existir este PRW, entao ele sera usado
			 M->VVA_JUREST := ExecBlock(cFunJEst,.f.,.f.,{( cQAlVV1 )->VV1_TRACPA,( cQAlVV1 )->VV1_CHAINT,VVF->VVF_DATEMI,dDataBase,'V'})
		 Else	
			 M->VVA_JUREST := FG_JurEst(( cQAlVV1 )->VV1_TRACPA,( cQAlVV1 )->VV1_CHAINT,VVF->VVF_DATEMI,dDataBase,"V")
		 Endif	
    Endif
	 nCusVei := VVG->VVG_VCNVEI+M->VVA_JUREST

	 nDespes := 0
	 aVetDesp:={}
    DbSelectArea("VVD")
	 DbSetOrder(1)
	 If Dbseek(xFilial("VVD")+VVG->VVG_TRACPA+( cQAlVV1 )->VV1_CHAINT) // Houve Despesas
	    while !eof() .and. VVD->VVD_TRACPA+VVD->VVD_CHAINT == ( cQAlVV1 )->VV1_TRACPA+( cQAlVV1 )->VV1_CHAINT
	    		nDespes += VVD->VVD_VALOR
	    	   aadd(aVetDesp,{VVD->VVD_CODIGO+"    "+VVD->VVD_DESCRI+"   "+DTOC(VVD->VVD_DATADR)+"  "+transform(VVD->VVD_VALOR,"@E 999,999.99")})
	    		DbSkip()
	    Enddo
	 Endif
	 nCusVDe := nCusvei + nDespes
    If Mv_Par01 > 0
		 nIncre := nCusVDe * Abs(Mv_Par01/100)
	 Else	 
		 nIncre := nCusVDe * Abs(Mv_Par01/100) * (-1)
	 Endif	 
	 nCusFin := (nCusVDe) + nIncre
	 If Mv_Par02 == 1 // Listagem para Gerente
		 cMarMod := ( cQAlVV1 )->VV1_CODMAR+" "+left(VV2->VV2_DESMOD,12)
	 Else	 
		 cMarMod := ( cQAlVV1 )->VV1_CODMAR+" "+left(VV2->VV2_DESMOD,20)
	 Endif	 
	 
    nValEqp := 0
	 dbSelectArea("VVT")
	 dbSetOrder(1)
    dbSeek(xFilial("VVT")+( cQAlVV1 )->VV1_CHAINT)
	 While VVT->VVT_CHAINT == ( cQAlVV1 )->VV1_CHAINT .and. !eof() .and. VVT->VVT_FILIAL == xFilial("VVT")
		 nValEqp += VVT->VVT_VALEQP
		 dbSelectarea("VVT")
		 dbSkip()
	 Enddo

	 nPreSug    := ( cQAlVV1 )->VV1_SUGVDA + nValEqp
	 
	 If ( cQAlVV1 )->VV1_STATUS == "FF"
		 aadd(aVetorFF,{cStatus,nDiaEst,VVF->VVF_NUMNFI+"-"+VVF->VVF_SERNFI,VVF->VVF_DATMOV,cMarMod,cAnoMod,cCombus,left(VVC->VVC_DESCRI,10),Transform(( cQAlVV1 )->VV1_PLAVEI,"@R ###-####"),cSitDoc,cLocali,nCusVei,nCusVDe-nCusVei,nCusFin,nPreSug,nCusVDe,STOD(( cQAlVV1 )->VV1_DATREP)})
	  aadd(atotUs, {cStatus,nCusvei})
	 Else	 
		 aadd(aVetor,{cStatus,nDiaEst,VVF->VVF_NUMNFI+"-"+VVF->VVF_SERNFI,VVF->VVF_DATMOV,cMarMod,cAnoMod,cCombus,left(VVC->VVC_DESCRI,10),Transform(( cQAlVV1 )->VV1_PLAVEI,"@R ###-####"),cSitDoc,cLocali,nCusVei,nCusVDe-nCusVei,nCusFin,nPreSug,nCusVDe})
	  aadd(atotUs, {cStatus,nCusvei})
	 Endif	 
	 
	 //DbSelectArea("VV1")
	 //DbSKip()
	 
//Enddo
( cQAlVV1 )->( DbSkip() )
EndDo
( cQAlVV1 )->( DbCloseArea() )
// Lista Veiculos Pendentes
//dbSelectArea("VV1")
//DbGoTop()

cQuery := "SELECT VV1.VV1_SITVEI , VV1.VV1_ESTVEI , VV1.VV1_TRACPA , VV1.VV1_NUMTRA , VV1.VV1_CHASSI , VV1.VV1_CODMAR , VV1.VV1_MODVEI , VV1.VV1_CORVEI , VV1.VV1_DTHRES , VV1.VV1_DTHVAL , VV1.VV1_FABMOD , VV1.VV1_PLAVEI, VV1.VV1_STATUS, VV1.VV1_CHAINT , VV1.VV1_SITDOC , VV1.VV1_SUGVDA , VV1.VV1_OBSPEN "
cQuery += "FROM "+RetSqlName("VV1")+" VV1 WHERE VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_SITVEI IN ('0','2','3','4','6') AND VV1.VV1_ESTVEI = '1' AND VV1.D_E_L_E_T_=' ' ORDER BY VV1.VV1_SITVEI , VV1.VV1_CODMAR , VV1.VV1_MODVEI , VV1.VV1_CORVEI "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV1 , .F., .T. )
//SetRegua( ( cQAlVV1 )->( RecCount() ) )
Do While !( cQAlVV1 )->( Eof() )


nTot := RecCount()
ProcRegua( nTot )     

//while !eof() .and. VV1->VV1_FILIAL == xFilial("VV1")

	 IncProc(STR0004) //Aguarde... Lendo Estoque de Veiculos Semi-Novos...   Incrementa a regua
	   /*
    If !VV1->VV1_ESTVEI == "1"
    	 DbSkip()
    	 Loop
    Endif  
    */
    If ( cQAlVV1 )->VV1_STATUS != "PE"
    	 ( cQAlVV1 )->( DbSkip() )
    	 Loop
    Endif  
      
	 dbSelectArea("VAE")
	 DbSetOrder(1)
	 dbseek(xFilial("VAE")+( cQAlVV1 )->VV1_STATUS)                            
    cStatus := VAE->VAE_DESCRI

	 dbSelectArea("VV2")
	 DbSetOrder(1)
	 dbseek(xFilial("VV2")+( cQAlVV1 )->VV1_CODMAR+( cQAlVV1 )->VV1_MODVEI)

	 cMarMod := ( cQAlVV1 )->VV1_CODMAR+" "+left(VV2->VV2_DESMOD,12)
	 
	 aadd(aVetorPE,{VVF->VVF_DATMOV,cMarMod,Transform(( cQAlVV1 )->VV1_PLAVEI,"@R ###-####"),( cQAlVV1 )->VV1_OBSPEN,cStatus})
	 
	//DbSelectArea("VV1")
	// DbSKip()
	 
//Enddo
	( cQAlVV1 )->( DbSkip() )
EndDo
( cQAlVV1 )->( DbCloseArea() )
If Mv_Par02 == 1 // Listagem para Gerente
	cCabec1 := STR0005  //D.Est NF Entrada  Data Ent Marca + Modelo   AnoMd C    Cor      Placa   Doc Loc Custo Veic Despesas  Custo+Desp Cus+Dsp+%I V Sugerido
	cCabec2 := "----- ----------  -------- ---------------- ----- - ---------- -------- --- --- ---------- --------- ---------- ---------- ----------"        
	//				 9999 xxxxxx-xxx  99/99/99 xxx xxxxxxxxxxxx 99/99 x xxxxxxxxxx xxx-9999 xxx xxx 999,999.99 99,999,99 999,999.99 999,999,99 999,999.99
	//				123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
	//							10			 20		  30        40        50        60        70        80        90       100       110       120       130

//	cCabec1 := "DiasEst NF Entrada Data Ent Marca + Modelo   AnoMod Comb    Cor      Placa   Doc Loc  Custo Veic   Despesas  Cus+Dsp+%In Vl Sugerido"
//	cCabec2 := "------- ---------- -------- ---------------- ------ ---- ---------- -------- --- ---  -----------  --------- ----------- -----------"        
	//				  9999  xxxxxx-xxx 99/99/99 xxx xxxxxxxxxxxx  99/99 xxxx xxxxxxxxxx xxx-9999 xxx xxx  9999,999.99  99,999,99 9999,999,99 9999,999.99
	//				123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
	//							10			 20		  30        40        50        60        70        80        90       100       110       120       130
Else // Listagem para Vendedor
	cCabec1 := STR0006  //Marca Modelo             AnoMod Comb    Cor      Placa   Loc  Valor Venda
	cCabec2 := "------------------------ ------ ---- ---------- -------- ---  -----------"        
	//				xxx xxxxxx xxxxxxxxxxxxx  99/99 xxxx xxxxxxxxxx xxx-9999  x   9999,999.99 
	//				123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
	//							10			 20		  30        40        50        60        70        80        90       100       110       120       130
Endif

aSort(aVetor,,,{|x,y| x[1]+x[5] < y[1]+y[5] })
if Len(aVetor) <> 0 
   cStat := aVetor[1,1]
Endif   
nStat := 0
For _i_ := 1 to Len(aVetor)

    If li > 56
	
	    cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		 If Mv_Par02 == 1 // Listagem para Gerente
		    li++
	 		 @ li,00 psay STR0007 +" "+transform(Mv_Par01,"@E 999.99%")   //Percentual de Incremento
		 Endif
	    li:=li+2
 		 @ li++,00 psay cStat
	    li++
	    @li,00  PSAY cCabec1
	    li:=li+1
	    @li,00  PSAY cCabec2
	    li:=li+2
				 
    Endif
    

    If cStat != aVetor[_i_,1]
	    @ li++,82 PSAY Transform(nStat,"@E 9999,999.99")
	   cStat := aVetor[_i_,1]
		  nStat := aVetor[_i_,12]
	    li:=li+2
 		 @ li++,00 psay cStat
	    li++
	    @li,00  PSAY cCabec1
	    li:=li+1
	    @li,00  PSAY cCabec2
	    li:=li+2
	 Else   
		 nStat := nStat + aVetor[_i_,12]
   
  Endif

    If Mv_Par02 == 1 // Listagem para Gerente
	    @ li++,01 PSAY Transform(aVetor[_i_,02],"@E 9999")+" "+aVetor[_i_,03]+"  "+Dtoc(aVetor[_i_,04])+" "+aVetor[_i_,05]+" "+aVetor[_i_,06]+" "+;
							 left(aVetor[_i_,07],1)+" "+aVetor[_i_,08]+" "+aVetor[_i_,09]+" "+aVetor[_i_,10]+"  "+aVetor[_i_,11]+"  "+;
							 Transform(aVetor[_i_,12],"@E 999,999.99")+" "+Transform(aVetor[_i_,13],"@E 99,999.99")+" "+Transform(aVetor[_i_,16],"@E 999,999.99")+" "+Transform(aVetor[_i_,14],"@E 999,999.99")+" "+Transform(aVetor[_i_,15],"@E 999,999.99")
	 Else // Listagem para Vendedor
	    @ li++,00 PSAY aVetor[_i_,05]+"  "+aVetor[_i_,06]+" "+aVetor[_i_,07]+" "+aVetor[_i_,08]+" "+aVetor[_i_,09]+"  "+aVetor[_i_,11]+"   "+If(aVetor[_i_,14]>aVetor[_i_,15],Transform(aVetor[_i_,14],"@E 9999,999.99"),Transform(aVetor[_i_,15],"@E 9999,999.99"))
	 Endif							 
	 
Next
@ li++,82 PSAY Transform(nStat,"@E 9999,999.99")


If Len(aVetorFF) > 0 .and. Mv_Par02 == 1 // Listagem para Gerente

   li := 80
	cCabec1 := STR0008  //D.Est NF Entrada  Data Ent Marca + Modelo   AnoMd C    Cor      Placa   Doc Loc Custo Veic Despesas  Custo+Desp Cus+Dsp+%I Dt Repasse
	cCabec2 := "----- ----------  -------- ---------------- ----- - ---------- -------- --- --- ---------- --------- ---------- ---------- ----------"        
	//				 9999 xxxxxx-xxx  99/99/99 xxx xxxxxxxxxxxx 99/99 x xxxxxxxxxx xxx-9999 xxx xxx 999,999.99 99,999,99 999,999.99 999,999,99  99/99/99 
	//				123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
	//							10			 20		  30        40        50        60        70        80        90       100       110       120       130
	//							10			 20		  30        40        50        60        70        80        90       100       110       120       130
	aSort(avetorFF,,,{|x,y| x[2] < y[2] })
	cStat := aVetorFF[1,1]
	nStat := 0
	For _i_ := 1 to Len(avetorFF)
 nStat := nStat + aVetorFF[_i_,12]
	    If li > 56
		
		    cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
			 If Mv_Par02 == 1 // Listagem para Gerente
			    li++
		 		 @ li,00 psay STR0007 +" "+transform(Mv_Par01,"@E 999.99%")  //Percentual de Incremento
			 Endif
		    li:=li+2
	 		 @ li++,00 psay cStat
		    li++
		    @li,00  PSAY cCabec1
		    li:=li+1
		    @li,00  PSAY cCabec2
		    li:=li+2
					 
	    Endif
	    
	    @ li++,01 PSAY Transform(aVetorFF[_i_,02],"@E 9999")+" "+aVetorFF[_i_,03]+"  "+Dtoc(aVetorFF[_i_,04])+" "+aVetorFF[_i_,05]+" "+aVetorFF[_i_,06]+" "+;
							 left(aVetorFF[_i_,07],1)+" "+aVetorFF[_i_,08]+" "+aVetorFF[_i_,09]+" "+aVetorFF[_i_,10]+"  "+aVetorFF[_i_,11]+"  "+;
							 Transform(aVetorFF[_i_,12],"@E 999,999.99")+" "+Transform(aVetorFF[_i_,13],"@E 99,999.99")+" "+Transform(aVetorFF[_i_,16],"@E 999,999.99")+" "+Transform(aVetorFF[_i_,14],"@E 999,999.99")+" "+DTOC(aVetorFF[_i_,17])
	    
	Next
@ li++,82 PSAY Transform(nStat,"@E 9999,999.99")
Endif


If Len(aVetorPE) > 0 .and. Mv_Par02 == 1 // Listagem para Gerente

   li := 80
	cCabec1 := STR0009  //Data Ent Marca + Modelo   Placa    Observacoes
	cCabec2 := "-------- ---------------- -------- ------------------------------------------------------------------------------------------"
	//				99/99/99 xxx xxxxxxxxxxxx xxx-9999 
	//				123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
	//							10			 20		  30        40        50        60        70        80        90       100       110       120       130
	aSort(avetorPE,,,{|x,y| x[2] < y[2] })
	cStat := aVetorPE[1,5]
	nStat := 0
	For _i_ := 1 to Len(avetorPE)
	
	    If li > 56
		
		    cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
			 If Mv_Par02 == 1 // Listagem para Gerente
			    li++
		 		 @ li,00 psay STR0007 +" "+transform(Mv_Par01,"@E 999.99%") //percentual de incremento
			 Endif
		    li:=li+2
	 		 @ li++,00 psay cStat
		    li++
		    @li,00  PSAY cCabec1
		    li:=li+1
		    @li,00  PSAY cCabec2
		    li:=li+2
					 
	    Endif
	    
	    @ li++,00 PSAY Dtoc(avetorPE[_i_,01])+" "+avetorPE[_i_,02]+" "+avetorPE[_i_,03]+" "+avetorPE[_i_,04]
	    
	Next

Endif
aSort(aTotUs,,,{|x,y| x[1]+x[1] < y[1]+y[1] })
LI++
@li,00 PSay "                                              QTD    CUSTO "
LI++
cStat := ""
For ni := 1 to len(Atotus)
  

  If cStat #  aTotUs[ni,1]
   If !Empty(cStat)
     @li++,00 Psay "TOTAL DE  "+cStat+" : "+Transform(nTotVei,"@E 99,999")+Transform(nTotCus,"@E 999,999,999.99")
   Else
    If nTotVei > 0
     @li++,00 Psay "TOTAL DE  "+"VEICULOS SEMI-NOV0S            : "+Transform(nTotVei,"@E 99,999")+Transform(nTotCus,"@E 999,999,999.99")
    EndIf
   EndIf
   nTotCus := 0
   nTotVei := 0    
   cStat   := aTotUs[ni,1]
  EndIf
 
cStat := aTotUs[ni,1]
nTotCus += aTotUs[ni,2]
nTotVei ++ 
Next   
@li,00 Psay "TOTAL DE  "+cStat+" : "+Transform(nTotVei,"@E 99,999")+Transform(nTotCus,"@E 999,999,999.99")
ms_flush()

Set Printer to
set Device  to Screen

If aReturn[5] == 1
	Set Printer TO
	dbCommitAll()
	ourspool(wnrel)
Endif

Return .t.



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºFun‡„o    ³VALIDPERG º Autor ³ AP5 IDE            º Data ³  13/07/01   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

Static Function ValidPerg
local _sAlias := Alias()
local aRegs := {}
local i,j
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := Padr("PVR220",len(SX1->X1_GRUPO))
// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
aAdd(aRegs,{cPerg,"01","% Incremento (+/-)","","","mv_ch1","N",6,2,0,"G","","Mv_Par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Listagem para?","","","mv_ch2","N",1,1,0,"C","","Mv_Par02","Gerente","","","","","Vendedor","","","","","","","","","","","","","","","","","","","",""})
For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next
dbSelectArea(_sAlias)
Return

*/
Static Function FS_Combust()
    
cRet := "----"

If Left(( cQAlVV1 )->VV1_COMVEI,1) == "0"
   cRet := STR0010  //Gas
ElseIf Left(( cQAlVV1 )->VV1_COMVEI,1) == "1"
   cRet := STR0011  //Alc
ElseIf Left(( cQAlVV1 )->VV1_COMVEI,1) == "2"
   cRet := STR0012  //Dies
ElseIf Left(( cQAlVV1 )->VV1_COMVEI,1) == "3"
   cRet := STR0013  //NatG
ElseIf Left(( cQAlVV1 )->VV1_COMVEI,1) == "4"
   cRet := STR0014  //Flex
Endif

Return(cRet)


