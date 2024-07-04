// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 4      º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFIXI017.CH"   

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | OFIXI017   | Autor | Thiago                | Data | 01/03/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Importação do arquivo de comunicação EDI com a montadora  	|##
##|          | MITSUBISHI veículos - Assunto PEDIDO  DE PEÇAS.				|##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFIXI017()
//
Local cDesc1  := STR0001
Local cDesc2  := STR0002
Local cDesc3  := STR0003
Local aSay := {}
Local aButton := {}
Local i := 0

Private cTitulo := STR0004
Private cPerg := "OXI017" 	
Private lErro := .f.  	    // Se houve erro, não move arquivo gerado
Private cArquivo			// Nome do Arquivo a ser importado
Private oNo      := LoadBitmap( GetResources(), "LBNO" )
Private oTik     := LoadBitmap( GetResources(), "LBTIK" )
Private aLayCK6011 := {}
Private aVetVeic := {}
Private aPedPen  := {{.f.,"","","",""}}
Private cAliasVI5 := "SQLVI5"
Private nOpca := 1
cCodMar := mv_par02

cQuery := "SELECT VI5.VI5_CODMAR,VI5.VI5_TIPREG,VI5.VI5_CODPED,VI5.VI5_CODCON "
cQuery += "FROM "
cQuery += RetSqlName( "VI5" ) + " VI5 " 
cQuery += "WHERE " 
cQuery += "VI5.VI5_FILIAL='"+ xFilial("VI5")+ "' AND VI5.VI5_TRANSM <> 'S' AND "
cQuery += "VI5.D_E_L_E_T_=' '"                                             

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVI5, .T., .T. )

Do While !( cAliasVI5 )->( Eof() )

   if Len(aPedPen) == 1 .and. Empty(aPedPen[1,2]+aPedPen[1,3]+aPedPen[1,4]+aPedPen[1,5]) 
       aPedPen := {}
   Endif    
   Aadd(aPedPen,{.f.,( cAliasVI5 )->VI5_CODMAR,( cAliasVI5 )->VI5_TIPREG,( cAliasVI5 )->VI5_CODPED,( cAliasVI5 )->VI5_CODCON})
   
   dbSelectArea(cAliasVI5)
   ( cAliasVI5 )->(dbSkip())
   
Enddo
( cAliasVI5 )->( dbCloseArea() )
if Len(aPedPen) == 1 .and. Empty(aPedPen[1,2]) .and. Empty(aPedPen[1,4])
   MsgInfo(STR0031)
   Return(.f.)
Endif       
   
cAchou := FS_TELA()
if cAchou == "0"        
	FS_TELA()
Elseif cAchou == "3"
   Return(.f.)
Endif

if nOpca == 1
	//
	CriaSX1()
	//
	aAdd( aSay, cDesc1 ) // Um para cada cDescN
	aAdd( aSay, cDesc2 ) // Um para cada cDescN
	aAdd( aSay, cDesc3 ) // Um para cada cDescN
	//
	nOpc := 0
	aAdd( aButton, { 5, .T., {|| Pergunte(cPerg,.T. )    }} )
	aAdd( aButton, { 1, .T., {|| nOpc := 1, FechaBatch() }} )
	aAdd( aButton, { 2, .T., {|| FechaBatch()            }} )
	//
	FormBatch( cTitulo, aSay, aButton )
	//
	If nOpc <> 1
		Return
	Endif
	//
	Pergunte(cPerg,.f.)
	//
	RptStatus( {|lEnd| ExportArq(@lEnd)},"",STR0010)
	//
//	RptStatus({|lEnd| ImprimeRel(@lEnd) },"Aguarde...", "Imprimindo relatório.", .T. )
	//

Endif

return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | ExportArq  | Autor | Thiago                | Data | 11/12/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Exporta arquivo.										        |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function ExportArq()
Local cQryAliasVI5 := "SQLVI5"   
Local i := 0
Local aLayHeader   := {}
Local aLayDetalhe  := {}
Local aLayTrailler := {}
Local aVetNome := {}
Local aVetTam := {}
Local aVetData := {}
Local aVetHora := {}   
Local aValCab  := {}
Local aValDet  := {}
Local aValTrei := {} 
Local y := 0
Local m := 0

//Registro Tipo 1 (Header). 

aAdd(aLayHeader, { "C",  1, 0,  1} )     // Tipo
aAdd(aLayHeader, { "N",  4, 0,  2} )     // Linha
aAdd(aLayHeader, { "N",  5, 0,  6} )     // Codigo da concessioria
aAdd(aLayHeader, { "C", 10, 0,  11} )    // (dd/mm/aaaa) Data do pedido 
aAdd(aLayHeader, { "C", 15, 0,  21} )    // Numero do pedido interno  do Concessionário 
aAdd(aLayHeader, { "N",  1, 0,  36} )    // Tipo Pedido
aAdd(aLayHeader, { "N",  1, 0,  37} )    // Cond. Pagamento
aAdd(aLayHeader, { "N",  1, 0,  38} )    // Via Transporte 1
aAdd(aLayHeader, { "N",  3, 0,  39} )    // Transportadora 3
aAdd(aLayHeader, { "N",  1, 0,  42} )    // Frete

// Registro Tipo 2 (Detalhe). 

aAdd(aLayDetalhe, { "C",  1, 0,  1} )     // Tipo
aAdd(aLayDetalhe, { "N",  4, 0,  2} )     // Linha
aAdd(aLayDetalhe, { "C", 22, 0,  6} )     // Codigo da peca
aAdd(aLayDetalhe, { "N",  5, 0,  28} )     // Quantidade pedida

// Registro Tipo 3 (Trailler). 

aAdd(aLayTrailler, { "C",  1, 0,  1} )     // Tipo
aAdd(aLayTrailler, { "N",  4, 0,  2} )     // Linha
aAdd(aLayTrailler, { "N",  4, 0,  6} )     // Qtd. Detalhes

cQryAliasSF2 := GetNextAlias()

For i := 1 to Len(aPedPen)                         
   if aPedPen[i,1]
		//
		//#############################################################################
		//# Tenta abrir o arquivo texto                                               #
		//#############################################################################
		cArquivo := "PP"+aPedPen[i,4]+".TXT"
		//
	    aValCab := {}  
	    aValDet := {}
		if aDir( Alltrim(MV_PAR01)+cArquivo ,aVetNome,aVetTam,aVetData,aVetHora) > 0
			if !MsgYesNo(STR0011,STR0012)
				lErro := .t.
				return
			endif
		endif
		//
		nHnd := FCREATE(Alltrim(MV_PAR01)+Alltrim(cArquivo),0)
		
		cQuery := "SELECT DISTINCT VI5.VI5_CODPED,VI5.VI5_CODMAR,VI5.VI5_TIPPED,SC7.C7_COND "
		cQuery += "FROM " + RetSQLName("VI5" ) + " VI5 "  
		cQuery += "LEFT JOIN " + RetSqlName("VEI") + " VEI ON VEI.VEI_FILIAL = '" +xFilial("VEI") + "' AND VEI.VEI_PEDFAB = VI5.VI5_CODPED AND VEI.D_E_L_E_T_ = ' ' "
		cQuery += "LEFT JOIN " + RetSqlName("SC7") + " SC7 ON SC7.C7_FILIAL = '" +xFilial("SC7") + "' AND SC7.C7_NUM = VEI.VEI_NUM AND SC7.D_E_L_E_T_ = ' ' "
		cQuery += "WHERE VI5.VI5_FILIAL = '" + xFilial("VI5") + "' AND "
		if !Empty(MV_PAR02)
			cQuery += "VI5.VI5_CODMAR = '"+MV_PAR02+"' AND "
		Endif	
		cQuery += "VI5.VI5_CODPED = '"+aPedPen[i,4]+"' AND "
		cQuery += "VI5.D_E_L_E_T_ = ' '"
		
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAliasVI5, .F., .T. )
		//
		nTotReg := Contar(cQryAliasVI5, "!Eof()")
		//
		SetRegua(nTotReg)
		                                                  
		(cQryAliasVI5)->(DBGoTop())
		
		While  !(cQryAliasVI5)->(Eof())
		                            
		    cDia  := Alltrim(strzero(day(ddatabase),2))
		    cMes  := Alltrim(strzero(month(ddatabase),2))
		    cAno  := Alltrim(strzero(year(ddatabase),4))
		    cData := cDia+"/"+cMes+"/"+cAno
                   
//		    dbSelectArea("VEJ")
//		    dbSelectArea(1)
//		    dbSeek(xFilial("VEJ")+(cQryAliasVI5)->VI5_CODMAR+(cQryAliasVI5)->VI5_TIPPED)
//		    if VEJ->VEJ_PROGRA == "2"
//		       cTipPed := "1"
//		    Else
//		       cTipPed := "0"
//		    Endif   

		    cTipPed := ""
            if Alltrim((cQryAliasVI5)->VI5_TIPPED) $ MV_PAR04
		       cTipPed := "0"
            Endif
            if Alltrim((cQryAliasVI5)->VI5_TIPPED) $ MV_PAR05
		       cTipPed := "1"
            Endif

            cTipCond := ""
            if Alltrim((cQryAliasVI5)->C7_COND) $ MV_PAR06
               cTipCond := 0
            Endif
            if Alltrim((cQryAliasVI5)->C7_COND) $ MV_PAR07
               cTipCond := 2
            Endif
               
//            dbSelectArea("SE4")
//            dbSetOrder(1)
//            dbSeek(xFilial("SE4")+(cQryAliasVI5)->C7_COND)
//            if SE4->E4_TIPO == "1" .AND. (Alltrim(SE4->E4_COND) == "0" .or. Alltrim(SE4->E4_COND) == "00")
//               cTipCond := 0
//            Else
//               cTipCond := 1
//            Endif   
            
            if MV_PAR10 == 1
               cPagar := 0
            Else
               cPagar := 1
            Endif    
			aAdd(aValCab,{"1",1,MV_PAR03,cData,(cQryAliasVI5)->VI5_CODPED,cTipPed,cTipCond,MV_PAR08,MV_PAR09,cPagar})

		//	aAdd(aVetVeic,{(cQryAliasVV1)->VV1_CHASSI,SD1->D1_EMISSAO,FGX_VLRSUGV( (cQryAliasVV1)->( VV1_CHAINT ) , , , , , .t. )} )
		
		   dbSelectArea("VI5")
		   dbSetOrder(1)
		   if dbSeek(xFilial("VI5")+(cQryAliasVI5)->VI5_CODMAR+(cQryAliasVI5)->VI5_CODPED)
		      RecLock("VI5",.f.)
		      VI5->VI5_TRANSM := "S"
		      MsUnlock()
		   Endif                        
		   
		   dbSelectArea(cQryAliasVI5)
		   (cQryAliasVI5)->(dbSkip())
		   
		Enddo   
		(cQryAliasVI5)->(dbCloseArea())

		cQuery := "SELECT VIB.VIB_CODITE,VIB.VIB_QTDADE "
		cQuery += "FROM " + RetSQLName("VIB" ) + " VIB "  
		cQuery += "WHERE VIB.VIB_FILIAL = '" + xFilial("VIB") + "' AND "
		if !Empty(MV_PAR02)
			cQuery += "VIB.VIB_CODMAR = '"+MV_PAR02+"' AND "
		Endif	
		cQuery += "VIB.VIB_CODPED = '"+aPedPen[i,4]+"' AND "
		cQuery += "VIB.D_E_L_E_T_ = ' '"
		
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAliasVIB, .F., .T. )
		//
		nTotReg := Contar(cQryAliasVIB, "!Eof()")
		//
		SetRegua(nTotReg)
		                                                  
		(cQryAliasVIB)->(DBGoTop())
		                      
		nSeq := 1
		While  !(cQryAliasVIB)->(Eof())
                     
     
			aAdd(aValDet,{"2",nSeq,(cQryAliasVIB)->VIB_CODITE,(cQryAliasVIB)->VIB_QTDADE})

		//	aAdd(aVetVeic,{(cQryAliasVV1)->VV1_CHASSI,SD1->D1_EMISSAO,FGX_VLRSUGV( (cQryAliasVV1)->( VV1_CHAINT ) , , , , , .t. )} )
		
           nSeq += 1
           
		   dbSelectArea(cQryAliasVIB)
		   (cQryAliasVIB)->(dbSkip())
		   
		Enddo   
		(cQryAliasVIB)->(dbCloseArea())
   Endif	

	nQtd := 0
	For y := 1 to Len(aValCab)
	
		cLinha := MontaEDI(aLayHeader,aValCab[y])
	  	fwrite(nHnd,cLinha)
	  	nQtd += 1
	
	Next
	
	For m := 1 to Len(aValDet)
	
		cLinha := MontaEDI(aLayDetalhe,aValDet[m])
	  	fwrite(nHnd,cLinha)
	  	nQtd += 1
	
	Next
	nQtd += 1
	
	// Monta CAI
	aValTrei := {}
	aAdd(aValTrei,{"9",nQtd,Len(aValDet)} )
	cLinha := MontaEDI(aLayTrailler,aValTrei[1])
	fwrite(nHnd,cLinha)

	fClose(nHnd)

Next     

MsgInfo(STR0013,STR0012)

return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | OFIXN003   | Autor |  Luis Delorme         | Data | 30/05/11 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Monta layout.                                                |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function MontaEDI(aLayout, aInfo)
Local nCntFor
Local cLinha := ""
for nCntFor = 1 to Len(aLayout)
	//
	cTipo := aLayout[nCntFor,1]
	nTamanho := aLayout[nCntFor,2]
	nDecimal := aLayout[nCntFor,3]
	nPosIni := aLayout[nCntFor,4]
	//
	ncValor := ""
	if Alltrim(cTipo) == "N"
		if valType(aInfo[nCntFor]) == "C"
			aInfo[nCntFor] = val(aInfo[nCntFor])
		endif
		ncValor = STRZERO(Round(aInfo[nCntFor] * (10 ^ nDecimal),0),nTamanho)
	elseif Alltrim(cTipo) == "D"       
	    cDia := substr(dtoc(aInfo[nCntFor]),1,2)
	    cMes := substr(dtoc(aInfo[nCntFor]),4,2)
	    cAno := substr(dtoc(aInfo[nCntFor]),7,4)
		ncValor := cDia+"/"+cMes+"/"+cAno
	else
		ncValor := LEFT(aInfo[nCntFor]+SPACE(nTamanho),nTamanho)
	endif
	cLinha += ncValor
next
cLinha += CHR(13) + CHR(10)
return cLinha

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | CriaSX1	  | Autor | Thiago                | Data | 18/02/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Criacao das perguntes.								        |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/     
Static Function CriaSX1()
Local aSX1    := {}
Local aEstrut := {}
Local i       := 0
Local j       := 0
Local lSX1	  := .F.
Local nOpcGetFil := GETF_LOCALHARD + GETF_NETWORKDRIVE + GETF_RETDIRECTORY

aEstrut:= { "X1_GRUPO"  ,"X1_ORDEM","X1_PERGUNT","X1_PERSPA","X1_PERENG" ,"X1_VARIAVL","X1_TIPO" ,"X1_TAMANHO","X1_DECIMAL","X1_PRESEL"	,;
"X1_GSC"    ,"X1_VALID","X1_VAR01"  ,"X1_DEF01" ,"X1_DEFSPA1","X1_DEFENG1","X1_CNT01","X1_VAR02"  ,"X1_DEF02"  ,"X1_DEFSPA2"	,;
"X1_DEFENG2","X1_CNT02","X1_VAR03"  ,"X1_DEF03" ,"X1_DEFSPA3","X1_DEFENG3","X1_CNT03","X1_VAR04"  ,"X1_DEF04"  ,"X1_DEFSPA4"	,;
"X1_DEFENG4","X1_CNT04","X1_VAR05"  ,"X1_DEF05" ,"X1_DEFSPA5","X1_DEFENG5","X1_CNT05","X1_F3"     ,"X1_GRPSXG" ,"X1_PYME" ,"X1_GRPSXG" ,"X1_HELP","X1_PICTURE"}


aAdd(aSX1,{cPerg,"01",STR0015,"","","MV_CH1","C",99,0,0,"G","!Vazio().or.(Mv_Par01:=cGetFile('Arquivos |*.*','',,,,"+AllTrim(Str(nOpcGetFil))+"))","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
aAdd(aSX1,{cPerg,"02",STR0006,"","","MV_CH2","C", 3,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","VE1",""	,"S","","",""})
aAdd(aSX1,{cPerg,"03",STR0016,"","","MV_CH3","N", 5,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","","99999"})
aAdd(aSX1,{cPerg,"04",STR0017,"","","MV_CH4","C",20,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
aAdd(aSX1,{cPerg,"05",STR0018,"","","MV_CH5","C",20,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
aAdd(aSX1,{cPerg,"06",STR0019,"","","MV_CH6","C",20,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
aAdd(aSX1,{cPerg,"07",STR0020,"","","MV_CH7","C",20,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
aAdd(aSX1,{cPerg,"08",STR0021,"","","MV_CH8","N", 1,0,0,"C","","mv_par08",STR0024,"","","","",STR0025,"","","","",STR0026,"","","","","","","","","","","","","","",""	,"S","","9",""})
aAdd(aSX1,{cPerg,"09",STR0022,"","","MV_CH9","C", 3,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
aAdd(aSX1,{cPerg,"10",STR0023,"","","MV_CHA","N", 1,0,0,"C","","mv_par10",STR0027,"","","","",STR0028,"","","","","","","","","","","","","","","","","","","",""	,"S","","","9"})

ProcRegua(Len(aSX1))

dbSelectArea("SX1")
dbSetOrder(1)
For i:= 1 To Len(aSX1)
	If !Empty(aSX1[i][1])
		If !dbSeek(Left(Alltrim(aSX1[i,1])+SPACE(100),Len(SX1->X1_GRUPO))+aSX1[i,2])
			lSX1 := .T.
			RecLock("SX1",.T.)
			
			For j:=1 To Len(aSX1[i])
				If !Empty(FieldName(FieldPos(aEstrut[j])))
					FieldPut(FieldPos(aEstrut[j]),aSX1[i,j])
				EndIf
			Next j
			
			dbCommit()
			MsUnLock()
			IncProc(STR0029)
		EndIf
	EndIf
Next i

return
           
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡…o    | FS_MARKA   | Autor | Thiago                | Data | 05/03/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡…o | Marca listbox.					                            |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_MARKA(nLin)

if aPedPen[nLin,01]
   aPedPen[nLin,01] := .f.
Else
   aPedPen[nLin,01] := .t.
Endif   

Return(.t.)

Static Function FS_TELA()
Local i := 0                  

DEFINE MSDIALOG oDlgPed TITLE OemtoAnsi(STR0005) FROM  08,10 TO 30,74 OF oMainWnd   //"Foram identificadas algumas inconsistencias no arquivo!"

	@ 001,001 LISTBOX oLbx3 FIELDS HEADER "",STR0006,STR0007,STR0008,STR0009 COLSIZES 40,50,50,50,50 SIZE 253,144 OF oDlgPed PIXEL ON DBLCLICK (FS_MARKA(oLbx3:nAt) )
	oLbx3:SetArray(aPedPen)
	oLbx3:bLine := { || {IIf(aPedPen[oLbx3:nAt,01] == .f.,oNo,oTik),;
	aPedPen[oLbx3:nAt,2],;
	aPedPen[oLbx3:nAt,3],;
	aPedPen[oLbx3:nAt,4],;
	aPedPen[oLbx3:nAt,5]}}

	DEFINE SBUTTON FROM 152,190 TYPE 1 ACTION ( nOpca := 1, oDlgPed:End() ) ENABLE OF oDlgPed
	DEFINE SBUTTON FROM 152,225 TYPE 2 ACTION ( nOpca := 0, oDlgPed:End() ) ENABLE OF oDlgPed
	
ACTIVATE MSDIALOG oDlgPed CENTER
           
cAchou := "0"
if nOpca == 1
	For i := 1 to Len(aPedPen)                         
   		if aPedPen[i,1]
	       cAchou := "1"
	    Endif   
	Next    
	if cAchou == "0"
	     MsgInfo(STR0030)
    	  FS_TELA()
    Endif
Else
   cAchou := "3"
Endif

Return(cAchou)