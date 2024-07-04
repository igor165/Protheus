#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "VEIXI004.CH"   

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | VEIXI004   | Autor | Thiago                | Data | 18/02/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Exportação do arquivo de comunicação EDI com a montadora 	|##
##|          | MITSUBISHI veículos - Assunto ESTOQUE DE VEÍCULOS SEMI NOVOS.|##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VEIXI004(lPainel,nFilSIR,MVPar03,MVPar04)
//
Local cDesc1  := STR0001
Local cDesc2  := STR0002
Local cDesc3  := STR0003
Local aSay := {}
Local aButton := {}

Private cTitulo := STR0004
Private cPerg := "VXI004" 	
Private lErro := .f.  	    // Se houve erro, não move arquivo gerado
Private cArquivo			// Nome do Arquivo a ser importado
Private aLayCK6011 := {}
Private aVetVeic := {}   
Private nFilS    := 0
Default lPainel  := .f.
Default nFilSIR  := 0

// SX1
// aAdd(aRegs,{STR0018,STR0018,STR0018,"MV_CH1","C",99,0,0,"G","!Vazio().or.(Mv_Par01:=cGetFile('Arquivos |*.*','',,,,"+AllTrim(Str(nOpcGetFil))+"))","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
// aAdd(aRegs,{STR0019,STR0019,STR0019,"MV_CH2","N",5 ,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","S","","","99999"})


if nFilSIR <> 0 
	nFilS := nFilSIR
Endif	
//
aAdd( aSay, cDesc1 ) // Um para cada cDescN
aAdd( aSay, cDesc2 ) // Um para cada cDescN
aAdd( aSay, cDesc3 ) // Um para cada cDescN
//
If !FWGetRunSchedule() // não está sendo chamada pelo Schedule
	//
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
	RptStatus( {|lEnd| ExportArq(@lEnd)},"",STR0005)
	//
	If !FWGetRunSchedule() // não está sendo chamada pelo Schedule
		RptStatus({|lEnd| ImprimeRel(@lEnd) },STR0006, STR0007, .T. )
	Endif
	//
Else
	//
	MV_Par01 := MVPar03
	Mv_Par02 := MVPar04
	//
	ExportArq()
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
Local cQryAliasVV1 := "SQLVV1"   
Local aVetNome := {}
Local aVetTam := {}
Local aVetData := {}
Local aVetHora := {}  
Local aLayVei  := {}
Local dUltcom  := ctod("")
Private cGruVei  := PadR(AllTrim(GetMv("MV_GRUVEI")),TamSx3("B1_GRUPO")[1]," ") // Grupo do Veiculo

aSM0 := FWArrFilAtu(cEmpAnt,cFilAnt) // Filial Origem (Filial logada)


aAdd(aLayVei, { "N",  3, 0,  1} )     // Versão Layout
aAdd(aLayVei, { "C",  5, 0,  4} )     // Código Concessionária
aAdd(aLayVei, { "N",  3, 0,  9} )     // Marca
aAdd(aLayVei, { "N",  5, 0, 12} )     // Modelo
aAdd(aLayVei, { "C",200, 0, 17} )     // Opcionais
aAdd(aLayVei, { "N",  4, 0,217} )     // Ano Fabricação
aAdd(aLayVei, { "N",  4, 0,221} )     // Ano Modelo
aAdd(aLayVei, { "C",  5, 0,225} )     // Cor
aAdd(aLayVei, { "C", 20, 0,230} )     // Chassi
aAdd(aLayVei, { "C",  3, 0,250} )     // Letras Placa
aAdd(aLayVei, { "N",  4, 0,253} )     // Numero Placa
aAdd(aLayVei, { "N", 20, 0,257} )     // KM
aAdd(aLayVei, { "N", 10, 0,277} )     // Valor
aAdd(aLayVei, { "C",  1, 0,287} )     // Valor oculto
aAdd(aLayVei, { "C",200, 0,288} )     // Observação
aAdd(aLayVei, { "D", 10, 0,488} )     // Data Entrada Veiculo Estoque


cQryAliasSF2 := GetNextAlias()

cQuery := "SELECT DISTINCT VE1.VE1_MAREDI,VV1.VV1_FABMOD,VVC.VVC_COREDI,VV1.VV1_CHASSI,VV1.VV1_PLAVEI,VV1.VV1_OBSMEM,VV1.VV1_CHAINT,VV1.VV1_KILVEI,VV2.VV2_MODEDI "
cQuery += " FROM " + RetSQLName("VV1" ) + " VV1 "  
cQuery += " INNER JOIN "+RetSqlName("VE1")+" VE1 ON VE1.VE1_FILIAL = '" + xFilial("VE1") + "' AND VE1.VE1_CODMAR = VV1.VV1_CODMAR AND VE1.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("VV2")+" VV2 ON VV2.VV2_FILIAL = '" + xFilial("VV2") + "' AND VV2.VV2_CODMAR = VV1.VV1_CODMAR AND VV2.VV2_MODVEI = VV1.VV1_MODVEI AND VV2.VV2_SEGMOD = VV1.VV1_SEGMOD AND VV2.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("VVC")+" VVC ON VVC.VVC_FILIAL = '" + xFilial("VVC") + "' AND VVC.VVC_CODMAR = VV1.VV1_CODMAR AND VVC.VVC_CORVEI = VV1.VV1_CORVEI AND VVC.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.B1_GRUPO = '"+cGruVei+"' AND SB1.B1_CODITE = VV1.VV1_CHAINT AND SB1.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("SB2")+" SB2 ON SB2.B2_FILIAL = '" + xFilial("SB2") + "' AND SB2.B2_COD = SB1.B1_COD AND SB2.B2_QATU > 0 AND SB1.D_E_L_E_T_ = ' ' "
cQuery += " WHERE VV1.VV1_FILIAL = '" + xFilial("VV1") + "' AND VV1.VV1_ESTVEI = '1' AND "
cQuery += "VV1.D_E_L_E_T_ = ' '"

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAliasVV1, .F., .T. )
//
nTotReg := Contar(cQryAliasVV1, "!Eof()")
//
If !FWGetRunSchedule() // não está sendo chamada pelo Schedule
	SetRegua(nTotReg)
Endif

(cQryAliasVV1)->(DBGoTop())
       
if nFilS == 0 
	nFilS := mv_par02
Endif
if !(cQryAliasVV1)->(Eof())                                                  
	//
	//#############################################################################
	//# Tenta abrir o arquivo texto                                               #
	//#############################################################################


	cArquivo := StrZero(nFilS,5)+"_"+cFilAnt+".TXT"
	//
	aDir( Alltrim(MV_PAR01)+cArquivo ,aVetNome,aVetTam,aVetData,aVetHora)
	//
	nHnd := FCREATE(Alltrim(MV_PAR01)+Alltrim(cArquivo),0)
Else
	If !FWGetRunSchedule() // não está sendo chamada pelo Schedule
		MsgInfo(STR0022+CHR(10)+CHR(13)+STR0021+cFilAnt+" - "+aSM0[7])
	Endif
Endif

While  !(cQryAliasVV1)->(Eof())

	nAno := Year(ddatabase)
	nMes := Month(ddatabase)
	nDia := Day(ddatabase)
	nData = nDia * 1000000 + nMes * 10000 + nAno 
	
	dUltcom  := ctod("")
	aQUltMov := FM_VEIUMOV( (cQryAliasVV1)->( VV1_CHASSI ) , "E" , "0" )
	If len(aQUltMov) > 0
		dUltCom := (aQUltMov[5])
	EndIf
	                 
	dbSelectArea("SYP")
	dbSetOrder(1)
	dbSeek(xFilial("SYP")+(cQryAliasVV1)->VV1_OBSMEM)      
	cObs := ""
	While !Eof() .and. xFilial("SYP") == SYP->YP_FILIAL .and. (cQryAliasVV1)->VV1_OBSMEM == SYP->YP_CHAVE

		nPos := AT("\13\10",SYP->YP_TEXTO)
		if nPos > 0
			nPos -= 1
		Else
			nPos := Len(SYP->YP_TEXTO)
		Endif
	
		cObs += Alltrim(Substr(SYP->YP_TEXTO,1,nPos))+" "
		SYP->(DbSkip())
	Enddo
    
	aValores := {"001",strzero(nFilS,5),;
	(cQryAliasVV1)->VE1_MAREDI,substr((cQryAliasVV1)->VV2_MODEDI,1,5),"",substr((cQryAliasVV1)->VV1_FABMOD,1,4),substr((cQryAliasVV1)->VV1_FABMOD,5,4),(cQryAliasVV1)->VVC_COREDI,(cQryAliasVV1)->VV1_CHASSI,substr((cQryAliasVV1)->VV1_PLAVEI,1,3),substr((cQryAliasVV1)->VV1_PLAVEI,4,4),(cQryAliasVV1)->VV1_KILVEI,FGX_VLRSUGV( (cQryAliasVV1)->( VV1_CHAINT ) , , , , , .t. ),"",PADR(cObs,200),dUltCom}

	aAdd(aVetVeic,{(cQryAliasVV1)->VV1_CHASSI,dUltCom,FGX_VLRSUGV( (cQryAliasVV1)->( VV1_CHAINT ) , , , , , .t. )} )
		
	cLinha := MontaEDI(aLayVei,aValores)
    
	fwrite(nHnd,cLinha)

   dbSelectArea(cQryAliasVV1)
   (cQryAliasVV1)->(dbSkip())
   
Enddo   

if !(cQryAliasVV1)->(Eof())                                                  
	fClose(nHnd)

Endif
(cQryAliasVV1)->(dbCloseArea())

return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡…o    | ImprimeRel | Autor | Luis Delorme          | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡…o | Imprime o resultado da importação                           |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function ImprimeRel()

Local nCntFor

Local cDesc1  := STR0011
Local cDesc2  := "" 
Local cDesc3  := ""

Private cString  := "VV1" // TODO
Private Tamanho  := "M"
Private aReturn  := { STR0012,2,STR0013,2,2,1,"",1 }
Private wnrel    := "ESTVEIC" // TODO
Private NomeProg := "ESTVEIC" // TODO
Private nLastKey := 0
Private Limite   := 80
Private Titulo   := STR0014
Private nTipo    := 0
Private cbCont   := 0
Private cbTxt    := " "
Private Li       := 80
Private m_pag    := 1
Private aOrd     := {}
Private Cabec1   := " "  // TODO
Private Cabec2   := " "  // TODO
Private cPerg := ""
//+-------------------------------------------------------------------------------
//| Solicita ao usuario a parametrizacao do relatorio.
//+-------------------------------------------------------------------------------
wnrel := SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,.F.,.F.)
//+-------------------------------------------------------------------------------
//| Se teclar ESC, sair
//+-------------------------------------------------------------------------------
If nLastKey == 27
	Return
Endif
//+-------------------------------------------------------------------------------
//| Estabelece os padroes para impressao, conforme escolha do usuario
//+-------------------------------------------------------------------------------
SetDefault(aReturn,cString)
//+-------------------------------------------------------------------------------
//| Verificar se sera reduzido ou normal
//+-------------------------------------------------------------------------------
nTipo := Iif(aReturn[4] == 1, 15, 18)
//+-------------------------------------------------------------------------------
//| Se teclar ESC, sair
//+-------------------------------------------------------------------------------
If nLastKey == 27
	Return
Endif
//+-------------------------------------------------------------------------------
//| Chama funcao que processa os dados
//+-------------------------------------------------------------------------------

aSM0 := FWArrFilAtu(cEmpAnt,cFilAnt) // Filial Origem (Filial logada)

li := 1
li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
li++

@ Li++, 1 PSay STR0021+cFilAnt+" - "+aSM0[7]
li++

@ Li++, 1 PSay STR0015
@ Li++, 0 psay Repl("*",52) 

 
for nCntFor = 1 to Len(aVetVeic)
	
	If Li > 55                                  
		li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		li++
	Endif
	// 
	@ Li++, 1   PSay aVetVeic[nCntFor,1]+" "+transform(aVetVeic[nCntFor,2],"@D")+" "+transform(aVetVeic[nCntFor,3],"@E 999,999,999.99")
	//+-------------------------------------------------------------------------------
	//| Se teclar ESC, sair
	//+-------------------------------------------------------------------------------
	If nLastKey == 27
		@ Li++ , 1 psay STR0016
		exit
	Endif
next
//
If Li <> 80
	Roda(cbCont,cbTxt,Tamanho)
Endif
//
If aReturn[5] == 1
	Set Printer TO
	dbCommitAll()
	OurSpool(wnrel)
EndIf
//
Ms_Flush()
//
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

