// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 4      º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFIXI012.CH"

/*
================================================================================
################################################################################
##+----------+------------+-------+-----------------------+------+-----------+##
##|Função    | OFIXI012   | Autor | Thiago                | Data | 02/01/13  |##
##+----------+------------+-------+-----------------------+------+-----------+##
##|Descrição | Exporta as informações do PPA.								 |##
##+----------+---------------------------------------------------------------+##
##|Uso       |                                                               |##
##+----------+---------------------------------------------------------------+##
################################################################################
================================================================================
*/
Function OFIXI012()
//
Local cDesc1  := STR0001
Local cDesc2  := STR0002

Local cDesc3  := STR0040
Local aSay := {}
Local aButton := {}

Private cTitulo := "" // TODO - Titulo do Assunto (Vai no relatório e FormBatch)
Private cPerg := "OXI012" 	// TODO -Pergunte
Private lErro := .f.  	    // Se houve erro, não move arquivo gerado
Private cArquivo			// Nome do Arquivo a ser importado
Private aLinhasRel := {}	// Linhas que serão apresentadas no relatorio

//
CriaSX1()
CriaSX1_2()
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
RptStatus( {|lEnd| ExportArq(@lEnd)},"",STR0003)

if !lErro
//	RptStatus({|lEnd| ImprimeRel(@lEnd) },"Aguarde...", "Imprimindo relatório.", .T. )
endif
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
//
Local aVetNome := {}
Local aVetTam := {}
Local aVetData := {}
Local aVetHora := {}  
Local CALIASVO3 := "SQLVO3"
Local cQryAliasVO4 := "SQLVO4"
Local CALIASVO2  := "SQLVO2"
Local CALIASSB2  := "SQLSB2"
Local cAliasVEC := "SQLVEC"
Local CALIASSD2  := "SQLSD2" 
Local CALIASSBM := "SQLSBM"
Local CALIASVE4 := "SQLVE4"  
Local CALIASSB1 := "SQLSB1"  
Local CALIASSD1 := "SQLSD1"  
Local CALIASSF2 := "SQLSF2"  
Local CALIASSF4 := "SQLSF4"  
Local CALIASSA1 := "SQLSA1"  
Local CALIASSA2  := "SQLSA2"  
Local ni      := 0  
Local ANUMBPC  := {}
Local i := 0 
//
Local nTotReg
//
Local aLayCHI    := {}
Local aLayCHF    := {}
Local aLayCPI    := {}
Local aLayCPF    := {}
Local aGrpPec := {} //vetor de Grupos de Pecas
Local aNumAce := {} //vetor de Acessorios
Local nTotCpO := 0  
Local aLayCP800 := {}                                 
Local aLayCP801 := {}                                 
Local aLayCP802 := {}                                 
Local aLayCP803 := {}                                 
Local aChave01 := {}
Local aChave02 := {}
Local aChave03 := {}
Local aChave04 := {}
Local aChave05 := {}
Local aChave06 := {}
Local aChave07 := {}
Local aLayCP804 := {}                                 
Local aNumLub   := {} 
Local aValCP801 := {}
Local AVALCP802 := {}     
Local aNumCpE := {}
Local AVALCP803 := {}
Local aTotPen := {}
Local aGrpCpR := {}
Local nGerente := 0 
Local nADM := 0 
Local nBalco := 0 
Local nBalcOFI := 0 
Local nVendAta := 0 
Local nVendAce := 0 
Local aNumCpO := {}  
Local aNumCpR := {}
cChave := Alltrim(MV_PAR04)
For ni:=1 to len(cChave)
	aAdd(aChave01,{substr(cChave,ni,6)})
	ni := ni + 6
Next
cChave := Alltrim(MV_PAR05)
For ni:=1 to len(cChave)
	aAdd(aChave02,{substr(cChave,ni,6)})
	ni := ni + 6
Next
cChave := Alltrim(MV_PAR06)
For ni:=1 to len(cChave)
	aAdd(aChave03,{substr(cChave,ni,6)})
	ni := ni + 6
Next
cChave := Alltrim(MV_PAR07)
For ni:=1 to len(cChave)
	aAdd(aChave04,{substr(cChave,ni,6)})
	ni := ni + 6
Next
cChave := Alltrim(MV_PAR08)
For ni:=1 to len(cChave)
	aAdd(aChave05,{substr(cChave,ni,6)})
	ni := ni + 6
Next
cChave := Alltrim(MV_PAR09)
For ni:=1 to len(cChave)
	aAdd(aChave06,{substr(cChave,ni,6)})
	ni := ni + 6
Next
cChave := Alltrim(MV_PAR10)
For ni:=1 to len(cChave)
	aAdd(aChave07,{substr(cChave,ni,6)})
	ni := ni + 6
Next

aAdd(aGrpCpR,{ "1" , STR0004 , 0 }) // Compras - Rede (Outros Distrib/Concessionarios)
aAdd(aGrpCpR,{ "2" , STR0005 , 0 }) // Compras - Lojas de Pecas
aAdd(aGrpCpR,{ "3" , STR0006 , 0 }) // Compras - Fabricantes
aAdd(aTotPen,{ 0 , 0 })  // Total de Vendas Pendentes

aAdd(aGrpPec,{ "A" , "01" , STR0007 , 0 , 0 })	// Grupo Pecas - Governo
aAdd(aGrpPec,{ "A" , "02" , STR0008 , 0 , 0 })	// Grupo Pecas - Frotistas
aAdd(aGrpPec,{ "A" , "03" , STR0009 , 0 , 0 })	// Grupo Pecas - Seguradoras
aAdd(aGrpPec,{ "A" , "04" , STR0010 , 0 , 0 })	// Grupo Pecas - Lj de Pecas
aAdd(aGrpPec,{ "A" , "05" , STR0011 , 0 , 0 })	// Grupo Pecas - Oficinas Independentes
aAdd(aGrpPec,{ "A" , "06" , STR0012 , 0 , 0 })	// Grupo Pecas - Rede (Concess. / Outros Distr.)
aAdd(aGrpPec,{ "O" , "07" , STR0007 , 0 , 0 })	// Grupo Pecas - Governo
aAdd(aGrpPec,{ "O" , "08" , STR0008 , 0 , 0 })	// Grupo Pecas - Frotistas
aAdd(aGrpPec,{ "O" , "09" , STR0009 , 0 , 0 })	// Grupo Pecas - Seguradoras
aAdd(aGrpPec,{ "O" , "10" , STR0013 , 0 , 0 })	// Grupo Pecas - Demais Clientes
aAdd(aGrpPec,{ "O" , "11" , STR0014 , 0 , 0 })	// Grupo Pecas - Garantia
aAdd(aGrpPec,{ "O" , "12" , STR0015 , 0 , 0 })	// Grupo Pecas - Consumo Interno


aAdd(aLayCHI, { "C", 3, 0, 1} )     // TIPO DE REGISTRO (CHI)
aAdd(aLayCHI, { "N", 1,	0,	4})     // VERSÃO DO LAYOUT (1)
aAdd(aLayCHI, { "N", 3,	0,	5})     // IDENTIFICAÇÃO DO PROCESSO (000)
aAdd(aLayCHI, { "N", 1,	0,	8})     // VERSÃO DO PROCESSO (0)
aAdd(aLayCHI, { "N", 5,	0,	9})     // CONTROLE DE TRANSMISSÃO (00000)
aAdd(aLayCHI, { "N", 12, 0,	14})    // DATA DA GERAÇÃO (0000ddmmaaaa)
aAdd(aLayCHI, { "C", 14, 0,	26})    // IDENTIFICAÇÃO DO TRANSMISSOR (0NNNNBBB….B)
aAdd(aLayCHI, { "N", 14, 0,	40})    // IDENTIFICAÇÃO DO RECEPTOR (00…0051)
aAdd(aLayCHI, { "C", 30, 0,	54})    // IDENTIFICAÇÃO DA SOFTWARE HOUSE
aAdd(aLayCHI, { "C",110, 0,	84})    // BRANCOS

aAdd(aLayCHF, { "C", 3, 0, 1} )     // TIPO DE REGISTRO (CHF)
aAdd(aLayCHF, { "N", 1,	0,	4})     // VERSÃO DO LAYOUT (1)
aAdd(aLayCHF, { "N", 5,	0,	5})     // CONTROLE DE TRANSMISSÃO (00000)
aAdd(aLayCHF, { "N", 9,	0, 10})     // TOTAL DE REGISTROS TRANSMITIDOS
aAdd(aLayCHF, { "C",175,0, 19})     // BRANCOS

// CPI - LAYOUT DO REGISTRO DE INICIO DE TRANSMISSÃO DO PROCESSO

aAdd(aLayCPI, { "C", 3, 0, 1} )     // TIPO DE REGISTRO (CPI)
aAdd(aLayCPI, { "N", 1,	0,	4})     // VERSÃO DO LAYOUT (1)
aAdd(aLayCPI, { "N", 3,	0,	5})     // IDENTIFICAÇÃO DO PROCESSO (000)
aAdd(aLayCPI, { "N", 1,	0,	8})     // VERSÃO DO PROCESSO (0)
aAdd(aLayCPI, { "N", 5,	0,	9})     // CONTROLE DE TRANSMISSÃO (00000)
aAdd(aLayCPI, { "N", 12, 0,	14})    // DATA DO MOVIMENTO (0000ddmmaaaa)
aAdd(aLayCPI, { "C", 14, 0,	26})    // IDENTIFICAÇÃO DO TRANSMISSOR (0NNNNBBB….B)
aAdd(aLayCPI, { "N", 14, 0,	40})    // IDENTIFICAÇÃO DO RECEPTOR (00…0051)
aAdd(aLayCPI, { "C", 30, 0,	54})    // IDENTIFICAÇÃO DA SOFTWARE HOUSE
aAdd(aLayCPI, { "C", 110, 0,	84})    // BRANCOS




// CPF - LAYOUT DO REGISTRO DE FIM DE TRANSMISSÃO DO PROCESSO
aAdd(aLayCPF, { "C", 3, 0, 1})		// TIPO DE REGISTRO (CPF)
aAdd(aLayCPF, { "N", 1, 0, 4})		// VERSÃO DO LAYOUT (1)
aAdd(aLayCPF, { "N", 5, 0, 5})		// CONTROLE DE TRANSMISSÃO (00000)
aAdd(aLayCPF, { "N", 9, 0, 10})		// TOTAL DE REGISTROS TRANSMITIDOS
// "  Quantidade total de registros de uma transmissão, incluindo os registros CPI e CPF."
aAdd(aLayCPF, { "C", 175, 0, 19}) 	// BRANCOS

//
//#############################################################################
//# Tenta abrir o arquivo texto                                               #
//#############################################################################
cArquivo := "OFIXI012.TXT"
//
if aDir( Alltrim(MV_PAR11)+cArquivo ,aVetNome,aVetTam,aVetData,aVetHora) > 0
	if !MsgYesNo(STR0017,STR0003)
		lErro := .t.
		return
	endif
endif
//
//       

nHnd := FCREATE(Alltrim(MV_PAR11)+Alltrim(cArquivo),0)

// Monta CHI
aValCHI := {}
nAno := Year(dDatabase)
nMes := Month(dDatabase)
nDia := Day(dDatabase)
nData = nDia * 1000000 + nMes * 10000 + nAno
aAdd(aValCHI,{"CHI",1, 0,0,0,nData, "0"+Alltrim(strzero(MV_PAR12,4)),51,STR0016," " } )
cLinhaCHI := MontaEDI(aLayCHI,aValCHI[1])
fwrite(nHnd,cLinhaCHI)

// Monta CPI
aValCPI := {}
nAno := Year(dDatabase)
nMes := Month(dDatabase)
nDia := Day(dDatabase)
nData = nDia * 1000000 + nMes * 10000 + nAno
aAdd(aValCPI,{"CPI",1, 0,0,0,nData, "0"+Alltrim(strzero(MV_PAR12,4)),51,STR0016," " } )
cLinhaCPI := MontaEDI(aLayCPI,aValCPI[1])
fwrite(nHnd,cLinhaCPI)

                                            
// CP800 - PERFORMANCE DE PEÇAS E ACESSÓRIOS - P.P.A.								
									
aAdd(aLayCP800, { "C",  3, 0, 1})		// CODIGO DO REGISTRO (CP8)
aAdd(aLayCP800, { "N",  2, 0, 4})		// SUBCÓDIGO DO REGISTRO (Fixo = 00)
aAdd(aLayCP800, { "N",  4, 0, 6})		// NÚMERO DO DEALER
aAdd(aLayCP800, { "N",  6, 0,10})		// MÊS / ANO DE REFERÊNCIA (mmaaaa)
aAdd(aLayCP800, { "N",  2, 0,16})		// REGIÃO DO DEALER
aAdd(aLayCP800, { "N",  1, 0,18})		// IDENTIFICAÇÃO DA SOFTWARE HOUSE (X)
aAdd(aLayCP800, { "C",169, 0,19})		// BRANCOS
aAdd(aLayCP800, { "N",  6, 0,188})		// VERSÃO DO LAYOUT (Fixo: 090902)

// CP801 - PERFORMANCE DE PEÇAS E ACESSÓRIOS - P.P.A.						 	 	 

aAdd(aLayCP801, { "C", 3, 0,  1} )     // CODIGO DO REGISTRO (CP8)
aAdd(aLayCP801, { "N", 2, 0,  4} )     // SUBCÓDIGO DO REGISTRO (FIXO = 01)
aAdd(aLayCP801, { "N",10, 0,  6} )     // GOVERNO ( VL = Vendas Líquidas )
aAdd(aLayCP801, { "N",10, 0, 16} )     // GOVERNO ( CV = Custo das Vendas )
aAdd(aLayCP801, { "N",10, 0, 26} )     // FROTISTAS ( VL )
aAdd(aLayCP801, { "N",10, 0, 36} )     // FROTISTAS ( CV )
aAdd(aLayCP801, { "N",10, 0, 46} )     // SEGURADORAS ( VL )
aAdd(aLayCP801, { "N",10, 0, 56} )     // SEGURADORAS (CV )
aAdd(aLayCP801, { "N",10, 0, 66} )     // LOJAS DE PEÇAS ( VL )
aAdd(aLayCP801, { "N",10, 0, 76} )     // LOJAS DE PEÇAS ( CV )
aAdd(aLayCP801, { "N",10, 0, 86} )     // OFICINAS INDEPENDENTES ( VL )
aAdd(aLayCP801, { "N",10, 0, 96} )     // OFICINAS INDEPENDENTES ( CV )
aAdd(aLayCP801, { "N",10, 0,106} )     // REDE (Outros Concessionários) ( VL )
aAdd(aLayCP801, { "N",10, 0,116} )     // REDE (Outros Concessionários) ( CV )
aAdd(aLayCP801, { "N",10, 0,126} )     // CLIENTES BALCÃO ( VL )
aAdd(aLayCP801, { "N",10, 0,136} )     // CLIENTES BALCÃO ( CV )
aAdd(aLayCP801, { "C",42, 0,146} )     // BRANCOS
aAdd(aLayCP801, { "N", 6, 0,188} )     // VERSÃO DO LAYOUT (Fixo: 090902)
           
// CP802 - PERFORMANCE DE PEÇAS E ACESSÓRIOS - P.P.A.						 	 	 

aAdd(aLayCP802, { "C", 3, 0,  1} )     // CODIGO DO REGISTRO (CP8)
aAdd(aLayCP802, { "N", 2, 0,  4} )     // SUBCÓDIGO DO REGISTRO (FIXO = 02)
aAdd(aLayCP802, { "N",10, 0,  6} )     // GOVERNO ( VL )
aAdd(aLayCP802, { "N",10, 0, 16} )     // GOVERNO ( CV )
aAdd(aLayCP802, { "N",10, 0, 26} )     // FROTISTAS ( VL )
aAdd(aLayCP802, { "N",10, 0, 36} )     // FROTISTAS ( CV )
aAdd(aLayCP802, { "N",10, 0, 46} )     // SEGURADORAS ( VL )
aAdd(aLayCP802, { "N",10, 0, 56} )     // SEGURADORAS (CV )
aAdd(aLayCP802, { "N",10, 0, 66} )     // DEMAIS CLIENTES ( VL )
aAdd(aLayCP802, { "N",10, 0, 76} )     // DEMAIS CLIENTES  (CV )
aAdd(aLayCP802, { "N",10, 0, 86} )     // GARANTIA ( VL )
aAdd(aLayCP802, { "N",10, 0, 96} )     // GARANTIA (CV )
aAdd(aLayCP802, { "N",10, 0,106} )     // CONSUMO INTERNO ( VL )
aAdd(aLayCP802, { "N",10, 0,116} )     // CONSUMO INTERNO ( CV )
aAdd(aLayCP802, { "N",10, 0,126} )     // ACESSÓRIOS ( VL )
aAdd(aLayCP802, { "N",10, 0,136} )     // ACESSÓRIOS ( CV )
aAdd(aLayCP802, { "N",10, 0,146} )     // TOTAL DE PEÇAS E ACESSÓRIOS ( VL )
aAdd(aLayCP802, { "N",10, 0,156} )     // TOTAL DE PEÇAS E ACESSÓRIOS ( CV )
aAdd(aLayCP802, { "N",10, 0,166} )     // OUTRAS VENDAS ( VL )
aAdd(aLayCP802, { "N",10, 0,176} )     // OUTRAS VENDAS ( CV )
aAdd(aLayCP802, { "C", 2, 0,186} )     // BRANCOS
aAdd(aLayCP802, { "N", 6, 0,188} )     // VERSÃO DO LAYOUT (Fixo: 090902)
							 	 	 
// CP803 - PERFORMANCE DE PEÇAS E ACESSÓRIOS - P.P.A.						 	 	 
						 	 	 
aAdd(aLayCP803, { "C", 3, 0,  1} )     // CODIGO DO REGISTRO (CP8)
aAdd(aLayCP803, { "N", 2, 0,  4} )     // SUBCÓDIGO DO REGISTRO (FIXO = 03)
aAdd(aLayCP803, { "N",10, 0,  6} )     // TOTAL GERAL ( VL )
aAdd(aLayCP803, { "N",10, 0, 16} )     // TOTAL GERAL ( CV )
aAdd(aLayCP803, { "N",10, 0, 26} )     // VENDAS PENDENTES ( VL )
aAdd(aLayCP803, { "N",10, 0, 36} )     // VENDAS PENDENTES ( CV )
aAdd(aLayCP803, { "N",10, 0, 46} )     // REDE (Outros Concessionários)
aAdd(aLayCP803, { "N",10, 0, 56} )     // LOJAS DE PEÇAS
aAdd(aLayCP803, { "N",10, 0, 66} )     // FABRICANTES
aAdd(aLayCP803, { "N",10, 0, 76} )     // TOTAL REDE E TERCEIROS
aAdd(aLayCP803, { "N",10, 0, 86} )     // OUTRAS COMPRAS
aAdd(aLayCP803, { "N",10, 0, 96} )     // COMPRAS ESPECÍFICAS
aAdd(aLayCP803, { "N",10, 0,106} )     // GERENTES
aAdd(aLayCP803, { "N",10, 0,116} )     // ADMINISTRATIVOS E OUTROS
aAdd(aLayCP803, { "N",10, 0,126} )     // BALCONISTAS DE VAREJO ( PÚBLICO )
aAdd(aLayCP803, { "N",10, 0,136} )     // BALCONISTAS DE OFICINA ( INTERNOS )
aAdd(aLayCP803, { "N",10, 0,146} )     // VENDEDORES ATACADO ( EXTERNOS )
aAdd(aLayCP803, { "N",10, 0,156} )     // VENDEDORES ACESSÓRIOS
aAdd(aLayCP803, { "N",10, 0,166} )     // TOTAL GERAL (QUADRO DE PESSOAL)
aAdd(aLayCP803, { "C",12, 0,176} )     // BRANCOS
aAdd(aLayCP803, { "N", 6, 0,188} )     // VERSÃO DO LAYOUT ( Fixo : 090902 )
 

// CP804 - PERFORMANCE DE PEÇAS E ACESSÓRIOS - P.P.A.						 	 	 

aAdd(aLayCP804, { "C", 3, 0,  1} )     // CODIGO DO REGISTRO (CP8)
aAdd(aLayCP804, { "N", 2, 0,  4} )     // SUBCÓDIGO DO REGISTRO (FIXO = 04)
aAdd(aLayCP804, { "N",10, 0,  6} )     // VEICULOS VENDIDOS
aAdd(aLayCP804, { "C",10, 0, 16} )     // BRANCOS
aAdd(aLayCP804, { "N", 4, 0, 26} )     // RESERVADO
aAdd(aLayCP804, { "N",10, 0, 30} )     // ESTOQUE: PEÇAS E ACESSORIOS
aAdd(aLayCP804, { "N",10, 0, 40} )     // ESTOQUE: OUTROS
aAdd(aLayCP804, { "N",10, 0, 50} )     // TRANSFERÊNCIAS POR ENTRADAS: PEÇAS E ACESSÓRIOS
aAdd(aLayCP804, { "N",10, 0, 60} )     // TRANSFERÊNCIAS POR ENTRADAS: OUTROS
aAdd(aLayCP804, { "N",10, 0, 70} )     // TRANSFERÊNCIAS POR SAÍDAS: PEÇAS E ACESSÓRIOS
aAdd(aLayCP804, { "N",10, 0, 80} )     // TRANSFERÊNCIAS POR SAÍDAS: OUTROS
aAdd(aLayCP804, { "N", 7, 0, 90} )     // QUANTIDADE DE ÍTENS ORIGINAIS NO ESTOQUE:
aAdd(aLayCP804, { "N", 8, 0, 97} )     // DATA (ddmmaaaa)
aAdd(aLayCP804, { "C",15, 0,105} )     // NOME DO RESPONSÁVEL
aAdd(aLayCP804, { "C",68, 0,120} )     // BRANCOS
aAdd(aLayCP804, { "N", 6, 0,188} )     // VERSÃO DO LAYOUT ( Fixo : 090902 )
						 	 	 


// Monta CP800
aValCP800 := {}         
cMes := month(MV_PAR02)
cAno := year(MV_PAR02)
cMesAno := Alltrim(str(cMes))+Alltrim(Str(cAno))
aAdd(aValCP800,{"CP8",0,Alltrim(strzero(MV_PAR12,4)),Val(cMesAno),"",5,"",90902} )
cLinCP800 := MontaEDI(aLayCP800,aValCP800[1])
fwrite(nHnd,cLinCP800)
nLinhArq := 1 

// Monta CP801

cNumBPCL := 0 
cNumBPCV := 0
cNumAceL := 0
cNumAceV := 0
nSomAceCL := 0
nSomAceCV := 0 
nLubCL := 0
nLubCV := 0 
cQuery := "SELECT * "
cQuery += "FROM "+RetSqlName( "VEC" ) + " VEC "
cQuery += "WHERE "
cQuery += "VEC.VEC_FILIAL='"+ xFilial("VEC")+ "' AND "
If !Empty(MV_PAR01)
	cQuery += " VEC.VEC_DATVEN >= '"+Dtos(MV_PAR01)+"' AND "
EndIf
If !Empty(MV_PAR02)
	cQuery += " VEC.VEC_DATVEN <= '"+Dtos(MV_PAR02)+"' AND "
EndIf
cQuery += "VEC.D_E_L_E_T_=' ' ORDER BY VEC.VEC_DATVEN, VEC.VEC_GRUITE, VEC.VEC_CODITE"

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVEC, .T., .T. )

//IncRegua()

While !(cAliasVEC)->(Eof())
//	If (nCont==350 .or. nCont==700 .or. nCont==1100 .or. nCont==1600 .or. nCont==2500)
//		IncRegua()
//	EndIf
//	nCont ++
	If Select(cAliasSBM) > 0
		( cAliasSBM )->( DbCloseArea() )
	EndIf
	cQuery := "SELECT SBM.BM_CODMAR, SBM.BM_TIPGRU, SBM.BM_DESC, SBM.BM_PROORI "
	cQuery += "FROM "+RetSqlName( "SBM" ) + " SBM "
	cQuery += "WHERE "
	cQuery += "SBM.BM_FILIAL='"+ xFilial("SBM")+ "' AND SBM.BM_GRUPO='"+(cAliasVEC)->VEC_GRUITE+"' AND "
	cQuery += "SBM.D_E_L_E_T_=' ' ORDER BY SBM.BM_GRUPO"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSBM, .T., .T. )
	
	If Select(cAliasVE4) > 0
		( cAliasVE4 )->( DbCloseArea() )
	EndIf
	cQuery := "SELECT VE4.VE4_CDOPSA, VE4.VE4_CODFOR, VE4.VE4_LOJFOR, VE4.VE4_CDOPEN "
	cQuery += "FROM "+RetSqlName( "VE4" ) + " VE4 "
	cQuery += "WHERE "
	cQuery += "VE4.VE4_FILIAL='"+ xFilial("VE4")+ "' AND VE4.VE4_PREFAB='"+(cAliasSBM)->BM_CODMAR+"' AND "
	cQuery += "VE4.D_E_L_E_T_=' ' ORDER BY VE4.VE4_PREFAB"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVE4, .T., .T. )
	
	If Select(cAliasSB1) > 0
		( cAliasSB1 )->( DbCloseArea() )
	EndIf
	cQuery := "SELECT SB1.B1_GRUPO, SB1.B1_COD, SB1.B1_ORIGEM, SB1.B1_LOCPAD "
	cQuery += "FROM "+RetSqlName( "SB1" ) + " SB1 "
	cQuery += "WHERE "
	cQuery += "SB1.B1_FILIAL='"+ xFilial("SB1")+ "' AND SB1.B1_GRUPO='"+(cAliasVEC)->VEC_GRUITE+"' AND SB1.B1_CODITE='"+(cAliasVEC)->VEC_CODITE+"' AND "
	cQuery += "SB1.D_E_L_E_T_=' ' ORDER BY SB1.B1_GRUPO, SB1.B1_CODITE"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSB1, .T., .T. )
	
	If Select(cAliasSF2) > 0
		( cAliasSF2 )->( DbCloseArea() )
	EndIf
	cQuery := "SELECT SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_CLIENTE, SF2.F2_LOJA, SF2.F2_PREFIXO "
	cQuery += "FROM "+RetSqlName( "SF2" ) + " SF2 "
	cQuery += "WHERE "
	cQuery += "SF2.F2_FILIAL='"+ xFilial("SF2")+ "' AND SF2.F2_DOC='"+(cAliasVEC)->VEC_NUMNFI+"' AND SF2.F2_SERIE='"+(cAliasVEC)->VEC_SERNFI+"' AND "
	cQuery += "SF2.D_E_L_E_T_=' ' ORDER BY SF2.F2_DOC, SF2.F2_SERIE"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSF2, .T., .T. )
	
	If Select(cAliasSD2) > 0
		( cAliasSD2 )->( DbCloseArea() )
	EndIf
	cQuery := "SELECT SD2.D2_TES, SD2.D2_EMISSAO, SD2.D2_GRUPO, SD2.D2_COD, SD2.D2_CF, SD2.D2_TOTAL "
	cQuery += "FROM "+RetSqlName( "SD2" ) + " SD2 "
	cQuery += "WHERE "
	cQuery += "SD2.D2_FILIAL='"+ xFilial("SD2")+ "' AND SD2.D2_DOC='"+(cAliasSF2)->F2_DOC+"' AND SD2.D2_SERIE='"+(cAliasSF2)->F2_SERIE+"' AND SD2.D2_CLIENTE='"+(cAliasSF2)->F2_CLIENTE+"' AND SD2.D2_LOJA='"+(cAliasSF2)->F2_LOJA+"' AND SD2.D2_COD='"+(cAliasSB1)->B1_COD+"' AND "
	cQuery += "SD2.D_E_L_E_T_=' ' ORDER BY SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_COD"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSD2, .T., .T. )
	
	If Select(cAliasSF4) > 0
		( cAliasSF4 )->( DbCloseArea() )
	EndIf
	cQuery := "SELECT SF4.F4_DUPLIC, SF4.F4_ESTOQUE, SF4.F4_OPEMOV, SF4.F4_PISCRED, SF4.F4_PISCOF "
	cQuery += "FROM "+RetSqlName( "SF4" ) + " SF4 "
	cQuery += "WHERE "
	cQuery += "SF4.F4_FILIAL='"+ xFilial("SF4")+ "' AND SF4.F4_CODIGO='"+(cAliasSD2)->D2_TES+"' AND "
	cQuery += "SF4.D_E_L_E_T_=' ' ORDER BY SF4.F4_CODIGO"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSF4, .T., .T. )
	
	
	if (cAliasVEC)->VEC_TIPTEM # "I"
		If (cAliasSF4)->F4_DUPLIC # "S" .or. (cAliasSF4)->F4_ESTOQUE # "S"
			DbSelectArea(cAliasVEC)
			Dbskip()
			loop
		EndIf
	Endif
	If ( (!Empty(MV_PAR01) .and. (Stod((cAliasVEC)->VEC_DATVEN) < MV_PAR01)) .Or. (  (cAliasVE4)->(Found()) .And. (cAliasSD2)->D2_TES == FG_TABTRIB((cAliasVE4)->VE4_CDOPSA,(cAliasSB1)->B1_ORIGEM) ) )
		DbSelectArea(cAliasVEC)
		Dbskip()
		loop
	EndIf
	
	If Select(cAliasSA1) > 0
		( cAliasSA1 )->( DbCloseArea() )
	EndIf
	cQuery := "SELECT SA1.A1_NOME, SA1.A1_CGC, SA1.A1_SATIV1 "
	cQuery += "FROM "+RetSqlName( "SA1" ) + " SA1 "
	cQuery += "WHERE "
	cQuery += "SA1.A1_FILIAL='"+ xFilial("SA1")+ "' AND SA1.A1_COD='"+(cAliasSF2)->F2_CLIENTE+"' AND SA1.A1_LOJA='"+(cAliasSF2)->F2_LOJA+"' AND "
	cQuery += "SA1.D_E_L_E_T_=' ' ORDER BY SA1.A1_COD, SA1.A1_LOJA"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSA1, .T., .T. )
	
	nPvalvda := (cAliasVEC)->VEC_VALVDA 
	nPvalicm := (cAliasVEC)->VEC_VALICM 
	nPvalpis := (cAliasVEC)->VEC_VALPIS 
	nPvalcof := (cAliasVEC)->VEC_VALCOF 
	nPvalvda := ( nPvalvda - ( nPvalicm + nPvalpis + nPvalcof ) )
	nPcustot := (cAliasVEC)->VEC_CUSTOT 
	
	///////////////////////
	//    ACESSORIOS     //
	///////////////////////
	
	If Alltrim((cAliasSBM)->BM_TIPGRU) $ "8|9" // ACESSORIOS ORIGINAIS E NAO ORIGINAIS
		
		nPos :=0
		nPos  := aScan(aNumAce,{|x| x[1] == (cAliasVEC)->VEC_GRUITE })
		If nPos == 0
			aAdd(aNumAce,{ (cAliasVEC)->VEC_GRUITE , (cAliasSBM)->BM_DESC , nPvalvda , nPcustot })
			cNumAceL += nPvalvda
			cNumAceV += nPcustot
		Else
			aNumAce[nPos,3] += nPvalvda
			aNumAce[nPos,4] += nPcustot  
			cNumAceL += aNumAce[nPos,3]
			cNumAceV += aNumAce[nPos,4]
		EndIf
			///////////////////////
		//   OUTRAS VENDAS   //
		///////////////////////
		
	ElseIf alltrim((cAliasSBM)->BM_TIPGRU) $ "2|3|A"    //LUB/PNEU/MOTOR/
		nPos :=0
		nPos  := aScan(aNumLub,{|x| x[1] == (cAliasVEC)->VEC_GRUITE })
		If nPos == 0
			aAdd(aNumLub,{ (cAliasVEC)->VEC_GRUITE , (cAliasSBM)->BM_DESC , nPvalvda , nPvalvda })
			if (cAliasVEC)->VEC_BALOFI == "O"
				nLubCL += nPvalvda    
				nLubCV += nPvalvda    
			Endif	
		Else
			aNumLub[nPos,3] += nPvalvda
			aNumLub[nPos,4] += nPcustot
			if (cAliasVEC)->VEC_BALOFI == "O"
				nLubCL += nPvalvda
				nLubCV += nPcustot
			Endif	
		EndIf
	Endif
	///////////////////////
	//  ATACADO/EXTERNA  //
	///////////////////////
		
	If (cAliasVEC)->VEC_BALOFI == "B"
			
		cSomou := "N"
		
		If (Len(Alltrim((cAliasSA1)->A1_CGC)) == 14) //  -->   Juridica
				
			nPos := 0
			nPos := aScan(aChave01,{|x| x[1] == (cAliasSA1)->A1_SATIV1 }) //Governo
			If nPos > 0
				cSomou := "S"
				aGrpPec[1,4] += nPvalvda
				aGrpPec[1,5] += nPcustot
            Endif
			nPos := 0
			nPos := aScan(aChave02,{|x| x[1] == (cAliasSA1)->A1_SATIV1 }) //Frotistas
			If nPos > 0
				cSomou := "S"
				aGrpPec[2,4] += nPvalvda
				aGrpPec[2,5] += nPcustot
			EndIf
				
			nPos := 0
			nPos := aScan(aChave03,{|x| x[1] == (cAliasSA1)->A1_SATIV1 }) //Seguradoras
			If nPos > 0
				cSomou := "S"
				aGrpPec[3,4] += nPvalvda
				aGrpPec[3,5] += nPcustot
			EndIf
				
			
			nPos := 0
			nPos := aScan(aChave04,{|x| x[1] == (cAliasSA1)->A1_SATIV1 }) // Lojas de Pecas
			If nPos > 0
				cSomou := "S"
				aGrpPec[4,4] += nPvalvda
				aGrpPec[4,5] += nPcustot
			EndIf
			
			nPos := 0
			nPos := aScan(aChave05,{|x| x[1] == (cAliasSA1)->A1_SATIV1 }) // Oficinas Independentes
			If nPos > 0
				cSomou := "S"
				aGrpPec[5,4] += nPvalvda
				aGrpPec[5,5] += nPcustot
			EndIf
			
			nPos := 0
			nPos := aScan(aChave06,{|x| x[1] == (cAliasSA1)->A1_SATIV1 }) //Rede (Outros Distr./Concess.)
			If nPos > 0
				cSomou := "S"
				aGrpPec[6,4] += nPvalvda
				aGrpPec[6,5] += nPcustot
			Endif
		Endif	
		If cSomou == "N"
				
			nPos  := aScan(aNumBPc,{|x| x[1] == (cAliasVEC)->VEC_GRUITE })
			If nPos == 0
				aAdd(aNumBPc,{ (cAliasVEC)->VEC_GRUITE , (cAliasSBM)->BM_DESC , nPvalvda , nPcustot })
			Else
				aNumBPc[nPos,3] += nPvalvda
				aNumBPc[nPos,4] += nPcustot
				cNumBPCL += aNumBPc[nPos,3]
				cNumBPCV += aNumBPc[nPos,4]
			EndIf    
		Endif	   

		nPos  := aScan(aValCP801,{|x| x[1]+Alltrim(str(x[2])) == "CP8"+Alltrim(str(1)) })
        if nPos == 0 
			aAdd(aValCP801,{"CP8",1,aGrpPec[1,4],aGrpPec[1,5],aGrpPec[2,4],aGrpPec[2,5],aGrpPec[3,4],aGrpPec[3,5],aGrpPec[4,4],aGrpPec[4,5],aGrpPec[5,4],aGrpPec[5,5],aGrpPec[6,4],aGrpPec[6,5],cNumBPCL,cNumBPCV,"",90902})
	    Else
	       aValCP801[nPos,3] += aGrpPec[1,4]
	       aValCP801[nPos,4] += aGrpPec[1,5]
	       aValCP801[nPos,5] += aGrpPec[2,4]
	       aValCP801[nPos,6] += aGrpPec[2,5]
	       aValCP801[nPos,7] += aGrpPec[3,4]
	       aValCP801[nPos,8] += aGrpPec[3,5]
	       aValCP801[nPos,9] += aGrpPec[4,4]
	       aValCP801[nPos,10] += aGrpPec[4,5]
	       aValCP801[nPos,11] += aGrpPec[5,4]
	       aValCP801[nPos,12] += aGrpPec[5,5]
	       aValCP801[nPos,13] += aGrpPec[6,4]
	       aValCP801[nPos,14] += aGrpPec[6,5]
	       aValCP801[nPos,15] += cNumBPCL
	       aValCP801[nPos,16] += cNumBPCV
	    Endif
	///////////////////////
	//  OFICINA/INTERNA  //
	///////////////////////
		
	Else //If (cAliasVEC)->VEC_BALOFI == "O"
			
		DbSelectArea("VOI")
		DbSetOrder(1)
		DbSeek(xFilial("VOI")+(cAliasVEC)->VEC_TIPTEM)
			
		If VOI->VOI_SITTPO $ "2/4"
			aGrpPec[11,4] += nPvalvda
			aGrpPec[11,5] += nPcustot
		ElseIf VOI->VOI_SITTPO == "3"
			aGrpPec[12,4] += nPvalvda // nPvalvda
			aGrpPec[12,5] += nPcustot
		Else
			cDCli := "S"
			nPos := 0
			nPos := aScan(aChave01,{|x| x[1] == (cAliasSA1)->A1_SATIV1 }) //Governo
			If nPos > 0
				cDCli := "N"
				aGrpPec[7,4] += nPvalvda
				aGrpPec[7,5] += nPcustot
			Endif
			nPos := 0
			nPos := aScan(aChave02,{|x| x[1] == (cAliasSA1)->A1_SATIV1 }) //Frotistas
			If nPos > 0
				cDCli := "N"
				aGrpPec[8,4] += nPvalvda
				aGrpPec[8,5] += nPcustot
			EndIf
			nPos := 0
			nPos := aScan(aChave03,{|x| x[1] == (cAliasSA1)->A1_SATIV1 }) //Seguradoras
			If nPos > 0
				cDCli := "N"
				aGrpPec[9,4] += nPvalvda
				aGrpPec[9,5] += nPcustot
			EndIf
				
			If cDCli == "S"
				aGrpPec[10,4] += nPvalvda
				aGrpPec[10,5] += nPcustot
			EndIf
			
		EndIf

		nSomAceCL := aGrpPec[1,4]+aGrpPec[2,4]+aGrpPec[3,4]+aGrpPec[4,4]+aGrpPec[5,4]+aGrpPec[6,4]+cNumBPCL+aGrpPec[7,4]+aGrpPec[8,4]+aGrpPec[9,4]+aGrpPec[10,4]+aGrpPec[11,4]+aGrpPec[12,4]+cNumAceL

		nSomAceCV := aGrpPec[1,5]+aGrpPec[2,5]+aGrpPec[3,5]+aGrpPec[4,5]+aGrpPec[5,5]+aGrpPec[6,5]+cNumBPCV+aGrpPec[7,5]+aGrpPec[8,5]+aGrpPec[9,5]+aGrpPec[10,5]+aGrpPec[11,5]+aGrpPec[12,5]+cNumAceV


		nPos  := aScan(aValCP802,{|x| x[1]+Alltrim(str(x[2])) == "CP8"+Alltrim(str(2)) })
        if nPos == 0 
			aAdd(aValCP802,{"CP8",2,aGrpPec[7,4],aGrpPec[7,5],aGrpPec[8,4],aGrpPec[8,5],aGrpPec[9,4],aGrpPec[9,5],aGrpPec[10,4],aGrpPec[10,5],aGrpPec[11,4],aGrpPec[11,5],aGrpPec[12,4],aGrpPec[12,5],cNumAceL,cNumAceV,nSomAceCL,nSomAceCV,nLubCL,nLubCV,"",90902})		
		Else
			aValCP802[nPos,3] := aGrpPec[7,4]
			aValCP802[nPos,4] := aGrpPec[7,5]
			aValCP802[nPos,5] := aGrpPec[8,4]
			aValCP802[nPos,6] := aGrpPec[8,5]
			aValCP802[nPos,7] := aGrpPec[9,4]
			aValCP802[nPos,8] := aGrpPec[9,5]
			aValCP802[nPos,9] := aGrpPec[10,4]
			aValCP802[nPos,10] := aGrpPec[10,5]
			aValCP802[nPos,11] := aGrpPec[11,4]
			aValCP802[nPos,12] := aGrpPec[11,5]
			aValCP802[nPos,13] := aGrpPec[12,4]
			aValCP802[nPos,14] := aGrpPec[12,5]
			aValCP802[nPos,15] := cNumAceL
			aValCP802[nPos,16] := cNumAceV
			aValCP802[nPos,17] := nSomAceCL
			aValCP802[nPos,18] := nSomAceCV
			aValCP802[nPos,19] := nLubCL
			aValCP802[nPos,20] := nLubCV
		Endif	
	EndIf


	DbSelectArea(cAliasVEC)
	Dbskip()
	
EndDo

// VENDAS PENDENTES

cQuery := "SELECT VO3.VO3_DATFEC, VO3.VO3_DATCAN, VO3.VO3_NOSNUM, VO3.VO3_GRUITE, VO3.VO3_CODITE, VO3.VO3_VALPEC, VO3.VO3_QTDREQ, VO3.VO3_FATPAR, VO3.VO3_LOJA, VO3.VO3_NUMNFI, VO3.VO3_SERNFI "
cQuery += "FROM "+RetSqlName( "VO3" ) + " VO3 "
cQuery += "INNER JOIN "+RetSQLName("SBM")+" SBM ON  SBM.BM_FILIAL  = '"+xFilial("SBM")+"' AND SBM.BM_GRUPO = VO3.VO3_GRUITE AND SBM.BM_CODMAR = '"+MV_PAR03+"' AND  SBM.D_E_L_E_T_=' ' "
cQuery += "WHERE "
cQuery += "VO3.VO3_FILIAL='"+ xFilial("VO3")+ "' AND "
cQuery += "VO3.VO3_DATFEC='        ' AND "
cQuery += "VO3.VO3_DATCAN='        ' AND "
cQuery += "VO3.D_E_L_E_T_=' ' ORDER BY VO3.VO3_DATFEC, VO3.VO3_TIPTEM"
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVO3, .T., .T. )
nIcm := 0
While !(cAliasVO3)->(Eof())
	nCof := GetMV("MV_TXCOFIN")
	nPis := GetMV("MV_TXPIS")
	cIcm := GetMV("MV_ESTICM")
	cIcm := Alltrim(cIcm)
	aSM0 := FWArrFilAtu(cEmpAnt,cFilAnt) // Filial Origem (Filial logada)
	cBkpFil := SM0->(Recno())     
	dbSelectArea("SM0")
	dbSetOrder(1)
	dbSeek(aSM0[1]+aSM0[2])
	For ni:= 1 to len(cIcm)
		If Substr(cIcm,ni,2) == SM0->M0_ESTENT
			nIcm := Val(Substr(cIcm,ni+2,2))
			ni := len(cIcm)
		EndIf
		ni := ni + 3
	Next
	SM0->(DbGoto(cBkpFil))
	If Select(cAliasVO2) > 0
		( cAliasVO2 )->( DbCloseArea() )
	EndIf
	cQuery := "SELECT VO2.VO2_DEVOLU, VO2.VO2_DATREQ "
	cQuery += "FROM "+RetSqlName( "VO2" ) + " VO2 "
	cQuery += "WHERE "
	cQuery += "VO2.VO2_FILIAL='"+ xFilial("VO2")+ "' AND "
	cQuery += "VO2.VO2_NOSNUM='"+(cAliasVO3)->VO3_NOSNUM+"' AND "
	cQuery += "VO2.D_E_L_E_T_=' ' ORDER BY VO2.VO2_NOSNUM"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVO2, .T., .T. )
	
	If (cAliasVO2)->VO2_DATREQ > DTOS(MV_PAR02)    // Despresa o registro se a data da requisicao for maior que a data final do parametro.
		DbSelectArea(cAliasVO3)
		Dbskip()
		loop
	EndIf
	
	If Select(cAliasSB1) > 0
		( cAliasSB1 )->( DbCloseArea() )
	EndIf
	cQuery := "SELECT SB1.B1_COD, SB1.B1_LOCPAD "
	cQuery += "FROM "+RetSqlName( "SB1" ) + " SB1 "
	cQuery += "WHERE "
	cQuery += "SB1.B1_FILIAL='"+ xFilial("SB1")+ "' AND "
	cQuery += "SB1.B1_GRUPO='"+(cAliasVO3)->VO3_GRUITE+"' AND SB1.B1_CODITE='"+(cAliasVO3)->VO3_CODITE+"' AND "
	cQuery += "SB1.D_E_L_E_T_=' ' ORDER BY SB1.B1_GRUPO, SB1.B1_CODITE"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSB1, .T., .T. )
	
	If Select(cAliasSB2) > 0
		( cAliasSB2 )->( DbCloseArea() )
	EndIf
	cQuery := "SELECT SB2.B2_COD, SB2.B2_CM1, SB2.B2_LOCAL "
	cQuery += "FROM "+RetSqlName( "SB2" ) + " SB2 "
	cQuery += "WHERE "
	cQuery += "SB2.B2_FILIAL='"+ xFilial("SB2")+ "' AND "
	cQuery += "SB2.B2_COD='"+(cAliasSB1)->B1_COD+"' AND SB2.B2_LOCAL='"+(cAliasSB1)->B1_LOCPAD+"' AND "
	cQuery += "SB2.D_E_L_E_T_=' ' ORDER BY SB2.B2_COD, SB2.B2_LOCAL"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSB2, .T., .T. )
	
	nPvalvda := ((cAliasVO3)->VO3_VALPEC - ((nPis + nCof + nIcm)/100) * (cAliasVO3)->VO3_VALPEC)
	nPvalvda := ( nPvalvda * (cAliasVO3)->VO3_QTDREQ )
	nPvalcus := (cAliasSB2)->B2_CM1
	nPvalvda := If((cAliasVO2)->VO2_DEVOLU == "0",((-1)*(nPvalvda)),nPvalvda)
	aTotPen[1,1] += nPvalvda       
	if aTotPen[1,2] == 0 
		aTotPen[1,2] += nPvalcus
	Endif	
	DbSelectArea(cAliasVO3)
	Dbskip()
EndDo
                                               
cQuery := "SELECT * "
cQuery += "FROM "+RetSqlName( "SD1" ) + " SD1 "
cQuery += "WHERE "
cQuery += "SD1.D1_FILIAL='"+ xFilial("SD1")+ "' AND "
cQuery += "SD1.D1_DTDIGIT>='"+DTOS(MV_PAR01)+"' AND SD1.D1_DTDIGIT<='"+DTOS(MV_PAR02)+"' AND "
cQuery += "SD1.D_E_L_E_T_=' ' ORDER BY SD1.D1_DTDIGIT, SD1.D1_NUMSEQ"
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSD1, .T., .T. )

nTotCom := 0 
nTotCpO := 0  
nTotCpE := 0 
nTotCpR := 0 
SetRegua( ( cAliasSD1 )->(RecCount()) )
Do While !( cAliasSD1 )->(Eof())
	IncRegua()
	If !((cAliasSD1)->D1_TIPO $ "N/C")
		DbSelectArea(cAliasSD1)
		DbSkip()
		Loop
	EndIf
	If (cAliasSD1)->D1_LOCAL # "01"
		DbSelectArea(cAliasSD1)
		DbSkip()
		Loop
	EndIf
	
	If Select(cAliasSF4) > 0
		( cAliasSF4 )->( DbCloseArea() )
	EndIf
	cQuery := "SELECT SF4.F4_DUPLIC, SF4.F4_ESTOQUE, SF4.F4_OPEMOV, SF4.F4_PISCRED, SF4.F4_PISCOF "
	cQuery += "FROM "+RetSqlName( "SF4" ) + " SF4 "
	cQuery += "WHERE "
	cQuery += "SF4.F4_FILIAL='"+ xFilial("SF4")+ "' AND "
	cQuery += "SF4.F4_CODIGO='"+(cAliasSD1)->D1_TES+"' AND "
	cQuery += "SF4.D_E_L_E_T_=' ' ORDER BY SF4.F4_CODIGO"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSF4, .T., .T. )
	
	If (cAliasSF4)->F4_ESTOQUE # "S" .or. !((cAliasSF4)->F4_OPEMOV $ "01/08")
		DbSelectArea(cAliasSD1)
		DbSkip()
		Loop
	EndIf
	
	If Select(cAliasSBM) > 0
		( cAliasSBM )->( DbCloseArea() )
	EndIf
	cQuery := "SELECT SBM.BM_CODMAR, SBM.BM_TIPGRU, SBM.BM_DESC, SBM.BM_PROORI "
	cQuery += "FROM "+RetSqlName( "SBM" ) + " SBM "
	cQuery += "WHERE "
	cQuery += "SBM.BM_FILIAL='"+ xFilial("SBM")+ "' AND SBM.BM_GRUPO='"+(cAliasSD1)->D1_GRUPO+"' AND "
	cQuery += "SBM.D_E_L_E_T_=' ' ORDER BY SBM.BM_GRUPO"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSBM, .T., .T. )
	
	If Select(cAliasSB1) > 0
		( cAliasSB1 )->( DbCloseArea() )
	EndIf
	cQuery := "SELECT SB1.B1_GRUPO, SB1.B1_COD, SB1.B1_ORIGEM, SB1.B1_LOCPAD "
	cQuery += "FROM "+RetSqlName( "SB1" ) + " SB1 "
	cQuery += "WHERE "
	cQuery += "SB1.B1_FILIAL='"+ xFilial("SB1")+ "' AND SB1.B1_COD='"+(cAliasSD1)->D1_COD+"' AND "
	cQuery += "SB1.D_E_L_E_T_=' ' ORDER BY SB1.B1_COD"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSB1, .T., .T. )
	
	If Select(cAliasSA2) > 0
		( cAliasSA2 )->( DbCloseArea() )
	EndIf
	cQuery := "SELECT SA2.A2_NOME, SA2.A2_SATIV1 "
	cQuery += "FROM "+RetSqlName( "SA2" ) + " SA2 "
	cQuery += "WHERE "
	cQuery += "SA2.A2_FILIAL='"+ xFilial("SA2")+ "' AND SA2.A2_COD='"+(cAliasSD1)->D1_FORNECE+"' AND SA2.A2_LOJA='"+(cAliasSD1)->D1_LOJA+"' AND "
	cQuery += "SA2.D_E_L_E_T_=' ' ORDER BY SA2.A2_COD, SA2.A2_LOJA"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSA2, .T., .T. )
	
	///////////////////////
	//  OUTRAS  COMPRAS  //
	///////////////////////
	
	If str(val((cAliasSBM)->BM_TIPGRU),2) $ " 2| 3| 9|10"
		nPos := 0
		nPos  := aScan(aNumCpO,{|x| x[1] == (cAliasSD1)->D1_GRUPO })
		If nPos == 0
			aAdd(aNumCpO,{ (cAliasSD1)->D1_GRUPO , (cAliasSBM)->BM_DESC , (cAliasSD1)->D1_CUSTO})
		Else
			aNumCpO[nPos,3] += (cAliasSD1)->D1_CUSTO
		EndIf
		
		nTotCom += (cAliasSD1)->D1_CUSTO
		nTotCpO += (cAliasSD1)->D1_CUSTO
		
	Else
		
		///////////////////////
		// REDE & ACESSORIOS //
		///////////////////////
		
		If Select(cAliasVE4) > 0
			( cAliasVE4 )->( DbCloseArea() )
		EndIf
		cQuery := "SELECT VE4.VE4_CDOPSA, VE4.VE4_CODFOR, VE4.VE4_LOJFOR, VE4.VE4_CDOPEN "
		cQuery += "FROM "+RetSqlName( "VE4" ) + " VE4 "
		cQuery += "WHERE "
		cQuery += "VE4.VE4_FILIAL='"+ xFilial("VE4")+ "' AND VE4.VE4_PREFAB='"+(cAliasSBM)->BM_CODMAR+"' AND "
		cQuery += "VE4.D_E_L_E_T_=' ' ORDER BY VE4.VE4_PREFAB"
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVE4, .T., .T. )
		
		cDCli := "S"
		If Alltrim((cAliasSBM)->BM_TIPGRU) # "8" .Or. (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_LOJA == (cAliasVE4)->VE4_CODFOR + (cAliasVE4)->VE4_LOJFOR
			nPos := 0
			nPos := aScan(aChave06,{|x| x[1] == (cAliasSA2)->A2_SATIV1 }) //Rede (Outros Distrib/Concessionarios)
			If nPos > 0
				cDCli := "N"
				nTotCom += (cAliasSD1)->D1_CUSTO
				nTotCpR += (cAliasSD1)->D1_CUSTO
				aGrpCpR[1,3] += (cAliasSD1)->D1_CUSTO
				nPos  := aScan(aNumCpR,{|x| x[1] + x[2] == "1" + (cAliasSD1)->D1_GRUPO })
				If nPos == 0
					aAdd(aNumCpR,{ "1" , (cAliasSD1)->D1_GRUPO , (cAliasSBM)->BM_DESC , (cAliasSD1)->D1_CUSTO })
				Else
					aNumCpR[nPos,4] += (cAliasSD1)->D1_CUSTO
				EndIf
			EndIf
			nPos := 0
			nPos := aScan(aChave04,{|x| x[1] == (cAliasSA2)->A2_SATIV1 }) //Lojas de Pecas
			If nPos > 0
				cDCli := "N"
				nTotCom += (cAliasSD1)->D1_CUSTO
				nTotCpR += (cAliasSD1)->D1_CUSTO
				aGrpCpR[2,3] += (cAliasSD1)->D1_CUSTO
				nPos := aScan(aNumCpR,{|x| x[1] + x[2] == "2" + (cAliasSD1)->D1_GRUPO })
				If nPos == 0
					aAdd(aNumCpR,{ "2" , (cAliasSD1)->D1_GRUPO , (cAliasSBM)->BM_DESC , (cAliasSD1)->D1_CUSTO })
				Else
					aNumCpR[nPos,4] += (cAliasSD1)->D1_CUSTO
				EndIf
			EndIf
			nPos := 0
			nPos := aScan(aChave07,{|x| x[1] == (cAliasSA2)->A2_SATIV1 }) //Fabricantes
			If nPos > 0
				cDCli := "N"
				nTotCom += (cAliasSD1)->D1_CUSTO
				nTotCpR += (cAliasSD1)->D1_CUSTO
				aGrpCpR[3,3] += (cAliasSD1)->D1_CUSTO
				nPos := aScan(aNumCpR,{|x| x[1] + x[2] == "3" + (cAliasSD1)->D1_GRUPO })
				If nPos == 0
					aAdd(aNumCpR,{ "3" , (cAliasSD1)->D1_GRUPO , (cAliasSBM)->BM_DESC , (cAliasSD1)->D1_CUSTO })
				Else
					aNumCpR[nPos,4] += (cAliasSD1)->D1_CUSTO
				EndIf
			EndIf
		EndIf
		
		///////////////////////
		//COMPRAS ESPECIFICAS//
		///////////////////////
		
		If cDCli == "S" .and. (cAliasSD1)->D1_GRUPO # "VEI "
			nTotCom += (cAliasSD1)->D1_CUSTO
			nTotCpE += (cAliasSD1)->D1_CUSTO
			nPos := 0
			nPos := aScan(aNumCpE,{|x| x[1] == (cAliasSD1)->D1_GRUPO })
			If nPos == 0
				aAdd(aNumCpE,{ (cAliasSD1)->D1_GRUPO , (cAliasSBM)->BM_DESC , (cAliasSD1)->D1_CUSTO })
			Else
				aNumCpE[nPos,3] += (cAliasSD1)->D1_CUSTO
			EndIf
		EndIf
		
	EndIf
	DbSelectArea(cAliasSD1)
	Dbskip()

EndDo
nGerente := 0 
Pergunte("OX12A")


DbSelectArea( "SX1" )
DbSetOrder(1)
If DbSeek( "OX12A", .t. )
	While Alltrim(X1_GRUPO) == "OX12A" .and. !eof()
		if alltrim(X1_PERGUNTE)  == alltrim(STR0018)
		   nGerente := X1_CNT01
		Elseif alltrim(X1_PERGUNTE)  == alltrim(STR0019)
		   nADM := X1_CNT01
		Elseif alltrim(X1_PERGUNTE)  == alltrim(STR0020)
		   nBalco := X1_CNT01
		Elseif alltrim(X1_PERGUNTE)  == alltrim(STR0021) 
		   nBalcOFI := X1_CNT01
		Elseif alltrim(X1_PERGUNTE)  == alltrim(STR0022)
		   nVendAta := X1_CNT01
		Elseif alltrim(X1_PERGUNTE)  == alltrim(STR0023)
		   nVendAce := X1_CNT01
		Endif
		DbSkip()
	EndDo
EndIf
                                                                                           
nTotTer := aGrpCpR[1,3]+aGrpCpR[2,3]+aGrpCpR[3,3]
nTotFun := val(nGerente)+val(nADM)+val(nBalco)+val(nBalcOFI)+val(nVendAta)+val(nVendAce)
aAdd(aValCP803,{"CP8",3,nSomAceCL+nLubCL,nSomAceCV+nLubCV,aTotPen[1,1],aTotPen[1,2],aGrpCpR[1,3],aGrpCpR[2,3],aGrpCpR[3,3],nTotTer,nTotCpO,nTotCpE,nGerente,nADM,nBalco,nBalcOFI,nVendAta,nVendAce,nTotFun,"",90902})		

For i := 1 to Len(aValCP801)

	cLinCP801 := MontaEDI(aLayCP801,aValCP801[i])
	nLinhArq += 1
	fwrite(nHnd,cLinCP801)

Next

For i := 1 to Len(aValCP802)

	cLinCP802 := MontaEDI(aLayCP802,aValCP802[i])
	nLinhArq += 1
	fwrite(nHnd,cLinCP802)

Next

For i := 1 to Len(aValCP803)

	cLinCP803 := MontaEDI(aLayCP803,aValCP803[i])
	nLinhArq += 1
	fwrite(nHnd,cLinCP803)

Next


// Monta CPF
aValCPF := {}
aAdd(aValCPF,{"CPF",1, 0,nLinhArq+2," " } )
cLinhaCPF := MontaEDI(aLayCPF,aValCPF[1])
fwrite(nHnd,cLinhaCPF)


// Monta CHF
aValCHF := {}
aAdd(aValCHF,{"CHF",1, 0,nLinhArq+2," " } )
cLinhaCHF := MontaEDI(aLayCHF,aValCHF[1])
fwrite(nHnd,cLinhaCHF)
//

fClose(nHnd)

MsgInfo(STR0024,STR0003)


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

Static Function ImprimeRel()

Local nCntFor

Local cDesc1  := STR0029 
Local cDesc2  := STR0030 
Local cDesc3  := ""

Private cString  := "VV1" // TODO
Private Tamanho  := "M"
Private aReturn  := { "Zebrado",2,"Administração",2,2,1,"",1 }
Private wnrel    := "AUTOPARTVW" // TODO
Private NomeProg := "AUTOPARTVW" // TODO
Private nLastKey := 0
Private Limite   := 132
Private Titulo   := cTitulo+" ("+cArquivo+")"+" - " + dtoc(ddatabase)
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
for nCntFor = 1 to Len(aLinhasRel)
	
	If Li > 55
		li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		li++
	Endif
	//
	@ Li++, 1   PSay aLinhasRel[nCntFor]
	//+-------------------------------------------------------------------------------
	//| Se teclar ESC, sair
	//+-------------------------------------------------------------------------------
	If nLastKey == 27
		@ Li++ , 1 psay "... ABORTADO PELO OPERADOR."
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
##|Função    | CriaSX1    | Autor |  Luis Delorme         | Data | 30/05/11 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Criacao das perguntas.                                       |##
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


aAdd(aSX1,{cPerg,"01",STR0026,"","","MV_CH1","D",8,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
aAdd(aSX1,{cPerg,"02",STR0027,"","","MV_CH2","D",8,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
aAdd(aSX1,{cPerg,"03",STR0028,"","","MV_CH3","C",4,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","VE1",""	,"S","","",""})
aAdd(aSX1,{cPerg,"04",STR0039,"","","MV_CH4","C",34,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
aAdd(aSX1,{cPerg,"05",STR0029,"","","MV_CH5","C",34,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
aAdd(aSX1,{cPerg,"06",STR0030,"","","MV_CH6","C",34,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
aAdd(aSX1,{cPerg,"07",STR0031,"","","MV_CH7","C",34,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
aAdd(aSX1,{cPerg,"08",STR0032,"","","MV_CH8","C",34,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
aAdd(aSX1,{cPerg,"09",STR0033,"","","MV_CH9","C",34,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
aAdd(aSX1,{cPerg,"10",STR0034,"","","MV_CHA","C",34,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
aAdd(aSX1,{cPerg,"11",STR0036,"","","MV_CHB","C",99,0,0,"G","!Vazio().or.(Mv_Par11:=cGetFile('Arquivos |*.*','',,,,"+AllTrim(Str(nOpcGetFil))+"))","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
aAdd(aSX1,{cPerg,"12",STR0037,"","","MV_CHC","N",4,0,0,"G","","mv_par12","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","","9999"})

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
			IncProc(STR0038)
		EndIf
	EndIf
Next i

return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | CriaSX1_2  | Autor |  Thiago		          | Data | 04/03/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Criacao das perguntas.                                       |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function CriaSX1_2()
Local aSX1    := {}
Local aEstrut := {}
Local i       := 0
Local j       := 0
Local lSX1	  := .F.


aEstrut:= { "X1_GRUPO"  ,"X1_ORDEM","X1_PERGUNT","X1_PERSPA","X1_PERENG" ,"X1_VARIAVL","X1_TIPO" ,"X1_TAMANHO","X1_DECIMAL","X1_PRESEL"	,;
"X1_GSC"    ,"X1_VALID","X1_VAR01"  ,"X1_DEF01" ,"X1_DEFSPA1","X1_DEFENG1","X1_CNT01","X1_VAR02"  ,"X1_DEF02"  ,"X1_DEFSPA2"	,;
"X1_DEFENG2","X1_CNT02","X1_VAR03"  ,"X1_DEF03" ,"X1_DEFSPA3","X1_DEFENG3","X1_CNT03","X1_VAR04"  ,"X1_DEF04"  ,"X1_DEFSPA4"	,;
"X1_DEFENG4","X1_CNT04","X1_VAR05"  ,"X1_DEF05" ,"X1_DEFSPA5","X1_DEFENG5","X1_CNT05","X1_F3"     ,"X1_GRPSXG" ,"X1_PYME" ,"X1_GRPSXG" ,"X1_HELP","X1_PICTURE"}

cPergA := "OX12A"
aAdd(aSX1,{cPergA,"01","Gerentes ?          ","","","MV_CH1","N", 3,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","","999"})
aAdd(aSX1,{cPergA,"02","Adm & Outros ?      ","","","MV_CH2","N", 3,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","","999"})
aAdd(aSX1,{cPergA,"03","Balconista Varejo ? ","","","MV_CH3","N", 3,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","","999"})
aAdd(aSX1,{cPergA,"04","Balconista Oficina ?","","","MV_CH4","N", 3,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","","999"})
aAdd(aSX1,{cPergA,"05","Vendedores Atacado ?","","","MV_CH5","N", 3,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","","999"})
aAdd(aSX1,{cPergA,"06","Vendedores Acessor ?","","","MV_CH6","N", 3,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","","999"})
aAdd(aSX1,{cPergA,"07","Nome Responsavel ?  ","","","MV_CH7","C",15,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S"})

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
			IncProc(STR0038)
		EndIf
	EndIf
Next i

return