#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 07/01/00

Function M100lven()        // incluido pelo assistente de conversao do AP5 IDE em 09/09/99
Local nZ:=0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("AIMPOSTOS,CALIASROT,NRECNOROT,AITEMINFO,ALIVRO,CNRLIVRO")
SetPrvt("CFORMULA,CVENDA,CNUMERO,_IDXF01,_IDXF02,_IDXF03")
SetPrvt("_IDXF04,_IDXF05,_IDXF06,_IDXF07,_IDXF08,_IDXF09")
SetPrvt("_IDXF10,_IDXF11,_IDXF12,_IDXF13,_IDXF28,_IDXF29")
SetPrvt("NE,NPOSQEB1,NPOSQEB2,NX,NPOSBASE,NPOSALIQ")
SetPrvt("NPOSVALR,")


/*/
______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+------------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ M100LVEN ¦ Autor ¦ William Yong           ¦ Data ¦ 05.04.01 ¦¦¦
¦¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Programa de Geração de Livro Fiscal "aLivro"  [Venezuela]   ¦¦¦
¦¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ MATA100, chamado pelo ponto de entrada                      ¦¦¦
¦¦+------------------------------------------------------------------------¦¦¦
¦¦¦         ATUALIZACIONES HECHAS DESDE LA CODIFICACION INICIAL.           ¦¦¦
¦¦+------------------------------------------------------------------------¦¦¦
¦¦¦Programador ¦ Fecha  ¦ BOPS ¦  Motivo de la Modificacion                ¦¦¦
¦¦+------------+--------+------+-------------------------------------------¦¦¦
¦¦¦William Yong¦05/06/01¦xxxxxx¦Desenvolvimento inicial.                   ¦¦¦
¦¦+------------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

//+----------------------------------------------------------------------------------+
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
//¦				   [n][11] := Valor do Frete Rateado                                    ¦
//¦					[n][12] := Valor Calculado do Imposto sobre Valor do Frete           ¦
//¦					[n][13] := Valor das Despesas Rateadas                               ¦
//¦					[n][14] := Valor Calculado do Imposto sobre Valor das Despesas       ¦
//¦                                                                                    ¦
//¦ ParamIxb[2] > Array de Geração do Livro Fiscal "aLivro"                            ¦
//+------------------------------------------------------------------------------------+
aImpostos := {}
cAliasROT := Alias()
nRecnoROT := Recno()

aItemINFO := ParamIxb[1]
aImpostos := ParamIxb[1,6]
aLivro    := ParamIxb[2]

cNrLivro  := SF4->F4_NRLIVRO
cFormula  := SF4->F4_FORMULA

//+---------------------------------------------------------------+
//¦ Inicializar variavel cNumero e Serie qdo módulo for LOJA.     ¦
//+---------------------------------------------------------------+
cVenda     := If( cVenda==NIL, "NORMAL", cVenda )
nTaxa	     :=	IIf(Type("nTaxa")<>"U",nTaxa,0)
nMoedaCor  :=	IIf(Type("nMoedaCor")<>"U",nMoedaCor,1)

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

_IdxF01 := AScan( aLivro[1],{|x| x == "F3_ALQIMP1" } )
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
_IdxF14 := AScan( aLivro[1],{|x| x == "F3_TIPOMOV" } )
_IdxF15 := AScan( aLivro[1],{|x| x == "F3_TPDOC" } )
_IdxF16 := AScan( aLivro[1],{|x| x == "F3_TIPO" } )

//+---------------------------------------------------------------+
//¦ Definiçäo da Coluna para o No GRavado.                        ¦
//+---------------------------------------------------------------+
_IdxF28 := AScan( aLivro[1],{|x| x == "F3_ISENIPI" } ) // No Gravado

//+---------------------------------------------------------------+
//¦ Nao eliminar o CFO. (Lucas)...                                ¦
//+---------------------------------------------------------------+
_IdxF29 := AScan( aLivro[1],{|x| x == "F3_CFO" } )

_IdxF30 := AScan( aLivro[1],{|x| AllTrim(x) == "F3_TES" } )
_IdxF31 := AScan( aLivro[1],{|x| AllTrim(x) == "F3_EXENTAS" } )

nE := Len( aLivro )
//Quebra por TES, Bruno
nE	:=	IIf(_IdxF30 > 0 .And. nE > 1 ,Ascan( aLivro ,{ |x| x[_IdxF30] == SF4->F4_CODIGO } ,2),nE)
// nE < 2 significa que eh o primeiro ou que o TES escolhido nao existe no ARRAY
If nE < 2 
   nE := Len( aLivro ) + 1
   AAdd( aLivro, Array( Len( aLivro[1] ) ) )
	//Bruno, Inicializar livro para nao mensagen de Nil no Protheus.
	For nZ	:=	1	To Len(aLivro[1])
		aLivro[nE][nZ]	:=	Criavar(aLivro[1][nZ])
	Next
	aLivro[nE,_IdxF02] := 0.00
   aLivro[nE,_IdxF04] := cFormula
   aLivro[nE,_IdxF05] := dDataBase
   aLivro[nE,_IdxF06] := cNFiscal
   aLivro[nE,_IdxF07] := cSerie
   aLivro[nE,_IdxF08] := IIF(cTipo$"DB",SA1->A1_COD,SA2->A2_COD)
   aLivro[nE,_IdxF09] := IIF(cTipo$"DB",SA1->A1_LOJA,SA2->A2_LOJA)
   aLivro[nE,_IdxF10] := IIF(cTipo$"DB",SA1->A1_EST,SA2->A2_EST)
   aLivro[nE,_IdxF11] := dDatabase
   aLivro[nE,_IdxF12] := cEspecie
	If _IdxF14	>	0
	   aLivro[nE,_IdxF14]:= If(cTipo$"D/B","V","C")
	Endif
   aLivro[nE,_IdxF16]:= cTipo 
	If (_IdxF28<>0)
		aLivro[nE,_IdxF28] := 0.00
	Endif
	If _IdxF30 > 0
		aLivro[nE,_IdxF30] := SF4->F4_CODIGO
	Endif

End
//Grava a Base no SF3->F3_VALCONT

aLivro[nE,_IdxF02] +=  xMoeda(aItemInfo[3]+ aItemInfo[4]+ aItemInfo[5],nMoedaCor,1,SF1->F1_DTDIGIT,,nTaxa)

//Grava os Impostos

GravaImp()

// Substituido pelo assistente de conversao do AP5 IDE em 09/09/99 ==> __Return( aLivro )
Return( aLivro )        // incluido pelo assistente de conversao do AP5 IDE em 09/09/99

// Substituido pelo assistente de conversao do AP5 IDE em 09/09/99 ==> Function GravaImp
Static Function GravaImp()
Local nX:=0

nTotalImp	:=	0
For nX:=1 To Len(aImpostos)
	If aImpostos[nX,2] > 0.00
		nPosBase:= AScan( aLivro[1],{|x| x == "F3_BASIMP"+aImpostos[nX][17] } )
		nPosAliq:= AScan( aLivro[1],{|x| x == "F3_ALQIMP"+aImpostos[nX][17] } )
		nPosValr:= AScan( aLivro[1],{|x| x == "F3_VALIMP"+aImpostos[nX][17] } )

		aLivro[nE,nPosBase] := IIf(aLivro[nE,nPosBase]==Nil,0,aLivro[nE,nPosBase]) + xMoeda(aImpostos[nX,3],nMoedaCor,1,SF1->F1_DTDIGIT,,nTaxa)
		aLivro[nE,nPosAliq] := aImpostos[nX,2]
		aLivro[nE,nPosValr] := Iif(aLivro[nE,nPosValr]==Nil,0,aLivro[nE,nPosValr]) + xMoeda(aImpostos[nX,4],nMoedaCor,1,SF1->F1_DTDIGIT,,nTaxa)

		nTotalImp := nTotalImp + aLivro[nE,nPosValr]

		//+---------------------------------------------------------------------+
      //¦Soma os impostos incidentes no campo F3_VALCONT.                     ¦
      //+---------------------------------------------------------------------+
        
       If Subs(aImpostos[nX][5],2,1)=="1" //si es incidente en la nota fiscal
            aLivro[nE,_IdxF02] := aLivro[nE,_IdxF02] + xMoeda(aImpostos[nX,4],nMoedaCor,1,SF1->F1_DTDIGIT,,nTaxa)
       ElseIf Subs(aImpostos[nX][5],2,1)=="2"
            aLivro[nE,_IdxF02] := aLivro[nE,_IdxF02] - xMoeda(aImpostos[nX,4],nMoedaCor,1,SF1->F1_DTDIGIT,,nTaxa)
       Endif 
	Endif
Next

If nTotalImp == 0 
   aLivro[nE,_IdxF31] +=  xMoeda(aItemInfo[3]+ aItemInfo[4]+ aItemInfo[5],nMoedaCor,1,SF1->F1_DTDIGIT,,nTaxa)
EndIf


Return
