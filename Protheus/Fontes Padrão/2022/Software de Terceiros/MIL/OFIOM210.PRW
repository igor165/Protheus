#INCLUDE "ofiom210.ch"
#Include "PROTHEUS.CH"  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunฦo    ณ OFIOM210 ณ Autor ณ  Fabio                ณ Data ณ 17/08/99 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriฦo ณ Importa orcamento p/ oficina                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Generico                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OFIOM210

Local aCores := {{'VS1->VS1_DATVAL >= dDataBase .And. Empty(VS1->VS1_NUMOSV)','ENABLE'},; // disponivel
					  {'!VS1->VS1_DATVAL >= dDataBase .or. !Empty(VS1->VS1_NUMOSV)','DISABLE'}} // nao disponivel
Local aIndVS1   := {} // Fabio 
Local cCondicao := "" // Fabio
Local aArea     := GetArea() // Fabio             
Private bFiltraBrw := {|| Nil} // Fabio
PRIVATE aCampos := {}
PRIVATE aRotina := MenuDef()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define o cabecalho da tela de atualizacoes                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
PRIVATE cCadastro := OemToAnsi(STR0004) //Dados do Veiculo para oficina //"Importacao do Orcamento Oficina"

DbSelectArea("VS1")
dbSetOrder(5)
            
cCondicao += "VS1->VS1_FILIAL == xFilial() .AND. VS1->VS1_TIPORC == '2'" // Fabio

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Endereca a funcao de BROWSE                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

bFiltraBrw := {|| FilBrowse("VS1",@aIndVS1,@cCondicao) } // Fabio
Eval(bFiltraBrw) // Fabio

//mBrowse( 6, 1,22,75,"VS1",,,,,,aCores,'om210Top()','om210Bottom()')
mBrowse( 6, 1,22,75,"VS1",,,,,,aCores)

//DbSelectArea("VS1")     Fabio
//DbsetOrder(1)           Fabio
dbSelectArea("VS1")       // Fabio
RetIndex("VS1")           // Fabio
dbClearFilter()           // Fabio
aEval(aIndVS1,{|x| Ferase(x[1]+OrdBagExt())}) // Fabio
RestArea(aArea)   // Fabio

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOM210TEL  บAutor  ณFabio               บ Data ณ  07/07/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava importacao                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณOficina                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM210TEL(cAlias,nReg,nOpc)                                            

Local lMarcar  := .f. , nImp := 0 
Private lMovto := ( GetNewPar("MV_RITEORC","N") == "S" )
Private aOsAbert := {} , aSrv := {} , aPeca := {} , aImpFatPar:={}
Private oLbOsAbert , oLbSrv , oLbPeca
Private oOk := LoadBitmap( GetResources(), "LBTIK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )
Private oVermelho := LoadBitmap( GetResources(), "BR_VERMELHO" )
                      

If !VS1->VS1_DATVAL >= dDataBase .or. !Empty(VS1->VS1_NUMOSV)
	 Help(" ",1,"DOCINVALID")
	 Return .F.
Endif	 
                      
&& Servicos
DbSelectArea("SA1")
DbSetOrder(1)
DbSeek( xFilial("SA1") +  VS1->VS1_CLIFAT + VS1->VS1_LOJA )

DbSelectArea("VS4")
DbSetOrder(1)
DbSeek(xFilial("VS4")+VS1->VS1_NUMORC)
Do While !Eof() .And. VS4->VS4_FILIAL == xFilial("VS4") .And. VS4->VS4_NUMORC == VS1->VS1_NUMORC
                   
   DbSelectArea("VO6")
   DbSetOrder(2)
   DbSeek( xFilial("VO6") + FG_MARSRV( VS1->VS1_CODMAR, VS4->VS4_CODSER ) + VS4->VS4_CODSER )

   Aadd( aSrv , { .f. , VS1->VS1_TIPTEM , VS1->VS1_CLIFAT , VS1->VS1_LOJA , SA1->A1_NOME , VS4->VS4_GRUSER , VS4->VS4_CODSER , VO6->VO6_DESSER , VS4->VS4_TIPSER , VS4->VS4_TEMPAD , VS4->VS4_KILROD , VS4->VS4_VALTOT } )      
        
   DbSelectArea("VS4")
   DbSkip()   
   
EndDo

If Len(aSrv) == 0
   Aadd( aSrv , { .f. , "" , "" , "" , "" , "" , "" , "" , "" , 0 , 0 , 0 } )      
EndIf

&& Pecas
DbSelectArea("VS3")
DbSetOrder(1)
DbSeek(xFilial("VS3")+VS1->VS1_NUMORC)
Do While !Eof() .And. VS3->VS3_FILIAL == xFilial("VS3") .And. VS3->VS3_NUMORC == VS1->VS1_NUMORC

   DbSelectArea("SB1")
   DbSetOrder(7)
   DbSeek( xFilial("SB1") + VS3->VS3_GRUITE + VS3->VS3_CODITE )

   Aadd( aPeca , { .f. , VS1->VS1_TIPTEM , VS1->VS1_CLIFAT , VS1->VS1_LOJA , SA1->A1_NOME , VS3->VS3_GRUITE , VS3->VS3_CODITE , SB1->B1_DESC , VS3->VS3_QTDITE , VS3->VS3_FORMUL , FG_VALPEC(VS1->VS1_TIPTEM,"VS3->VS3_FORMUL",VS3->VS3_GRUITE,VS3->VS3_CODITE,,.f.,.t. ) , .t. } )

   DbSelectArea("VS3")
   DbSkip()   
   
EndDo     

If Len(aPeca) == 0
   Aadd( aPeca , { .f. , "" , "" , "" , "" , "" , "" , "" , 0 , "" , 0 , .t. } )
EndIf

&& Os Abertas
DbSelectArea("VO1")
DbSetOrder(2)

If !DbSeek( xFilial("VO1") + "A" )
         
   Help("  ",1,"OSNABERENC")
   Return

EndIf

Do While !Eof() .And. VO1->VO1_FILIAL == xFilial("VO1") .And. VO1->VO1_STATUS == "A"
                                         
   DbSelectArea("VV1")
   DbSetOrder(1)
   DbSeek( xFilial("VV1") + VO1->VO1_CHAINT )

   DbSelectArea("VV2")
   DbSetOrder(1)
   DbSeek( xFilial("VV2") + VV1->VV1_CODMAR + VV1->VV1_MODVEI )

   DbSelectArea("SA1")
   DbSetOrder(1)
   DbSeek( xFilial("SA1") +  VV1->VV1_PROATU + VV1->VV1_LJPATU )
           
	aImpFatPar := {"","",""}
	FG_TIPTPFAT(VS1->VS1_TIPTEM,"aImpFatPar[1]","aImpFatPar[2]","aImpFatPar[3]",VS1->VS1_CODMAR,,,,.f.)

	If !Empty(aImpFatPar[1])

		For nImp := 1 To Len(aSrv)
			aSrv[nImp,3] := aImpFatPar[1]
			aSrv[nImp,4] := aImpFatPar[2]
			aSrv[nImp,5] := aImpFatPar[3]
		Next	        
	
		For nImp := 1 To Len(aPeca)
			aPeca[nImp,3] := aImpFatPar[1]
			aPeca[nImp,4] := aImpFatPar[2]
			aPeca[nImp,5] := aImpFatPar[3]
		Next	        

	EndIf

   Aadd( aOsAbert , { .f. , VO1->VO1_NUMOSV , VV1->VV1_CHASSI , VV1->VV1_CODMAR , VV1->VV1_MODVEI , VV2->VV2_DESMOD , VV1->VV1_PROATU , VV1->VV1_LJPATU , SA1->A1_NOME , aClone(aSrv) , aClone(aPeca) } )

   DbSelectArea("VSJ")
   DbSetOrder(1)
                                           
	&& Se a peca ja foi importada marca flag para nao importar denovo
	For nImp := 1 To Len( aOsAbert[Len(aOsAbert),11] )

	   If DbSeek( xFilial("VSJ") +  VO1->VO1_NUMOSV + aOsAbert[Len(aOsAbert),11,nImp,6] + aOsAbert[Len(aOsAbert),11,nImp,7] )
      
			aOsAbert[Len(aOsAbert),11,nImp,12] := .f.

		EndIf
			
	Next

   DbSelectArea("VO1")
   DbSkip()   
   
EndDo

If Len(aOsAbert) == 0
  
   Aadd( aOsAbert , { .f. , "" , "" , "" , "" , "" , "" , "" , "" , aClone(aSrv) , aClone(aPeca) } )

Else

	Asort(aOsAbert,1,,{|x,y|x[2] > y[2]})

EndIf                                                               
       
DEFINE MSDIALOG oDlgOrc TITLE STR0004 From 3,0 to 32,083 of oMainWnd //"Importacao do Orcamento Oficina"

@ 001, 006 CHECKBOX oRPecas VAR lMarcar PROMPT STR0005 ; //"Marcar"
                           OF oDlgOrc ;
                           ON CLICK FS_CHECK(lMarcar) ;
                           SIZE 40,10 PIXEL 

@ 011,003 TO 091,325 LABEL STR0006 OF oDlgOrc PIXEL //"Ordem de Servico"
                     
@ 021,006 LISTBOX oLbOsAbert FIELDS HEADER  OemToAnsi(""),; 
                                             OemToAnsi(STR0007),; //"Nro da OS"
                                             OemToAnsi(STR0008),; //"Chassi"
                                             OemToAnsi(STR0009),; //"Marca"
                                             OemToAnsi(STR0010),; //"Modelo"
                                             OemToAnsi(STR0011),; //"Descricao"
                                             OemToAnsi(STR0012),; //"Proprietario"
                                             OemToAnsi(STR0013),; //"Loja"
                                             OemToAnsi(STR0014); //"Nome"
   COLSIZES 10,30,60,20,40,60,30,20,60 ;
   SIZE 315,64 OF oDlgOrc ON DBLCLICK FS_TIK( oLbOsAbert:nAt ) ;
                          ON CHANGE (oLbSrv:SetFocus(),oLbPeca:SetFocus(),oLbOsAbert:SetFocus()) PIXEL
                        
oLbOsAbert:SetArray(aOsAbert)
oLbOsAbert:bLine := { || { If( aOsAbert[oLbOsAbert:nAt,1] , oOk , oNo ) ,;
                            aOsAbert[oLbOsAbert:nAt,2] ,;
                            aOsAbert[oLbOsAbert:nAt,3] ,;
                            aOsAbert[oLbOsAbert:nAt,4] ,;
                            aOsAbert[oLbOsAbert:nAt,5] ,;
                            aOsAbert[oLbOsAbert:nAt,6] ,;
                            aOsAbert[oLbOsAbert:nAt,7] ,;
                            aOsAbert[oLbOsAbert:nAt,8] ,;
                            aOsAbert[oLbOsAbert:nAt,9] }}
oLbOsAbert:cReadVar := "oLbOsAbert"
oLbOsAbert:bGotFocus := {|| oLbSrv:nClrPane := CLR_HGRAY , oLbPeca:nClrPane := CLR_HGRAY , oLbOsAbert:nClrPane := CLR_WHITE }

@ 090,003 TO 198,325 LABEL STR0015 OF oDlgOrc PIXEL //"Orcamento"

@ 095,005 TO 193,162 LABEL STR0016 OF oDlgOrc PIXEL //"Servico"

@ 100,009 LISTBOX oLbSrv FIELDS HEADER  OemToAnsi(""),; 
                                         OemToAnsi(STR0017),; //"Grupo"
                                         OemToAnsi(STR0018),; //"Codigo"
                                         OemToAnsi(STR0011),; //"Descricao"
                                         OemToAnsi(STR0019),; //"Tp"
                                         OemToAnsi(STR0020),; //"Faturar Para"
                                         OemToAnsi(STR0013),; //"Loja"
                                         OemToAnsi(STR0014),; //"Nome"
                                         OemToAnsi(STR0021),; //"Tp Srv"
                                         OemToAnsi(STR0022),; //"Tp Padrao"
                                         OemToAnsi(STR0023); //"Km Rodado"
   COLSIZES 10,15,50,50,10,30,15,50,20,40,40 ;
   SIZE 149,89 OF oDlgOrc ON DBLCLICK FS_TIK( oLbSrv:nAt ) PIXEL

oLbSrv:SetArray(aSrv)
oLbSrv:bLine := { || { If( aOsAbert[oLbOsAbert:nAt,10,oLbSrv:nAt,1] , oOk , oNo )  ,;
                        aOsAbert[oLbOsAbert:nAt,10,oLbSrv:nAt,6] ,;
                        aOsAbert[oLbOsAbert:nAt,10,oLbSrv:nAt,7] ,;
                        aOsAbert[oLbOsAbert:nAt,10,oLbSrv:nAt,8] ,;
                        aOsAbert[oLbOsAbert:nAt,10,oLbSrv:nAt,2] ,;
                        aOsAbert[oLbOsAbert:nAt,10,oLbSrv:nAt,3] ,;
                        aOsAbert[oLbOsAbert:nAt,10,oLbSrv:nAt,4] ,;
                        aOsAbert[oLbOsAbert:nAt,10,oLbSrv:nAt,5] ,;
                        aOsAbert[oLbOsAbert:nAt,10,oLbSrv:nAt,9] ,;
                        Transform(aOsAbert[oLbOsAbert:nAt,10,oLbSrv:nAt,10],"@R 99:99") ,;
                        Transform(aOsAbert[oLbOsAbert:nAt,10,oLbSrv:nAt,11],"@E 999,999,999") }}

oLbSrv:cReadVar := "oLbSrv"
oLbSrv:bGotFocus := {|| oLbOsAbert:nClrPane := CLR_HGRAY , oLbPeca:nClrPane := CLR_HGRAY , oLbSrv:nClrPane := CLR_WHITE }

@ 095,165 TO 193,323 LABEL STR0024 OF oDlgOrc PIXEL //"Peca"

@ 180,168 CHECKBOX oRMovto VAR lMovto PROMPT STR0025 ; //"Importa pecas para o reservado?"
                           OF oDlgOrc ;
                           SIZE 100,10 PIXEL 

@ 100,168 LISTBOX oLbPeca FIELDS HEADER  OemToAnsi(""),; 
                                          OemToAnsi(STR0017),; //"Grupo"
                                          OemToAnsi(STR0018),; //"Codigo"
                                          OemToAnsi(STR0011),; //"Descricao"
                                          OemToAnsi(STR0019),; //"Tp"
                                          OemToAnsi(STR0020),; //"Faturar Para"
                                          OemToAnsi(STR0013),; //"Loja"
                                          OemToAnsi(STR0014),; //"Nome"
                                          OemToAnsi(STR0026),; //"Quantidade"
                                          OemToAnsi(STR0027),; //"Formula"
                                          OemToAnsi(STR0028); //"Valor"
   COLSIZES 10,20,50,50,10,30,15,50,30,30,30 ;
   SIZE 152,79 OF oDlgOrc ON DBLCLICK FS_TIK( oLbPeca:nAt ) PIXEL

oLbPeca:SetArray(aPeca)
oLbPeca:bLine := { || { If( !aOsAbert[oLbOsAbert:nAt,11,oLbPeca:nAt,12] , oVermelho , If( aOsAbert[oLbOsAbert:nAt,11,oLbPeca:nAt,1] , oOk , oNo ) ) ,;
                         aOsAbert[oLbOsAbert:nAt,11,oLbPeca:nAt,6] ,;
                         aOsAbert[oLbOsAbert:nAt,11,oLbPeca:nAt,7] ,;
                         aOsAbert[oLbOsAbert:nAt,11,oLbPeca:nAt,8] ,;
                         aOsAbert[oLbOsAbert:nAt,11,oLbPeca:nAt,2] ,;
                         aOsAbert[oLbOsAbert:nAt,11,oLbPeca:nAt,3] ,;
                         aOsAbert[oLbOsAbert:nAt,11,oLbPeca:nAt,4] ,;
                         aOsAbert[oLbOsAbert:nAt,11,oLbPeca:nAt,5] ,;
                         Transform(aOsAbert[oLbOsAbert:nAt,11,oLbPeca:nAt,9],"@E 999,999,999") ,;
                         aOsAbert[oLbOsAbert:nAt,11,oLbPeca:nAt,10] ,;
                         Transform(aOsAbert[oLbOsAbert:nAt,11,oLbPeca:nAt,11],"@E 99,999,999.99") }}

oLbPeca:cReadVar := "oLbPeca"
oLbPeca:bGotFocus := {|| oLbSrv:nClrPane := CLR_HGRAY , oLbOsAbert:nClrPane := CLR_HGRAY , oLbPeca:nClrPane := CLR_WHITE }

DEFINE SBUTTON FROM 202,240 TYPE 1 ACTION If(OM210IMP(cAlias,nReg,nOpc),oDlgOrc:End(),.f.) ENABLE OF oDlgOrc
DEFINE SBUTTON FROM 202,280 TYPE 2 ACTION oDlgOrc:End() ENABLE OF oDlgOrc
                  
ACTIVATE MSDIALOG oDlgOrc CENTER

VS1->(DbSetOrder(5))
Return                             

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_CHECK  บAutor  ณFabio               บ Data ณ  09/27/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMarca tik em tados as linhas                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_CHECK(lMarcar)

Local ni := 0

For ni := 1 to Len(aOsAbert)           

   FS_TIK( ni , Upper("oLbOsAbert") )

Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_TIK()  บAutor  ณFabio               บ Data ณ  09/22/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMarca tik                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_TIK( nReg , cVarMem )

Local ni := 0 

Default cVarMem := ReadVar()

If cVarMem == Upper("oLbOsAbert")

   aOsAbert[ nReg , 1 ] := !aOsAbert[ nReg , 1 ]
   
   For ni := 1 to Len( aOsAbert[nReg,10] )
   
   	If !Empty( aOsAbert[nReg,10,ni,7] )
   
	      aOsAbert[nReg,10,ni,1] := aOsAbert[nReg,1] 
	      
		EndIf
      
   Next   

   For ni := 1 to Len( aOsAbert[nReg,11] )
      
   	&& Nao deixa marca se a peca ja tenha sido importada para a OS.
   	If aOsAbert[nReg,11,ni,12] .And. !Empty( aOsAbert[nReg,11,ni,6] ) .And. !Empty( aOsAbert[nReg,11,ni,7] )

	      aOsAbert[nReg,11,ni,1] := aOsAbert[nReg,1] 
   	
   	EndIf
      
   Next   
   
Else
                    
   If cVarMem == Upper("oLbSrv") 
   
   	If Empty( aOsAbert[oLbOsAbert:nAt,10,nReg,7] )

			Return
			   
   	EndIf

      aOsAbert[oLbOsAbert:nAt,10,nReg,1] := !aOsAbert[oLbOsAbert:nAt,10,nReg,1]
   	   
   EndIf   

   If cVarMem == Upper("oLbPeca") 
           
   	&& Nao deixa marca se a peca ja tenha sido importada para a OS.
   	If !aOsAbert[oLbOsAbert:nAt,11,nReg,12]                     

			Help("  " , 1 , "VPECJAIMP")
			   	
   		Return
   	
   	EndIf

   	If Empty( aOsAbert[oLbOsAbert:nAt,11,nReg,6] ) .Or. Empty( aOsAbert[oLbOsAbert:nAt,11,nReg,7] )

			Return
			   
   	EndIf

      aOsAbert[oLbOsAbert:nAt,11,nReg,1] := !aOsAbert[oLbOsAbert:nAt,11,nReg,1]

   EndIf
   
   aOsAbert[oLbOsAbert:nAt,1] := .f.

   For ni := 1 to Len( aOsAbert[oLbOsAbert:nAt,10] )
       
       If aOsAbert[oLbOsAbert:nAt,10,ni,1]
       
          aOsAbert[oLbOsAbert:nAt,1] := .t.
          
          Exit
          
       EndIf
          
   Next

   For ni := 1 to Len( aOsAbert[oLbOsAbert:nAt,11] )
       
       If aOsAbert[oLbOsAbert:nAt,11,ni,1]
       
          aOsAbert[oLbOsAbert:nAt,1] := .t.
          
          Exit
          
       EndIf
          
   Next

EndIf

oLbSrv:SetFocus()
oLbPeca:SetFocus()
oLbOsAbert:SetFocus() 

cVarMem+=":SetFocus()"
&(cVarMem)
 
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOM210IMP  บAutor  ณFabio               บ Data ณ  07/07/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava importacao                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณOficina                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM210IMP(cAlias,nReg,nOpc)

Local    ni := 0 , __nReg := 0
Local    nValTotal := 0 , nQtdReg := 0 , aImpFatPar:={}

aImpFatPar:={"","","",""}

For ni := 1 to Len(aOsAbert)
    
    If aOsAbert[ni,1]
         
       For __nReg := 1 to Len(aOsAbert[ni,10])
           
          If aOsAbert[ni,10,__nReg,1]
                
				 aImpFatPar[1] := aOsAbert[ni,10,__nReg,3]
				 aImpFatPar[2] := aOsAbert[ni,10,__nReg,4]
				 aImpFatPar[3] := aOsAbert[ni,10,__nReg,5]
				 aImpFatPar[4] := aOsAbert[ni,10,__nReg,2]

             nValTotal := nValTotal + aOsAbert[ni,10,__nReg,12]
               
             nQtdReg++
           
          EndIf
       
       Next
    
       For __nReg := 1 to Len(aOsAbert[ni,11])
           
          If aOsAbert[ni,11,__nReg,1]
                
				 aImpFatPar[1] := aOsAbert[ni,11,__nReg,3]
				 aImpFatPar[2] := aOsAbert[ni,11,__nReg,4]
				 aImpFatPar[3] := aOsAbert[ni,11,__nReg,5]
				 aImpFatPar[4] := aOsAbert[ni,11,__nReg,2]

             nValTotal := nValTotal + ( aOsAbert[ni,11,__nReg,9] * aOsAbert[ni,11,__nReg,11] )

             nQtdReg++
           
          EndIf
       
       Next
    
		 If !FG_FATSP(aImpFatPar[4],aImpFatPar[1]+aImpFatPar[2],"x",,.f.,,,,,,, aOsAbert[ni,2] )
          Help(" ",1,"FATPARSP")                                      
			    
		  	 Return(.f.)                                                                        
			   
		 EndIf   
   
    EndIf

Next
   
If Empty(GetMv("MV_CPNCLC")) .Or. Empty(VS1->VS1_FORPAG) .Or. AllTrim(GetMv("MV_CPNCLC")) <> Alltrim(VS1->VS1_FORPAG)

	If "I" $ GetMv("MV_CHKCRE") .And. !(Posicione("VOI",1,xFilial("VOI")+VS1->VS1_TIPTEM,"VOI_SITTPO") $ "2/3")
	
		If !MaAvalCred(aImpFatPar[1],aImpFatPar[2], nValTotal + FG_AVALCRED( aImpFatPar[1] , aImpFatPar[2] ) ,1,.T.)   
		   
		  Help(" ",1,"LIMITECRED")
		  Return(.f.)
		     
		EndIf                       
	
	EndIf

EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria variaveis M->????? da GetDados                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RegToMemory("VO1",.T.)
RegToMemory("VO2",.T.)
RegToMemory("VO3",.T.)
RegToMemory("VO4",.T.)
   
nQtdReg := nQtdReg + 2

&& Grava Ordem de servico VO1
Processa( { || FS_GRVO1( nQtdReg , nOpc )  } )
   
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GRVO1  บAutor  ณFabio               บ Data ณ  07/07/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava Ordem de servico VO1                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณOficina                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                   
Static Function FS_GRVO1( nQtdReg , nOpc )
   
Local ni := 0 , nCntFor := 0 , nItens := 0

&& Variavei da impressao

Local cAlias , cNomeRel , cGPerg , cTitulo , cDesc1 , cDesc2 := cDesc3 := "" , aOrdem := {} , lHabil , cTamanho
Private lMsFinalAuto := .f.
Private aReturn  := { OemToAnsi(STR0029), 1,OemToAnsi(STR0030), 2, 2, 2,,1 }
Private titulo,cabec1,cabec2,nLastKey:=0,wnrel
Private aItensNImp := {}
Private lMsErroAuto := .f. , lMsHelpAuto := .t.
Private lCriouVSJ := .f.
                        
aItensNImp:={}               
Aadd(aItensNImp , {} )  && 1 - Cabecalho do listbox
Aadd(aItensNImp , {} )  && 2 - Itens do listbox
                  
DbSelectArea("VSJ")
For nItens := 1 to FCount()
			
	Aadd(aItensNImp[1] , FieldName(nItens) )
			
Next      

Aadd(aItensNImp[1] , "B1_DESC" )
Aadd(aItensNImp[1] , "B1_LOCPAD" )

ProcRegua( nQtdReg ) 

lMsErroAuto := .F.
Begin Transaction

   For ni := 1 to Len(aOsAbert)

      If aOsAbert[ni,1]
                              
         DbSelectArea("VO1" ) 
         DbSetOrder(1)
         DbSeek( xFilial("VO1") + aOsAbert[ni,2] )
                 
			For nCntFor := 1 TO FCount()
			    &( "M->"+FieldName(nCntFor) ) := FieldGet(nCntFor)
			Next

			DbSelectArea("SX3")      
			DbSetOrder(1)
			DbSeek("VO1")
			Do While !Eof() .And. x3_Arquivo == "VO1"
			              
			   If x3_context == "V"
				   &("M->"+x3_campo) := CriaVar(x3_campo)
				EndIf   
			   
			   DbSelectArea("SX3")      
			   DbSkip()
			
			EndDo                
    
         DbSelectArea("VV1")              
         DbSetOrder(1)
         DbSeek( xFilial("VV1") + VS1->VS1_CHAINT )
           
         && Marca Status do Box
         && FS_POEBOX()     

			lCriouVSJ := .f.

			// Reposiciona na OS (variavel carregada na Abertura da OS (apos Importacao do Orcamento para a OS) // 
			If Type("GrvNoOS_") # "U"
	         DbSelectArea("VO1")              
   	      DbSetOrder(1)
      	   DbSeek( xFilial("VO1") + GrvNoOS_ )
			EndIf

         && Grava Servico
         && Grava Servicos Requisitados
         FS_GRVO4( aOsAbert[ni,10] , nOpc ) 
	         
			// Reposiciona na OS (variavel carregada na Abertura da OS (apos Importacao do Orcamento para a OS) // 
			If Type("GrvNoOS_") # "U"
	         DbSelectArea("VO1")              
   	      DbSetOrder(1)
      	   DbSeek( xFilial("VO1") + GrvNoOS_ )
			EndIf

         && Grava Pecas
         && Grava Pecas Requisitadas
         If !FS_GRVJS( aOsAbert[ni,11],@aItensNImp )
         	DisarmTransaction()
         	Break
         Endif	
         
         If lCriouVSJ
	         DbSelectArea("VS1")  
   	      RecLock("VS1",.F.)
					VS1->VS1_VPERDI := "0"
	      	   VS1->VS1_NUMOSV := VO1->VO1_NUMOSV
//					VS1->VS1_NUMOSV := aOsAbert[ni,2]
	         MsUnLock()
				If VO1->(FieldPos("VO1_NUMORC")) > 0
					If Empty(VO1->VO1_NUMORC)
						DbSelectArea("VO1")
						RecLock("VO1",.F.)
							VO1->VO1_NUMORC := VS1->VS1_NUMORC
						MsUnLock()
					EndIf
				EndIf
   		Else
   			MsgAlert(STR0043 +" "+ CHR(13)+CHR(10)+CHR(13)+CHR(10)+" "+ STR0044 +" "+ VO1->VO1_NUMOSV +" "+ STR0045,STR0034) //Nao foi possivel importar os itens para a OS.###Favor importar novamente para a OS ### ja existente.#Atencao 
   		EndIf
   		
			IncProc( OemtoAnsi( STR0029 ) )    //Gerando Ordem de Servico
      
      	&& Imprime a ordem de servico
			FG_PEDORD(VO1->VO1_NUMOSV,"N","S")
      
      EndIf  

   Next
   
End Transaction   
lMsHelpAuto := .f. 


If !lMsErroAuto

	&& Relatorio das pecas que nao estao no estoque
	If Len(aItensNImp[2]) # 0 .And. MsgYesNo(OemToAnsi(STR0033),OemToAnsi(STR0034)) //Pecas sem saldo suficiente! Imprimir relacao de pecas?###Atencao!

		cAlias   := Alias()
		cNomeRel := "ORCNIMPORT"
		cGPerg   := ""
		cTitulo  := STR0035 //Pecas do orcamento nao transferido para o reservado.
		cDesc1   := cDesc2 := cDesc3 := ""
		lHabil   := .f.
		cTamanho := "P"
		
		cNomeRel := SetPrint(cAlias,cNomeRel,,@cTitulo,cDesc1,cDesc2,cDesc3,lHabil,,,cTamanho)
		
		If nlastkey == 27
		   Return(Allwaystrue())
		EndIf
		
		SetDefault(aReturn,cAlias)
		
		RptStatus( { |lEnd| FS_IMPORCPEC( aItensNImp , cNomeRel ) } )

	EndIf
	                  
Else
     
	MostraErro()

EndIf

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GRVO4  บAutor  ณFabio               บ Data ณ  07/07/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava Sevicos da Ordem de Servico VO4                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณOficina                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                   
Static Function FS_GRVO4( aItens , nOpc )
             
Local ni := 0
Local nx_ := 0
Private aHeaderSrv := {} , aHeaderIniFim := {} , aHeader := {}
                        
If Ascan( aItens , { |x| x[1] == .t. } ) == 0

   Return      

EndIf	              

&& Grava Cabecalho de Servico
IncProc( OemtoAnsi( STR0030 ) )    //Gerando Cabecalho Ordem de Servico

DbSelectArea("VO2")
DbSetOrder(1)
DbSeek(xFilial("VO2") + VO1->VO1_NUMOSV + "S" )

DbSelectArea("SX3")      
DbSetOrder(1)
DbSeek("VO2")
Do While !Eof() .And. x3_Arquivo == "VO2"
   
   &("M->"+x3_campo) := CriaVar(x3_campo)
                        
	If Alltrim(x3_campo) $ "VO2_NOSNUM" 
	   &( "M->"+Alltrim(x3_campo) ) := If(!VO2->(Found()),GetSxeNum("VO2",x3_campo) , VO2->VO2_NOSNUM )
		ConfirmSx8()
	EndIf
   
   DbSelectArea("SX3")      
   DbSkip()

EndDo  

&& Monta aHeader's
FS_MTAHEADER()
                                               
aColsSrv := {} 
aColsIniFim := {} 
aCols := {}

&& Servicos           
DbSelectArea("VO4")
DbSetOrder(4)

For ni := 1 to Len(aItens)

   If aItens[ni,1] .And. !DbSeek( xFilial("VO4") + aItens[ni,07] + M->VO2_NOSNUM )

		lCriouVSJ := .t.

      Aadd( aColsSrv , Array(Len(aHeaderSrv)+1) )      
              
      aColsSrv[Len(aColsSrv), FG_POSVAR("VO4_TIPTEM","aHeaderSrv") ] := aItens[ni,02]
      aColsSrv[Len(aColsSrv), FG_POSVAR("VO4_FATPAR","aHeaderSrv") ] := aItens[ni,03]
      aColsSrv[Len(aColsSrv), FG_POSVAR("VO4_LOJA"  ,"aHeaderSrv") ] := aItens[ni,04]
      aColsSrv[Len(aColsSrv), FG_POSVAR("VO4_GRUSER","aHeaderSrv") ] := aItens[ni,06]
      aColsSrv[Len(aColsSrv), FG_POSVAR("VO4_CODSER","aHeaderSrv") ] := aItens[ni,07]
      aColsSrv[Len(aColsSrv), FG_POSVAR("VO4_TIPSER","aHeaderSrv") ] := aItens[ni,09]
      aColsSrv[Len(aColsSrv), FG_POSVAR("VO4_TEMPAD","aHeaderSrv") ] := aItens[ni,10]
      aColsSrv[Len(aColsSrv), FG_POSVAR("VO4_KILROD","aHeaderSrv") ] := aItens[ni,11]
      If Len(aItens[ni]) >= 12
	      aColsSrv[Len(aColsSrv), FG_POSVAR("VO4_VALVEN","aHeaderSrv") ] := aItens[ni,12]
      EndIf
      aColsSrv[Len(aColsSrv), Len(aColsSrv[Len(aColsSrv)]) ]        := .F.

      For nx_ := 1 to Len(aHeaderSrv)
   
          If aColsSrv[Len(aColsSrv),nx_] == NIL
             aColsSrv[Len(aColsSrv),nx_] := CriaVar(aHeaderSrv[nx_,2])
          EndIf
       
      Next

      Aadd( aColsIniFim , Array(Len(aHeaderIniFim)+1) )      
              
      aColsIniFim[Len(aColsIniFim), FG_POSVAR("VO4_GRUSER","aHeaderIniFim") ] := aItens[ni,06]
      aColsIniFim[Len(aColsIniFim), FG_POSVAR("VO4_CODSER","aHeaderIniFim") ] := aItens[ni,07]
      aColsIniFim[Len(aColsIniFim), Len(aColsIniFim[Len(aColsIniFim)]) ]     := .F.

      For nx_ := 1 to Len(aHeaderIniFim)
   
          If aColsIniFim[Len(aColsIniFim),nx_] == NIL
             aColsIniFim[Len(aColsIniFim),nx_] := CriaVar(aHeaderIniFim[nx_,2])
          EndIf
       
      Next
   
   EndIf   

   IncProc( OemtoAnsi( STR0031 ) )    //Importando Servicos

Next
     
If Len(aColsSrv) # 0

   && Grava Servicos
   FS_GRSRVs(.t.)
    
EndIf   

Return                  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GRVJS  บAutor  ณFabio               บ Data ณ  07/07/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava Pecas   da Ordem de Servico VO3                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณOficina                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                   
Static Function FS_GRVJS( aItens )

&& variaveis da gravacao                  
Local aItensNew := {}
Local aDisponivel := {} , ni := 0 
Local nItens := 0
Local lIncAlt := .t.
Private n := 1

&& Pecas
For ni := 1 to Len(aItens)

   DbSelectArea("VSJ")
   DbSetOrder(1)
   DbSeek( xFilial("VSJ") + VO1->VO1_NUMOSV + aItens[ni,6] + aItens[ni,7] )
	lIncAlt := .t.
	Do While !Eof() .And. VSJ->VSJ_FILIAL+VSJ->VSJ_NUMOSV+VSJ->VSJ_GRUITE+VSJ->VSJ_CODITE == xFilial("VSJ") + VO1->VO1_NUMOSV + aItens[ni,6] + aItens[ni,7]
              
		If VSJ->VSJ_NUMORC == VS1->VS1_NUMORC
			lIncAlt := .f.
			Exit	                               
		EndIf

	   DbSelectArea("VSJ")
	   DbSkip()

	EndDo

   DbSelectArea("SB1")
   DbSetOrder(7)
   DbSeek( xFilial("SB1") + aItens[ni,6] + aItens[ni,7] )
 
   DbSelectArea("VSJ")

   If aItens[ni,1] 
   
		lCriouVSJ := .t.
	   DbSelectArea("VSJ")
   
//      RecLock("VSJ", !Found() )
      RecLock("VSJ", lIncAlt )

      VSJ->VSJ_FILIAL := xFilial("VSJ")
      VSJ->VSJ_NUMORC := VS1->VS1_NUMORC
      VSJ->VSJ_NUMOSV := VO1->VO1_NUMOSV
      VSJ->VSJ_GRUITE := aItens[ni,6]
      VSJ->VSJ_CODITE := aItens[ni,7]
      VSJ->VSJ_QTDITE := aItens[ni,9]
      VSJ->VSJ_PROIMP := Posicione("VAI",4,xFilial("VAI") + __cUserID , "VAI_CODUSR" )
      VSJ->VSJ_ORIDAD := "2"
		VSJ->VSJ_RESPEC := "0"
                  
		DbSelectArea("SB2")
		DbSetOrder(1)
		DbSeek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD)
	   Aadd( aDisponivel, SaldoSB2() )
//      aDisponivel := CalcEst(SB1->B1_COD,SB1->B1_LOCPAD,dDataBase+1)

	   DbSelectArea("VSJ")

      If aItens[ni,9] > aDisponivel[len(aDisponivel)]   		&& Monta vetor com itens que nao foram para o almoxarifado reservado  MV_RESITE

			Aadd(aItensNImp[2] , {} )
			For nItens := 1 to FCount()
			
				Aadd(aItensNImp[2,Len(aItensNImp[2])] , FieldGet(nItens) )
			
			Next      

			Aadd(aItensNImp[2,Len(aItensNImp[2])] , SB1->B1_DESC )
			Aadd(aItensNImp[2,Len(aItensNImp[2])] , SB1->B1_LOCPAD )
		EndIf
		
      If lMovto		&& Movto peca
      
			If !Empty(aDisponivel[len(aDisponivel)]) .And. aItens[ni,9] <= aDisponivel[len(aDisponivel)]						&& itens que foram para o almoxarifado reservado  MV_RESITE

				VSJ->VSJ_RESPEC := "1"
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณMovimentacao interna do Item                                         ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู         
				aItensNew:={}             
				
				DbSelectArea("SB5")
				DbSetOrder(1)
				DbSeek( xFilial("SB5") + SB1->B1_COD )
				
				DbSelectArea("SB1")
				DbSetOrder(1)
				
				//
				// Adiciona cabecalho com numero do documento e data da transferencia modelo II
				//
				aadd (aItensNew,{ nextnumero("SD3",2,"D3_DOC",.t.), ddatabase})
				                   
				// sequencia								               			 
				// produto, descricao, unidade de medida, local/localizacao origem
				// produto, descricao, unidade de medida, local/localizacao destino
				// numero de serie, lote, sublote, data de validade, qunatidade
				// quantidade na 2 unidade, estorno, numero de sequencia
				//
				//
								
				aadd ( aItensNew,{ SB1->B1_COD, SB1->B1_DESC, SB1->B1_UM, SB1->B1_LOCPAD , IIf(Localiza(SB1->B1_COD),SB5->B5_LOCALIZ,Space(15)) ,;
				                    SB1->B1_COD, SB1->B1_DESC, SB1->B1_UM, GetMv( "MV_RESITE" )+Space(TamSx3("BF_LOCAL")[1]-Len(GetMv("MV_RESITE"))) , IIf(Localiza(SB1->B1_COD),GetMv( "MV_RESLOC" )+Space(TamSx3("BF_LOCALIZ")[1]-Len(GetMv("MV_RESLOC"))),Space(15)) ,;
 											  VSJ->VSJ_NUMSER , VSJ->VSJ_LOTECT , VSJ->VSJ_NUMLOT   ,;
   	                             criavar('D3_DTVALID'), criavar('D3_POTENCI'), VSJ->VSJ_QTDITE , criavar("D3_QTSEGUM")   ,;
      	                          criavar("D3_ESTORNO"), criavar("D3_NUMSEQ"), criavar("D3_LOTECTL"), criavar("D3_DTVALID"), criavar("D3_ITEMGRD")} )

				MSExecAuto({|x| MATA261(x)},aItensNew)       	    
				
				If lMsErroAuto            
				   && Cancela Gravacao
				   DisarmTransaction()
				   Break
				EndIf            
						        
	      EndIf

		EndIf

      MsUnLock()
      
	EndIf
	
   IncProc( OemtoAnsi( STR0007 ) )   

Next

If ExistBlock("IMPORCVSJ")
	ExecBlock("IMPORCVSJ",.f.,.f.,{VO1->VO1_NUMOSV})
Endif
       
Return( !lMsErroAuto )
   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_IMPORCPบAutor  ณFabio               บ Data ณ  04/03/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime pecas que nao foram para reservado                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_IMPORCPEC( aItens , cNomeRel )	
      
Local bTitulo   := {|cCampo| SX3->(DbSetOrder(2)) , If( SX3->( DbSeek( cCampo ) ) , X3Titulo() , "" )  }
Local bConteudo := {|cCampo| Ascan( aItens[1] , cCampo )  }
      
Local nLin := 0 , i := 0 
Private cbTxt , cbCont , cString , Li , m_Pag , wnRel , cTitulo , cabec1 , cabec2 , nomeprog , tamanho , nCaracter := 0 

Set Printer to &cNomeRel
Set Printer On
Set device to Printer

cbTxt    := Space(10)
cbCont   := 0
cString  := Alias()
Li       := 80
m_Pag    := 1

wnRel    := "OFIOM210"

cTitulo:= STR0036 //Pecas do orcamento nao transferido para o reservado. 
cabec1 := Eval(bTitulo,"VSJ_NUMORC") + aItens[2,1,Eval(bConteudo,"VSJ_NUMORC")]
cabec2 := Substr( Eval(bTitulo,"VSJ_NUMOSV") , 1 , 10 )+ " " + Substr( Eval(bTitulo,"VSJ_GRUITE") , 1,5) + " " + Eval(bTitulo,"VSJ_CODITE") +Space(16)+ Eval(bTitulo,"B1_DESC") +Space(10)+ Substr( Eval(bTitulo,"VSJ_QTDITE"),1,7) + " " + Substr( Eval(bTitulo,"B1_LOCPAD") ,1,5)

NomeProg := "ORCNIMPORT"
tamanho:="P"
nCaracter:=15

For i := 1 to Len(aItens[2])
      
	If nLin == 0
		nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
	EndIf      
	
   @ nLin++,0 PSAY aItens[2,i,Eval(bConteudo,"VSJ_NUMOSV")] + Space(3) + aItens[2,i,Eval(bConteudo,"VSJ_GRUITE")] + Space(2) + aItens[2,i,Eval(bConteudo,"VSJ_CODITE")] + Space(1) + Substr( aItens[2,i,Eval(bConteudo,"B1_DESC")] ,1,15) +Space(3)+ Transform( aItens[2,i,Eval(bConteudo,"VSJ_QTDITE")] , "@E 999,999,999")  + Space(4) + aItens[2,i,Eval(bConteudo,"B1_LOCPAD")] 

	If nLin >= 63
		
		nLin := 0
			
	EndIf
       
Next

Eject

Set Printer to
Set device to Screen

MS_FLUSH()

If aReturn[5] == 1
     
	OurSpool(cNomeRel)	

EndIf

return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VOLIMP บAutor  ณFabio               บ Data ณ  04/04/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVolta importacao                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                    
Function FS_VOLIMP(cAlias,nReg,nOpc)
      
Local lMarcar  := .f. 
Private aPecas := {}
Private oLbPecas , oLbPeca
Private oOk := LoadBitmap( GetResources(), "LBTIK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )
                      
&& Servicos
DbSelectArea("VSJ")
DbSetOrder(2)
DbSeek( xFilial("VSJ") +  VS1->VS1_NUMORC )

Do While !Eof() .And. VSJ->VSJ_FILIAL == xFilial("VSJ") .And. VSJ->VSJ_NUMORC == VS1->VS1_NUMORC
                                             
//	If VSJ->VSJ_RESPEC == "1"                   
                   
	   DbSelectArea("SB1")
	   DbSetOrder(7)
	   DbSeek( xFilial("SB1") + VSJ->VSJ_GRUITE + VSJ->VSJ_CODITE )
	
	   Aadd( aPecas , { .f. , VSJ->VSJ_NUMOSV , VSJ->VSJ_GRUITE , VSJ->VSJ_CODITE , SB1->B1_DESC , VSJ->VSJ_QTDITE , VSJ->VSJ_PROIMP , VSJ->VSJ_LOTECT , VSJ->VSJ_NUMLOT , VSJ->VSJ_NUMSER , VSJ->VSJ_RESPEC } )

//	EndIf
        
   DbSelectArea("VSJ")
   DbSkip()   
   
EndDo

If Len( aPecas ) # 0

	DEFINE MSDIALOG oDlgOrc TITLE STR0037 From 3,0 to 32,083 of oMainWnd //Volta pecas importadas para o reservado
	
	@ 005,003 TO 200,325 LABEL STR0038 OF oDlgOrc PIXEL //Pecas
	                     
	@ 010,006 LISTBOX oLbPecas FIELDS HEADER  OemToAnsi(""),; 
	                                           OemToAnsi(STR0039),; //Nro OS
	                                           OemToAnsi(STR0017),; //Grupo
	                                           OemToAnsi(STR0040),; //Codigo Item
	                                           OemToAnsi(STR0011),; //Descricao
	                                           OemToAnsi(STR0026),; //Quantidade
	                                           OemToAnsi(STR0041); //Prod Imp
	   COLSIZES 10,30,30,60,80,60,60;
	   SIZE 315,184 OF oDlgOrc ON DBLCLICK aPecas[oLbPecas:nAt,1] := !aPecas[oLbPecas:nAt,1] PIXEL
	                        
	oLbPecas:SetArray(aPecas)
	oLbPecas:bLine := { || { If( aPecas[oLbPecas:nAt,1] , oOk , oNo ) ,;
	                            aPecas[oLbPecas:nAt,2] ,;
	                            aPecas[oLbPecas:nAt,3] ,;
	                            aPecas[oLbPecas:nAt,4] ,;
	                            aPecas[oLbPecas:nAt,5] ,;
	                            aPecas[oLbPecas:nAt,6] ,;
	                            aPecas[oLbPecas:nAt,7] }}
	
	DEFINE SBUTTON FROM 202,240 TYPE 1 ACTION ( Processa( { || FS_MVPEC() } ) , oDlgOrc:End() ) ENABLE OF oDlgOrc
	DEFINE SBUTTON FROM 202,280 TYPE 2 ACTION oDlgOrc:End() ENABLE OF oDlgOrc
	                  
	ACTIVATE MSDIALOG oDlgOrc CENTER

EndIf
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_MVPEC  บAutor  ณFabio               บ Data ณ  04/03/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMovimenta peca para o reservado                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_MVPEC()
                                      
Local cMailConta , cMailServer , cMailSenha , lOk := .f. , lSendOk := .f.
Local nImp := 0 , nAdd := 0 , nRegProcess := 0
Local aItensNew := {} , aEmail := {}
Private lMsErroAuto := .f. , lMsHelpAuto := .t., lMsFinalAuto := .f.
Private n := 1
                      
ProcRegua( Len(aPecas) ) 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMovimentacao interna do Item                                         ณ
//ณ                                                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	                         
Begin Transaction
	            
	For nImp := 1 to Len(aPecas)	
	
		If aPecas[nImp,1]      

			nAdd := 0		                                       
			If Len(aEmail) # 0
			
				nAdd := Ascan( aEmail , {|x| x[1] == aPecas[nImp,7]+"#" } )
   
   		EndIf
   		          
			If Len(aEmail) == 0 .Or. nAdd == 0
			
				aadd(aEmail , { aPecas[nImp,7]+"#" , {} })
				
				aadd(aEmail[Len(aEmail),2], STR0039+Space(1)+STR0017+Space(1)+STR0040+Space(15)+STR0011+Space(15)+STR0026) //Nro OS###Grupo###Codigo Item###Descricao###Quantidade

				nAdd := Len(aEmail)
		
			EndIf
			
			aadd(aEmail[nAdd,2], aPecas[nImp,2]+" "+aPecas[nImp,3]+" "+aPecas[nImp,4]+" "+aPecas[nImp,5]+" "+Transform(aPecas[nImp,6],"@E 999,999,999") )

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณMovimentacao interna do Item                                         ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู         
			If aPecas[nImp,11] == "1"

				aItensNew:={}             
				
			   DbSelectArea("SB1")
			   DbSetOrder(7)
			   DbSeek( xFilial("SB1") + aPecas[nImp,3] + aPecas[nImp,4] )
	
				DbSelectArea("SB5")
				DbSetOrder(1)
				DbSeek( xFilial("SB5") + SB1->B1_COD )
				
				DbSelectArea("SB1")
				DbSetOrder(1)
				
				//
				// Adiciona cabecalho com numero do documento e data da transferencia modelo II
				//
				aadd (aItensNew,{ nextnumero("SD3",2,"D3_DOC",.t.), ddatabase})
				                   
				// sequencia								               			 
				// produto, descricao, unidade de medida, local/localizacao origem
				// produto, descricao, unidade de medida, local/localizacao destino
				// numero de serie, lote, sublote, data de validade, qunatidade
				// quantidade na 2 unidade, estorno, numero de sequencia
				//
				//
								
				aadd ( aItensNew,{ SB1->B1_COD, SB1->B1_DESC, SB1->B1_UM, GetMv( "MV_RESITE" )+Space(TamSx3("BF_LOCAL")[1]-Len(GetMv("MV_RESITE"))) , IIf(Localiza(SB1->B1_COD),GetMv( "MV_RESLOC" )+Space(TamSx3("BF_LOCALIZ")[1]-Len(GetMv("MV_RESLOC"))) ,Space(15)) ,;
										  SB1->B1_COD, SB1->B1_DESC, SB1->B1_UM, SB1->B1_LOCPAD , IIf(Localiza(SB1->B1_COD),SB5->B5_LOCALIZ ,Space(15)) ,;
	                             aPecas[nImp,10] , aPecas[nImp,8] , aPecas[nImp,9]    ,;
	                             criavar('D3_DTVALID'), criavar('D3_POTENCI'), aPecas[nImp,6] , criavar("D3_QTSEGUM")   ,;
	                             criavar("D3_ESTORNO"), criavar("D3_NUMSEQ"), criavar("D3_LOTECTL")} )
	
				MSExecAuto({|x| MATA261(x)},aItensNew)       	    
				
				If lMsErroAuto            
				   && Cancela Gravacao
				   DisarmTransaction()
				   Break
				EndIf            

			EndIf            
		                   
			&& Se todos os itens foram cancelados apaga relacionamente com OS
			nRegProcess += 1                      
			If Len(aPecas) == nRegProcess
	         RecLock("VS1",.F.)
	         VS1->VS1_NUMOSV := Space(Len(VS1->VS1_NUMOSV))
	         MsUnLock()
			EndIf

			DbSelectArea("VSJ")
			DbSetOrder(1)
			If DbSeek( xFilial("VSJ") + aPecas[nImp,2] + aPecas[nImp,3] + aPecas[nImp,4] )
			
				// deletar ao inves de marcar como nao importada, pois na tentativa de importar
				// novamente, o sistema nao deixa porque ja existe o registro no VSJ
		      RecLock("VSJ", .f. )
				VSJ->(Dbdelete())
				//	VSJ->VSJ_RESPEC := "0"
		      MsUnLock()
		
			EndIf

		EndIf

		IncProc( OemtoAnsi("") )   
	
	Next

End Transaction
lMsHelpAuto := .f. 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณEnvia e-mail do Evento 003                                              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
// Obtem dados necessarios a conexao
cMailConta :=GETMV("MV_EMCONTA")
cMailServer:=GETMV("MV_RELSERV")
cMailSenha :=GETMV("MV_EMSENHA")

If Len( aEmail ) # 0 .And. !Empty(cMailServer) .And. !Empty(cMailConta) .And. !Empty(cMailSenha)

	// Conecta uma vez com o servidor de e-mails
//	CONNECT SMTP SERVER cMailServer ACCOUNT cMailConta PASSWORD cMailSenha RESULT lOk
	
	If lOk

		For nImp := 0 to Len(aEmail)
			
			// Envia e-mail com os dados necessarios
//			SEND MAIL FROM cMailConta to UsrRetMail(aEmail[nImp,1]) SUBJECT ("Pecas liberadas do orcamento pelo usuario "+UsrRetName(__cUserID)) BODY aEmail[nImp,2] FORMAT TEXT RESULT lSendOk 
			If !lSendOk
				//Erro no Envio do e-mail
//				GET MAIL ERROR cError
				MsgInfo(cError,OemToAnsi(STR0042)) // Erro no envio de e-Mail		 //Erro no envio de e-Mail
			EndIf
	
		Next 
	
		// Desconecta com o servidor de e-mails
//		DISCONNECT SMTP SERVER
	
	Else

		//Erro na conexao com o SMTP Server
//		GET MAIL ERROR cError
		MsgInfo(cError,OemToAnsi(STR0042)) // Erro no envio de e-Mail
	EndIf
	
EndIf

If lMsErroAuto
     
	MostraErro()
	
EndIf

Return( !lMsErroAuto )

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณOM210LEG   ณ Autor ณ Ricardo Farinelli    ณ Data ณ 11/12/01 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Cria uma janela contendo a legenda da mBrowse              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณVEIVM005                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM210LEG()
Local aLegenda := 	{{'ENABLE',STR0046},; 		//Disponivel para Importacao/Devolucao
					{'DISABLE',STR0047}}  		//Nao Disponivel para Importacao/Devolucao

BrwLegenda(cCadastro,"Legenda" ,aLegenda)

Return .T.

// Top do filtro da mbrowse
Function OM210Top()
Return xFilial("VS1")+"2"

// Bottom do filtro da mbrowse
Function OM210Bottom()
Return xFilial("VS1")+"2"

Static Function MenuDef()
Local aRotina := { { STR0001 ,"AxPesqui", 0 , 1},;   && Pesquisar //"Pesquisar"
                      { STR0002 ,"OM210TEL", 0 , 2},;   && Importar //"Importar"
                      { STR0003 ,"FS_VOLIMP", 0 , 3},;  &&  volta importacao //"Volta Imp"
	  						{ OemToAnsi(STR0048),"OM210LEG" , 0 , 2,0,.f.}} //Legenda		     
Return aRotina
