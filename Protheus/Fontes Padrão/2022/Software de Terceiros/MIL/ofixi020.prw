#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFIXI020.CH"
#include "OFIXDEF.CH"

/*
================================================================================
################################################################################
##+----------+------------+-------+-----------------------+------+-----------+##
##|Função    | OFIXI020   | Autor | Thiago                | Data | 11/03/13  |##
##+----------+------------+-------+-----------------------+------+-----------+##
##|Descrição | A exportação das notas fiscais de pecas MitSubishi            |##
##+----------+---------------------------------------------------------------+##
##|Uso       |                                                               |##
##+----------+---------------------------------------------------------------+##
################################################################################
================================================================================
*/
Function OFIXI020(lPainel,nFilSIR,MVPar01,MVPar02,MVPar03,MVPar04,MVPar05,MVPar06,MVPar07,MVPar08)
//
Local cDesc1  := STR0001
Local cDesc2  := STR0002
Local cDesc3  := STR0003
Local aSay := {}
Local aButton := {}

Private cTitulo := STR0004
Private cPerg := "OXI020"
Private lErro := .f.  	    // Se houve erro, não move arquivo gerado
Private cArquivo			// Nome do Arquivo a ser importado
Private oNo      := LoadBitmap( GetResources(), "LBNO" )
Private oTik     := LoadBitmap( GetResources(), "LBTIK" )
Private nFilS    := 0
Default lPainel  := .f.
Default nFilSIR  := 0

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
	// aAdd(aRegs,{STR0016,STR0016,STR0016,"MV_CH5","C", 1,0,0,"C","","mv_par05",STR0017,"","","","",STR0018,"","","","","","","","","","","","","","","","","","","",""	,"S","","","9"})
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
//Local cQryVEC   := "SQLVEC"
//Local cQryVSC   := "SQLVSC"
Local lRetorn  := .f.
Private cPrefBAL := GetNewPar("MV_PREFBAL","BAL")
Private cPrefOFI := GetNewPar("MV_PREFOFI","OFI")
//Local cGruVei  := PadR(AllTrim(GetMv("MV_GRUVEI")),TamSx3("B1_GRUPO")[1]," ") // Grupo do Veiculo
Private cQrySF2   := "SQLSF2"
Private aSM0     := {}
aSM0 := FWArrFilAtu(cEmpAnt,cFilAnt) // Filial Origem (Filial logada)

if SA1->(FieldPos("A1_TPLOGR")) == 0
	If !FWGetRunSchedule() // não está sendo chamada pelo Schedule
		MsgStop("Campo Tipo Logr (A1_TPLOGR) não está criado no cadastro de clientes. Favor aplicar o compatilizador UPDMITSUB!")
	Endif
	Return(.f.)
Endif
cQuery := "SELECT DISTINCT SF2.F2_DOC, SF2."+ FGX_MILSNF("SF2", 3, "F2_SERIE") +" , SF2.F2_SERIE , SF2.F2_FILIAL , SF2.F2_PREFORI , SF2.F2_EMISSAO , SF2.F2_CLIENTE , SF2.F2_LOJA , SF2.F2_VEND1 , VO1.VO1_NUMOSV , VO1.VO1_KILOME , VO1.VO1_CHAINT , VO1.VO1_PROVEI , VO1.VO1_LOJPRO , VO1.VO1_FATPAR , VO1.VO1_LOJA , VO1.VO1_OBSMEM, VO1.VO1_DATABE, VO1.VO1_DATENT, SX5.X5_DESCRI , SD2.D2_CF , SF2.D_E_L_E_T_ AS SF2DEL "
cQuery += "FROM " + RetSQLName("SF2" ) + " SF2 "
cQuery += "INNER JOIN "+RetSqlName("VEC")+" VEC ON (VEC.VEC_FILIAL = '"+xFilial("VEC")+"' AND VEC.VEC_NUMNFI = SF2.F2_DOC AND VEC.VEC_SERNFI = SF2.F2_SERIE) "
cQuery += "LEFT JOIN "+RetSqlName("VO1")+" VO1 ON (VO1.VO1_FILIAL = '"+xFilial("VO1")+"' AND VO1.VO1_NUMOSV = VEC.VEC_NUMOSV AND "
if !Empty(MV_PAR06)
	cQuery += "VO1.VO1_CODMAR = '"+MV_PAR06+"' AND "
Endif
cQuery += " VO1.D_E_L_E_T_=' ')
cQuery += "INNER JOIN "+RetSqlName("SD2")+" SD2 ON (SD2.D2_FILIAL = '"+xFilial("SD2")+"' AND SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND SD2.D2_CLIENTE = SF2.F2_CLIENTE AND SD2.D2_LOJA = SF2.F2_LOJA) "
if !Empty(MV_PAR06)
	cQuery += "INNER JOIN "+RetSqlName("SB1")+" SB1 ON (SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.B1_COD = SD2.D2_COD AND SB1.D_E_L_E_T_=' ') "
	cQuery += "INNER JOIN "+RetSqlName("SBM")+" SBM ON (SBM.BM_FILIAL = '"+xFilial("SBM")+"' AND SBM.BM_GRUPO = SB1.B1_GRUPO AND SBM.BM_CODMAR = '"+MV_PAR06+"' AND SBM.D_E_L_E_T_=' ') "
Endif
cQuery += "LEFT JOIN "+RetSqlName("SX5")+" SX5 ON (SX5.X5_FILIAL = '"+xFilial("SX5")+"' AND SX5.X5_TABELA = '13' AND SX5.X5_CHAVE = SD2.D2_CF AND SX5.D_E_L_E_T_=' ') "
cQuery += "WHERE SF2.F2_FILIAL = '" + xFilial("SF2") + "' AND SF2.F2_EMISSAO >= '"+dtos(MV_PAR01)+"' AND SF2.F2_EMISSAO <= '"+dtos(MV_PAR02)+"' AND (SF2.F2_PREFORI = '"+cPrefOFI+"' OR SF2.F2_PREFORI = '"+cPrefBAL+"')"
If Empty(Mv_Par07)
	if mv_par09 == 1
		cQuery += " AND NOT EXISTS (SELECT VDU_NUMSEQ FROM "+RetSQLName("VDU")+" VDU WHERE VDU.VDU_FILIAL='"+xFilial("VDU")+"' AND SF2.F2_FILIAL = VDU.VDU_FILDOC AND VDU.VDU_CODMAR='"+MV_Par06+"' AND VDU.VDU_NUMDOC = SF2.F2_DOC AND VDU.VDU_SERDOC = SF2.F2_SERIE AND VDU.D_E_L_E_T_=' ') "
	Endif
Else
	cQuery += " AND SF2.F2_DOC = '" + Mv_Par07 +"' AND SF2."+ FGX_MILSNF("SF2", 3, "F2_SERIE") +" LIKE '" + Mv_Par08 + "%' "
Endif
if mv_par09 == 4 // Cancelamento
	cQuery += " AND SF2.D_E_L_E_T_<>' ' "
Else
	cQuery += " AND SF2.D_E_L_E_T_=' ' AND SD2.D_E_L_E_T_=' ' AND VEC.D_E_L_E_T_=' '	"
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

	cQuery := "SELECT SF1.F1_DTDIGIT, SF2.F2_CLIENTE, SF2.F2_FILIAL, SF2.F2_LOJA ,SF2.F2_SERIE, SF2.F2_EMISSAO, SF2.F2_DOC, F2_VEND1, SD2.D2_CF, SF2.F2_PREFORI, SF1.F1_FORNECE, SF1.F1_LOJA, VO1.VO1_NUMOSV , VO1.VO1_KILOME , VO1.VO1_CHAINT , VO1.VO1_PROVEI , VO1.VO1_LOJPRO , VO1.VO1_FATPAR , VO1.VO1_LOJA, VO1.VO1_OBSMEM, VO1.VO1_DATABE, VO1.VO1_DATENT, SX5.X5_DESCRI "
	cQuery += "FROM "+RetSqlName("SF1")+ " SF1 "
	cQuery += "JOIN "+RetSqlName("SD1")+ " SD1 ON SF1.F1_DOC=SD1.D1_DOC AND SD1.D1_FILIAL='"+xFilial("SD1")+"' "
	cQuery += "JOIN "+RetSqlName("SF2")+ " SF2 ON SD1.D1_NFORI=SF2.F2_DOC AND SF2.F2_FILIAL='"+xFilial("SF2")+"' "
	cQuery += "INNER JOIN "+RetSqlName("SD2")+" SD2 ON (SD2.D2_FILIAL = '"+xFilial("SD2")+"' AND SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND SD2.D2_CLIENTE = SF2.F2_CLIENTE AND SD2.D2_LOJA = SF2.F2_LOJA) "
	cQuery += "INNER JOIN "+RetSqlName("VEC")+" VEC ON (VEC.VEC_FILIAL = '"+xFilial("VEC")+"' AND VEC.VEC_NUMNFI = SF2.F2_DOC AND VEC.VEC_SERNFI = SF2.F2_SERIE AND VEC.D_E_L_E_T_=' ') "
	cQuery += "LEFT JOIN "+RetSqlName("VO1")+" VO1 ON (VO1.VO1_FILIAL = '"+xFilial("VO1")+"' AND VO1.VO1_NUMOSV = VEC.VEC_NUMOSV AND VO1.D_E_L_E_T_=' ') "
	cQuery += "LEFT JOIN "+RetSqlName("SX5")+" SX5 ON (SX5.X5_FILIAL = '"+xFilial("SX5")+"' AND SX5.X5_TABELA = '13' AND SX5.X5_CHAVE = SD2.D2_CF AND SX5.D_E_L_E_T_=' ') "
	cQuery += "WHERE SF1.F1_FILIAL='"+xFilial("SF1")+"' AND SD1.D1_TIPO='D' AND "
	cQuery += "SF1.F1_DTDIGIT>='"+dtos(MV_PAR01)+"' AND SF1.F1_DTDIGIT<='"+dtos(MV_PAR02)+"' "
	If !Empty(Mv_Par07)
		cQuery += " AND SF2.F2_DOC = '" + Mv_Par07 +"' AND SF2."+ FGX_MILSNF("SF2", 3, "F2_SERIE") +" LIKE '" + Mv_Par08 + "%' "
	Endif
	cQuery += " AND (SF2.F2_PREFORI = '"+cPrefOFI+"' OR SF2.F2_PREFORI = '"+cPrefBAL+"') AND "
	cQuery += "SF1.D_E_L_E_T_  = ' ' AND SD1.D_E_L_E_T_  = ' ' AND SF2.D_E_L_E_T_  = ' ' ORDER BY SF1.F1_DTDIGIT"

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
Local cTpNota := ""
Local cDataPrev := ""
Local aVetNome := {}
Local aVetTam := {}
Local aVetData := {}
Local aVetHora := {}
Local i        := 0
Local cQryAlVSC := "SQLVSC"
Local cPar10   := Subs(Alltrim(Mv_Par10),6)
Local cPar11   := Subs(Alltrim(Mv_Par11),6)
Local lCelularCust := !Empty(Mv_Par10) .and. !Empty(Mv_Par11) .and. SA1->(FieldPos((cPar10))) > 0 .and. SA1->(FieldPos((cPar11))) > 0
Local cSQLAux  := "SQLSD2"

Private aPeca   := {}
Private aCalSer  := {}

if mv_par09 == 1
	cTpNota := "PSN"
Elseif mv_par09 == 2
	cTpNota := "PSCE"
Elseif mv_par09 == 3
	cTpNota := "PSCC"
Elseif mv_par09 == 4
	cTpNota := "PSC"
Endif

//#############################################################################
//# Tenta abrir o arquivo texto                                               #
//#############################################################################
if mv_par09 == 4
	cArquivo := "OFIXI020_"+(cQrySF2)->F2_DOC+"_"+cFilAnt+"C.XML"
Else
	cArquivo := "OFIXI020_"+(cQrySF2)->F2_DOC+"_"+cFilAnt+".XML"
Endif
//
aDir( Alltrim(MV_PAR01)+cArquivo ,aVetNome,aVetTam,aVetData,aVetHora)
//
nHnd := FCREATE(Alltrim(MV_PAR03)+Alltrim(cArquivo),0)

cDataPrev := IiF(!Empty(stod((cQrySF2)->VO1_DATENT)),dtoc(stod((cQrySF2)->VO1_DATENT)),"")

cLinha := "<?xml version='1.0' encoding='ISO-8859-1' ?>"+CHR(13)+CHR(10)
cLinha += "<notafiscal>"+CHR(13)+CHR(10)

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
lAchou := .f.

if !Empty((cQrySF2)->VO1_PROVEI+(cQrySF2)->VO1_LOJPRO)
	cProVei := (cQrySF2)->VO1_PROVEI
	cLojPro := (cQrySF2)->VO1_LOJPRO
Else
	cProVei := (cQrySF2)->VO1_FATPAR
	cLojPro := (cQrySF2)->VO1_LOJA
Endif

if !Empty((cQrySF2)->VO1_NUMOSV)
	if SA1->A1_COD+SA1->A1_LOJA <> cProVei+cLojPro
		lAchou := .t.
	Endif
Endif
if lAchou   // somente listar o proprietario do veiculo quando for uma venda de pecas ofina
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
	cLinha += "<CEP>"+Alltrim(PADR(SA1->A1_CEP,8))+"</CEP>"+CHR(13)+CHR(10)
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
if !Empty((cQrySF2)->VO1_NUMOSV)
	cLinha += "<veiculo>"+CHR(13)+CHR(10)
	dbSelectArea("VV1")
	dbSetOrder(1)
	dbSeek(xFilial("VV1")+(cQrySF2)->VO1_CHAINT)
	cLinha += "<chassi>"+Alltrim(PADR(VV1->VV1_CHASSI,22))+"</chassi>"+CHR(13)+CHR(10)
	If !Empty(VV1->VV1_PLAVEI)
		cLinha += "<placa>"+Alltrim(substr(VV1->VV1_PLAVEI,1,3)+"-"+substr(VV1->VV1_PLAVEI,4,4))+"</placa>"+CHR(13)+CHR(10)
	Endif
	If !Empty((cQrySF2)->VO1_KILOME)
		cLinha += "<km>"+Alltrim(PADR((cQrySF2)->VO1_KILOME,8))+"</km>"+CHR(13)+CHR(10)
	Endif
	cLinha += "</veiculo>"+CHR(13)+CHR(10)
Else
	cLinha += "<veiculo>"+CHR(13)+CHR(10)
	cLinha += "</veiculo>"+CHR(13)+CHR(10)
Endif
cLinha += "<itensVendidos>"+CHR(13)+CHR(10)

nSeq := 1
cTipOs := ""

if (cQrySF2)->F2_PREFORI == cPrefOFI

	VOI->(dbSetOrder(1))
	cTipOs := ""
	if mv_par09 <> 4
		aPeca := FMX_CALPEC( (cQrySF2)->VO1_NUMOSV ,;
									/* cTipTem */,;
									/* cGruIte */,;
									/* cCodIte */,;
									.f. /* lMov */,;
									.t. /* lNegoc */,;
									.t. /* lReqZerada */,;
									.t. /* lRetAbe */,;
									.t. /* lRetLib */,;
									.t. /* lRetFec */,;
									.f. /* lRetCan */,;
									/* cLibVOO */,;
									" VO3_NUMNFI = '" + (cQrySF2)->F2_DOC + "' AND VO3_SERNFI = '" + (cQrySF2)->F2_SERIE + "'" /* cFiltroSQL */ )
	Else
		aPeca := FS_DELETADO()
	Endif

	if mv_par09 == 4
		nPosQtd := 3
		nPosTiptem := 4
	Else
		nPosQtd := 5
		nPosTiptem := PECA_TIPTEM
	Endif
	For i := 1 to Len(aPeca)
		dbSelectArea("SB1")
		dbSetOrder(7)
		dbSeek(xFilial("SB1")+aPeca[i,1]+aPeca[i,2])
		cQuery := "SELECT SD2.R_E_C_N_O_ RECSD2 "
		cQuery += "FROM "+RetSqlName("SD2")+ " SD2 "
		cQuery += "WHERE SD2.D2_FILIAL = '"+xFilial("SD2")+"' AND "
		cQuery += "SD2.D2_DOC = '"+(cQrySF2)->F2_DOC+"' AND "
		cQuery += "SD2.D2_SERIE = '"+(cQrySF2)->F2_SERIE+"' AND "
		cQuery += "SD2.D2_CLIENTE = '"+(cQrySF2)->F2_CLIENTE+"' AND "
		cQuery += "SD2.D2_LOJA = '"+(cQrySF2)->F2_LOJA+"' AND "
		cQuery += "SD2.D2_COD = '"+SB1->B1_COD+"' AND "
		if mv_par09 == 4 // Le cancelados
			cQuery += "SD2.D_E_L_E_T_ <> ' '"
		Else
			cQuery += "SD2.D_E_L_E_T_ = ' '"
		Endif

		nRecNo := FM_SQL(cQuery)

		dbSelectArea("SD2")
		SD2->(DBGoTo(nRecNo))
		if !Empty(MV_PAR06)
			dbSelectArea("SBM")
			dbSetOrder(1)
			dbSeek(xFilial("SBM")+SB1->B1_GRUPO)
			if SBM->BM_CODMAR <> MV_PAR06
				Loop
			Endif
		Endif
		cLinha += "<detalhesItem>"+CHR(13)+CHR(10)
		cLinha += "<sequencia>"+Alltrim(str(nSeq))+"</sequencia>"+CHR(13)+CHR(10)
		cLinha += "<partNumber>"+Alltrim(PADR(aPeca[i,2],20))+"</partNumber>"+CHR(13)+CHR(10)
		cLinha += "<descrItem>"+Alltrim(PADR(SB1->B1_DESC,60))+"</descrItem>"+CHR(13)+CHR(10)
		if Alltrim(SB1->B1_UM) == "L"
			cUM := "Litros"
		Elseif Alltrim(SB1->B1_UM) == "UN"
			cUM := "Unidades"
		Else
			cUM := "Pecas"
		Endif
		cLinha += "<unidadeMedida>"+Alltrim(PADR(cUM,8))+"</unidadeMedida>"+CHR(13)+CHR(10)
		cLinha += "<precoUnitario>"+Alltrim(str(SD2->D2_PRUNIT))+"</precoUnitario>"+CHR(13)+CHR(10)
		//			cLinha += "<precoUnitario>"+transform(SD2->D2_PRUNIT,"@E 999,999.99")+"</precoUnitario>"+CHR(13)+CHR(10)
		cLinha += "<quantidade>"+Alltrim(transform(aPeca[i,nPosQtd],"9999999999"))+"</quantidade>"+CHR(13)+CHR(10)
		//			cLinha += "<descontoUnitario>"+transform(SD2->D2_DESCON/aPeca[i,5],"@E 9999999,99")+"</descontoUnitario>"+CHR(13)+CHR(10)
		cLinha += "<descontoUnitario>"+Alltrim(str(SD2->D2_DESCON/aPeca[i,nPosQtd]))+"</descontoUnitario>"+CHR(13)+CHR(10)
		cLinha += "</detalhesItem>"+CHR(13)+CHR(10)

		nSeq += 1

		If i == 1
			VOI->(MsSeek(xFilial("VOI")+aPeca[i,nPosTiptem]))
			if VOI->VOI_SITTPO == "3"
				cTipOs := "I"
			Elseif VOI->VOI_SITTPO == "2"
				cTipOs := "G"
			Else
				cTipOs := "C"
			Endif
			If ( ExistBlock("OXITIPOS") )
				cTipOs := ExecBlock("OXITIPOS",.f.,.f.,{aPeca[i,nPosTiptem]})
			EndIf

		EndIf

	Next
	cLinha += "</itensVendidos>"+CHR(13)+CHR(10)

////////////////////////////////		Manoel - 02/04/2015

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
	nValSer := (cQryAlVSC)->VALSER
	(cQryAlVSC)->(dbCloseArea())
	cLinha += "</servicos>"+CHR(13)+CHR(10)

	if mv_par09 <> 4 // Cancelamento
		aCalSer := FMX_CALSER((cQrySF2)->VO1_NUMOSV  ,;
									  /* cTipTem */ ,;
									 /* cGruSer */,;
									 /* cCodSer */,;
									 .f. /* lApont */ ,;
									 .t. /* lNegoc */,;
									 .t. /* lRetAbe */,;
									 .t. /* lRetLib */,;
									 .t. /* lRetFec */,;
									 .f. /* lRetCan*/ )
   Else
		aCalSer := FS_DELSRV()
   Endif
	if mv_par09 == 4
		nCodSer := 1
		nValS   := 2
		nValD   := 3
	Else
		nCodSer := 2
		nValS   := 9
		nValD   := 8
	Endif


	nSeq := 1
	cLinha += "<itensOS>"+CHR(13)+CHR(10)
	if nValSer <> 0
	    For i := 1 to Len(aCalSer)
			cLinha += "<detalhesServicos>"+CHR(13)+CHR(10)
			cLinha += "<seqServico>"+Alltrim(str(nSeq))+"</seqServico>"+CHR(13)+CHR(10)
			cLinha += "<codigoServico>"+Alltrim(PADR(aCalSer[i,nCodSer],10))+"</codigoServico>"+CHR(13)+CHR(10)
			dbSelectArea("VO6")
			dbSetOrder(4)
			dbSeek(xFilial("VO6")+aCalSer[i,nCodSer])
			cLinha += "<descricaoServico>"+Alltrim(PADR(VO6->VO6_DESSER,100))+"</descricaoServico>"+CHR(13)+CHR(10)
			cLinha += "<precoUnitServico>"+Alltrim(PADR(Alltrim(str(aCalSer[i,nValS])),10))+"</precoUnitServico>"+CHR(13)+CHR(10)
			cLinha += "<quantidadeServico>"+Alltrim(PADR(Alltrim(str(1)),10))+"</quantidadeServico>"+CHR(13)+CHR(10)
			cLinha += "<descontoUnitServico>"+Alltrim(PADR(Alltrim(str(aCalSer[i,nValD])),10))+"</descontoUnitServico>"+CHR(13)+CHR(10)
			cLinha += "<respostaReparo>"+Alltrim(PADR(VO6->VO6_DESSER,250))+"</respostaReparo>"+CHR(13)+CHR(10)
			cLinha += "</detalhesServicos>"+CHR(13)+CHR(10)
		    nSeq += 1
		Next
	Endif

	cLinha += "</itensOS>"+CHR(13)+CHR(10)

////////////////////////////////		Manoel - 02/04/2015

	cLinha += "<ordemServico>"+CHR(13)+CHR(10)
	if cTIPCli == "U"
		cLinha += "<tipoCliente>"+"U"+"</tipoCliente>"+CHR(13)+CHR(10)
	Else
		cLinha += "<tipoCliente>"+"P"+"</tipoCliente>"+CHR(13)+CHR(10)
	Endif
	cLinha += "<tipoOS>"+cTipOs+"</tipoOS>"+CHR(13)+CHR(10)
	cLinha += "<formaPagamento>"+"PP"+"</formaPagamento>"+CHR(13)+CHR(10)

	SYP->(DbSeek(xFilial("SYP")+(cQrySF2)->VO1_OBSMEM ))
	cObs := ""
	Do While !SYP->(Eof()) .And. SYP->YP_CHAVE == (cQrySF2)->VO1_OBSMEM .And. SYP->YP_FILIAL == xFilial("SYP")
		cObs := RTrim(Stuff(SYP->YP_TEXTO, If( (nPos:=At("\13\10",SYP->YP_TEXTO))<=0 ,80,nPos) ,6,Space(6)))
		SYP->(DbSkip())
	EndDo
	iF !Empty(cObs)
		cLinha += "<obs>"+Alltrim(PADR(cObs,250))+"</obs>"+CHR(13)+CHR(10)
	Endif
	cLinha += "</ordemServico>"+CHR(13)+CHR(10)

Else

	cQuery := "SELECT SD2.R_E_C_N_O_ AS RECSD2 "
	cQuery += "FROM "+RetSqlName("SD2")+ " SD2 "
	cQuery += "WHERE SD2.D2_FILIAL = '"+xFilial("SD2")+"' AND "
	cQuery += "SD2.D2_DOC = '"+(cQrySF2)->F2_DOC+"' AND "
	cQuery += "SD2.D2_SERIE = '"+(cQrySF2)->F2_SERIE+"' AND "
	if mv_par09 == 4 // Le cancelados
		cQuery += "SD2.D_E_L_E_T_ <> ' '"
	Else
		cQuery += "SD2.D_E_L_E_T_ = ' '"
	Endif
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAux, .F., .T. )
	While !(cSQLAux)->(Eof())
		//
		dbSelectArea("SD2")
		SD2->(DBGoTo((cSQLAux)->( RECSD2 )))
		//
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1")+SD2->D2_COD)
		if !Empty(MV_PAR06)
			dbSelectArea("SBM")
			dbSetOrder(1)
			dbSeek(xFilial("SBM")+SB1->B1_GRUPO)
			if SBM->BM_CODMAR <> MV_PAR06
				(cSQLAux)->(dbSkip())
				Loop
			Endif
		Endif
		cLinha += "<detalhesItem>"+CHR(13)+CHR(10)
		cLinha += "<sequencia>"+Alltrim(str(nSeq))+"</sequencia>"+CHR(13)+CHR(10)
		cLinha += "<partNumber>"+Alltrim(PADR(SB1->B1_CODITE,20))+"</partNumber>"+CHR(13)+CHR(10)
		cLinha += "<descrItem>"+Alltrim(PADR(SB1->B1_DESC,60))+"</descrItem>"+CHR(13)+CHR(10)
		if Alltrim(SB1->B1_UM) == "L"
			cUM := "Litros"
		Elseif Alltrim(SB1->B1_UM) == "UN"
			cUM := "Unidades"
		Else
			cUM := "Pecas"
		Endif
		cLinha += "<unidadeMedida>"+Alltrim(PADR(cUM,8))+"</unidadeMedida>"+CHR(13)+CHR(10)
		cLinha += "<precoUnitario>"+Alltrim(str(SD2->D2_PRUNIT))+"</precoUnitario>"+CHR(13)+CHR(10)
		//			cLinha += "<precoUnitario>"+transform(SD2->D2_PRUNIT,"@E 999,999.99")+"</precoUnitario>"+CHR(13)+CHR(10)
		cLinha += "<quantidade>"+Alltrim(transform(SD2->D2_QUANT,"9999999999"))+"</quantidade>"+CHR(13)+CHR(10)
		//			cLinha += "<descontoUnitario>"+transform(SD2->D2_DESCON/aPeca[i,5],"@E 9999999,99")+"</descontoUnitario>"+CHR(13)+CHR(10)
		cLinha += "<descontoUnitario>"+Alltrim(str(SD2->D2_DESCON/SD2->D2_QUANT))+"</descontoUnitario>"+CHR(13)+CHR(10)
		cLinha += "</detalhesItem>"+CHR(13)+CHR(10)

		nSeq += 1

		(cSQLAux)->(dbSkip())
	EndDo
	(cSQLAux)->(dbCloseArea())
	//
	cLinha += "</itensVendidos>"+CHR(13)+CHR(10)
Endif
dbSelectArea("SD2")

nValSer := 0
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
If FieldPos("VDU_SDOC") > 0 .and. (cQrySF2)->(FieldPos("F2_SDOC")) <> 0
	VDU->VDU_SDOC := (cQrySF2)->F2_SDOC
EndIf

VDU->VDU_TIPDOC := "P"
VDU->VDU_NUMSEQ := GetSXENum("VDU","VDU_NUMSEQ")
VDU->VDU_DATENV := ddatabase
ConfirmSX8()
MsUnlock()

Return

Static Function FS_DELETADO()
Local cQryVEC := "SQLVEC"

cQuery := "SELECT VEC.VEC_GRUITE,VEC.VEC_CODITE,VEC.VEC_QTDITE,VEC.VEC_TIPTEM "
cQuery += "FROM "+RetSqlName("VEC")+ " VEC "
cQuery += "WHERE VEC.VEC_FILIAL = '" + xFilial("VEC") + "' AND "
cQuery += "VEC.VEC_NUMNFI = '"+(cQrySF2)->(F2_DOC)+"' AND "
cQuery += "VEC.VEC_SERNFI = '"+(cQrySF2)->(F2_SERIE)+"' AND "
cQuery += "VEC.D_E_L_E_T_ <> ' '"

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryVEC, .F., .T. )

While  !(cQryVEC)->(Eof())

	aAdd(aPeca,{(cQryVEC)->VEC_GRUITE,(cQryVEC)->VEC_CODITE,(cQryVEC)->VEC_QTDITE,(cQryVEC)->VEC_TIPTEM})

	dbSelectArea(cQryVEC)
	(cQryVEC)->(dbSkip())

Enddo
(cQryVEC)->(dbCloseArea())

Return(aPeca)

Static Function FS_DELSRV()
Local cQryVSC := "SQLVSC"

cQuery := "SELECT VSC.VSC_CODSER,VSC.VSC_VALSER,VSC.VSC_VALDES "
cQuery += "FROM " + RetSQLName("VSC" ) + " VSC "
cQuery += "WHERE VSC.VSC_FILIAL = '" + xFilial("VSC") + "' AND VSC.VSC_NUMNFI = '"+(cQrySF2)->F2_DOC+"' AND "
cQuery += "VSC.VSC_SERNFI = '"+(cQrySF2)->F2_SERIE+"' AND "
cQuery += "VSC.D_E_L_E_T_ <> ' '"


dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryVSC, .F., .T. )

While  !(cQryVSC)->(Eof())

	aAdd(aCalSer,{(cQryVSC)->VSC_CODSER,(cQryVSC)->VSC_VALSER,(cQryVSC)->VSC_VALDES})

	dbSelectArea(cQryVSC)
	(cQryVSC)->(dbSkip())

Enddo
(cQryVSC)->(dbCloseArea())

Return(aCalSer)