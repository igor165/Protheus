// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 07     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#include "PROTHEUS.CH"
#Include "OFIIA420.CH"
/*
ANTIGO M_CDPRERM
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ OFIIA420 ³ Autor ³ Renata G. F. Marteli  ³ Data ³ 04/11/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Layout nao vem pelo Cores - Grava o valor p/contrato R&M   ³±±
±±³Descri‡„o ³ Atualiza B5_PRV5/B5_PRV6/B5_CODCAI/B5_GRTPPC  e VSV        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ OFIIA420                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Manoel      ³09/11/10³      ³ Passado para projeto                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Sugestoes  04/11/10
O caminho para pegar os arquivos deve ter mais uma pasta formada pela empresa e filial
Programa esta sem begin

Arquivo Novo
VSV  - compartilhado

Campos Novos:
SB5->B5_GRTPPC  C 3   real
SB5->B5_DESGTP  C 30  virtual

VSV->VSV_FILIAL
VSV->VSV_GRTPPC  C 3   real
VSV->VSV_DESGTP  C 30  real
*/
Function OFIIA420()

Local i

If !MsgYesNo(STR0001)
	Return
Endif

aFiles := {}
aSize  := {}

FM_Direct("\INT\IMP\PRI_RM\INTERFACE\PUBLIC\",.f.,.T.)

ADIR("\INT\IMP\PRI_RM\INTERFACE\PUBLIC\*.TXT",aFiles,aSize)

if Len(aSize)== 0
	MsgStop(STR0002,STR0003)
	return
endif

// o algoritmo abaixo acha o indice
// do arquivo com menor tamanho
nMenor :=1           //nao precisa dessa rotina, pois tem 1 arquivo somente
nValor := aSize[1]
for i = 2 to len(aSize)
	if aSize[i] < nValor
		nMenor := i
		nValor := aSize[i]
	endif
next

cFile :="\INT\IMP\PRI_RM\INTERFACE\PUBLIC\"+aFiles[nMenor]  //verificar

Processa ({ || FS_GRAVA(cFile,nValor)})

MsgStop(STR0004)

return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FS_GRAVA ³ Autor³ Renata G Ferrante Marteli ³ Data ³ 04/11/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava campos no SB5                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_GRAVA(cFile,nValor)
Local cGrpOri    := ""
Local oFile
Local cQAlSBM    := "SQLSBM"
Local cQAlSB1    := "SQLSB1"
Local aEmp       := {}
Local nContFil   := 0
Local aFilAtu    := FWArrFilAtu() // carrega os dados da Filial logada ( Grupo de Empresa / Empresa / Filial ) 
Local aSM0       := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. ) // Levanta todas as Filiais da Empresa logada (vetor utilizado no FOR das Filiais)
Local nCont      := 0
Local cBkpFilAnt := cFilAnt // salvar cFilAnt

For nContFil := 1 to Len(aSM0)
    cFilAnt := aSM0[nContFil]
    If aScan(aEmp, {|x| x[2] == xFilial("SB5") } ) <= 0
		Aadd( aEmp, { cFilAnt , xFilial("SB5") } )
	EndIf
Next
cFilAnt := cBkpFilAnt // voltar cFilAnt salvo anteriormente

&& Permite que o vetor com as empresa seja manipulado.
if ( ExistBlock("IA420EMP") )
	aEmp := ExecBlock("IA420EMP",.f.,.f., { aEmp } )
EndIf

cNameSB1 := RetSqlName("SB1")

cQuery := "SELECT BM_GRUPO "
cQuery += "FROM "+RetSqlName("SBM")
cQuery += " WHERE BM_PROORI = '1'"
cQuery += " AND D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSBM, .F., .T. )
do while !( cQAlSBM )->( Eof() )
	cGrpOri += "'"+( cQAlSBM )->( BM_GRUPO )+"',"
	( cQAlSBM )->( dbSkip() )
Enddo
( cQAlSBM )->( dbCloseArea() )
If !Empty(cGrpOri)
	cGrpOri := left(cGrpOri,len(cGrpOri)-1)
EndIf

DBSelectArea("SB5")
DBSetOrder(1) // B5_FILIAL+B5_COD

ProcRegua(((nValor/300)/500)) // Tamanho total do arquivo / 300 caracteres por linha

oFile := FWFileReader():New(cFile)

if (oFile:Open())

	IncProc(STR0005)
	
	while (oFile:hasLine())
		
		cLinha := oFile:GetLine()
		
		nCont++
		If nCont == 500
			IncProc(STR0005)
			nCont := 0
		EndIf
    	
		if left(cLinha,1) $ "0.1.2.3.4.5.6.7.8.9"

			Begin Transaction

				cCodite := subs(cLinha,1,7)
		
				cQuery := "SELECT SB1.B1_GRUPO , SB1.B1_CODITE , SB1.B1_DESC , SB1.B1_COD "
				cQuery += "FROM "+cNameSB1+" SB1 "
				cQuery += "WHERE SB1.B1_CODITE='"+cCodIte+"'"
				cQuery += "	 AND SB1.B1_GRUPO IN ( "+cGrpOri+" )"
				cQuery += "  AND SB1.D_E_L_E_T_=' '"
				
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSB1, .F., .T. )
				
				do while !( cQAlSB1 )->( Eof() )
					
					&& Inclui os registro no SB5 para todas as filiais
					For nContFil := 1 to Len(aEmp)
						
						cFilAnt := aEmp[nContFil,1]
						
						DBSelectArea("SB5")
						
						if DBSeek( xFilial("SB5") +(cQAlSB1)->B1_COD )
							reclock("SB5",.f.)
							if empty(SB5->B5_CODCAI) .or. left(SB5->B5_CODCAI,2) == "00"
								SB5->B5_CODCAI := strzero(val(SUBS(cLinha,127,2)),2) + "000" //CODCAI Geral
							endif
							if empty(SB5->B5_CEME)
								SB5->B5_CEME := (cQAlSB1)->B1_DESC
							endif
							SB5->B5_PRV5   := val(SUBS(cLinha,263,17))  //PRECO BALCAO CONTRATO
							SB5->B5_PRV6   := val(SUBS(cLinha,217,17))	 //PRECO DEALER CONTRATO				
							If SB5->( FieldPos("B5_PRV9")) # 0
								SB5->B5_PRV9   := val(SUBS(cLinha,235,17))	 //PRECO DEALER NORMAL
							Endif	
							SB5->B5_GRTPPC := strzero(val(alltrim(SUBS(cLinha,68,3))),3)  //GRUPO DE TIPO DA PECA
							msunlock()
						else
							reclock("SB5",.t.)
							SB5->B5_FILIAL := xFilial("SB5")
							SB5->B5_COD    := (cQAlSB1)->B1_COD
							SB5->B5_CODFAB := (cQAlSB1)->B1_CODITE
							SB5->B5_CEME   := (cQAlSB1)->B1_DESC
							SB5->B5_CODCAI := strzero(val(SUBS(cLinha,127,2)),2) + "000" //CODCAI Geral
							SB5->B5_PRV5   := val(SUBS(cLinha,263,17))
							SB5->B5_PRV6   := val(SUBS(cLinha,217,17))				
							If SB5->( FieldPos("B5_PRV9")) # 0
								SB5->B5_PRV9   := val(SUBS(cLinha,235,17))	 //PRECO DEALER NORMAL
							Endif					
							SB5->B5_GRTPPC := strzero(val(alltrim(SUBS(cLinha,68,3))),3)
							msunlock()
						endif
						
						DBSelectArea("VSV")
						if !DBSeek(xFilial("VSV")+strzero(val(alltrim(SUBS(cLinha,68,3))),3))
							reclock("VSV",.t.)
							VSV->VSV_GRTPPC := strzero(val(alltrim(SUBS(cLinha,68,3))),3)
							VSV->VSV_DESGTP := SUBS(cLinha,74,30)
							VSV->VSV_MSFIL  := cFilAnt // CODFIL
							msunlock()
						endif
						
					Next
			
					cFilAnt := cBkpFilAnt // voltar cFilAnt salvo anteriormente
					
					( cQAlSB1 )->( dbSkip() )
					
				Enddo
				
				( cQAlSB1 )->( dbCloseArea() )
		
			End Transaction

		endif

	end
	
	oFile:Close()
endif
IncProc(STR0005)	

Return
