#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "VEIXI003.CH"

/*
================================================================================
################################################################################
##+----------+------------+-------+-----------------------+------+-----------+##
##|Função    | VEIXI003   | Autor | Thiago                | Data | 12/03/13  |##
##+----------+------------+-------+-----------------------+------+-----------+##
##|Descrição | A exportação das NOTAS FISCAIS DE VEÍCULOS MitSubishi         |##
##+----------+---------------------------------------------------------------+##
##|Uso       |                                                               |##
##+----------+---------------------------------------------------------------+##
################################################################################
================================================================================
*/
Function VEIXI003(lPainel,nFilSIR,MVPar01,MVPar02,MVPar03,MVPar04,MVPar05,MVPar06,MVPar07,MVPar08)
//
Local cDesc1  := STR0001
Local cDesc2  := STR0002
Local cDesc3  := STR0003
Local aSay := {}
Local aButton := {}

Private cTitulo := STR0004
Private cPerg := "VXI003" 	
Private lErro := .f.  	    // Se houve erro, não move arquivo gerado
Private cArquivo			// Nome do Arquivo a ser importado
Private oNo      := LoadBitmap( GetResources(), "LBNO" )
Private oTik     := LoadBitmap( GetResources(), "LBTIK" )
Private nFilS    := 0
Default lPainel  := .f.
Default nFilSIR  := 0


// CRIASX1 
// Local nOpcGetFil := GETF_LOCALHARD + GETF_NETWORKDRIVE + GETF_RETDIRECTORY
// aAdd(aRegs,{STR0012,STR0012,STR0012,"MV_CH1","D", 8,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
// aAdd(aRegs,{STR0013,STR0013,STR0013,"MV_CH2","D", 8,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
// aAdd(aRegs,{STR0014,STR0014,STR0014,"MV_CH3","C",99,0,0,"G","!Vazio().or.(Mv_Par03:=cGetFile('Arquivos |*.*','',,,,"+AllTrim(Str(nOpcGetFil))+"))","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
// aAdd(aRegs,{STR0015,STR0015,STR0015,"MV_CH4","N", 6,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","","999999"})
// aAdd(aRegs,{STR0016,STR0016,STR0016,"MV_CH5","N", 1,0,0,"C","","mv_par05",STR0017,"","","","",STR0018,"","","","","","","","","","","","","","","","","","","",""	,"S","","","9"})
// aAdd(aRegs,{STR0020,STR0020,STR0020,"MV_CH6","C", 3,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","VE1",""	,"S","","",""})
// aAdd(aRegs,{STR0023,STR0023,STR0023,"MV_CH7","C", 9,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","SF2",""	,"S","","",""})
// aAdd(aRegs,{STR0024,STR0024,STR0024,"MV_CH8","C", TamSx3(FGX_MILSNF("SF2", 3, "F2_SERIE"))[1],0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
// aAdd(aRegs,{STR0025,STR0025,STR0025,"MV_CH9","C", 1,0,0,"C","","mv_par09",STR0026,"","","","",STR0027,"","","","",STR0028,"","","","",STR0030,"","","","","","","","","",""	,"S","","",""})

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

	If !Empty(Mv_Par07)
		If Mv_Par09 == 1
			MsgStop(STR0021,STR0007)
			return
		Endif
	Endif
	//
	RptStatus( {|lEnd| ExportArq(@lEnd)},"",STR0005)
	//
Else
	//
	MV_Par01 := MVPar01
	MV_Par02 := MVPar02
	MV_Par03 := MVPar03
	MV_Par04 := MVPar04
	MV_Par05 := MVPar05
	MV_Par06 := MVPar06
	MV_Par10 := MVPar07
	Mv_Par11 := MVPar08
	MV_Par07 := ""
	MV_Par08 := ""
	MV_Par09 := 1
	//
	ExportArq()
	//
Endif
//
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
Local cPrefVEI := GetNewPar("MV_PREFVEI","VEI")
Local lRetorn  := .f.
Private cQrySF2   := "SQLSF2"    
Private aSM0     := {}
aSM0 := FWArrFilAtu(cEmpAnt,cFilAnt) // Filial Origem (Filial logada)

cQuery := "SELECT DISTINCT SF2.F2_DOC , SF2.F2_SERIE, SF2.F2_FILIAL , SF2.F2_EMISSAO , SF2.F2_CLIENTE , SF2.F2_LOJA , SX5.X5_DESCRI , VV1.VV1_KILVEI , VV1.VV1_PLAVEI , VV1.VV1_CHAINT , VV1.VV1_CHASSI , VV1.VV1_PROATU , VV1.VV1_LJPATU , SF2.F2_VEND1 , SD2.D2_CF , SD2.D2_TOTAL ,SF2.D_E_L_E_T_ AS SF2DEL "
if mv_par09 <> 4
	cQuery += ", VV0.R_E_C_N_O_ AS VV0REC "
Endif
cQuery += "FROM " + RetSQLName("SF2" ) + " SF2 "  
cQuery += "INNER JOIN "+RetSqlName("SD2")+" SD2 ON (SD2.D2_FILIAL = '"+xFilial("SD2")+"' AND SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND SD2.D2_CLIENTE = SF2.F2_CLIENTE AND SD2.D2_LOJA = SF2.F2_LOJA) "
cQuery += "INNER JOIN "+RetSqlName("SF4")+" SF4 ON (SF4.F4_FILIAL = '"+xFilial("SF4")+"' AND SF4.F4_CODIGO = SD2.D2_TES AND SF4.F4_OPEMOV = '05' AND SF4.D_E_L_E_T_=' ') "
cQuery += "INNER JOIN "+RetSqlName("SB1")+" SB1 ON (SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.B1_COD = SD2.D2_COD AND SB1.D_E_L_E_T_=' ') "
if mv_par09 <> 4
	cQuery += "INNER JOIN "+RetSqlName("VV0")+" VV0 ON (VV0.VV0_FILIAL = '"+xFilial("VV0")+"' AND VV0.VV0_NUMNFI = SF2.F2_DOC AND VV0.VV0_SERNFI = SF2.F2_SERIE AND VV0.VV0_TIPFAT <> '1') "
Endif
cQuery += "INNER JOIN "+RetSqlName("VV1")+" VV1 ON (VV1.VV1_FILIAL = '"+xFilial("VV1")+"' AND VV1.VV1_CHAINT = SB1.B1_CODITE AND "
if !Empty(MV_PAR06)
	cQuery += "VV1.VV1_CODMAR = '"+MV_PAR06+"' AND "
Endif	
cQuery += "VV1.D_E_L_E_T_=' ') "
cQuery += "LEFT JOIN "+RetSqlName("SX5")+" SX5 ON (SX5.X5_FILIAL = '"+xFilial("SX5")+"' AND SX5.X5_TABELA = '13' AND SX5.X5_CHAVE = SD2.D2_CF AND SX5.D_E_L_E_T_=' ') "
cQuery += " WHERE  SF2.F2_FILIAL = '" + xFilial("SF2") + "' AND SF2.F2_EMISSAO >= '"+dtos(MV_PAR01)+"' AND SF2.F2_EMISSAO <= '"+dtos(MV_PAR02)+"' AND SF2.F2_PREFORI = '"+cPrefVEI+"'"

If Empty(Mv_Par07)   
	if mv_par09 == 1
		cQuery += " AND NOT EXISTS (SELECT VDU_NUMSEQ FROM "+RetSQLName("VDU")+" VDU WHERE VDU.VDU_FILIAL='"+xFilial("VDU")+"' AND SF2.F2_FILIAL = VDU.VDU_FILDOC AND VDU.VDU_CODMAR='"+MV_Par06+"' AND VDU.VDU_NUMDOC = SF2.F2_DOC AND VDU.VDU_SERDOC = SF2.F2_SERIE AND VDU.D_E_L_E_T_=' ') "
	Endif		
Else
	cQuery += " AND SF2.F2_DOC = '" + Mv_Par07 +"' AND SF2.F2_SERIE LIKE '" + Mv_Par08 + "%' "
Endif       
if mv_par09 == 4 // Cancelamento
	cQuery += " AND SF2.D_E_L_E_T_<>' ' "  
Else
	cQuery += " AND SF2.D_E_L_E_T_=' ' AND SD2.D_E_L_E_T_=' ' AND VV0.D_E_L_E_T_=' '	"
Endif

	
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQrySF2, .F., .T. )
nTotReg := Contar(cQrySF2, "!Eof()")

If !FWGetRunSchedule() // não está sendo chamada pelo Schedule
	SetRegua(nTotReg)
Endif
		                                                  
(cQrySF2)->(DBGoTop())
		
cTIPCli := "P"	
While  !(cQrySF2)->(Eof())

	lRetorn := .t. 
	FS_IMPRESSAO()

    dbSelectArea(cQrySF2)
    (cQrySF2)->(dbSkip())
    
Enddo    
(cQrySF2)->(dbCloseArea())

// DEVOLUCAO
if mv_par09 == 4

	cQuery := "SELECT DISTINCT SF2.F2_DOC , SF2.F2_SERIE, SF2.F2_FILIAL , SF2.F2_EMISSAO , SF2.F2_CLIENTE , SF2.F2_LOJA , SX5.X5_DESCRI , VV1.VV1_KILVEI , VV1.VV1_PLAVEI , VV1.VV1_CHAINT , VV1.VV1_CHASSI , VV1.VV1_PROATU , VV1.VV1_LJPATU , SF2.F2_VEND1 , SD2.D2_CF , SD2.D2_TOTAL " 
	cQuery += "FROM "+RetSqlName("SF1")+ " SF1 "
	cQuery += "JOIN "+RetSqlName("SD1")+ " SD1 ON SF1.F1_DOC=SD1.D1_DOC AND SD1.D1_FILIAL='"+xFilial("SD1")+"' "
	cQuery += "JOIN "+RetSqlName("SF2")+ " SF2 ON SD1.D1_NFORI=SF2.F2_DOC AND SF2.F2_FILIAL='"+xFilial("SF2")+"' "
	cQuery += "INNER JOIN "+RetSqlName("SD2")+" SD2 ON (SD2.D2_FILIAL = '"+xFilial("SD2")+"' AND SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND SD2.D2_CLIENTE = SF2.F2_CLIENTE AND SD2.D2_LOJA = SF2.F2_LOJA) "
	cQuery += "INNER JOIN "+RetSqlName("SB1")+" SB1 ON (SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.B1_COD = SD2.D2_COD AND SB1.D_E_L_E_T_=' ') "
	cQuery += "LEFT JOIN "+RetSqlName("SX5")+" SX5 ON (SX5.X5_FILIAL = '"+xFilial("SX5")+"' AND SX5.X5_TABELA = '13' AND SX5.X5_CHAVE = SD2.D2_CF AND SX5.D_E_L_E_T_=' ') "
	cQuery += "INNER JOIN "+RetSqlName("VV1")+" VV1 ON (VV1.VV1_FILIAL = '"+xFilial("VV1")+"' AND VV1.VV1_CHAINT = SB1.B1_CODITE AND "
	if !Empty(MV_PAR06)
		cQuery += "VV1.VV1_CODMAR = '"+MV_PAR06+"' AND "
	Endif	
	cQuery += "VV1.D_E_L_E_T_=' ') "
	cQuery += "WHERE SF1.F1_FILIAL='"+xFilial("SF1")+"' AND SD1.D1_TIPO='D' AND "
	cQuery += "SF1.F1_DTDIGIT>='"+dtos(MV_PAR01)+"' AND SF1.F1_DTDIGIT<='"+dtos(MV_PAR02)+"' "
	If !Empty(Mv_Par07)
		cQuery += " AND SF2.F2_DOC = '" + Mv_Par07 +"' AND SF2."+ FGX_MILSNF("SF2", 3, "F2_SERIE") +" LIKE '" + Mv_Par08 + "%' "
	Endif
	cQuery += " AND (SF2.F2_PREFORI = '"+cPrefVEI+"') AND "
	cQuery += "SF1.D_E_L_E_T_  = ' ' AND SD1.D_E_L_E_T_  = ' ' AND SF2.D_E_L_E_T_  = ' ' "
	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQrySF2, .F., .T. )

	While  !(cQrySF2)->(Eof())

		lRetorn := .t. 
		FS_IMPRESSAO()

		dbSelectArea(cQrySF2)
		(cQrySF2)->(dbSkip())
	
	Enddo
	(cQrySF2)->(dbCloseArea())
Endif

If !FWGetRunSchedule() // não está sendo chamada pelo Schedule
	if !lRetorn
		MsgStop(STR0022+chr(13) + chr(10)+chr(13) + chr(10)+STR0029+cFilAnt+" - "+aSM0[7],STR0007)
	Else
		MsgInfo(STR0010,STR0007)
	Endif
Endif

return


Static Function FS_IMPRESSAO()    
Local aVetNome := {}
Local aVetTam  := {}
Local aVetData := {}
Local aVetHora := {}   
Local cTpNota  := ""    
Local cPar10   := Subs(Alltrim(Mv_Par10),6)
Local cPar11   := Subs(Alltrim(Mv_Par11),6)
Local lCelularCust := !Empty(Mv_Par10) .and. !Empty(Mv_Par11) .and. SA1->(FieldPos((cPar10))) > 0 .and. SA1->(FieldPos((cPar11))) > 0
Local lEmplacament := .f.

if mv_par09 <> 4
	VV0->(dbgoto((cQrySF2)->(VV0REC)))
Endif
lEmplacament := VV0->(FieldPos("VV0_EMPLAC")) > 0
//
//#############################################################################
//# Tenta abrir o arquivo texto                                               #
//#############################################################################
if mv_par09 == 4
	cArquivo := "VEIXI003_"+(cQrySF2)->F2_DOC+"_"+cFilAnt+"C.XML"
Else
	cArquivo := "VEIXI003_"+(cQrySF2)->F2_DOC+"_"+cFilAnt+".XML"
Endif	
//
aDir( Alltrim(MV_PAR01)+cArquivo ,aVetNome,aVetTam,aVetData,aVetHora) 
//
nHnd := FCREATE(Alltrim(MV_PAR03)+Alltrim(cArquivo),0)
	
cLinha := "<?xml version='1.0' encoding='ISO-8859-1' ?>"+CHR(13)+CHR(10)
cLinha += "<notafiscal>"+CHR(13)+CHR(10)
    
cTpNota := "N"
if mv_par09 == 1
	cTpNota := "N"
Elseif mv_par09 == 2
	cTpNota := "CE"
Elseif mv_par09 == 3
	cTpNota := "CC"
Elseif mv_par09 == 4
	cTpNota := "C"
Endif

cLinha += "<header>"+CHR(13)+CHR(10)      
if MV_PAR05 == 1
   cTipoArq := "T"
Else
   cTipoArq := "P"
Endif   
if nFilS == 0
	nFilS := mv_par04
Endif
cLinha += "<tipoArquivo>"+Alltrim(cTipoArq)+"</tipoArquivo>"+CHR(13)+CHR(10)
cLinha += "<tipoNota>"+Alltrim(cTpNota)+"</tipoNota>"+CHR(13)+CHR(10)   
cLinha += "<codigoConcessionaria>"+Alltrim(PADR(Alltrim(str(nFilS)),6))+"</codigoConcessionaria>"+CHR(13)+CHR(10)
cLinha += "<cnpjConcessionaria>"+Alltrim(PADR(aSM0[18],18))+"</cnpjConcessionaria>"+CHR(13)+CHR(10)
cLinha += "<natOper>"+Alltrim(substr((cQrySF2)->X5_DESCRI,1,50))+"</natOper>"+CHR(13)+CHR(10)
cLinha += "<cfop>"+Alltrim(PADR((cQrySF2)->D2_CF,4))+"</cfop>"+CHR(13)+CHR(10)
cNumNota := Alltrim((cQrySF2)->F2_DOC)+"/"+Alltrim( FGX_UFSNF((cQrySF2)->(F2_SERIE)) )+"/"+"1"
cLinha += "<numeroNF>"+Alltrim(cNumNota)+"</numeroNF>"+CHR(13)+CHR(10) 
cLinha += "<dataEmissao>"+Alltrim(dtoc(stod((cQrySF2)->F2_EMISSAO)))+"</dataEmissao>"+CHR(13)+CHR(10)     

cLinha += "<faturado>"+CHR(13)+CHR(10)    
dbSelectArea("SA1")
dbSetOrder(1)
dbSeek(xFilial("SA1")+(cQrySF2)->F2_CLIENTE+(cQrySF2)->F2_LOJA)
	
cLinha += "<tipoPessoa>"+Alltrim(SA1->A1_PESSOA)+"</tipoPessoa>"+CHR(13)+CHR(10) 
cLinha += "<nome>"+Alltrim(PADR(SA1->A1_NOME,70))+"</nome>"+CHR(13)+CHR(10) 
cLinha += "<cpf>"+Alltrim(PADR(SA1->A1_CGC,18))+"</cpf>"+CHR(13)+CHR(10) 
If !Empty(SA1->A1_PFISICA)
	cLinha += "<rg>"+Alltrim(SA1->A1_PFISICA)+"</rg>"+CHR(13)+CHR(10) 
Endif
cLinha += "<endereco>"+CHR(13)+CHR(10) 
if SA1->(FieldPos("A1_TPLOGR")) > 0
	cLinha += "<tipoLogr>"+Alltrim(SA1->A1_TPLOGR)+"</tipoLogr>"+CHR(13)+CHR(10)
Endif
cEnd    := SA1->A1_END
cLinha += "<logradouro>"+Alltrim(cEnd)+"</logradouro>"+CHR(13)+CHR(10)
if SA1->(FieldPos("A1_NUMERO")) > 0 .and. !Empty(SA1->A1_NUMERO)
	cLinha += "<numero>"+Alltrim(SA1->A1_NUMERO)+"</numero>"+CHR(13)+CHR(10)
Endif
if !Empty(SA1->A1_COMPLEM)
	cLinha += "<complemento>"+Alltrim(PADR(SA1->A1_COMPLEM,50))+"</complemento>"+CHR(13)+CHR(10)
Endif
cLinha += "<bairro>"+Alltrim(PADR(SA1->A1_BAIRRO,30))+"</bairro>"+CHR(13)+CHR(10)
cLinha += "<cidade>"+Alltrim(PADR(SA1->A1_MUN,30))+"</cidade>"+CHR(13)+CHR(10)
cLinha += "<estado>"+Alltrim(SA1->A1_EST)+"</estado>"+CHR(13)+CHR(10)
cLinha += "<CEP>"+Alltrim(PADR(SA1->A1_CEP,8))+"</CEP>"+CHR(13)+CHR(10)
dbSelectArea("SYA")
dbSetOrder(1)
dbSeek(xFilial("SYA")+SA1->A1_PAIS)
cLinha += "<pais>"+Alltrim(PADR(SYA->YA_DESCR,30))+"</pais>"+CHR(13)+CHR(10)
cLinha += "</endereco>"+CHR(13)+CHR(10)
cLinha += "<telefone>"+CHR(13)+CHR(10)
cLinha += "<ddi>"+Alltrim(PADR(SA1->A1_DDI,3))+"</ddi>"+CHR(13)+CHR(10)
cLinha += "<ddd>"+Alltrim(PADR(SA1->A1_DDD,3))+"</ddd>"+CHR(13)+CHR(10)
cLinha += "<numero>"+Alltrim(PADR(SA1->A1_TEL,12))+"</numero>"+CHR(13)+CHR(10)
//cLinha += "<ramal></ramal>"+CHR(13)+CHR(10)
cLinha += "</telefone>"+CHR(13)+CHR(10)
cLinha += "<email>"+Alltrim(PADR(SA1->A1_EMAIL,50))+"</email>"+CHR(13)+CHR(10)
If !Empty(dtoc(SA1->A1_DTNASC))
	cLinha += "<data_nasc>"+dtoc(SA1->A1_DTNASC)+"</data_nasc>"+CHR(13)+CHR(10)
Endif

If lCelularCust .and. !Empty(SA1->A1_DDI) .and. !Empty(&(Mv_Par10)) .and. !Empty(&(Mv_Par11))
	cLinha += "<celular>"+CHR(13)+CHR(10)
	cLinha += "<ddi>"+Alltrim(PADR(SA1->A1_DDI,3))+"</ddi>"+CHR(13)+CHR(10)
	cLinha += "<ddd>"+Alltrim(PADR(&(Mv_Par10),3))+"</ddd>"+CHR(13)+CHR(10)
	cLinha += "<numero>"+Alltrim(PADR(&(Mv_Par11),12))+"</numero>"+CHR(13)+CHR(10)
	cLinha += "</celular>"+CHR(13)+CHR(10)
Endif

If !Empty(SA1->A1_DDI) .and. !Empty(SA1->A1_DDD) .and. !Empty(SA1->A1_TEL)
	cLinha += "<telefoneResidencial>"+CHR(13)+CHR(10)
	cLinha += "<ddi>"+Alltrim(PADR(SA1->A1_DDI,3))+"</ddi>"+CHR(13)+CHR(10)
	cLinha += "<ddd>"+Alltrim(PADR(SA1->A1_DDD,3))+"</ddd>"+CHR(13)+CHR(10)
	cLinha += "<numero>"+Alltrim(PADR(SA1->A1_TEL,12))+"</numero>"+CHR(13)+CHR(10)
	cLinha += "</telefoneResidencial>"+CHR(13)+CHR(10)
Endif

cLinha += "</faturado>"+CHR(13)+CHR(10) 
	
if SA1->A1_COD+SA1->A1_LOJA <> (cQrySF2)->VV1_PROATU+(cQrySF2)->VV1_LJPATU
	cLinha += "<proprietarioVeiculo>"+CHR(13)+CHR(10) 
	dbSelectArea("SA1")
	dbSetOrder(1)
	If !Empty((cQrySF2)->VV1_PROATU)
		dbSeek(xFilial("SA1")+(cQrySF2)->VV1_PROATU+(cQrySF2)->VV1_LJPATU)
	Else
		dbSeek(xFilial("SA1")+SA1->A1_COD+SA1->A1_LOJA)
	Endif
	cLinha += "<tipoPessoa>"+Alltrim(SA1->A1_PESSOA)+"</tipoPessoa>"+CHR(13)+CHR(10) 
	cLinha += "<nome>"+Alltrim(PADR(SA1->A1_NOME,70))+"</nome>"+CHR(13)+CHR(10) 
	cLinha += "<cpf>"+Alltrim(PADR(SA1->A1_CGC,18))+"</cpf>"+CHR(13)+CHR(10) 
	If !Empty(SA1->A1_PFISICA)
		cLinha += "<rg>"+Alltrim(SA1->A1_PFISICA)+"</rg>"+CHR(13)+CHR(10)
	Endif
	cLinha += "<endereco>"+CHR(13)+CHR(10) 
	if SA1->(FieldPos("A1_TPLOGR")) > 0
		cLinha += "<tipoLogr>"+Alltrim(SA1->A1_TPLOGR)+"</tipoLogr>"+CHR(13)+CHR(10)
	Endif
	cEnd    := SA1->A1_END
	cLinha += "<logradouro>"+Alltrim(cEnd)+"</logradouro>"+CHR(13)+CHR(10)
	if SA1->(FieldPos("A1_NUMERO")) > 0 .and. !Empty(SA1->A1_NUMERO)
		cLinha += "<numero>"+Alltrim(SA1->A1_NUMERO)+"</numero>"+CHR(13)+CHR(10)
	Endif
	if !Empty(SA1->A1_COMPLEM)
		cLinha += "<complemento>"+Alltrim(PADR(SA1->A1_COMPLEM,50))+"</complemento>"+CHR(13)+CHR(10)
	Endif
	cLinha += "<bairro>"+Alltrim(PADR(SA1->A1_BAIRRO,30))+"</bairro>"+CHR(13)+CHR(10)
	cLinha += "<cidade>"+Alltrim(PADR(SA1->A1_MUN,30))+"</cidade>"+CHR(13)+CHR(10)
	cLinha += "<estado>"+Alltrim(SA1->A1_EST)+"</estado>"+CHR(13)+CHR(10)
	cLinha += "<CEP>"+Alltrim(PADR(SA1->A1_CEP,8))+"</CEP>"+CHR(13)+CHR(10)
	dbSelectArea("SYA")
	dbSetOrder(1)
	dbSeek(xFilial("SYA")+SA1->A1_PAIS)
	cLinha += "<pais>"+Alltrim(PADR(SYA->YA_DESCR,30))+"</pais>"+CHR(13)+CHR(10)
	cLinha += "</endereco>"+CHR(13)+CHR(10)
	cLinha += "<telefone>"+CHR(13)+CHR(10)
	cLinha += "<ddi>"+Alltrim(PADR(SA1->A1_DDI,3))+"</ddi>"+CHR(13)+CHR(10)
	cLinha += "<ddd>"+Alltrim(PADR(SA1->A1_DDD,3))+"</ddd>"+CHR(13)+CHR(10)
	cLinha += "<numero>"+Alltrim(PADR(SA1->A1_TEL,12))+"</numero>"+CHR(13)+CHR(10)
	//cLinha += "<ramal></ramal>"+CHR(13)+CHR(10)
	cLinha += "</telefone>"+CHR(13)+CHR(10)
	cLinha += "<email>"+Alltrim(PADR(SA1->A1_EMAIL,50))+"</email>"+CHR(13)+CHR(10)
	If !Empty(dtoc(SA1->A1_DTNASC))
		cLinha += "<data_nasc>"+dtoc(SA1->A1_DTNASC)+"</data_nasc>"+CHR(13)+CHR(10)
	Endif

	If lCelularCust .and. !Empty(SA1->A1_DDI) .and. !Empty(&(Mv_Par10)) .and. !Empty(&(Mv_Par11))
		cLinha += "<celular>"+CHR(13)+CHR(10)
		cLinha += "<ddi>"+Alltrim(PADR(SA1->A1_DDI,3))+"</ddi>"+CHR(13)+CHR(10)
		cLinha += "<ddd>"+Alltrim(PADR(&(Mv_Par10),3))+"</ddd>"+CHR(13)+CHR(10)
		cLinha += "<numero>"+Alltrim(PADR(&(Mv_Par11),12))+"</numero>"+CHR(13)+CHR(10)
		cLinha += "</celular>"+CHR(13)+CHR(10)
	Endif

	If !Empty(SA1->A1_DDI) .and. !Empty(SA1->A1_DDD) .and. !Empty(SA1->A1_TEL)
		cLinha += "<telefoneResidencial>"+CHR(13)+CHR(10)
		cLinha += "<ddi>"+Alltrim(PADR(SA1->A1_DDI,3))+"</ddi>"+CHR(13)+CHR(10)
		cLinha += "<ddd>"+Alltrim(PADR(SA1->A1_DDD,3))+"</ddd>"+CHR(13)+CHR(10)
		cLinha += "<numero>"+Alltrim(PADR(SA1->A1_TEL,12))+"</numero>"+CHR(13)+CHR(10)
		cLinha += "</telefoneResidencial>"+CHR(13)+CHR(10)
	Endif

	cLinha += "</proprietarioVeiculo>"+CHR(13)+CHR(10)
Endif
cLinha += "</header>"+CHR(13)+CHR(10)
cLinha += "<veiculo>"+CHR(13)+CHR(10)
cLinha += "<chassi>"+Alltrim(PADR((cQrySF2)->VV1_CHASSI,22))+"</chassi>"+CHR(13)+CHR(10)
nVALOR := (cQrySF2)->D2_TOTAL
cLinha += "<valorVeiculo>"+Alltrim(str(nVALOR)) +"</valorVeiculo>"+CHR(13)+CHR(10)

If lEmplacament .and. mv_par09 <> 4
	cLinha += "<zeroEmplacado>"+IIf(VV0->VV0_EMPLAC=="1","S","N")+"</zeroEmplacado>"+CHR(13)+CHR(10)
Else
	cLinha += "<zeroEmplacado>"+""+"</zeroEmplacado>"+CHR(13)+CHR(10)
Endif
// Carro Zero foi Emplacado na Concessiopnária
// S ou N

cLinha += "</veiculo>"+CHR(13)+CHR(10)

cLinha += "<atendente>"+CHR(13)+CHR(10) 
dbSelectArea("SA3")
dbSetOrder(1)
dbSeek(xFilial("SA3")+(cQrySF2)->F2_VEND1)
cLinha += "<nome>"+Alltrim(PADR(SA3->A3_NOME,70))+"</nome>"+CHR(13)+CHR(10) 
cLinha += "<cpf>"+Alltrim(PADR(SA3->A3_CGC,11))+"</cpf>"+CHR(13)+CHR(10) 
If !Empty(SA3->A3_EMAIl)
	cLinha += "<email>"+Alltrim(PADR(SA3->A3_EMAIL,50))+"</email>"+CHR(13)+CHR(10) 
Endif
dbSelectArea("SA3")
dbSetOrder(1)
dbSeek(xFilial("SA3")+SA3->A3_GEREN)
If !Empty(SA3->A3_NOME).and. !Empty(SA3->A3_CGC).and. !Empty(SA3->A3_EMAIL)
	cLinha += "<gerente>"+CHR(13)+CHR(10) 
	cLinha += "<nome>"+Alltrim(PADR(SA3->A3_NOME,70))+"</nome>"+CHR(13)+CHR(10) 
	cLinha += "<cpf>"+Alltrim(PADR(SA3->A3_CGC,11))+"</cpf>"+CHR(13)+CHR(10) 
	cLinha += "<email>"+Alltrim(PADR(SA3->A3_EMAIL,50))+"</email>"+CHR(13)+CHR(10) 
	cLinha += "</gerente>"+CHR(13)+CHR(10) 
Endif
cLinha += "<codigoConcVenda>"+Alltrim(PADR(Alltrim(str(nFilS)),6))+"</codigoConcVenda>"+CHR(13)+CHR(10) 


cLinha += "</atendente>"+CHR(13)+CHR(10) 
dbSelectArea("SA1")
dbSetOrder(3)
dbSeek(xFilial("SA1")+aSM0[18])
If !Empty(SA1->A1_EMAIL)
	cLinha += "<emailOut>"+Alltrim(PADR(SA1->A1_EMAIL,50))+"</emailOut>"+CHR(13)+CHR(10) 
Endif
cLinha += "</notafiscal>"+CHR(13)+CHR(10) 
	

fwrite(nHnd,cLinha)

fClose(nHnd)

dbSelectArea("VDU")
RecLock("VDU",.t.)
VDU->VDU_FILIAL := xFilial("VDU")
VDU->VDU_FILDOC := (cQrySF2)->F2_FILIAL
VDU->VDU_NUMDOC := (cQrySF2)->F2_DOC
VDU->VDU_CODMAR := MV_Par06
VDU->VDU_SERDOC := (cQrySF2)->F2_SERIE
If FieldPos("VDU_SDOC") > 0 .and.  (cQrySF2)->(FieldPos("F2_SDOC")) <> 0
	VDU->VDU_SDOC := (cQrySF2)->F2_SDOC
Endif
    
VDU->VDU_TIPDOC := "V"
VDU->VDU_NUMSEQ := GetSXENum("VDU","VDU_NUMSEQ")
VDU->VDU_DATENV := ddatabase
ConfirmSX8()
MsUnlock()

Return