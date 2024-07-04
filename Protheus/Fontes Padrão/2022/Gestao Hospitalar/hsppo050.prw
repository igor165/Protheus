#INCLUDE "PROTHEUS.CH"
#include "msgraphi.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³HSPPO050  ³ Autor ³ Rogerio Tabosa        ³ Data ³ 16/04/2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta array para Painel de Gestao Tipo 2 Padrao 3: Quantidade ³±±
±±³          ³de Atendimentos realizados no dia (DataBase)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³HSPPO050()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array = {{cCombo1,{cText1,cValor,nColorValor,cClick},..},..} ³±±
±±³          ³ cCombo1     = Detalhes                                       ³±±
±±³          ³ cText1      = Texto da Coluna                         		³±±
±±³          ³ cValor      = Valor a ser exibido (string)                   ³±±
±±³          ³ nColorValor = Cor do Valor no formato RGB (opcional)         ³±±
±±³          ³ cClick      = Funcao executada no click do valor (opcional)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAMDI                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


Function HSPPO050()

Local aArea		:= GetArea()
Local aAreaGCY	:= GCY->(GetArea())
Local cAliasRC1	:= "GCY"
//Local cCodLocI	:= "  "
//Local cCodLocF	:= "ZZ"
//Local aRet		:= {} 
Local cMes		:= StrZero(Month(dDataBase),2)
Local cAno		:= Substr(DTOC(dDataBase),7,2)
Local dDataIni	:= CTOD("01/"+cMes+"/"+cAno)
Local dDataFim	:= CTOD(StrZero(F_ULTDIA(dDataBase),2)+"/"+cMes+"/"+cAno)
//Local dDataIniA	:= CTOD("01/01/"+cAno)
//Local dDataFimA := CTOD("31/12/"+cAno)
Local nAteAmbM	:= 0 //Tipo 1
Local nAteAmbD	:= 0

Local nAteIntM	:= 0 //Tipo 0
Local nAteIntD	:= 0
Local nAtePAM	:= 0 //Tipo 2
Local nAtePAD	:= 0
Local nAteAmb	:= 0 
Local nAtePA	:= 0
Local nAteInt	:= 0
Local aEixoX    := {}
Local aValores  := {}  
Local aRetPanel := {}  
//Local aTabela	:= {}  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                        ³
//³                              D I A R I O                               ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Numero de Atendimentos cancelados por mes                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAliasRC1 := GetNextAlias()

BeginSql alias cAliasRC1
 SELECT Count(GCY.GCY_ATENDI) QTD, GCY.GCY_ATENDI TIPO
 FROM %table:GCY% GCY 
 WHERE GCY.GCY_FILIAL = %xFilial:GCY% AND GCY.%NotDel%
 AND GCY.GCY_DATATE = %Exp:DTOS(dDataBase)% 
 GROUP BY GCY.GCY_ATENDI
EndSql
 
While !(cAliasRC1)->(EOF())
	If (cAliasRC1)->TIPO == "0"
		nAteInt := nAteIntD := (cAliasRC1)->QTD
	ElseIf (cAliasRC1)->TIPO == "1"
		nAteAmb := nAteAmbD := (cAliasRC1)->QTD
	ElseIf (cAliasRC1)->TIPO == "2"
		nAtePA := nAtePAD := (cAliasRC1)->QTD
	EndIf
	(cAliasRC1)->(DbSkip())
End
(cAliasRC1)->(DbCloseArea())


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                        ³
//³                              M E N S A L                               ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Numero de Atendimentos cancelados por mes                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAliasRC1 := GetNextAlias()

BeginSql alias cAliasRC1
 SELECT Count(GCY.GCY_ATENDI) QTD, GCY.GCY_ATENDI TIPO
 FROM %table:GCY% GCY 
 WHERE GCY.GCY_FILIAL = %xFilial:GCY% AND GCY.%NotDel%
 AND GCY.GCY_DATATE BETWEEN %Exp:DTOS(dDataIni)% AND %Exp:DTOS(dDataFim)%
 GROUP BY GCY.GCY_ATENDI
EndSql
 
While !(cAliasRC1)->(EOF())
	If (cAliasRC1)->TIPO == "0"
		nAteInt := nAteIntM := (cAliasRC1)->QTD
	ElseIf (cAliasRC1)->TIPO == "1"
		nAteAmb := nAteAmbM := (cAliasRC1)->QTD
	ElseIf (cAliasRC1)->TIPO == "2"
		nAtePA := nAtePAM := (cAliasRC1)->QTD
	EndIf
	(cAliasRC1)->(DbSkip())
End
(cAliasRC1)->(DbCloseArea())

//aTabela := {  { "Dia",{ "Pronto Atendimento" , "Ambulatorio", "Internação" }  , {   {STR(nAtePAD),STR(nAteAmbD),STR(nAteIntD) }}  }  , { "Mes", { "Pronto Atendimento" , "Ambulatorio", "Internação"  } , {   {STR(nAtePAM),STR(nAteAmbM),STR(nAteIntM) } }  },{ "Ano",{  "Pronto Atendimento" , "Ambulatorio", "Internação" }  , {   {STR(nAtePAA),STR(nAteAmbA),STR(nAteIntA) }  }  } }
//aRetPanel := {  GRP_PIE, { "", {|| ONCLICKG}, {"Pronto Atendimento" , "Ambulatorio","Internação"} , {nAtePA,nAteAmb,nAteInt}  } , { "Atendimentos", {|| ONCLICKT},  aTabela  }     } 

Aadd( aEixoX, "Pronto Atendimento" )
Aadd( aEixoX, "Ambulatorio" )
Aadd( aEixoX, "Internação" )
Aadd( aValores, nAtePAD)
Aadd( aValores, nAteAmbD)
Aadd( aValores, nAteIntD)
        
aRetPanel := 	{GRP_PIE,;
				{},;
				{aEixoX},;
				{""},;
				{aValores},;
				"",""}
        
RestArea(aAreaGCY)
RestArea(aArea)

Return aRetPanel  


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³HSPPO051  ³ Autor ³ Rogerio Tabosa        ³ Data ³ 16/04/2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta array para Painel de Gestao Tipo 2 Padrao 3: Quantidade ³±±
±±³          ³de Atendimentos realizados no mes corrente                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³HSPPO051()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array = {{cCombo1,{cText1,cValor,nColorValor,cClick},..},..} ³±±
±±³          ³ cCombo1     = Detalhes                                       ³±±
±±³          ³ cText1      = Texto da Coluna                         		³±±
±±³          ³ cValor      = Valor a ser exibido (string)                   ³±±
±±³          ³ nColorValor = Cor do Valor no formato RGB (opcional)         ³±±
±±³          ³ cClick      = Funcao executada no click do valor (opcional)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAMDI                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function HSPPO051()

Local aArea		:= GetArea()
Local aAreaGCY	:= GCY->(GetArea())
Local cAliasRC1	:= "GCY"
//Local cCodLocI	:= "  "
//Local cCodLocF	:= "ZZ"
//Local aRet		:= {} 
Local cMes		:= StrZero(Month(dDataBase),2)
Local cAno		:= Substr(DTOC(dDataBase),7,2)
Local dDataIni	:= CTOD("01/"+cMes+"/"+cAno)
Local dDataFim	:= CTOD(StrZero(F_ULTDIA(dDataBase),2)+"/"+cMes+"/"+cAno)
//Local dDataIniA	:= CTOD("01/01/"+cAno)
//Local dDataFimA := CTOD("31/12/"+cAno)
Local nAteAmbM	:= 0 //Tipo 1
Local nAteIntM	:= 0 //Tipo 0
Local nAtePAM	:= 0 //Tipo 2
Local aEixoX    := {}
Local aValores  := {}  
Local aRetPanel := {}  
//Local aTabela	:= {}  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                        ³
//³                              M E N S A L                               ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Numero de Atendimentos cancelados por mes                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAliasRC1 := GetNextAlias()

BeginSql alias cAliasRC1
 SELECT Count(GCY.GCY_ATENDI) QTD, GCY.GCY_ATENDI TIPO
 FROM %table:GCY% GCY 
 WHERE GCY.GCY_FILIAL = %xFilial:GCY% AND GCY.%NotDel%
 AND GCY.GCY_DATATE BETWEEN %Exp:DTOS(dDataIni)% AND %Exp:DTOS(dDataFim)%
 GROUP BY GCY.GCY_ATENDI
EndSql
 
While !(cAliasRC1)->(EOF())
	If (cAliasRC1)->TIPO == "0"
		nAteIntM := (cAliasRC1)->QTD
	ElseIf (cAliasRC1)->TIPO == "1"
		nAteAmbM := (cAliasRC1)->QTD
	ElseIf (cAliasRC1)->TIPO == "2"
		nAtePAM := (cAliasRC1)->QTD
	EndIf
	(cAliasRC1)->(DbSkip())
End
(cAliasRC1)->(DbCloseArea())


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                        ³
//³                              A N U A L                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Numero de Atendimentos cancelados por mes                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAliasRC1 := GetNextAlias()

BeginSql alias cAliasRC1
 SELECT Count(GCY.GCY_ATENDI) QTD, GCY.GCY_ATENDI TIPO
 FROM %table:GCY% GCY 
 WHERE GCY.GCY_FILIAL = %xFilial:GCY% AND GCY.%NotDel%
 AND GCY.GCY_DATATE BETWEEN %Exp:DTOS(dDataIniA)% AND %Exp:DTOS(dDataFimA)%
 GROUP BY GCY.GCY_ATENDI
EndSql
 
While !(cAliasRC1)->(EOF())
	If (cAliasRC1)->TIPO == "0"
		nAteInt := nAteIntA := (cAliasRC1)->QTD
	ElseIf (cAliasRC1)->TIPO == "1"
		nAteAmb := nAteAmbA := (cAliasRC1)->QTD
	ElseIf (cAliasRC1)->TIPO == "2"
		nAtePA := nAtePAA := (cAliasRC1)->QTD
	EndIf
	(cAliasRC1)->(DbSkip())
End
(cAliasRC1)->(DbCloseArea())
   */ 


//aRetPanel := {  GRP_PIE, { "", {|| ONCLICKG}, {"Pronto Atendimento" , "Ambulatorio","Internação"} , {nAtePA,nAteAmb,nAteInt}  } , { "Atendimentos", {|| ONCLICKT},  aTabela  }     } 

Aadd( aEixoX, "Pronto Atendimento" )
Aadd( aEixoX, "Ambulatorio" )
Aadd( aEixoX, "Internação" )
Aadd( aValores, nAtePAM)
Aadd( aValores, nAteAmbM)
Aadd( aValores, nAteIntM)
        
aRetPanel := 	{GRP_PIE,;
				{},;
				{aEixoX},;
				{""},;
				{aValores},;
				"",""}
        
RestArea(aAreaGCY)
RestArea(aArea)

Return aRetPanel
                   