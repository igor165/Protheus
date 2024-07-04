#include "protheus.ch"
//#include "veiva650.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunฦo    ณ veiva650 ณ Autor ณ  Rafael Goncalves     ณ Data ณ 28/05/10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriฦo ณ Acordo de F&I                                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Generico                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function veiva650()
Private aCampos := {}
Private aRotina := MenuDef()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define o cabecalho da tela de atualizacoes                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
PRIVATE cCadastro := OemToAnsi("Acordo de F&I") //Acordo de F&I	  
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Endereca a funcao de BROWSE                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
mBrowse( 6, 1,22,75,"VZU")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOA650V    บAutor  ณRafael Goncalves    บ Data ณ  27/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVisualizar                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OA650V(cAlias,nReg,nOpc)

CAMPOA650()
AxVisual(cAlias,nReg,nOpc,aCampos)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOA650I    บAutor  ณRafael Goncalves    บ Data ณ  27/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณIncluir                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OA650I(cAlias,nReg,nOpc)
PRIVATE aMemos  := {{"VZU_OBSMEM","VZU_OBSERV"}}

CAMPOA650()
AxInclui(cAlias,nReg,nOpc,aCampos)

//if (AxInclui(cAlias,nReg,nOpc,aCampos)) == 1     // RETIRADO, POIS NAO GRAVA O MEMO (DELETAVA TODA VEZ)
//	RegToMemory("VZU",.T.)                         // BOBY - 24/01/11
//	DbSelectArea("VZU")
//	RecLock("VZU",.f.)
//	MSMM(VZU->VZU_OBSMEM,TamSx3("VZU_OBSERV")[1],,&(aMemos[1][2]),1,,,"VZU","VZU_OBSMEM") 
//	MsUnlock()
//EndIf         
 
Return                                                                             	

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOA650C    บAutor  ณRafael Goncalves    บ Data ณ  27/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Consulta                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function OA650C(cAlias,nReg,nOpc)

//variaveis controle de janela
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {} 
Local aSizeAut := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntTam := 0     
Local aAcorFI := {}
Local dPerIni := ctod("")
Local dPerFim := ctod("")
Local dDatIni := ctod("")
Local dDatFim := ctod("")

// Configura os tamanhos dos objetos 							
aObjects := {}
AAdd( aObjects, { 05, 39 , .T. , .F. } ) 	//Cabecalho			
AAdd( aObjects, { 01, 10 , .T. , .T. } )  	//list box 			
//AAdd( aObjects, { 05, 12 , .T. , .F. } )  	//Rodape 			
//AAdd( aObjects, { 1, 10, .T. , .T. } )  //list box superior	
//AAdd( aObjects, { 10, 10, .T. , .F. } )  //list box inferior 	
//tamanho para resolucao 1024*768 								
//aSizeAut[3]:= 508     										
//aSizeAut[5]:= 1016            								
// Fator de reducao de 0.8                       				
for nCntTam := 1 to Len(aSizeAut)           					
	aSizeAut[nCntTam] := INT(aSizeAut[nCntTam] * 0.8)  			
next     														

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)    
        
If Len(aAcorFI) <= 0
	aAdd(aAcorFI,{"","","","","",""})
EndIf

DEFINE MSDIALOG oAcorFI TITLE "Consulta Acordo de F&I" FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL //Consulta Acordo de F&I

@ aPosObj[1,1]+004,aPosObj[1,2]+002 TO aPosObj[1,3]-002,aPosObj[1,2]+090 LABEL ("Acordo") OF oAcorFI PIXEL 		
// DATA INICIAL ACORDO//
@ aPosObj[1,1]+013,aPosObj[1,2]+006 SAY "Data Inicio" SIZE 50,8 OF oAcorFI PIXEL COLOR CLR_BLUE //Per. Vigencia
@ aPosObj[1,1]+022,aPosObj[1,2]+006 MSGET oPerIni VAR dPerIni PICTURE "@D" SIZE 38,08 OF oAcorFI PIXEL COLOR CLR_BLACK HASBUTTON
// DATA FINAL ACORDO //
@ aPosObj[1,1]+013,aPosObj[1,2]+048 SAY "Data Final" SIZE 50,8 OF oAcorFI PIXEL COLOR CLR_BLUE // Data  Final
@ aPosObj[1,1]+022,aPosObj[1,2]+048 MSGET oPerFim VAR dPerFim VALID(IIF(dPerIni>dPerFim,dPerFim:=dPerIni,.T.)) PICTURE "@D" SIZE 38,08 OF oAcorFI PIXEL COLOR CLR_BLACK HASBUTTON

@ aPosObj[1,1]+005,aPosObj[1,2]+100 TO aPosObj[1,3]-002,aPosObj[1,2]+200 LABEL ("Vigencia") OF oAcorFI PIXEL 		
// DATA INICIAL //
@ aPosObj[1,1]+013,aPosObj[1,2]+110 SAY "Data Inicial" SIZE 50,8 OF oAcorFI PIXEL COLOR CLR_BLUE // Data  Final
@ aPosObj[1,1]+022,aPosObj[1,2]+110 MSGET oDatIni VAR dDatIni VALID(IIF(dDatIni>dDatFim,dDatFim:=dDatIni,.T.)) PICTURE "@D" SIZE 38,08 OF oAcorFI PIXEL COLOR CLR_BLACK HASBUTTON
// DATA FINAL //
@ aPosObj[1,1]+013,aPosObj[1,2]+152 SAY "Data Final" SIZE 50,8 OF oAcorFI PIXEL COLOR CLR_BLUE // Data  Final
@ aPosObj[1,1]+022,aPosObj[1,2]+152 MSGET odatFim VAR dDatFim VALID(IIF(dDatIni>dDatFim,.F.,.T.)) PICTURE "@D" SIZE 38,08 OF oAcorFI PIXEL COLOR CLR_BLACK HASBUTTON

@ aPosObj[1,1]+020,aPosObj[1,4]-056 BUTTON oFiltro PROMPT OemToAnsi("Filtrar") OF oAcorFI SIZE 48,10 PIXEL ACTION (FS_FILTRAR(dPerIni,dPerFim,dDatIni,dDatFim,@aAcorFI))


// MARCA //
@ aPosObj[2,1]+004,aPosObj[2,2]+1 LISTBOX oLbMar FIELDS HEADER "Cod. do Acordo","Data do Acordo","Banco","Dat Ini Coef.","Dat Fim Coef.","Valor do Acordo" COLSIZES 55,55,100,55,55,90 SIZE aPosObj[2,4]-002,aPosObj[2,3]-aPosObj[2,1]-004 OF oAcorFI PIXEL ON DBLCLICK (FS_FECHAR(	aAcorFI[oLbMar:nAt,1] ))

oLbMar:SetArray(aAcorFI)
oLbMar:bLine := { || { 	aAcorFI[oLbMar:nAt,1] ,;
						aAcorFI[oLbMar:nAt,2] ,;
						aAcorFI[oLbMar:nAt,3] ,;
						aAcorFI[oLbMar:nAt,4] ,;
						aAcorFI[oLbMar:nAt,5] ,;
						FG_AlinVlrs(Transform(aAcorFI[oLbMar:nAt,6],"@E 999,999,999.99")) }}
                                           
ACTIVATE MSDIALOG oAcorFI CENTER ON INIT (EnchoiceBar(oAcorFI,{|| oAcorFI:End(),.f.},{ || oAcorFI:End()},,))
Return
 
 
 /*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_FECHAR บAutor  ณRafael Goncalves    บ Data ณ  31/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Posiciona no Regsitro e fecha a janela                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cCodAco - Codigo do acordo                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/  
Static Function FS_FECHAR(cCodAco)
DbSelectArea("VZU")
DbSetOrder(1)
DbSeek(xFilial("VZU")+cCodAco)
oAcorFI:End()
Return    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_FILTRARบAutor  ณRafael Goncalves    บ Data ณ  31/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza o filtro                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ dPerIni - Data Inciial do acordo                           บฑฑ
ฑฑบ          ณ dPerFim - Data Final do Acordo                             บฑฑ
ฑฑบ          ณ dDatIni - Data Inicial da Vigencia                         บฑฑ
ฑฑบ          ณ dDatFim - Data Final da Vigencia                           บฑฑ
ฑฑบ          ณ aAcorFI - Array dos acordos no periodo.                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Static Function FS_FILTRAR(dPerIni,dPerFim,dDatIni,dDatFim,aAcorFI)
Local cQuery  := ""
Local cQAlSQL := "ALIASSQL" 
Local cNomBco := "" 
aAcorFI:= {}

cQuery := "SELECT VZU.* , VAS.* , VAR.* "
cQuery += "FROM "+RetSqlName("VZU")+" VZU "
cQuery    += "INNER JOIN "+RetSqlName("VAS")+" VAS ON (VAS.VAS_FILIAL='"+xFilial("VAS")+"' AND VAS.VAS_CODACO=VZU.VZU_CODACO AND VAS.D_E_L_E_T_=' ') "
cQuery    += "LEFT JOIN "+RetSqlName("VAR")+" VAR ON (VAR.VAR_FILIAL='"+xFilial("VAR")+"' AND VAR.VAR_CODIGO=VAS.VAS_CODIGO AND VAR.D_E_L_E_T_=' ') "

cQuery += "WHERE VZU.VZU_FILIAL='"+xFilial("VZU")+"' AND "
If !Empty(dPerIni)
	cQuery += "VZU.VZU_DATACO >= '"+dtos(dPerIni)+"' AND "
EndIf 
If !Empty(dPerFim)
	cQuery += "VZU.VZU_DATACO <= '"+dtos(dPerFim)+"' AND "
EndIf	
If !Empty(dDatIni)
	cQuery += "VAS.VAS_DATINI >= '"+dtos(dDatIni)+"' AND "
EndIf	
If !Empty(dDatFim)
	cQuery += "VAS.VAS_DATFIN <= '"+dtos(dDatFim)+"' AND "
EndIf			   
cQuery += "VZU.D_E_L_E_T_=' ' ORDER BY VZU.VZU_CODACO"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
While !( cQAlSQL )->( Eof() )
	cNomBco := ""  
            DbSelectArea("SA6")
	DbSetOrder(1)
	IF DbSeek(xFilial("SA6")+( cQAlSQL )->( VAR_CODBCO ))
       	cNomBco := " - "+SA6->A6_NOME
	EndIf

	aAdd(aAcorFI, {	( cQAlSQL )->( VZU_CODACO ) ,;//Cod. do Acordo
					Transform(stod(( cQAlSQL )->( VZU_DATACO )),"@D") ,;//Data do acordo
					( cQAlSQL )->( VAR_CODBCO )+cNomBco,;//banco
					Transform(stod(( cQAlSQL )->( VAS_DATINI )),"@D") ,;//data vigencia inicial
					Transform(stod(( cQAlSQL )->( VAS_DATFIN )),"@D") ,;//adta vigencia final
					( cQAlSQL )->( VZU_VALACO )  } )//valor do acordo.
	
	( cQAlSQL )->( DbSkip() )
EndDo
( cQAlSQL )->( dbCloseArea() )

If Len(aAcorFI) <= 0
	aAdd(aAcorFI,{"","","","","",""} )
EndIf 
oLbMar:SetArray(aAcorFI)
oLbMar:bLine := { || { 	aAcorFI[oLbMar:nAt,1] ,;
						aAcorFI[oLbMar:nAt,2] ,;
						aAcorFI[oLbMar:nAt,3] ,;
						aAcorFI[oLbMar:nAt,4] ,;
						aAcorFI[oLbMar:nAt,5] ,;
						FG_AlinVlrs(Transform(aAcorFI[oLbMar:nAt,6],"@E 999,999,999.99")) }}
						
						
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCAMPOA650 บAutor  ณRafael Goncalves    บ Data ณ  27/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Leavnta campos usados                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CAMPOA650()

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VZU")
aCampos := {}

do While !eof() .and. x3_arquivo == "VZU"

   If X3USO(x3_usado).and.cNivel>=x3_nivel 
   
      aadd(aCampos,x3_campo)
      
   EndIf
      
   DbSkip()
   
Enddo 

DbSelectArea("VZU")

Return       

Static Function MenuDef()
Local aRotina := { { "Pesquisar" ,"AxPesqui", 0 , 1} ,;  // Pesquisar
                      { "Visualizar" ,"OA650V", 0 , 2},;  // Visualizar
                      { "Incluir" ,"OA650I", 0 , 3},;  // Incluir
                      { "Consultar" ,"OA650C", 0 , 4}}   // Consultar
Return aRotina
