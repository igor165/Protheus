#include "rwmake.ch"

Function M100ldom()  
Local nX:=0

If MafisFound()
   Return
Endif 
SetPrvt("AIMPOSTOS,CALIASROT,NRECNOROT,AITEMINFO,ALIVRO,CNRLIVRO")
SetPrvt("CFORMULA,CVENDA,CNUMERO,_IDXF01,_IDXF02,_IDXF03")
SetPrvt("_IDXF04,_IDXF05,_IDXF06,_IDXF07,_IDXF08,_IDXF09")
SetPrvt("_IDXF10,_IDXF11,_IDXF12,_IDXF13,_IDXF28,_IDXF29,_IDXF30")
SetPrvt("NE,NX,NPOSBASE,NPOSALIQ")
SetPrvt("NPOSVALR,")

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M100LDOM ³ Autor ³                        ³ Data ³ 25.02.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Geracao de Livro Fiscal "aLivro"[Rep.Dominicana]³±±
±±³          ³ Baseado no prg M100LARG (Argentina)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA460/8, chamado pelo ponto de entrada                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES EFETUADAS DESDE A CODIFICACAO INICIAL          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Bruno       ³17/07/00³xxxxxx³Incluir tratamento de faturamento e compra.³±±
±±³            ³        ³      ³ em mais de uma moeda.O livro deve ser     ³±±
±±³            ³        ³      ³ sempre gravado na moeda 1.                ³±±
±±³            ³        ³      ³                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

//+------------------------------------------------------------------------------------+
//¦ ParamIxb[1] > Recebe um Array Contendo a seguinte Estrutura:                       ¦
//¦             > Array referente a cada Item processando da Nota                      ¦
//¦                                                                                    ¦
//¦         [1] > Quantidade Vendida                                                   ¦
//¦         [2] > Preço Unitário de Venda                                              ¦
//¦         [3] > Valor Total                                                          ¦
//¦         [4] > Valor de Frete/Despesas (Rateado)                                    ¦
//¦         [5] > Valor das Despesas (Rateado)                                         ¦
//¦         [6] > {...} Array c/Impostos Calculados p/o Item                           ¦
//¦               [n][01] -> Código do Imposto                                         ¦
//¦               [n][02] -> Alíquota do Imposto                                       ¦
//¦               [n][03] -> Base de Cálculo do Imposto                                ¦
//¦               [n][04] -> Valor Calculado do Imposto                                ¦
//¦               [n][05] := "___" = Onde                                              ¦
//¦                          Pos.: 1-Inclui no Valor da Duplicata   (S/N)              ¦
//¦                                2-Inclui no Total da Nota Fiscal (S/N)              ¦
//¦								   	  3-Credita se do imposto para cálculo do Custo (SN)  ¦
//¦               [n][06] := Cpo.Gravação SD1 (Valor Imposto)                          ¦
//¦               [n][07] :=                  (Base de Cálculo)                        ¦
//¦               [n][08] := Cpo.Gravação SF1 (Valor Imposto)                          ¦
//¦               [n][09] :=                  (Base de Cálculo)                        ¦
//¦               [n][10] := Código dos Impostos Incidentes no Cálculo                 ¦
//¦				  [n][11] := Valor do Frete Rateado                                    ¦
//¦				  [n][12] := Valor Calculado do Imposto sobre Valor do Frete           ¦
//¦				  [n][13] := Valor das Despesas Rateadas                               ¦
//¦				  [n][14] := Valor Calculado do Imposto sobre Valor das Despesas       ¦
//¦                                                                                    ¦
//¦ ParamIxb[2] > Array de Geração do Livro Fiscal "aLivro"                            ¦
//+------------------------------------------------------------------------------------+
aImpostos:={}
cAliasROT:=Alias()
nRecnoROT:=Recno()

aItemINFO:=ParamIxb[1]
aImpostos:=ParamIxb[1,6]
aLivro   :=ParamIxb[2]

cNrLivro :=SF4->F4_NRLIVRO
cFormula :=SF4->F4_FORMULA

//Tratanmento dd taxa variavel
nTaxa		:=	IIf(Type("nTaxa")		=="U",0,nTaxa)
nMoedaNf	:=	IIf(Type("nMoedaNF")	=="U",1,nMoedaNf)
//+---------------------------------------------------------------+
//¦ Inicializar variavel cNumero e Serie qdo módulo for LOJA.     ¦
//+---------------------------------------------------------------+
cVenda := If( cVenda==NIL, "NORMAL", cVenda )

cNumero := cNFiscal

If cModulo == "LOJ"
	If cVenda == "RAPIDA"
		aImpostos := {}
	EndIf
EndIf

If ValType( aLivro ) #"A" .Or. Len( aLivro ) == 0
	aLivro := {{}}
	dbSelectArea( "SX3" )
	dbSetOrder( 1 )
	dbSeek( "SF3" )
	While !Eof() .and. X3_ARQUIVO=="SF3"
		If x3uso(x3_usado) .AND. cNivel >= x3_nivel
			AAdd( aLivro[1], RTrim(X3_CAMPO) )
		EndIf
		dbSkip()
	End
	dbSelectArea( cAliasROT )
	dbGoTo( nRecnoROT )
End

//_IdxF01 := AScan( aLivro[1],{|x| x == "F3_ALQIMP1" } )
_IdxF02 := AScan( aLivro[1],{|x| x == "F3_VALCONT" } )
_IdxF03 := AScan( aLivro[1],{|x| x == "F3_NRLIVRO" } )
_IdxF04 := AScan( aLivro[1],{|x| x == "F3_FORMULA" } )
_IdxF05 := AScan( aLivro[1],{|x| x == "F3_ENTRADA" } )
_IdxF06 := AScan( aLivro[1],{|x| x == "F3_NFISCAL" } )
_IdxF07 := AScan( aLivro[1],{|x| x == "F3_SERIE" } )
_IdxF08 := AScan( aLivro[1],{|x| x == "F3_CLIEFOR" } )
_IdxF09 := AScan( aLivro[1],{|x| x == "F3_LOJA" } )
_IdxF10 := AScan( aLivro[1],{|x| x == "F3_ESTADO" } )
_IdxF11 := AScan( aLivro[1],{|x| x == "F3_EMISSAO" } )
_IdxF12 := AScan( aLivro[1],{|x| x == "F3_ESPECIE" } )
_IdxF13 := AScan( aLivro[1],{|x| x == "F3_ALQIMP3" } )
//_IdxF14 := AScan( aLivro[1],{|x| x == "F3_TIPOMOV" } )
_IdxF15 := AScan( aLivro[1],{|x| x == "F3_TIPO" } )

//+---------------------------------------------------------------+
//¦ Definiçäo da Coluna para o No GRavado.                        ¦
//+---------------------------------------------------------------+
_IdxF28 := AScan( aLivro[1],{|x| x == "F3_ISENIPI" } ) // No Gravado

//+---------------------------------------------------------------+
//¦ Nao eliminar o CFO. (Lucas)...                                ¦
//+---------------------------------------------------------------+
_IdxF29 := AScan( aLivro[1],{|x| x == "F3_CFO" } )
_IdxF30 := AScan( aLivro[1],{|x| x == "F3_TES" } )

//nE:=Ascan( aLivro,{|x| x[_IdxF01] == SD1->D1_IPI },2 )

for nX:=1 to len(aImpostos)
//    if aImpostos[nX,3]>0 
       nPosAliq:=AScan(aLivro[1],{|x| x=="F3_ALQIMP"+aImpostos[nX][17]})
       ne:=ascan(aLivro,{|x| (x[nPosAliq]==aImpostos[nX,2] .or. x[nPosAliq]==nil) .and. ;
          if(_IdxF29<>0,x[_IdxF29]==SF4->F4_CF,.t.) .and. ;
          if(_IdxF30<>0,x[_IdxF30]==SF4->F4_CODIGO,.t.)},2)
       if ne==0
          nE:=Len(aLivro)+1
          AAdd(aLivro,Array(Len(aLivro[1])))
          aLivro[nE,_IdxF02] := 0.00
          // aLivro[nE,_IdxF03] := cNrLivro
          aLivro[nE,_IdxF04]:=cFormula
          aLivro[nE,_IdxF05]:=dDataBase
          aLivro[nE,_IdxF06]:=cNFiscal
          aLivro[nE,_IdxF07]:=cSerie
          aLivro[nE,_IdxF08]:=IIF(cTipo$"DB",SA1->A1_COD,SA2->A2_COD)
          aLivro[nE,_IdxF09]:=IIF(cTipo$"DB",SA1->A1_LOJA,SA2->A2_LOJA)
          aLivro[nE,_IdxF10]:=IIF(cTipo$"DB",SA1->A1_EST,SA2->A2_EST)
          aLivro[nE,_IdxF11]:=dDataBase
          aLivro[nE,_IdxF12]:=cEspecie
 //         aLivro[nE,_IdxF14]:=if(cEspecie == "NF   ","C",If(cEspecie=="NCC  ","V","C"))
          aLivro[nE,_IdxF15]:=cTipo //if(cEspecie == "NF ","N",If(cEspecie=="NCC","D","C"))
          If (_IdxF28<>0)
             aLivro[nE,_IdxF28]:=0.00
          Endif
          If (_IdxF29<>0)
             aLivro[nE,_IdxF29]:=SF4->F4_CF
          Endif
          If (_IdxF30<>0)
             aLivro[nE,_IdxF30]:=SF4->F4_CODIGO
          Endif
       endif
       //Grava os Impostos
       nPosBase:=AScan(aLivro[1],{|x| x=="F3_BASIMP"+aImpostos[nX][17]})
       nPosValr:=AScan(aLivro[1],{|x| x=="F3_VALIMP"+aImpostos[nX][17]})
       aLivro[nE,nPosBase]:=IIf(aLivro[nE,nPosBase]==Nil,0,aLivro[nE,nPosBase])+xMoeda(aImpostos[nX,3],nMoedaNF,1,dDatabase,,nTaxa)
       aLivro[nE,nPosAliq]:=aImpostos[nX,2]
       aLivro[nE,nPosValr]:=Iif(aLivro[nE,nPosValr]==Nil,0,aLivro[nE,nPosValr])+xMoeda(aImpostos[nX,4],nMoedaNF,1,dDatabase,,nTaxa)
       //+---------------------------------------------------------------------+
       //¦Soma os impostos incidentes no campo F3_VALCONT.                     ¦
       //+---------------------------------------------------------------------+
       If Subs(aImpostos[nX][5],2,1)=="S" //si es incidente en la nota fiscal
         aLivro[nE,_IdxF02] := aLivro[nE,_IdxF02] + xMoeda(aImpostos[nX,4],nMoedaNF,1,dDatabase,,nTaxa)
       endif
//    endif   
next
if len(aLivro)>1
   //Grava a Base no SF3->F3_VALCONT
   aLivro[nE,_IdxF02]:=aLivro[nE,_IdxF02]+xMoeda(aItemInfo[3]+aItemInfo[4]+aItemInfo[5],nMoedaNf,1,dDatabase,,nTaxa)
endif
Return(aLivro)
