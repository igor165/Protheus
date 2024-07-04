// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 13     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFIXI019.CH"

/*
================================================================================
################################################################################
##+----------+------------+-------+-----------------------+------+-----------+##
##|Função    | OFIXI019   | Autor | Thiago                | Data | 02/01/13  |##
##+----------+------------+-------+-----------------------+------+-----------+##
##|Descrição | A exportação das notas fiscais de serviço MitSubishi			 |##
##+----------+---------------------------------------------------------------+##
##|Uso       |                                                               |##
##+----------+---------------------------------------------------------------+##
################################################################################
================================================================================
*/
Function OFIXI019(lPainel,nFilSIR,MVPar01,MVPar02,MVPar03,MVPar04,MVPar05,MVPar06,MVPar07,MVPar08)
//
Local cDesc1  := STR0001
Local cDesc2  := STR0002
Local cDesc3  := STR0003
Local aSay := {}
Local aButton := {}

Private cTitulo := STR0004
Private cPerg := "OXI019"
Private lErro := .f.  	    // Se houve erro, não move arquivo gerado
Private cArquivo			// Nome do Arquivo a ser importado
Private oNo      := LoadBitmap( GetResources(), "LBNO" )
Private oTik     := LoadBitmap( GetResources(), "LBTIK" )
Private nFilS    := 0
Default lPainel  := .f.
Default nFilSIR  := 0
//
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
	// aAdd(aRegs,{STR0012,STR0012,STR0012,"MV_CH1","D", 8,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
	// aAdd(aRegs,{STR0013,STR0013,STR0013,"MV_CH2","D", 8,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
	// aAdd(aRegs,{STR0014,STR0014,STR0014,"MV_CH3","C",99,0,0,"G","!Vazio().or.(Mv_Par03:=cGetFile('Arquivos |*.*','',,,,"+AllTrim(Str(nOpcGetFil))+"))","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
	// aAdd(aRegs,{STR0015,STR0015,STR0015,"MV_CH4","N", 6,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","","999999"})
	// aAdd(aRegs,{STR0016,STR0016,STR0016,"MV_CH5","N", 1,0,0,"C","","mv_par05",STR0017,"","","","",STR0018,"","","","","","","","","","","","","","","","","","","",""	,"S","","","9"})
	// aAdd(aRegs,{STR0020,STR0020,STR0020,"MV_CH6","C", 3,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","VE1",""	,"S","","",""})
	// aAdd(aRegs,{STR0023,STR0023,STR0023,"MV_CH7","C", 9,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","SF2",""	,"S","","",""})
	// aAdd(aRegs,{STR0024,STR0024,STR0024,"MV_CH8","C", 3,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
	// aAdd(aRegs,{STR0025,STR0025,STR0025,"MV_CH9","C", 1,0,0,"C","","mv_par09",STR0026,"","","","",STR0027,"","","","",STR0028,"","","","",STR0030,"","","","","","","","","",""	,"S","","",""})
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
Local cPrefOFI := GetNewPar("MV_PREFOFI","OFI")
Private aSM0     := {}
Private cQrySF2   := "SQLSF2"
aSM0 := FWArrFilAtu(cEmpAnt,cFilAnt) // Filial Origem (Filial logada)


cQuery := "SELECT DISTINCT SF2.F2_DOC , SF2.F2_SERIE, SF2."+ FGX_MILSNF("SF2", 3, "F2_SERIE") +" , SF2.F2_FILIAL , SF2.F2_EMISSAO , SF2.F2_CLIENTE , SF2.F2_LOJA , SX5.X5_DESCRI , VO1.VO1_KILOME , VO1.VO1_NUMOSV , VO1.VO1_FUNABE , VO1.VO1_OBSMEM , VO1.VO1_PROVEI , VO1.VO1_LOJPRO , VO1.VO1_CHAINT , VO1.VO1_FATPAR , VO1.VO1_LOJA , VO1.VO1_DATABE , VO1.VO1_DATENT, SD2.D2_CF , SF2.D_E_L_E_T_ AS SF2DEL "
cQuery += "FROM " + RetSQLName("SF2" ) + " SF2 "
cQuery += "INNER JOIN "+RetSqlName("VSC")+" VSC ON (VSC.VSC_FILIAL = '"+xFilial("VSC")+"' AND VSC.VSC_NUMNFI = SF2.F2_DOC AND VSC.VSC_SERNFI = SF2.F2_SERIE) "
cQuery += "INNER JOIN "+RetSqlName("VO1")+" VO1 ON (VO1.VO1_FILIAL = '"+xFilial("VO1")+"' AND VO1.VO1_NUMOSV = VSC.VSC_NUMOSV AND "
if !Empty(MV_PAR06)
	cQuery += "VO1.VO1_CODMAR = '"+MV_PAR06+"' AND "
Endif
cQuery += "VO1.D_E_L_E_T_=' ') "
cQuery += "INNER JOIN "+RetSqlName("SD2")+" SD2 ON (SD2.D2_FILIAL = '"+xFilial("SD2")+"' AND SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND SD2.D2_CLIENTE = SF2.F2_CLIENTE AND SD2.D2_LOJA = SF2.F2_LOJA) "
cQuery += "LEFT JOIN "+RetSqlName("SX5")+" SX5 ON (SX5.X5_FILIAL = '"+xFilial("SX5")+"' AND SX5.X5_TABELA = '13' AND SX5.X5_CHAVE = SD2.D2_CF AND SX5.D_E_L_E_T_=' ') "
cQuery += "WHERE SF2.F2_FILIAL = '" + xFilial("SF2") + "' AND SF2.F2_EMISSAO >= '"+dtos(MV_PAR01)+"' AND SF2.F2_EMISSAO <= '"+dtos(MV_PAR02)+"' AND SF2.F2_PREFORI = '"+cPrefOFI+"'"

If Empty(Mv_Par07)
	if mv_par09 == 1
		cQuery += " AND NOT EXISTS (SELECT VDU_NUMSEQ FROM "+RetSQLName("VDU")+" VDU WHERE VDU.VDU_FILIAL='"+xFilial("VDU")+"' AND SF2.F2_FILIAL = VDU.VDU_FILDOC AND VDU.VDU_CODMAR='"+MV_Par06+"' AND VDU.VDU_NUMDOC = SF2.F2_DOC AND VDU.VDU_SERDOC = SF2.F2_SERIE AND VDU.D_E_L_E_T_=' ') "
	Endif
Else
	cQuery += " AND SF2.F2_DOC = '" + Mv_Par07 +"' AND SF2."+ FGX_MILSNF("SF2", 3, "F2_SERIE") +" = '" + Mv_Par08 + "' "
Endif
if mv_par09 == 4 // Cancelamento
	cQuery += " AND SF2.D_E_L_E_T_<>' ' "
Else
	cQuery += " AND SF2.D_E_L_E_T_=' ' AND SD2.D_E_L_E_T_=' ' AND VSC.D_E_L_E_T_=' '	"
Endif

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQrySF2, .F., .T. )
nTotReg := Contar(cQrySF2, "!Eof()")

If !FWGetRunSchedule() // não está sendo chamada pelo Schedule
	SetRegua(nTotReg)
Endif

(cQrySF2)->(DBGoTop())

cTIPCli := "P"
If (cQrySF2)->(Eof())
	If !FWGetRunSchedule() // não está sendo chamada pelo Schedule
		MsgStop(STR0022+chr(13) + chr(10)+chr(13) + chr(10)+STR0029+cFilAnt+" - "+aSM0[7],STR0007)
	Endif
	(cQrySF2)->(dbCloseArea())
	return
Endif

While  !(cQrySF2)->(Eof())

	FS_IMPRESSAO()

	dbSelectArea(cQrySF2)
	(cQrySF2)->(dbSkip())

Enddo
(cQrySF2)->(dbCloseArea())

If !FWGetRunSchedule() // não está sendo chamada pelo Schedule
	MsgInfo(STR0010,STR0007)
Endif

return




Static Function FS_IMPRESSAO()
Local cQryAlVSC := "SQLVSC"
Local cQryVSC   := "SQLVSC"

Local cDataPrev := ""
Local aVetNome := {}
Local aVetTam := {}
Local aVetData := {}
Local aVetHora := {}
Local cPar10   := Subs(Alltrim(Mv_Par10),6)
Local cPar11   := Subs(Alltrim(Mv_Par11),6)
Local lCelularCust := !Empty(Mv_Par10) .and. !Empty(Mv_Par11) .and. SA1->(FieldPos((cPar10))) > 0 .and. SA1->(FieldPos((cPar11))) > 0

//
//#############################################################################
//# Tenta abrir o arquivo texto                                               #
//#############################################################################
cArquivo := "OFIXI019_"+(cQrySF2)->F2_DOC+"_"+cFilAnt+".XML"
//
aDir( Alltrim(MV_PAR01)+cArquivo ,aVetNome,aVetTam,aVetData,aVetHora)
//
nHnd := FCREATE(Alltrim(MV_PAR03)+Alltrim(cArquivo),0)

cDataPrev := IiF(!Empty(stod((cQrySF2)->VO1_DATENT)),dtoc(stod((cQrySF2)->VO1_DATENT)),"")

cLinha := "<?xml version='1.0' encoding='ISO-8859-1' ?>"+CHR(13)+CHR(10)
cLinha += "<notafiscal>"+CHR(13)+CHR(10)

if mv_par09 == 1
	cTpNota := "PSN"
Elseif mv_par09 == 2
	cTpNota := "PSCE"
Elseif mv_par09 == 3
	cTpNota := "PSCC"
Elseif mv_par09 == 4
	cTpNota := "PSC"
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
cLinha += "<codigoConcessionaria>"+Alltrim(str(nFilS))+"</codigoConcessionaria>"+CHR(13)+CHR(10)
cLinha += "<cnpjConcessionaria>"+Alltrim(aSM0[18])+"</cnpjConcessionaria>"+CHR(13)+CHR(10)
cLinha += "<natOper>"+Alltrim(substr((cQrySF2)->X5_DESCRI,1,50))+"</natOper>"+CHR(13)+CHR(10)
cLinha += "<cfop>"+Alltrim((cQrySF2)->D2_CF)+"</cfop>"+CHR(13)+CHR(10)
cNumNota := Alltrim((cQrySF2)->F2_DOC)+"/"+Alltrim( (cQrySF2)->&(FGX_MILSNF("SF2", 3, "F2_SERIE")) )+"/"+"1"
cLinha += "<numeroNF>"+Alltrim(cNumNota)+"</numeroNF>"+CHR(13)+CHR(10)
cLinha += "<dataEmissao>"+Alltrim(dtoc(stod((cQrySF2)->F2_EMISSAO)))+"</dataEmissao>"+CHR(13)+CHR(10)

cLinha += "<numeroOS>"+(cQrySF2)->VO1_NUMOSV+"</numeroOS>"+CHR(13)+CHR(10)
cLinha += "<dataOS>"+Alltrim(dtoc(stod((cQrySF2)->VO1_DATABE)))+"</dataOS>"+CHR(13)+CHR(10)

If !Empty(cDataPrev)
	cLinha += "<dataPrevisao>"+cDataPrev+"</dataPrevisao>"+CHR(13)+CHR(10)
Endif

cLinha += "<faturado>"+CHR(13)+CHR(10)
cCliente := (cQrySF2)->F2_CLIENTE
cLoja    := (cQrySF2)->F2_LOJA
dbSelectArea("SA1")
dbSetOrder(1)
dbSeek(xFilial("SA1")+cCliente+cLoja)
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

if !Empty((cQrySF2)->VO1_PROVEI+(cQrySF2)->VO1_LOJPRO)
   cProVei := (cQrySF2)->VO1_PROVEI
   cLojPro := (cQrySF2)->VO1_LOJPRO
    Else
   cProVei := (cQrySF2)->VO1_FATPAR
   cLojPro := (cQrySF2)->VO1_LOJA
Endif
if SA1->A1_COD+SA1->A1_LOJA <> cProVei+cLojPro
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial("SA1")+cProVei+cLojPro)
	cLinha += "<proprietarioVeiculo>"+CHR(13)+CHR(10)
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
	cLinha += "<CEP>"+Alltrim(SA1->A1_CEP)+"</CEP>"+CHR(13)+CHR(10)
	dbSelectArea("SYA")
	dbSetOrder(1)
	dbSeek(xFilial("SYA")+SA1->A1_PAIS)
	cLinha += "<pais>"+Alltrim(PADR(SYA->YA_DESCR,30))+"</pais>"+CHR(13)+CHR(10)
	cLinha += "</endereco>" +CHR(13)+CHR(10)
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
	cTIPCli := "U"
    Endif
cLinha += "</header>"+CHR(13)+CHR(10)
cLinha += "<veiculo>"+CHR(13)+CHR(10)
dbSelectArea("VV1")
dbSetOrder(1)
dbSeek(xFilial("VV1")+(cQrySF2)->VO1_CHAINT)
cLinha += "<chassi>"+Alltrim(PADR(VV1->VV1_CHASSI,22))+"</chassi>"+CHR(13)+CHR(10)
cPlaVei := substr(VV1->VV1_PLAVEI,1,3)+"-"+substr(VV1->VV1_PLAVEI,4,4)
If !Empty(cPlaVei)
	cLinha += "<placa>"+Alltrim(cPlaVei)+"</placa>"+CHR(13)+CHR(10)
Endif
If !Empty(str((cQrySF2)->VO1_KILOME))
	cLinha += "<km>"+Alltrim(PADR(Alltrim(str((cQrySF2)->VO1_KILOME)),8))+"</km>"+CHR(13)+CHR(10)
Endif
cLinha += "</veiculo>"+CHR(13)+CHR(10)
cLinha += "<servicos>"+CHR(13)+CHR(10)

cQuery := "SELECT SUM(VSC.VSC_VALSER) AS VALSER "
cQuery += "FROM " + RetSQLName("VSC" ) + " VSC "
cQuery += "WHERE VSC.VSC_FILIAL = '" + xFilial("VSC") + "' AND VSC.VSC_NUMNFI = '"+(cQrySF2)->F2_DOC+"' AND VSC.VSC_SERNFI = '"+(cQrySF2)->F2_SERIE+"' AND "
if mv_par09 == 4 // Cancelamento
	cQuery += "VSC.D_E_L_E_T_ <> ' '"
Else
	cQuery += "VSC.D_E_L_E_T_ = ' '"
Endif

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAlVSC, .F., .T. )

cLinha += "<valorServico>"+Alltrim(Str((cQryAlVSC)->VALSER))+"</valorServico>"+CHR(13)+CHR(10)
(cQryAlVSC)->(dbCloseArea())
cLinha += "</servicos>"+CHR(13)+CHR(10)

cQuery := "SELECT VSC.VSC_CODSER,VSC.VSC_VALSER,VSC.VSC_TIPTEM,VSC.VSC_VALDES "
cQuery += "FROM " + RetSQLName("VSC" ) + " VSC "
cQuery += "WHERE VSC.VSC_FILIAL = '" + xFilial("VSC") + "' AND VSC.VSC_NUMNFI = '"+(cQrySF2)->F2_DOC+"' AND VSC.VSC_SERNFI = '"+(cQrySF2)->F2_SERIE+"' AND "
if mv_par09 == 4 // Cancelamento
	cQuery += "VSC.D_E_L_E_T_ <> ' '"
Else
	cQuery += "VSC.D_E_L_E_T_ = ' '"
Endif

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryVSC, .F., .T. )

(cQryVSC)->(DBGoTop())
nSeq := 1
cLinha += "<itensOS>"+CHR(13)+CHR(10)
cTipOs := ""
While  !(cQryVSC)->(Eof())

	cLinha += "<detalhesServicos>"+CHR(13)+CHR(10)
	cLinha += "<seqServico>"+Alltrim(str(nSeq))+"</seqServico>"+CHR(13)+CHR(10)
	cLinha += "<codigoServico>"+Alltrim(PADR((cQryVSC)->VSC_CODSER,10))+"</codigoServico>"+CHR(13)+CHR(10)
	dbSelectArea("VO6")
	dbSetOrder(4)
	dbSeek(xFilial("VO6")+(cQryVSC)->VSC_CODSER)
	cLinha += "<descricaoServico>"+Alltrim(PADR(VO6->VO6_DESSER,100))+"</descricaoServico>"+CHR(13)+CHR(10)
	cLinha += "<precoUnitServico>"+Alltrim(PADR(Alltrim(str((cQryVSC)->VSC_VALSER)),10))+"</precoUnitServico>"+CHR(13)+CHR(10)
	cLinha += "<quantidadeServico>"+Alltrim(PADR(Alltrim(str(1)),10))+"</quantidadeServico>"+CHR(13)+CHR(10)
	cLinha += "<descontoUnitServico>"+Alltrim(PADR(Alltrim(str((cQryVSC)->VSC_VALDES)),10))+"</descontoUnitServico>"+CHR(13)+CHR(10)
	cLinha += "<respostaReparo>"+Alltrim(PADR(VO6->VO6_DESSER,250))+"</respostaReparo>"+CHR(13)+CHR(10)
	cLinha += "</detalhesServicos>"+CHR(13)+CHR(10)
	dbSelectArea("VOI")
	dbSetOrder(1)
	dbSeek(xFilial("VOI")+(cQryVSC)->VSC_TIPTEM)
	if VOI->VOI_SITTPO == "3"
	   cTipOs := "I"
	Elseif VOI->VOI_SITTPO == "2"
	   cTipOs := "G"
	Else
	   cTipOs := "C"
	Endif
	If ( ExistBlock("OXITIPOS") )
		cTipOs := ExecBlock("OXITIPOS",.f.,.f.,{(cQryVSC)->VSC_TIPTEM})
	EndIf

	nSeq += 1
	dbSelectArea(cQryVSC)
	(cQryVSC)->(dbSkip())

Enddo
(cQryVSC)->(dbCloseArea())

cLinha += "</itensOS>"+CHR(13)+CHR(10)
cLinha += "<ordemServico>"+CHR(13)+CHR(10)

if cTIPCli == "U"
	cLinha += "<tipoCliente>"+"U"+"</tipoCliente>"+CHR(13)+CHR(10)
Else
	cLinha += "<tipoCliente>"+"P"+"</tipoCliente>"+CHR(13)+CHR(10)
Endif
cLinha += "<tipoOS>"+cTipOs+"</tipoOS>"+CHR(13)+CHR(10)
cLinha += "<formaPagamento>"+"PP"+"</formaPagamento>"+CHR(13)+CHR(10)

DbSelectArea("SYP")
DbSeek(xFilial("SYP")+(cQrySF2)->VO1_OBSMEM )

cObs := ""
Do While !Eof() .And. SYP->YP_CHAVE == (cQrySF2)->VO1_OBSMEM .And. SYP->YP_FILIAL == xFilial("SYP")

	cObs := RTrim(Stuff(SYP->YP_TEXTO, If( (nPos:=At("\13\10",SYP->YP_TEXTO))<=0 ,80,nPos) ,6,Space(6)))

	dbSelectArea("SYP")
	DbSkip()

EndDo
If !Empty(cObs)
	cLinha += "<obs>"+Alltrim(PADR(cObs,250))+"</obs>"+CHR(13)+CHR(10)
eNDIF
cLinha += "</ordemServico>"+CHR(13)+CHR(10)
cLinha += "<atendente>"+CHR(13)+CHR(10)
dbSelectArea("VAI")
dbSetOrder(1)
dbSeek(xFilial("VAI")+(cQrySF2)->VO1_FUNABE)
cLinha += "<nome>"+Alltrim(PADR(VAI->VAI_NOMTEC,70))+"</nome>"+CHR(13)+CHR(10)
cLinha += "<cpf>"+Alltrim(PADR(VAI->VAI_CPF,11))+"</cpf>"+CHR(13)+CHR(10)
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
If FieldPos("VDU_SDOC") > 0 .and. (cQrySF2)->(FieldPos("F2_SDOC")) <> 0
 	VDU->VDU_SDOC := (cQrySF2)->F2_SDOC
EndIf

VDU->VDU_TIPDOC := "S"
VDU->VDU_NUMSEQ := GetSXENum("VDU","VDU_NUMSEQ")
VDU->VDU_DATENV := ddatabase
ConfirmSX8()
MsUnlock()

Return
