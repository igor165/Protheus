#INCLUDE "QDOR090.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "Report.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QDOR090  ³ Autor ³ Leandro S. Sabino     ³ Data ³ 25/05/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio de Documentos vencidos e a vencer                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Obs:      ³ (Versao Relatorio Personalizavel) 		                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOR090	                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function QDOR090()
Local oReport
Private cPerg	:= "QDR090"

If TRepInUse()
	Pergunte(cPerg,.F.) 
    oReport := ReportDef()
    oReport:PrintDialog()
Else
	Return QDOR090R3() //Executa versão anterior do fonte
EndIf           

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ReportDef()   ³ Autor ³ Leandro Sabino   ³ Data ³ 25.05.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Montar a secao				                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ReportDef()				                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOR090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()
Local oReport                                             
Local oSection1 
Local cFilDep  	 := xFilial("QAD")

DEFINE REPORT oReport NAME "QDOR090" TITLE OemToAnsi(STR0001) PARAMETER "QDR090" ACTION {|oReport| PrintReport(oReport)} DESCRIPTION (OemToAnsi(STR0002)+OemToAnsi(STR0003))
//"LISTA DE DOCUMENTOS VENCIDOS E A VENCER"##"Este programa ira imprimir uma rela‡ao de Documentos Vencidos e A Vencer"##
oReport:SetLandscape(.T.)

DEFINE SECTION oSection1 OF oReport TABLES "QDH" TITLE STR0023 // "Documentos"
DEFINE CELL NAME "QDH_DOCTO"  OF oSection1 ALIAS "QDH" AUTO SIZE 
DEFINE CELL NAME "QDH_RV"     OF oSection1 ALIAS "QDH" AUTO SIZE  
DEFINE CELL NAME "QDH_TITULO" OF oSection1 ALIAS "QDH" AUTO SIZE 
DEFINE CELL NAME "QDH_DTLIM"  OF oSection1 ALIAS "QDH" 
DEFINE CELL NAME "QDH_DTLIM"  OF oSection1 ALIAS "QDH" TITLE OemToAnsi(STR0022)     SIZE 17 BLOCK{|| QDR090DI() } //"Dias"
DEFINE CELL NAME "cUsu"       OF oSection1 ALIAS "QDH" TITLE OemToAnsi(STR0021)     SIZE 25 BLOCK{|| AllTrim(QA_NUSR(QDH->QDH_FILMAT,QDH->QDH_MAT,.T.,"A"))} 
DEFINE CELL NAME "QDH_DEPTOE" OF oSection1 ALIAS "QDH" SIZE 25 BLOCK{|| AllTrim(QA_NDEPT(QDH->QDH_DEPTOE,.T.,cFilDep))}  

Return oReport



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PrintReport   ³ Autor ³ Leandro Sabino   ³ Data ³ 25.05.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Imprimir os campos do relatorio                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PrintReport(ExpO1)  	     	                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto oPrint                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOR090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PrintReport( oReport )
Local oSection1  := oReport:Section(1)
Local cFiltro 

MakeAdvplExpr("QDR090")

DbSelectarea("QDH")
DbSetOrder(1)

cFiltro:= 'QDH->QDH_FILIAL=="'  +xFilial("QDH")+'" .And. '
cFiltro:= 'QDH->QDH_OBSOL <> "S" .And. QDH->QDH_CANCEL <> "S" .And. !Empty(QDH->QDH_DTLIM) .And. '
cFiltro+= 'QDH->QDH_DOCTO >= "' +mv_par01+'" .And. QDH->QDH_DOCTO <= "' +mv_par02+'".And. '
cFiltro+= 'QDH->QDH_RV >= "' +mv_par03+'" .And. QDH->QDH_RV <= "'    +mv_par04+'".And. '
cFiltro+= 'DTOS(QDH->QDH_DTLIM) >= "'+DTOS(mv_par05)+'" .And. DTOS(QDH->QDH_DTLIM) <= "'+DTOS(mv_par06)+'".And. '
cFiltro+= 'QDH->QDH_FILMAT >= "' +mv_par11+'" .And. QDH->QDH_FILMAT <= "' +mv_par08+'".And. '
cFiltro+= 'QDH->QDH_MAT >= "' +mv_par07+'" .And. QDH->QDH_MAT <= "' +mv_par08+'".And. '
cFiltro+= 'QDH->QDH_DEPTOE >= "' +mv_par09+'" .And. QDH->QDH_DEPTOE <= "' +mv_par10+'"'

oSection1:SetFilter(cFiltro)

oSection1:Print()

Return



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ QDOR090  ³ Autor ³ Eduardo de Souza      ³ Data ³ 23/11/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Relatorio de Documentos vencidos e a vencer                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOR090                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Eduardo S.  ³28/03/02³ META ³ Retirada a funcao QA_AjustSX1()          ³±±
±±³Eduardo S.  ³21/08/02³059354³ Acertado para listar corretamente datas  ³±±
±±³            ³        ³      ³ com 4 digitos.                           ³±±
±±³Eduardo S   |13/12/02³ ---- ³ Incluido a pergunta 11 e 12 permitindo   ³±±
±±³            ³        ³      ³ filtrar por filial de departamento.      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDOR090R3()

Local cTitulo   := OemToAnsi(STR0001) // "LISTA DE DOCUMENTOS VENCIDOS E A VENCER"
Local cDesc1    := OemToAnsi(STR0002) // "Este programa ira imprimir uma rela‡ao de Documentos Vencidos e A Vencer"
Local cDesc2    := OemToAnsi(STR0003) // "de acordo com os parƒmetros definidos pelo usu rio."
Local cString   := "QDH"
Local wnrel     := "QDOR090"
Local Tamanho   := "G"

Private cPerg   := "QDR090"
Private aReturn := {STR0004,1,STR0005,1,2,1,"",1} // "Zebrado" ### "Administra‡ao"##"de acordo com os parƒmetros definidos pelo usu rio."
Private nLastKey:= 0
Private INCLUI  := .F.	// Colocada para utilizar as funcoes

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                               ³
//³ mv_par01	// De Documento                                        ³
//³ mv_par02	// Ate Documento                                       ³
//³ mv_par03	// De Revisao                                          ³
//³ mv_par04	// Ate Revisao                                         ³
//³ mv_par05	// De Data Validade                                    ³
//³ mv_par06	// Ate Data Validade                                   ³
//³ mv_par07	// De Usuario Digitador                                ³
//³ mv_par08	// Ate Usuario Digitador                               ³
//³ mv_par09	// De Departamento Digitador                           ³
//³ mv_par10	// Ate Departamento Digitador                          ³
//³ mv_par11	// De Filial Usuario Digitador                         ³
//³ mv_par12	// Ate Filial Usuario Digitador                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Pergunte(cPerg,.F.)

wnrel := AllTrim(SetPrint(cString,wnrel,cPerg,ctitulo,cDesc1,cDesc2,"",.F.,,.F.,Tamanho))

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif

RptStatus({|lEnd| QDOR090Imp(@lEnd,ctitulo,wnRel,tamanho)},ctitulo)

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QDOR090Imp³ Autor ³ Eduardo de Souza      ³ Data ³ 23/11/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Envia para funcao que faz a impressao do relatorio.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDOR090Imp(ExpL1,ExpC1,ExpC2,ExpC3)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOR090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QDOR090Imp(lEnd,ctitulo,wnRel,tamanho)

Local cCabec1  := ""
Local cCabec2  := ""
Local cbtxt    := SPACE(10)
Local nTipo	   := GetMV("MV_COMP")
Local cbcont   := 0
Local cIndex1  := CriaTrab(Nil,.F.)
Local cFiltro  := ""
Local cKey     := ""
Local cDias    := ""
Local cValidade:= ""
Local cFilDep  := xFilial("QAD")

DbSelectarea("QDH")
DbSetOrder(1)

cFiltro:= 'QDH->QDH_FILIAL=="'  +xFilial("QDH")+'" .And. '
cFiltro:= 'QDH->QDH_OBSOL <> "S" .And. QDH->QDH_CANCEL <> "S" .And. !Empty(QDH->QDH_DTLIM) .And. '
cFiltro+= 'QDH->QDH_DOCTO >= "' +mv_par01+'" .And. QDH->QDH_DOCTO <= "' +mv_par02+'".And. '
cFiltro+= 'QDH->QDH_RV >= "' +mv_par03+'" .And. QDH->QDH_RV <= "'    +mv_par04+'".And. '
cFiltro+= 'DTOS(QDH->QDH_DTLIM) >= "'+DTOS(mv_par05)+'" .And. DTOS(QDH->QDH_DTLIM) <= "'+DTOS(mv_par06)+'".And. '
cFiltro+= 'QDH->QDH_FILMAT >= "' +mv_par11+'" .And. QDH->QDH_FILMAT <= "' +mv_par08+'".And. '
cFiltro+= 'QDH->QDH_MAT >= "' +mv_par07+'" .And. QDH->QDH_MAT <= "' +mv_par08+'".And. '
cFiltro+= 'QDH->QDH_DEPTOE >= "' +mv_par09+'" .And. QDH->QDH_DEPTOE <= "' +mv_par10+'"'

cKey:= 'QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV+DTOS(QDH->QDH_DTLIM)'

IndRegua("QDH",cIndex1,cKey,,cFiltro,OemToAnsi(STR0016)) // "Selecionando Registros.."

Li     := 80
m_Pag  := 1

cCabec1:= OemToAnsi(STR0017) // "DT TRANSF. RESPONSAVEL        DEPTO                     MOTIVO                          TIPO"                          

QDH->(DbSeek(xFilial("QDH")))
SetRegua(QDH->(RecCount())) // Total de Elementos da Regua

While QDH->(!Eof())
	If FWModeAccess("QAD")=="E" //!Empty(cFilDep)
		cFilDep:= QDH->QDH_FILMAT
	EndIf
	If lEnd
		Li++
		@ PROW()+1,001 PSAY OemToAnsi(STR0018) // "CANCELADO PELO OPERADOR"
		Exit
	EndIf
	If Li > 60
		Cabec(cTitulo,cCabec1,cCabec2,wnrel,Tamanho,nTipo)
	EndIf

    @ Li,000 PSay QDH->QDH_DOCTO
    @ Li,018 PSay QDH->QDH_RV
    @ Li,022 PSay Left(QDH->QDH_TITULO, 131)
	@ Li,154 PSay DToC(QDH_DTLIM)

	If (QDH->QDH_DTLIM - dDatabase) > 0
		cDias:= StrZero((QDH->QDH_DTLIM - dDatabase),4)
		cValidade:=	OemToAnsi(STR0019) // "A Vencer"
	Else
		cDias:= StrZero((dDataBase - QDH->QDH_DTLIM),4)
		cValidade:=	OemToAnsi(STR0020) // "Vencido"
	EndIf
   
    
	@ Li,165 PSay cDias
	@ Li,170 PSay cValidade
	@ Li,183 PSay QA_NUSR(QDH->QDH_FILMAT,QDH->QDH_MAT,.T.,"A") // Apelido
	@ Li,198 PSay AllTrim(QA_NDEPT(QDH->QDH_DEPTOE,.T.,cFilDep))
    Li++
	QDH->(DbSkip())


EndDo

If Li != 80
	Roda(cbcont,cbtxt,tamanho)
EndIf

RetIndex("QDH")
Set Filter to

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga indice de trabalho                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cIndex1 += OrdBagExt()
Delete File &(cIndex1)

Set Device To Screen

If aReturn[5] = 1
	Set Printer TO 
	DbCommitAll()
	Ourspool(wnrel)
Endif
MS_FLUSH()

Return .T.


Static Function QDR090DI()

If (QDH->QDH_DTLIM - dDatabase) > 0
	cDias:= (StrZero((QDH->QDH_DTLIM - dDatabase),4))+" "+ OemToAnsi(STR0019)
Else
	cDias:= (StrZero((dDataBase - QDH->QDH_DTLIM),4))+" "+ OemToAnsi(STR0020)
EndIf

return cDias

