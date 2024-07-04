#include "Protheus.ch"
#include "msgraphi.ch"
#Include "VEIPGFN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIP010  ³ Autor ³ ANDRE                 ³ Data ³ 20/07/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Painel de Venda de Pecas por condicao de Pagamento         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Tipo      ³ 1   | Filtro |                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIP010()
    
Local ni
Local aRetPanel := {}
Local aRet := OFIOC280( "B" , "1" , "1" , , )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenche array do Painel de Gestao                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For ni := 1 to Len(aRet)
	aAdd( aRetPanel, {aRet[ni,1], Transform(aRet[ni,2],"@E 999,999"), CLR_HRED, ,/*bClick*/ } )
Next

if Len(aRet) = 0 
	aAdd( aRetPanel, {"", "", CLR_HRED, ,/*bClick*/ } )
Endif

Return(aRetPanel)


Function VEIP020()
    
Local ni
Local aRetPanel := {}
Local aRet := OFIOC280( "B" , "1" , "2" , , )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenche array do Painel de Gestao                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For ni := 1 to Len(aRet)
	aAdd( aRetPanel, {aRet[ni,1], Transform(aRet[ni,2],"@E 999,999"), CLR_HRED, ,/*bClick*/ } )
Next

if Len(aRet) = 0 
	aAdd( aRetPanel, {"", "", CLR_HRED, ,/*bClick*/ } )
Endif

Return(aRetPanel)

Function VEIP030()
    
Local ni, nx
Local aCab      := {STR0001,STR0002,STR0003} //Finalizados # Nao Finalizados # Cancelados
Local aVal      := {}
Local aTabela   := {}
Local aRetPanel := {}
Local aRet      := OFIOC280( "V" , "1" , "1" , , )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenche array do Painel de Gestao                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aVal    := {0,0,0}
aTabela := {{STR0001,{STR0004,STR0005}, {} },;	//Finalizados",{Valor Modelo"
            {STR0002,{STR0004,STR0005}, {} },;	//Nao Finalizados",{Valor Modelo"
            {STR0003,{STR0004,STR0005}, {} }}	//Cancelados",{Valor",modelo"

For ni := 1 to Len(aRet)
	aVal[1] += aRet[ni,2]
	aVal[2] += aRet[ni,3]
	aVal[3] += aRet[ni,4]
	if aRet[ni,2] > 0
      aadd(aTabela[1,3],{Str(aRet[ni,2],5),substr(aRet[ni,1],1,10)})
   Endif   
	if aRet[ni,3] > 0
      aadd(aTabela[2,3],{Str(aRet[ni,3],5),substr(aRet[ni,1],1,10)})
   Endif   
	if aRet[ni,4] > 0
      aadd(aTabela[3,3],{Str(aRet[ni,4],5),substr(aRet[ni,1],1,10)})
   Endif   
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Complementa o array com informacoes nulas, caso nao haja informacao p/ ser exibida³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aRetPanel := 	{ GRP_PIE, {STR0007, /*{|| ONCLICKG()}*/, aCab, aVal },;	//Atendimentos por modelo
					{ STR0008, /*{|| ONCLICKG()}*/, aTabela }}	//Modelos


if Len(aRet) = 0
	aTabela := {  { "",{ ""  } , {   {""} ,  {"" } ,  {"" }  }  }  ,; 
	              { "", { "" } , {   {""} ,  {"" } ,  {"" }  }  } }

	aRetPanel := {  GRP_PIE, ;
	{ "", {|| ONCLICKG}, {""} , {0}  } , ;
	{ "", {|| ONCLICKT},  aTabela  }  } 
Endif   

Return(aRetPanel)


Function VEIP040()
    
Local ni, nx
Local aCab      := {STR0001,STR0002,STR0003} //Finalizados # Nao Finalizados # Cancelados
Local aVal      := {}
Local aTabela   := {}
Local aRetPanel := {}
Local aRet      := OFIOC280( "V" , "1" , "2" , , )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenche array do Painel de Gestao                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aVal    := {0,0,0}
aTabela := {{STR0001,{STR0006,STR0005}, {} },; //Finalizados {"Qtdade Modelo"
            {STR0002,{STR0006,STR0005}, {} },; //Nao Finalizados {"Qtdade Modelo
            {STR0003,{STR0006,STR0005}, {} }} //Cancelados {"Qtdade Modelo

For ni := 1 to Len(aRet)
	aVal[1] += aRet[ni,2]
	aVal[2] += aRet[ni,3]
	aVal[3] += aRet[ni,4]
	if aRet[ni,2] > 0
      aadd(aTabela[1,3],{Str(aRet[ni,2],5),substr(aRet[ni,1],1,10)})
   Endif   
	if aRet[ni,3] > 0
      aadd(aTabela[2,3],{Str(aRet[ni,3],5),substr(aRet[ni,1],1,10)})
   Endif   
	if aRet[ni,4] > 0
      aadd(aTabela[3,3],{Str(aRet[ni,4],5),substr(aRet[ni,1],1,10)})
   Endif   
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Complementa o array com informacoes nulas, caso nao haja informacao p/ ser exibida³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

if Len(aRet) = 0
	aTabela := {  { "",{ ""  } , {   {""} ,  {"" } ,  {"" }  }  }  ,; 
	              { "", { "" } , {   {""} ,  {"" } ,  {"" }  }  } }

	aRetPanel := {  GRP_PIE, ;
	{ "", {|| ONCLICKG}, {""} , {0}  } , ;
	{ "", {|| ONCLICKT},  aTabela  }  } 
Else   
	aRetPanel := 	{ GRP_PIE, {STR0007, /*{|| ONCLICKG()}*/, aCab, aVal },;  //Atendimentos por modelo"
						{ STR0008, /*{|| ONCLICKG()}*/, aTabela }} //"Modelos
Endif

Return(aRetPanel)


Function VEIP050()
    
Local ni
Local aRetPanel := {}
Local aRet := OFIOC280( "B" , "2" , "1" , , )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenche array do Painel de Gestao                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For ni := 1 to Len(aRet)
	aAdd( aRetPanel, {aRet[ni,1], Transform(aRet[ni,2],"@E 999,999"), CLR_HRED, ,/*bClick*/ } )
Next

if Len(aRet) = 0 
	aAdd( aRetPanel, {"", "", CLR_HRED, ,/*bClick*/ } )
Endif

Return(aRetPanel)


Function VEIP060()
    
Local ni
Local aRetPanel := {}
Local aRet := OFIOC280( "V" , "2" , "2" , , )

if Len(aRet) = 0 
	aAdd( aRetPanel, {"", "", CLR_HRED, ,/*bClick*/ } )
	Return (aRetPanel)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenche array do Painel de Gestao                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For ni := 1 to Len(aRet)
	aAdd( aRetPanel, {aRet[ni,1], Transform(aRet[ni,2],"@E 999,999"), CLR_HRED, ,/*bClick*/ } )
Next

if Len(aRet) = 0 
	aAdd( aRetPanel, {"", "", CLR_HRED, ,/*bClick*/ } )
Endif

Return(aRetPanel)


Function VEIP070()
    
Local ni
Local aRetPanel := {}
Local aRet := OFIOC280( "O" , "2" , "1" , , )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenche array do Painel de Gestao                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For ni := 1 to Len(aRet)
	aAdd( aRetPanel, {aRet[ni,1], Transform(aRet[ni,2]+aRet[ni,3],"@E 999,999"), CLR_HRED, ,/*bClick*/ } )
Next

if Len(aRet) = 0 
	aAdd( aRetPanel, {"", "", CLR_HRED, ,/*bClick*/ } )
Endif

Return(aRetPanel)

Function VEIP080()
    
Local ni
Local aRetPanel := {}
Local aRet := OFIOC280( "O" , "2" , "1" , , )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenche array do Painel de Gestao                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For ni := 1 to Len(aRet)
	aAdd( aRetPanel, {aRet[ni,1], Transform(aRet[ni,3],"@E 999,999"), CLR_HRED, ,/*bClick*/ } )
Next

if Len(aRet) = 0 
	aAdd( aRetPanel, {"", "", CLR_HRED, ,/*bClick*/ } )
Endif

Return(aRetPanel)


Function VEIP090()
    
Local ni
Local aRetPanel := {}
Local aRet := OFIOC280( "O" , "2" , "1" , , )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenche array do Painel de Gestao                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For ni := 1 to Len(aRet)
	aAdd( aRetPanel, {aRet[ni,1], Transform(aRet[ni,2],"@E 999,999"), CLR_HRED, ,/*bClick*/ } )
Next

if Len(aRet) = 0 
	aAdd( aRetPanel, {"", "", CLR_HRED, ,/*bClick*/ } )
Endif

Return(aRetPanel)
