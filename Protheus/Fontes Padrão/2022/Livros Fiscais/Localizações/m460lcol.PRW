#include "SIGAWIN.CH"        

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M460LCOL ³ Autor ³                        ³ Data ³ 25.02.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Geracao de Livro Fiscal "aLivro"  [Colombia]    ³±±
±±³          ³ Baseado no prg M460LARG (Argentina)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA460, chamado pelo ponto de entrada                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES EFETUADAS DESDE A CODIFICACAO INICIAL          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Rubens Pante³12/01/01³xxxxx ³Gravacao dos campos F3_TIPO e F3_TIPOMOV   ³±±
±±³            ³        ³      ³em aLivro                                  ³±±
±±³            ³        ³      ³                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M460LCOL()        

Local nMoedaBase  := 0
Local nMoedaValor := 0
Local nMoedaAliq  := 0
Local nMoedaTotal := 0
Local nX := 0
Local nY := 0

SetPrvt("CALIASROT,NRECNOROT,AITEMINFO,CESPECIE,AIMPOSTOS,ALIVRO")
SetPrvt("COPERACAO,CNRLIVRO,CFORMULA,CNUMERO,CSERIE,_IDXF01")
SetPrvt("_IDXF02,_IDXF03,_IDXF04,_IDXF05,_IDXF06,_IDXF07")
SetPrvt("_IDXF08,_IDXF09,_IDXF10,_IDXF11,_IDXF12,_IDXF13")
SetPrvt("_IDXF28,_IDXF29,_IDXF30,_IDXF31,NE,NPOSQEB1,NPOSQEB2,NX")
SetPrvt("NPOSBASE,NPOSALIQ,NPOSVALR,NPOSRET,")

If MaFisFound()
   Return
Endif   

cAliasROT := Alias()
nRecnoROT := Recno()

cEspecie  := If( cEspecie==NIL,"NF ",cEspecie )

aItemINFO := ParamIxb[1]
aImpostos := ParamIxb[1,6]
aLivro    := ParamIxb[2]
cOperacao := ParamIxb[3]

cNrLivro  := SF4->F4_NRLIVRO
cFormula  := SF4->F4_FORMULA

//Tratamento de taxa variavel - Denis
nTaxaMd		:= If(Type("nTaxa")=="U",0,nTaxa)
nMoedaCor	:= If(Type("nMoedaCor")=="U",1,nMoedaCor)


//+---------------------------------------------------------------+
//¦ Inicializar variavel cNumero e Serie qdo módulo for LOJA.     ¦
//+---------------------------------------------------------------+
If cModulo $ "LOJ|FRT"
	If cOperacao == "0"
		cNumero := cNFiscal
		cSerie :=  cSerie
		aImpostos := {}
	Else
		cNumero := cNFiscal
		cSerie :=  cSerie
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
	//dbEval( {|| AAdd( aLivro[1], RTrim(X3_CAMPO) ) },,{|| !Eof() .And. X3_ARQUIVO=="SF3" } )
	dbSelectArea( cAliasROT )
	dbGoTo( nRecnoROT )
End

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
_IdxF14:=AScan(aLivro[1],{|x| x=="F3_TIPOMOV"})
_IdxF16:=AScan(aLivro[1],{|x| x=="F3_TIPO"})
_IdxF28:=AScan(aLivro[1],{|x| x=="F3_ISENIPI"}) // No Gravado

//+---------------------------------------------------------------+
//¦ Nao eliminar o CFO. (Lucas)...                                ¦
//+---------------------------------------------------------------+
_IdxF29:=AScan(aLivro[1],{|x| x=="F3_CFO"})
_IdxF30:=AScan(aLivro[1],{|x| x=="F3_TES"})
_IdxF31:=Ascan(aLivro[1],{|x| x=="F3_NIT"}) 
//nE:=Ascan( aLivro,{|x| x[_IdxF01] == SB1->B1_IPI },2 )

for nX:=1 to len(aImpostos)
    if aImpostos[nX,3]>0
       nPosAliq:=AScan(aLivro[1],{|x| x=="F3_ALQIMP"+aImpostos[nX][17]})
       ne:=ascan(aLivro,{|x| (x[nPosAliq]==aImpostos[nX,2] .or. x[nPosAliq]==0.00) .and. ;
          if(_IdxF29<>0,x[_IdxF29]==SF4->F4_CF,.t.) .and. ;
          if(_IdxF30<>0,x[_IdxF30]==SF4->F4_CODIGO,.t.) .and.; 
          if(_IdxF31<>0,x[_IdxF31]==aItemInfo[7],.t.)},2) 
       if ne==0
          nE:=Len(aLivro)+1
          AAdd(aLivro,Array(Len(aLivro[1])))
	      For nY := 1 To Len(aLivro[1])
    	  	aLivro[nE, nY] := Criavar(aLivro[1, nY])
          Next
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
          aLivro[nE,_IdxF14]:= "V"  
          aLivro[nE,_IdxF16]:= "N"
          If _IdxF28<>0
             aLivro[nE,_IdxF28]:=0.00
          Endif
          if _IdxF29<>0
             aLivro[nE,_IdxF29]:=SF4->F4_CF
          endif   
          if _IdxF30<>0
             aLivro[nE,_IdxF30]:=SF4->F4_CODIGO
          endif  
          if _IdxF31<>0
             aLivro[nE,_IdxF31]:=aItemInfo[7]  
          endif                      
       endif
		nPosBase:=AScan(aLivro[1],{|x| x=="F3_BASIMP"+aImpostos[nX][17]})
		nPosValr:=AScan(aLivro[1],{|x| x=="F3_VALIMP"+aImpostos[nX][17]})
		aLivro[nE,nPosBase]:=If(aLivro[nE,nPosBase]==Nil,0,aLivro[nE,nPosBase])+aImpostos[nX,3]
		aLivro[nE,nPosAliq]:=aImpostos[nX,2]
		aLivro[nE,nPosValr]:=if(aLivro[nE,nPosValr]==Nil,0,aLivro[nE,nPosValr])+aImpostos[nX,4]

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³No caso de moeda extrangeira, deve-se converter para moeda local³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
		
	   If nMoedaCor > 1
       	  nMoedaBase  := xMoeda(aLivro[nE,nPosBase],nMoedaCor,1,NIL,,nTaxaMd)
          nMoedaValor := xMoeda(aLivro[nE,nPosValr],nMoedaCor,1,NIL,,nTaxaMd)
	      nMoedaTotal := xMoeda(aImpostos[nX,3],nMoedaCor,1,NIL,,nTaxaMd)
	   Else
       	  nMoedaBase  := Round(aLivro[nE,nPosBase],MsDecimais(nMoedaCor))
          nMoedaValor := Round(aLivro[nE,nPosValr],MsDecimais(nMoedaCor))
	      nMoedaTotal := Round(aImpostos[nX,3],MsDecimais(nMoedaCor))
	   EndIf
	   aLivro[nE,nPosBase]:=nMoedaBase
	   aLivro[nE,nPosValr]:=nMoedaValor        

		//+---------------------------------------------------------------------+
        //¦Soma os impostos incidentes no campo F3_VALCONT.                     ¦
        //+---------------------------------------------------------------------+
       If Subs(aImpostos[nX][5],2,1)=="1" //si es incidente en la nota fiscal
	      aLivro[nE,_IdxF02] := aLivro[nE,_IdxF02] + nMoedaValor
	   ElseIf Subs(aImpostos[nX][5],2,1)=="2" 
	      aLivro[nE,_IdxF02] := aLivro[nE,_IdxF02] - nMoedaValor
	   Endif
    Endif   
next
if len(aLivro)>1
   If ne != NIL
      aLivro[nE,_IdxF02]:=aLivro[nE,_IdxF02]+nMoedaTotal
   Endif   
endif

Return( aLivro )        
