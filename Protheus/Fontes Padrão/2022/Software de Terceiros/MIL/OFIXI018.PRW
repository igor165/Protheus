#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFIXI018.CH"

/*
================================================================================
################################################################################
##+----------+------------+-------+-----------------------+------+-----------+##
##|Função    | OFIXI018   | Autor | Thiago                | Data | 02/01/13  |##
##+----------+------------+-------+-----------------------+------+-----------+##
##|Descrição | Exportação das ordem de serviço MitSubishi					 |##
##+----------+---------------------------------------------------------------+##
##|Uso       |                                                               |##
##+----------+---------------------------------------------------------------+##
################################################################################
================================================================================
*/
Function OFIXI018(lPainel,nFilSIR,MVPar01,MVPar02,MVPar03,MVPar04,MVPar05,MVPar06,MVPar07,MVPar08)
//
Local cDesc1  := STR0001
Local cDesc2  := STR0002
Local cDesc3  := STR0003
Local aSay := {}
Local aButton := {}
//
Private cTitulo := STR0004
Private cPerg := "OXI018"
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
	// Local nOpcGetFil := GETF_LOCALHARD + GETF_NETWORKDRIVE + GETF_RETDIRECTORY
	// aAdd(aRegs,{STR0012,STR0012,STR0012,"MV_CH1","D", 8,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S"})
	// aAdd(aRegs,{STR0013,STR0013,STR0013,"MV_CH2","D", 8,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S"})
	// aAdd(aRegs,{STR0014,STR0014,STR0014,"MV_CH3","C",99,0,0,"G","!Vazio().or.(Mv_Par03:=cGetFile('Arquivos |*.*','',,,,"+AllTrim(Str(nOpcGetFil))+"))","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S"})
	// aAdd(aRegs,{STR0015,STR0015,STR0015,"MV_CH4","N", 6,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","","999999"})
	// aAdd(aRegs,{STR0016,STR0016,STR0016,"MV_CH5","N", 1,0,0,"C","","mv_par05",STR0017,"","","","",STR0018,"","","","","","","","","","","","","","","","","","","",""	,"S","","","9"})
	// aAdd(aRegs,{STR0020,STR0020,STR0020,"MV_CH6","C", 3,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","VE1",""	,"S","","",""})
	// aAdd(aRegs,{STR0023,STR0023,STR0023,"MV_CH7","C", 9,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","VO1",""	,"S","","",""})
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
Else
	//
	MV_Par01 := MVPar01
	MV_Par02 := MVPar02
	MV_Par03 := MVPar03
	MV_Par04 := MVPar04
	MV_Par05 := MVPar05
	MV_Par06 := MVPar06
	MV_Par08 := MVPar07
	Mv_Par09 := MVPar08
	MV_Par07 := ""
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
Local cQryVO1   := "SQLVO1"    
Local nCont := 0 
Local aSM0     := {}
Local aCalSer := {}
Local cPar08   := Subs(Alltrim(Mv_Par08),6)
Local cPar09   := Subs(Alltrim(Mv_Par09),6)
Local lCelularCust := !Empty(Mv_Par08) .and. !Empty(Mv_Par09) .and. SA1->(FieldPos((cPar08))) > 0 .and. SA1->(FieldPos((cPar09))) > 0

aSM0 := FWArrFilAtu(cEmpAnt,cFilAnt) // Filial Origem (Filial logada)

if nFilS == 0
	nFilS := mv_par04
Endif

cQuery := "SELECT VO1.VO1_NUMOSV,VO1.VO1_STATUS,VO1.VO1_FILIAL,VO1.VO1_DATABE,VO1.VO1_DATENT,VO1.VO1_PROVEI,VO1.VO1_LOJPRO,VO1.VO1_CHAINT,VO1.VO1_OBSMEM,VO1.VO1_FUNABE,VO1.VO1_KILOME "
cQuery += "FROM " + RetSQLName("VO1" ) + " VO1 "  
cQuery += "WHERE VO1.VO1_FILIAL = '" + xFilial("VO1") + "' AND VO1.VO1_DATABE >= '"+dtos(MV_PAR01)+"' AND VO1.VO1_DATABE <= '"+dtos(MV_PAR02)+"' AND VO1.VO1_STATUS <> 'F' AND "
if !Empty(MV_PAR06)
	cQuery += "VO1.VO1_CODMAR = '"+MV_PAR06+"' AND "
Endif	
If Empty(Mv_Par07) 
	cQuery += " NOT EXISTS (SELECT VDU_NUMSEQ FROM "+RetSQLName("VDU")+" VDU WHERE VDU.VDU_FILIAL='"+xFilial("VDU")+"' AND VDU.VDU_CODMAR='"+MV_Par06+"' AND VDU.VDU_NUMDOC = VO1.VO1_NUMOSV AND VDU.D_E_L_E_T_=' ') AND "
Else
	cQuery += " VO1.VO1_NUMOSV = '" + Alltrim(Mv_Par07) + "' AND "
Endif       

cQuery += " EXISTS( SELECT VO4_NUMOSV FROM "+RetSQLName("VO4")+" VO4 WHERE VO4_FILIAL = '" + xFilial("VO4") + "' AND VO4.VO4_NUMOSV = VO1.VO1_NUMOSV AND VO4.D_E_L_E_T_ = ' '"
cQuery +=               " AND VO4_DATFEC = '        ') AND " // Nao considera servicos fechados 
cQuery += "VO1.D_E_L_E_T_ = ' '"
		
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryVO1, .F., .T. )
nTotReg := Contar(cQryVO1, "!Eof()")

conout("Query "+cQuery)

If !FWGetRunSchedule() // não está sendo chamada pelo Schedule
	SetRegua(nTotReg)
Endif
																											
(cQryVO1)->(DBGoTop())

If (cQryVO1)->(Eof())
	MsgStop(STR0022,STR0007)
	(cQryVO1)->(dbCloseArea())
	return
Endif
		
cTIPCli := "P"	
While  !(cQryVO1)->(Eof())

	//
	//#############################################################################
	//# Tenta abrir o arquivo texto                                               #
	//#############################################################################
	cArquivo := "OFIXI018_"+(cQryVO1)->VO1_NUMOSV+".XML"
	//
	nHnd := FCREATE(Alltrim(MV_PAR03)+Alltrim(cArquivo),0)

	cLinha := "<?xml version='1.0' encoding='ISO-8859-1' ?>"+CHR(13)+CHR(10)
	cLinha += "<notafiscal>"+CHR(13)+CHR(10)
	
	aCalSer := FMX_CALSER( (cQryVO1)->VO1_NUMOSV,;
							/* cTipTem */ ,;
							/* cGruSer */ ,;
							/* cCodSer */ ,;
							.f. /* lApont */,;
							.f. /* lNegoc */,;
							.t. /* lRetAbe */,;
							.t. /* lRetLib */,;
							.f. /* lRetFec */,;
							.f. /* lRetCan */,;
							/* cLibVOO */,;
							/* cFiltroSQL */ )

		
	cLinha += "<header>"+CHR(13)+CHR(10)      
	if MV_PAR05 == 1
		 cTipoArq := "T"
	Else
		 cTipoArq := "P"
	Endif   
	cLinha += "<tipoArquivo>"+cTipoArq+"</tipoArquivo>"+CHR(13)+CHR(10)
	if !Empty(mv_par07)
		cTpNota := "OSCE"
		Else
		if (cQryVO1)->VO1_STATUS == "C"
			 cTpNota := "OSC "
		Else
			 cTpNota := "OSN "
		Endif
	Endif
	cLinha += "<tipoNota>"+cTpNota+"</tipoNota>"+CHR(13)+CHR(10)
	cLinha += "<codigoConcessionaria>"+Alltrim(str(nFilS))+"</codigoConcessionaria>"+CHR(13)+CHR(10)
	cLinha += "<cnpjConcessionaria>"+Alltrim(PADR(aSM0[18],18))+"</cnpjConcessionaria>"+CHR(13)+CHR(10)
	cLinha += "<numeroOS>"+Alltrim(PADR((cQryVO1)->VO1_NUMOSV,18))+"</numeroOS>"+CHR(13)+CHR(10)
	cLinha += "<dataOS>"+dtoc(stod((cQryVO1)->VO1_DATABE))+"</dataOS>"+CHR(13)+CHR(10)
	
	If !Empty(sTod(((cQryVO1)->VO1_DATENT)))
		cLinha += "<dataPrevisao>"+dtoc(stod((cQryVO1)->VO1_DATENT))+"</dataPrevisao>"+CHR(13)+CHR(10)
	Endif
	cLinha += "<faturado>"+CHR(13)+CHR(10)            
		
	nValSer := 0
	for nCont:=1 to Len(aCalSer)
		nValSer += aCalSer[nCont,7]
		cCliente := aCalSer[nCont,20]
		cLoja    := aCalSer[nCont,21]
	Next

	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial("SA1")+cCliente+cLoja)
	cLinha += "<tipoPessoa>"+SA1->A1_PESSOA+"</tipoPessoa>"+CHR(13)+CHR(10)
	cLinha += "<nome>"+Alltrim(PADR(SA1->A1_NOME,70))+"</nome>"+CHR(13)+CHR(10)
	cLinha += "<cpf>"+Alltrim(PADR(SA1->A1_CGC,18))+"</cpf>"+CHR(13)+CHR(10)
	If !Empty(SA1->A1_PFISICA)
		cLinha += "<rg>"+SA1->A1_PFISICA+"</rg>"+CHR(13)+CHR(10)
	Endif
	cLinha += "<endereco>"+CHR(13)+CHR(10) 
		if SA1->(FieldPos("A1_TPLOGR")) > 0
		cLinha += "<tipoLogr>"+SA1->A1_TPLOGR+"</tipoLogr>"+CHR(13)+CHR(10)
	Endif
	cEnd    := SA1->A1_END
	cLinha += "<logradouro>"+cEnd+"</logradouro>"+CHR(13)+CHR(10)
	if SA1->(FieldPos("A1_NUMERO")) > 0 .and. !Empty(SA1->A1_NUMERO)
		cLinha += "<numero>"+Alltrim(SA1->A1_NUMERO)+"</numero>"+CHR(13)+CHR(10)
	Endif
	if !Empty(SA1->A1_COMPLEM)
		cLinha += "<complemento>"+Alltrim(PADR(SA1->A1_COMPLEM,50))+"</complemento>"+CHR(13)+CHR(10)
	Endif
	cLinha += "<bairro>"+Alltrim(PADR(SA1->A1_BAIRRO,30))+"</bairro>"+CHR(13)+CHR(10)
	cLinha += "<cidade>"+Alltrim(PADR(SA1->A1_MUN,30))+"</cidade>"+CHR(13)+CHR(10)
	cLinha += "<estado>"+SA1->A1_EST+"</estado>"+CHR(13)+CHR(10)
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
	//cLinha += "<ramal>    </ramal>"+CHR(13)+CHR(10)
	cLinha += "</telefone>"+CHR(13)+CHR(10)
	cLinha += "<email>"+Alltrim(PADR(SA1->A1_EMAIL,50))+"</email>"+CHR(13)+CHR(10)
	
	If !Empty(dtoc(SA1->A1_DTNASC))
		cLinha += "<data_nasc>"+dtoc(SA1->A1_DTNASC)+"</data_nasc>"+CHR(13)+CHR(10)
	Endif

	If lCelularCust .and. !Empty(SA1->A1_DDI) .and. !Empty(&(Mv_Par08)) .and. !Empty(&(Mv_Par09))
		cLinha += "<celular>"+CHR(13)+CHR(10)
		cLinha += "<ddi>"+Alltrim(PADR(SA1->A1_DDI,3))+"</ddi>"+CHR(13)+CHR(10)
		cLinha += "<ddd>"+Alltrim(PADR(&(Mv_Par08),3))+"</ddd>"+CHR(13)+CHR(10)
		cLinha += "<numero>"+Alltrim(PADR(&(Mv_Par09),12))+"</numero>"+CHR(13)+CHR(10)
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
	

	cLinha += "</header>"+CHR(13)+CHR(10) 
	cLinha += "<servicos>"+CHR(13)+CHR(10) 

																								 
	cLinha += "<valorServico>"+Alltrim(Str(nValSer))+"</valorServico>"+CHR(13)+CHR(10) 
	cLinha += "</servicos>"+CHR(13)+CHR(10) 

	nSeq := 1 
	cLinha += "<itensOS>"+CHR(13)+CHR(10) 

		for nCont:=1 to Len(aCalSer)
		cLinha += "<detalhesServicos>"+CHR(13)+CHR(10) 
		cLinha += "<seqServico>"+Alltrim(str(nSeq))+"</seqServico>"+CHR(13)+CHR(10) 
		cLinha += "<codigoServico>"+Alltrim(PADR(aCalSer[nCont,2],10))+"</codigoServico>"+CHR(13)+CHR(10) 
		dbSelectArea("VO6")
		dbSetOrder(4)
		dbSeek(xFilial("VO6")+aCalSer[nCont,2])
		cLinha += "<descricaoServico>"+Alltrim(PADR(VO6->VO6_DESSER,100))+"</descricaoServico>"+CHR(13)+CHR(10) 
		cLinha += "<precoUnitServico>"+Alltrim(str(aCalSer[nCont,7]))+"</precoUnitServico>"+CHR(13)+CHR(10) 
		cLinha += "<quantidadeServico>"+Alltrim(str(1))+"</quantidadeServico>"+CHR(13)+CHR(10)      
		
		dbSelectArea("VZ1")
		dbSetOrder(4)
		if dbSeek(xFilial("VZ1")+(cQryVO1)->VO1_NUMOSV+aCalSer[nCont,4]+"S"+aCalSer[nCont,1]+aCalSer[nCont,2]+aCalSer[nCont,5])
			cLinha += "<descontoUnitServico>"+Alltrim(str(VZ1->VZ1_VALDES))+"</descontoUnitServico>"+CHR(13)+CHR(10) 
			Else 
			cLinha += "<descontoUnitServico>"+Alltrim(str(aCalSer[nCont,8]))+"</descontoUnitServico>"+CHR(13)+CHR(10) 
			Endif
		cLinha += "<respostaReparo>"+Alltrim(PADR(VO6->VO6_DESSER,250))+"</respostaReparo>"+CHR(13)+CHR(10) 
		cLinha += "</detalhesServicos>"+CHR(13)+CHR(10) 
		dbSelectArea("VOI")
		dbSetOrder(1)
		dbSeek(xFilial("VOI")+aCalSer[nCont,4]+"S") 
		if VOI->VOI_SITTPO == "3"
			 cTipOs := "I"
		Elseif VOI->VOI_SITTPO == "2"
			 cTipOs := "G"
		Else            
			 cTipOs := "C"
		Endif
		If ( ExistBlock("OXITIPOS") ) 
			cTipOs := ExecBlock("OXITIPOS",.f.,.f.,{aCalSer[nCont,4]})
		EndIf   	
		
			nSeq += 1
	 
	Next
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
	 DbSeek(xFilial("SYP")+(cQryVO1)->VO1_OBSMEM )

	cObs := ""
	Do While !Eof() .And. SYP->YP_CHAVE == (cQryVO1)->VO1_OBSMEM .And. SYP->YP_FILIAL == xFilial("SYP")

				cObs := RTrim(Stuff(SYP->YP_TEXTO, If( (nPos:=At("\13\10",SYP->YP_TEXTO))<=0 ,80,nPos) ,6,Space(6)))

				dbSelectArea("SYP")
				DbSkip()

	EndDo
	If !Empty(cObs)
		cLinha += "<obs>"+Alltrim(PADR(cObs,250))+"</obs>"+CHR(13)+CHR(10) 
	Endif
	cLinha += "</ordemServico>"+CHR(13)+CHR(10) 
	cLinha += "<atendente>"+CHR(13)+CHR(10)   
	dbSelectArea("VAI")
	dbSetOrder(1)
	dbSeek(xFilial("VAI")+(cQryVO1)->VO1_FUNABE)
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
		VDU->VDU_FILDOC := (cQryVO1)->VO1_FILIAL
		VDU->VDU_NUMDOC := (cQryVO1)->VO1_NUMOSV
		VDU->VDU_CODMAR := MV_Par06
		VDU->VDU_SERDOC := ""
		if FieldPos("VDU_SDOC") > 0
			VDU->VDU_SDOC := ""
		EndIf
		VDU->VDU_TIPDOC := "O"
		VDU->VDU_NUMSEQ := GetSXENum("VDU","VDU_NUMSEQ")
		VDU->VDU_DATENV := dDataBase
		ConfirmSX8()
		MsUnlock()
	

		dbSelectArea(cQryVO1)
		(cQryVO1)->(dbSkip())
		
Enddo    
(cQryVO1)->(dbCloseArea())

If !FWGetRunSchedule() // não está sendo chamada pelo Schedule
	MsgInfo(STR0010,STR0007)
Endif

return

