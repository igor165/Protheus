#INCLUDE "ESTPGDW.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ESTPgDw  ³ Autor ³ Nereu Humberto Junior ³ Data ³ 29/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta tabela temporaria no banco para carregar informacoes ³±±
±±³          ³ para o painel de gestao off-line Giro Medio do Estoque     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ESTPgDw()                                                   ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEST                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ESTPgDw(aParam) 

Local cEmp  := aParam[1]  //Empresa
Local cFil  := aParam[2]  //Filial   
Local cAliasDw := ALLTRIM(aParam[3])  //Alias   
Local dDtIni := STOD("") //aParam[4]
Local dDtFin := STOD("") //aParam[5]
Local cAliasGir := 'GIRO'
Local cAliasSB2    := ""
Local cAliasSD2    := ""
Local nX           := 0 
Local dDataIni := CTOD("")
Local dDataFin := CTOD("")
Local aDatas   := {}
Local nAnoIni  := 0
Local nAnoFin  := 0
Local nMesIni  := 0
Local nMesFin  := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preparando o ambiente para execucao                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//-- Evita que se consuma licenca
RpcSetType ( 3 )

PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil MODULO "EST"

dDtIni := aParam[4]
dDtFin := aParam[5]
 
//-- Cria tabela temporaria de periodos
//-- antes de criá-la deve-se eliminar a tabela.
EstDwPerCreaFile(cAliasGir, cAliasDW, cEmp, cFil )

nAnoIni := YEAR(dDtIni)
nAnoFin := YEAR(dDtFin)

nMesIni := MONTH(dDtIni)
nMesFin := MONTH(dDtFin)

If nAnoFin > YEAR(dDataBase)
	nAnoFin := YEAR(dDataBase)
Endif

If nMesFin > MONTH(dDataBase) 
	nMesFin := MONTH(dDataBase)
Endif

If nAnoIni == nAnoFin .And. nMesIni < nMesFin
	For nX := nMesIni To nMesFin
		dDataIni := CTOD("01/"+StrZero(nX,2)+"/"+Substr(Str(nAnoIni,4),3,2))
		dDataFin := LastDay(dDataIni)
		AADD(aDatas,{dDataIni,dDataFin})
	Next 
ElseIf nAnoIni < nAnoFin
	nMesAux := nMesFin
	nMesFin := nMesIni+(12-nMesIni)
	For nX := nMesIni To nMesFin
		dDataIni := CTOD("01/"+StrZero(nX,2)+"/"+Substr(Str(nAnoIni,4),3,2))
		dDataFin := LastDay(dDataIni)
		AADD(aDatas,{dDataIni,dDataFin})
	Next 
	nMesFin := nMesAux
	For nX := 1 To nMesFin
		dDataIni := CTOD("01/"+StrZero(nX,2)+"/"+Substr(Str(nAnoFin,4),3,2))
		dDataFin := LastDay(dDataIni)
		AADD(aDatas,{dDataIni,dDataFin})
	Next 	
Endif	

//-- Alimenta tabela temporaria

dbSelectArea("SB2")
cAliasSB2 := GetNextAlias()	
	
BeginSql Alias cAliasSB2

SELECT DISTINCT B2_COD, B2_LOCAL

FROM %table:SB2% SB2
	
WHERE SB2.B2_FILIAL = %xFilial:SB2%
      AND SB2.%NotDel%

EndSql

While (cAliasSB2)->(!Eof())
    For nX:= 1 To Len(aDatas)
	    Reclock(cAliasGir,.T.)
		(cAliasGir)->GIRO_CODIGO  := cEmpAnt
		(cAliasGir)->GIRO_CODFIL  := cFilAnt
	    (cAliasGir)->GIRO_PROD  := (cAliasSB2)->B2_COD
		(cAliasGir)->GIRO_LOCAL := (cAliasSB2)->B2_LOCAL
		(cAliasGir)->GIRO_DATA  := aDatas[nx,2]

		nSalIni := CalcEst((cAliasSB2)->B2_COD,(cAliasSB2)->B2_LOCAL,aDatas[nx,1]+1)[2] //Custo no inicio do mes
		nSalFin := CalcEst((cAliasSB2)->B2_COD,(cAliasSB2)->B2_LOCAL,aDatas[nx,2]+1)[2] //Custo no final do mes
			
		(cAliasGir)->GIRO_EST := (nSalIni+nSalFin) / 2
		(cAliasGir)->GIRO_VENDA  := 0
		MsUnlock()
    Next
	(cAliasSB2)->(dbSkip())
EndDo

dbSelectArea(cAliasSB2)
dbCloseArea()

dbSelectArea("SB2")
dbSetOrder(1)

dbSelectArea("SD2")
cAliasSD2 := GetNextAlias()	
	
BeginSql Alias cAliasSD2

SELECT D2_COD, D2_LOCAL, D2_EMISSAO, SUM(D2_CUSTO1) CUSTO

FROM  %table:SD2% SD2,
      %table:SF4% SF4
	
WHERE D2_FILIAL = %xFilial:SD2%
      AND D2_TIPO NOT IN ('D','B')
	  AND D2_EMISSAO  >= %Exp:Dtos(dDtIni)% 
	  AND D2_EMISSAO  <= %Exp:Dtos(dDtFin)%
      AND SD2.%NotDel%
      AND SF4.F4_FILIAL = %xFilial:SF4%
      AND SD2.D2_TES = SF4.F4_CODIGO
      AND SF4.F4_DUPLIC = 'S'
      AND SF4.F4_ESTOQUE = 'S'
      AND SF4.%NotDel%

GROUP BY D2_COD,D2_LOCAL, D2_EMISSAO

EndSql

TcSetField(cAliasSD2,"D2_EMISSAO","D", 8, 0)

While (cAliasSD2)->(!Eof())
    If (cAliasGir)->(dbSeek(cEmpAnt+cFilAnt+(cAliasSD2)->D2_COD+(cAliasSD2)->D2_LOCAL))
	    While !(cAliasGir)->(Eof()) .And. cEmpAnt+cFilAnt+(cAliasSD2)->D2_COD+(cAliasSD2)->D2_LOCAL == ;
	          (cAliasGir)->(GIRO_CODIGO+GIRO_CODFIL+GIRO_PROD+GIRO_LOCAL)
		    If MONTH((cAliasGir)->GIRO_DATA) == MONTH((cAliasSD2)->D2_EMISSAO)
			    Reclock(cAliasGir,.F.)
				(cAliasGir)->GIRO_VENDA += (cAliasSD2)->CUSTO
				MsUnlock()
			Endif	
		(cAliasGir)->(dbSkip())
		EndDo	
	Endif	
	(cAliasSD2)->(dbSkip())
EndDo

dbSelectArea(cAliasSD2)
dbCloseArea()

dbSelectArea("SD2")
dbSetOrder(1)

dbSelectArea(cAliasGir)
dbCloseArea()
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Finalisando o ambiente para execucao                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RESET ENVIRONMENT 

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EstDwPerCreaFile  ³ Autor ³ Nereu Humberto Junior ³ Data ³ 29/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria/Abre arquivo temporario para Giro Medio do Estoque             ³±±
±±³          ³                                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³EstDwPerCreaFile                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEST                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
 
Function EstDwPerCreaFile( cAliasDW ,; //Alias da tabela temporaria
       cNameFile ,; //Nome do arquivo da tabela temporaria
       cEmp   ,; //Codigo da Empresa 
       cFil   ;  //Codigo da Filial 
        )    
 
Local cNameIndex := cNameFile + "1"
Local cRdd     := "TOPCONN"
Local aFields  := {}
Local nTamPrd  := TamSX3("B2_COD")[1]
Local nTamLoc  := TamSX3("B2_LOCAL")[1]
Local nTamVlr  := TamSX3("B2_VATU1")[1]
Local nDec     := TamSX3("B2_VATU1")[2]
 
//-- Elimina a Tabela Criada
EstDwDelFile({cNameFile}) 
 
//-- Os nomes M0_ devem ser respeitados para que o roteiro do DW identifique 
//-- quais são os atributos referentes a Empresa e Filial.
//-- Campos obrigatorios
AADD(aFields, { "GIRO_CODIGO"  ,"C", 2       ,0  })  
AADD(aFields, { "GIRO_CODFIL"  ,"C", TamSX3("B2_FILIAL")[1] ,0  })
 
//-- Campos adicionais
AADD(aFields, { "GIRO_PROD"   ,"C", nTamPrd  ,0  })
AADD(aFields, { "GIRO_LOCAL"  ,"C", nTamLoc  ,0  })
AADD(aFields, { "GIRO_DATA"   ,"D", 8        ,0  }) 
AADD(aFields, { "GIRO_EST"    ,"N", nTamVlr  ,nDec  }) 
AADD(aFields, { "GIRO_VENDA"  ,"N", nTamVlr  ,nDec  }) 
 
IF( lRet := MSCreate( cNameFile , aFields , cRdd ) )
    //-- Abre o arquivo em modo Exclusivo
    DbUseArea(.T.,cRdd,cNameFile,cAliasDW,.F.,.F.)
    dbCreateIndex( cNameIndex, "GIRO_CODIGO + GIRO_CODFIL + GIRO_PROD + GIRO_LOCAL", { || GIRO_CODIGO + GIRO_CODFIL + GIRO_PROD + GIRO_LOCAL})
EndIF
 
Return (cNameFile) 
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³   EstDwDelFile    ³ Autor ³ Nereu Humberto Junior ³ Data ³ 29/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Elimina tabela temporaria para Giro Medio do Estoque                ³±±
±±³          ³                                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³EstDwDelFile                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEST                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
 
Function EstDwDelFile(aParam)
Local cNameFile := aParam[1] 
 
//-- Elimina a Tabela Criada 
If TcCanOpen(cNameFile)
   MsErase(cNameFile)    
EndIf   
 
Return Nil  