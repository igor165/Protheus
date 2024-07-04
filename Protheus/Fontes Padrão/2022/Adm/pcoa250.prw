#INCLUDE "pcoa250.ch"
#INCLUDE "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ PCOA250  ³ Autor ³ Paulo Carnelossi      ³ Data ³ 10/04/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastramento de Relatorios Modulo SIGAPCO                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPCO                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PCOA250()

A250Pop_ALH()

AxCadastro("ALH",STR0001, "PCOA250DEL()")  //"Cadastro de Relatorios"

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PCOA250DEL³ Autor ³ Paulo Carnelossi      ³ Data ³10/04/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Rotina de validacao de exclusao de Relatorios               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 -> Validacao OK                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PCOA250                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOA250DEL()

Return .T.

Static Function A250Pop_ALH()
Local aRelat := {}, nX
//planilha
aAdd(aRelat,{"PCOR010",STR0002 ,"PCR010", "(aPerg)"}) //"Planilha Resumida"
aAdd(aRelat,{"PCOR045",STR0003,"PCR015", "(aPerg)"}) //"Planilha Detalhada"
aAdd(aRelat,{"PCOR050",STR0004,"PCR010", "(aPerg)"}) //"Totalizadores da Planilha"
aAdd(aRelat,{"PCOR211",STR0005,"PCR211", "(,,,,aPerg)"}) //"Comparacao entre Versoes da Planilha"

//movimentos
aAdd(aRelat,{"PCOR400",STR0006,"PCR400", "(aPerg)"}) //"Relatorio de Movimentos"

//Cubos Gerenciais
aAdd(aRelat,{"PCOR330",STR0007,"PCR330", "(aPerg)"}) //"Cubos - Movimentos"
aAdd(aRelat,{"PCOR310",STR0008,"PCR310", "(aPerg)"}) //"Cubos - Demonstrativo de Saldos"
aAdd(aRelat,{"PCOR300",STR0009,"PCR300", "(aPerg)"}) //"Cubos - Balancete"
aAdd(aRelat,{"PCOR320",STR0010,"PCR320", "(aPerg)"}) //"Cubos - Demonstrativo por Periodo"

//Cubos Gerenciais Comparativos
aAdd(aRelat,{"PCOR510",STR0011,"PCR510", "(aPerg)"}) //"Cubos Comparativos - Demonstrativo de Saldos"
aAdd(aRelat,{"PCOR500",STR0012,"PCR500", "(aPerg)"}) //"Cubos Comparativos - Balancete"
aAdd(aRelat,{"PCOR520",STR0013,"PCR520", "(aPerg)"}) //"Cubos Comparativos - Demonstrativo por Periodo"
aAdd(aRelat,{"PCOR530",STR0014,"PCR520", "(aPerg)"}) //"Cubos Comparativos - Dem.Resumido por Periodo"

//Visoes
aAdd(aRelat,{"PCOR030",STR0015 ,"PCR030", "(,aPerg)"}) //"Visao - Estrutura Resumida"
aAdd(aRelat,{"PCOR055",STR0016,"PCR035", "(,aPerg)"}) //"Visao - Estrutura Completa"
aAdd(aRelat,{"PCOR060",STR0017,"PCR030", "(,aPerg)"}) //"Totalizadores da Visao"

dbSelectArea("ALH")
dbSetOrder(01)

For nX := 1 TO Len(aRelat)
	If !dbSeek(xFilial("ALH")+aRelat[nX,1])
		RecLock("ALH", .T.)
		ALH->ALH_FILIAL := xFilial("ALH")
		ALH->ALH_PRGREL := aRelat[nX,1]
		ALH->ALH_TITREL := aRelat[nX,2]
		ALH->ALH_GRPERG := aRelat[nX,3]
		ALH->ALH_PRGPAR := aRelat[nX,4]
		MsUnLock()
	EndIf	
Next

Return