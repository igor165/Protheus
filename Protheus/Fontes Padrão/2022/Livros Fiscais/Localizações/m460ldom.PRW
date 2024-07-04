#include "SIGAWIN.CH"        

Function M460lDom()        
Local nX:=0

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M460LMEX ³ Autor ³                        ³ Data ³ 25.02.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Geracao de Livro Fiscal "aLivro"  [Mexico]      ³±±
±±³          ³ Baseado no prg M460LARG (Argentina)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA460, chamado pelo ponto de entrada                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES EFETUADAS DESDE A CODIFICACAO INICIAL          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Percy       ³11/11/00³xxxxxx³ Conversion de moneda extranjera p/moneda  ³±±
±±³            ³        ³      ³ local. Actualiza [Libros Fiscales]        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
SetPrvt("CALIASROT,NRECNOROT,AITEMINFO,CESPECIE,AIMPOSTOS,ALIVRO")
SetPrvt("COPERACAO,CNRLIVRO,CFORMULA,CNUMERO,CSERIE,_IDXF01")
SetPrvt("_IDXF02,_IDXF03,_IDXF04,_IDXF05,_IDXF06,_IDXF07")
SetPrvt("_IDXF08,_IDXF09,_IDXF10,_IDXF11,_IDXF12,_IDXF13")
SetPrvt("_IDXF28,_IDXF29,_IDXF30,NE,NPOSQEB1,NPOSQEB2,NX")
SetPrvt("NPOSBASE,NPOSALIQ,NPOSVALR,CSERLJ")

//+---------------------------------------------------------------+
//¦ ParamIxb[1] > Recebe um Array Contendo a seguinte Estrutura:  ¦
//¦             > Array referente a cada Item processando da Nota ¦
//¦                                                               ¦
//¦            [1] > Quantidade Vendida                           ¦
//¦            [2] > Preço Unitário de Venda                      ¦
//¦            [3] > Valor Total                                  ¦
//¦            [4] > Valor de Frete/Despesas (Rateado)            ¦
//¦            [5] > {...} Array c/Impostos Calculados p/o Item   ¦
//¦                  [.][1] -> Código do Imposto                  ¦
//¦                  [.][2] -> Alíquota do Imposto                ¦
//¦                  [.][3] -> Base de Cálculo do Imposto         ¦
//¦                  [.][4] -> Valor Calculado do Imposto         ¦
//¦                  [.][>] -> Outras Informações                 ¦
//¦                                                               ¦
//¦ ParamIxb[2] > Array de Geração do Livro Fiscal "aLivro"       ¦
//+---------------------------------------------------------------+
cAliasROT := Alias()
nRecnoROT := Recno()

aItemINFO := ParamIxb[1]

cEspecie  := If( cEspecie==NIL,"NF ",cEspecie )

If cEspecie != "NF " .and. cEspecie != "FT "
	aImpostos := ParamIxb[1,6]
Else
	aImpostos := ParamIxb[1,6]
EndIf

aLivro    := ParamIxb[2]
cOperacao := ParamIxb[3]

cNrLivro  := SF4->F4_NRLIVRO
cFormula  := SF4->F4_FORMULA

//Tratamento de taxa variavel - 11/11/2000 - Percy
nTaxaMd	    :=	IIf(Type("nTaxaMd")=="U",0,nTaxaMd)
nMoedaCor	:=	IIf(Type("nMoedaCor")=="U",1,nMoedaCor)

//+---------------------------------------------------------------+
//¦ Inicializar variavel cNumero e Serie qdo módulo for LOJA.     ¦
//+---------------------------------------------------------------+
If nModulo == 12 .OR. nModulo == 72 // SIGALOJA //SIGAPHOTO
	If cOperacao == "0"
		aImpostos := {}
	EndIf
    cNumero := cNFiscal
	cSerie :=  IIf(empty(cSerie),Iif(Type("cSerLj")=="U",Space(03),cSerLj),cSerie) 
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
	//dbEval( {|| AAdd( aLivro[1], RTrim(X3_CAMPO) ) },,{|| !Eof() .And. X3_ARQUIVO=="SF3" } )
   dbSelectArea( cAliasROT )
   dbGoTo( nRecnoROT )
End

//_IdxF01:=AScan(aLivro[1],{|x| x==F3_ALQIMP1"})
_IdxF02:=AScan(aLivro[1],{|x| x=="F3_VALCONT"})
_IdxF03:=AScan(aLivro[1],{|x| x=="F3_NRLIVRO"})
_IdxF04:=AScan(aLivro[1],{|x| x=="F3_FORMULA"})
_IdxF05:=AScan(aLivro[1],{|x| x=="F3_ENTRADA"})
_IdxF06:=AScan(aLivro[1],{|x| x=="F3_NFISCAL"})
_IdxF07:=AScan(aLivro[1],{|x| x=="F3_SERIE"})
_IdxF08:=AScan(aLivro[1],{|x| x=="F3_CLIEFOR"})
_IdxF09:=AScan(aLivro[1],{|x| x=="F3_LOJA"})
_IdxF10:=AScan(aLivro[1],{|x| x=="F3_ESTADO"})
_IdxF11:=AScan(aLivro[1],{|x| x=="F3_EMISSAO"})
_IdxF12:=AScan(aLivro[1],{|x| x=="F3_ESPECIE"})
//_IdxF14:=Ascan(aLivro[1],{|x| x=="F3_TIPOMOV"})
_IdxF28:= AScan( aLivro[1],{|x| x=="F3_ISENIPI"}) // No Gravado

//+---------------------------------------------------------------+
//¦ Nao eliminar o CFO. (Lucas)...                                ¦
//+---------------------------------------------------------------+
_IdxF29:=AScan(aLivro[1],{|x| x=="F3_CFO"})

_IdxF30:=AScan(aLivro[1],{|x| x=="F3_TES"})

//nE:=Ascan( aLivro,{|x| x[_IdxF01] == SB1->B1_IPI },2 )

for nX:=1 to len(aImpostos)
//    if aImpostos[nX,3]>0
       nPosAliq:=AScan(aLivro[1],{|x| x=="F3_ALQIMP"+aImpostos[nX][17]})
       ne:=ascan(aLivro,{|x| (x[nPosAliq]==aImpostos[nX,2] .or. x[nPosAliq]==nil) .and. ;
          if(_IdxF29<>0,x[_IdxF29]==SF4->F4_CF,.t.) .and. ;
          if(_IdxF30<>0,x[_IdxF30]==SF4->F4_CODIGO,.t.)},2)
       if ne==0
          nE:=Len(aLivro)+1
          AAdd(aLivro,Array(Len(aLivro[1])))
          aLivro[nE,_IdxF02]:=0.00
          // aLivro[nE,_IdxF03]:=cNrLivro
          aLivro[nE,_IdxF04]:=cFormula
          aLivro[nE,_IdxF05]:=dDataBase
          aLivro[nE,_IdxF06]:=cNFiscal
          aLivro[nE,_IdxF07]:=cSerie
          aLivro[nE,_IdxF08]:=IIf(cModulo$"COM|EST",SA2->A2_COD,SA1->A1_COD)
          aLivro[nE,_IdxF09]:=IIf(cModulo$"COM|EST",SA2->A2_LOJA,SA1->A1_LOJA)
          aLivro[nE,_IdxF10]:=IIf(cModulo$"COM|EST",SA2->A2_EST,SA1->A1_EST)
          aLivro[nE,_IdxF11]:=dDataBase
          aLivro[nE,_IdxF12]:=cEspecie  // SigaLoja...
//	      aLivro[nE,_IdxF14]:= if(Alltrim(cEspecie) == "FT","V",If(Alltrim(cEspecie)$"NDC|NCC","V","C"))
          If _IdxF28<>0
             aLivro[nE,_IdxF28]:=0.00
          Endif
          if _IdxF29<>0
             aLivro[nE,_IdxF29]:=SF4->F4_CF
          endif   
          if _IdxF30<>0
             aLivro[nE,_IdxF30]:=SF4->F4_CODIGO
          endif
       endif
       nPosBase:=AScan(aLivro[1],{|x| x=="F3_BASIMP"+aImpostos[nX][17]})
       nPosValr:=AScan(aLivro[1],{|x| x=="F3_VALIMP"+aImpostos[nX][17]})

       //Conversion de Moneda extranjera para PESOS (moneda local de mejico) - Percy - 11/11/2000.
       aLivro[nE,nPosBase]:=IIf(aLivro[nE,nPosBase]==Nil,0,aLivro[nE,nPosBase])+Iif(nMoedaCor>1,xMoeda(aImpostos[nX,3],nMoedaCor,1,Nil,nTaxaMd),aImpostos[nX,3])
       aLivro[nE,nPosValr]:=Iif(aLivro[nE,nPosValr]==Nil,0,aLivro[nE,nPosValr])+Iif(nMoedaCor>1,xMoeda(aImpostos[nX,4],nMoedaCor,1,Nil,nTaxaMd),aImpostos[nX,4])
       aLivro[nE,nPosAliq]:=aImpostos[nX,2]

       //+---------------------------------------------------------------------+
       //¦Soma os impostos incidentes no campo F3_VALCONT.                     ¦
       //+---------------------------------------------------------------------+
       If Subs(aImpostos[nX][5],2,1)=="S" //si es incidente en la nota fiscal
          aLivro[nE,_IdxF02]:=aLivro[nE,_IdxF02]+Iif(nMoedaCor>1,xMoeda(aImpostos[nX,4],nMoedaCor,1,Nil,,nTaxaMd),aImpostos[nX,4])
       Endif
//    Endif   
next
if len(aLivro)>1
   aLivro[nE,_IdxF02]:=aLivro[nE,_IdxF02]+Iif(nMoedaCor>1,xMoeda(aItemInfo[3],nMoedaCor,1,Nil,nTaxaMd),aItemInfo[3])
endif   
Return( aLivro )        
