#include "SIGAWIN.CH"        // incluido pelo assistente de conversao do AP5 IDE em 09/09/99
#include "PROTHEUS.CH" 
#INCLUDE "TOPCONN.CH"   
#DEFINE _DEBUG   .F.   // Flag para Debuggear el codigo
#DEFINE _NOMIMPOST 01
#DEFINE _ALIQUOTA  02
#DEFINE _BASECALC  03
#DEFINE _IMPUESTO  04
#DEFINE _VLRTOTAL  3
#DEFINE _FLETE     4
#DEFINE _GASTOS    5
//Posicoes  do terceiro array recebido nos impostos a traves da matxfis...
#DEFINE X_IMPOSTO    01 //Nome do imposto
#DEFINE X_NUMIMP     02 //Sufixo do imposto 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ M100RFTE ³ Autor ³ Laura Medina Prado  ³ Data ³ 02.07.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Calculo do RFTE - Entrada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cPar01 - Solicitacao da MATXFIS, pondendo ser A (aliquota),³±±
±±³          ³          B (base), V (valor).                              ³±±
±±³          ³ nPar02 - Item do documento fiscal.                         ³±±
±±³          ³ aPar03 - Array com as informacoes do imposto.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ xRet - Retorna o valor solicitado pelo paremetro cPar01    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³ Uso      ³ MATXFIS                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador ³ Fecha  ³ Comentario                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Laura Medina ³22/11/13³ Se modifico para que tome el %Base de Cal por  ³±±
±±³             ³        ³ proveedor y con opción a cambiar desde la NF.  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function M100RFTE(cCalculo,nItem,aInfo) 

Local aRet
Local cFunct   := ""
Local aCountry := {}
Local lXFis    := .T.
Local aArea    := GetArea()

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Observacao :                                                  ³
³                                                               ³
³ a variavel ParamIxb tem como conteudo um Array[2], contendo : ³
³ [1,1] > Quantidade Vendida                                    ³
³ [1,2] > Preco Unitario                                        ³
³ [1,3] > Valor Total do Item, com Descontos etc...             ³
³ [1,4] > Valor do Frete Rateado para Este Item ...             ³
³ [1,5] > Array Contendo os Impostos já calculados, no caso de  ³
³         incidência de outros impostos.                        ³
³ [2,1] > Array aImposto, Contendo as Informações do Imposto que³
³         será calculado.                                       ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
	
lXFis    := ( MafisFound() .And. ProcName(1)!="EXECBLOCK" )
aCountry := GetCountryList()
cFunct   := "M100RFT" + aCountry[aScan( aCountry, { |x| x[1] == cPaisLoc } )][3] //Monta el nombre de la funcion
aRet     := &(cFunct)(cCalculo,nItem,aInfo,lXFis) //Ejecuta la funcion del pais

RestArea(aArea)

Return aRet    



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ M100RFTCO ³ Autor ³ Laura Medina        ³ Data ³ 03.07.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Calculo do IRF - Entrada                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cPar01 - Solicitacao da MATXFIS, pondendo ser A (aliquota), ³±±
±±³          ³          B (base), V (valor).                               ³±±
±±³          ³ nPar02 - Item do documento fiscal.                          ³±±
±±³          ³ aPar03 - Array com as informacoes do imposto.               ³±±
±±³          ³ lPar04 - Define se e rotina automaticao ou nao.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ xRet - Retorna o valor solicitado pelo paremetro cPar01     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Colombia                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


Function M100RFTCO(cCalculo,nItem,aInfo,lXFis)

Local xRet
Local cContrib  := ""
Local cLojaPro  := ""
Local cCodPro   := ""  
Local lFacEnt   := .F.    
Local nBaseRet  := 0 //Base de retencion Fuente
Local nBaseRUVT := 0 //Base de retencion Fuente en UVT
Local nMV_UVT   := SuperGetMv("MV_VALUVT",,26841) //Si no esta creado toma el valor por default
Local nPorcCal  := M->F1_TASARFT  //SuperGetMv("MV_TASARFT")

Private clTipo  := ""

SetPrvt("CALIASROT,CORDEMROT,AITEMINFO,AIMPOSTO,_CPROCNAME,_CZONCLSIGA")
SetPrvt("_LAGENTE,_LEXENTO,AFISCAL,_LCALCULAR,_LESLEGAL,_NALICUOTA,NALIQ")
SetPrvt("_NVALORMIN,_NREDUCIR,CTIPOEMPR,CTIPOCLI,CTIPOFORN,CZONFIS,CCFO,")
SetPrvt("CCLASCLI,CCLASFORN,CMVAGENTE,NPOSFORN,NPOSLOJA,NTOTBASE,LRETCF")

lRet    := .F.
lRetCF  := .T.
cAliasRot  := Alias()
cOrdemRot  := IndexOrd()
cTipo 	:= Iif( Type("cTipo")=="U","N",cTipo)
xRet	:=0  

lXFis:=(MaFisFound() .And. ProcName(1)<>"EXECBLOCK")
	
If !lXFis
	aItemINFO  := ParamIxb[1]
	aImposto   := ParamIxb[2]
	xRet:=aImposto
Else
	xRet:=0
Endif
nBase      := 0
clTipo	   := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Deve-se verificar se cEspecie pertence a NCC/NCE/NDC/NDE para que ocor-³
//³ra busca no SA1, caso contrario deve-se buscar no SA2(Arq.Proveedores) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipo = "D"   // devolucao de venda 
	cContrib    := SA1->A1_CONTRBE //CONTRIBUINTE    
	cAgRet      := SA1->A1_RETENED
Else
	cTipoCliFor := SA2->A2_TPESSOA
	cAgRet      := SA2->A2_RETENED
	cLojaPro    := SA2->A2_LOJA
	cCodPro     := SA2->A2_COD  
	If  ( Alltrim(cEspecie) == "NF" ) //Solo aplican facturas de entrada   
		lFacEnt := .T. 
	Endif
Endif

/*If  (cAgRet == "S") //Verificar si es agente retenedor                            
	lRetCF := .F.
Else
	lRetCF := .T.           
Endif    */                   
   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³             Verifica se Calcula Retencao en la Fuente:              ³
//³                        Cliente / Proveedor                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lFacEnt

	nBase    :=0
	nAliq    :=0
	nDesconto:=0
	nVRet    :=0
	aValRet  := {0,0}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifico no SFB existe SFB->ALIQ e nao apresenta tabela SFB->TABELA³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SFB")
	dbSetOrder(1)
	If dbSeek(xFilial("SFB")+aInfo[X_IMPOSTO])
		If  cCalculo$"ABV"  //Aliquota/Base		  
			nVal :=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
			nAliq:=SFB->FB_ALIQ		
			lRet := .F.
			If  Alltrim(aInfo[X_IMPOSTO])=="RFT"   //Burcar en la tabla el valor que le va a corresponder
				lRet := .T.						
			Else
				lRet:=.F.
			Endif
		Endif
	Endif

	If lRet
		Do Case     
			Case cCalculo=="A"      //Pendiente, sera el valor que le corresponda en la tabla
				nVRet:=nAliq
			Case cCalculo=="B"    
				nBase:= nVal
				nTaxaMoed := 0
				nMoeda := 1
			   	If Type("M->F1_MOEDA")<>"U" 			   	
				    nMoeda    := M->F1_MOEDA
				    nTaxaMoed := M->F1_TXMOEDA			
		        EndIf	        
		        nBaseAtu := xMoeda(nBase,nMoeda,1,Nil,Nil,nTaxaMoed)   
		             						
		        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   	   	//³Obtener la facturacion del mes y la retencion RFT      ³
		   	   	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
				aValRet := RetValFT(cLojaPro,cCodPro)
				//aValRet[01] = base acumulada
				//aValRet[02] = retencao acumulada 				
				aValRet[1] := xMoeda(aValRet[1],1,nMoeda,Nil,Nil,Nil, nTaxaMoed)
				aValRet[2] := xMoeda(aValRet[2],1,nMoeda,Nil,Nil,Nil, nTaxaMoed)  
				
				nBaseRet   := (nBaseAtu + aValRet[1]) * nPorcCal   //Valor Factura actual + Valor TOTAL de compras 		
				nVRet:= nBaseRet                                                                                   
			Case cCalculo$"V"
				nBase:= nVal		
				nTaxaMoed := 0
				nMoeda := 1
			   	If Type("M->F1_MOEDA")<>"U" 			   	
				    nMoeda    := M->F1_MOEDA
				    nTaxaMoed := M->F1_TXMOEDA			
		        EndIf	        
		        nBaseAtu := xMoeda(nBase,nMoeda,1,Nil,Nil,nTaxaMoed)   
		             						
		        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   	   	//³Obtener la facturacion del mes y la retencion RFT      ³
		   	   	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
				aValRet := RetValFT(cLojaPro,cCodPro)
				//aValRet[01] = base acumulada
				//aValRet[02] = retencao acumulada 				
				aValRet[1] := xMoeda(aValRet[1],1,nMoeda,Nil,Nil,Nil, nTaxaMoed)
				aValRet[2] := xMoeda(aValRet[2],1,nMoeda,Nil,Nil,Nil, nTaxaMoed)  
				
				nBaseRet   := (nBaseAtu + aValRet[1]) * nPorcCal   //Valor Factura actual + Valor TOTAL de compras 
				nBaseRUVT  := nBaseRet/ nMV_UVT   //Base de Retencion Fuente / Valor UVT 2013
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   	   	//³Obtener el valor valor UVT que le corresponde          ³
		   	   	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
				
				nVret := ObtUVT(nBaseRUVT,1)
				nVret := (IIf(nVret>0,nVret,0)  ) * nMV_UVT	   
				
				// Obtener el valor de retencion Acumulada (solo si hubo compras anteriores en el mes)	 
				If  aValRet[2]>0   //Hubo acumulado de Retencion
				    nVret := nVret - aValRet[2]
				Endif
					   						
		EndCase
	Endif                    
Endif

dbSelectArea( cAliasRot )
dbSetOrder( cOrdemRot )
Return(nVRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RETVALFT ºAutor  ³Laura Medina        º Data ³  03/07/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Busca el acumulado del impuesto y el valor acumulado de   º±±
±±º          ³  retencion RFT.                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Colombia                                                   º±±   
±±ºParam  	 ³ cImp: imposto											  º±± 
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Static Function RetValFT(cLoja,cProveedor)

Local cQueryNF := ""
Local aArea    := GetArea()
Local aRetNF   := {0,0}         
Local aRet     := {0,0}      
Local nTamEsp  := TAMSX3("F1_ESPECIE")[1]  
Local cSF1Esp  := Padr("NF",nTamEsp)
   			
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Seleciona el acumulado de retenciones del mes para las notas NF ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
	cQueryNF := " SELECT SUM(F1_VALMERC) SUMBASE, SUM(F1_VALIMP"+aInfo[X_NUMIMP]+") SUMRETENC
	cQueryNF += " FROM "+RetSqlName("SF1")+" SF1 "
	cQueryNF += " WHERE SF1.D_E_L_E_T_='' "
	cQueryNF += " AND SF1.F1_FILIAL  = '"+XFILIAL("SF1")+"' "		                                   		
	cQueryNF += " AND SF1.F1_EMISSAO LIKE '"+SubStr(Dtos(DDATABASE),1,6)+"%'"
	cQueryNF += " AND SF1.F1_ESPECIE = '"+cSF1Esp+"' "		
	cQueryNF += " AND SF1.F1_FORNECE = '"+cProveedor+"' "	
	cQueryNF += " AND SF1.F1_LOJA = '"+cLoja+"' "
	   
	cQueryNF:=ChangeQuery(cQueryNF)
	TcQuery cQueryNF New Alias "VALRTE"    

	DbSelectArea("VALRTE")
	If VALRTE->(!Eof())		
		aRetNF[1] := IIf(!Empty(VALRTE->SUMBASE),VALRTE->SUMBASE,0)
		aRetNF[2] := IIf(!Empty(VALRTE->SUMRETENC),VALRTE->SUMRETENC,0)				
		DbCloseArea()
    EndIf  
            
    aRet[1] := aRetNF[1] //base acumulada 
    aRet[2] := aRetNF[2] //valor de retencao acumulado 
        
RestArea(aArea)
Return aRet
                            

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ ObtUVT    ³ Autor ³ Laura Medina        ³ Data ³ 04.07.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Obtener la Retención en UVT del Pago mensualizado.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cPar01 - Pago mensualizado en UVT                           ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ xRet - Retorna el valor 'retencion' que le corresponde.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Colombia                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ObtUVT(nBaseUVT,nOpc)   
Local cQueryUVT:= ""
Local aArea    := GetArea()         
Local nValUVT  := 0 //Retencion en UVT 
Local cImpVar  := "RFT"    
Local nValExc  := 0
    
If  nOpc==1 .And. ObtRangos(nBaseUVT,@nValExc)  //Significa que está al inicio o final del rango de la tabla y se aplica otra regla
	nValUVT := nValExc
	//Validar si es mayor de 1136.92

Else  
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Seleciona la retencion UVT del pago mensualizado                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
	cQueryUVT := " SELECT  FF_ALIQ, MAX(FF_IMPORTE) 
	cQueryUVT += " FROM "+RetSqlName("SFF")+" SFF "
	cQueryUVT += " WHERE SFF.D_E_L_E_T_='' " 
	cQueryUVT += " AND SFF.FF_FILIAL  = '"+XFILIAL("SFF")+"' "			                                   		
	cQueryUVT += " AND SFF.FF_IMPORTE < "+ str(nBaseUVT)+" "	
	cQueryUVT += " AND SFF.FF_IMPOSTO = '"+ cImpVar+"' "
	cQueryUVT += " GROUP BY FF_ALIQ, FF_IMPORTE"
	cQueryUVT += " ORDER BY FF_IMPORTE DESC"
		   
	cQueryUVT:=ChangeQuery(cQueryUVT)
	TcQuery cQueryUVT New Alias "VALRTE"    
	
	DbSelectArea("VALRTE")
	If VALRTE->(!Eof())		
		nValUVT:= IIf(!Empty(VALRTE->FF_ALIQ),VALRTE->FF_ALIQ,0)			
		VALRTE->(DbCloseArea())
    EndIf  

Endif    

	
	

RestArea(aArea)
Return nValUVT
                   

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ ObtRangos ³ Autor ³ Laura Medina        ³ Data ³ 10/07/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Obtener el valor maximo y minimo de la tabla de Retencion   ³±±
±±³          ³ UVT.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cPar01 - Pago mensualizado en UVT                           ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ xRet - Retorna el valor maximo y minimo                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Colombia                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ObtRangos(nBaseUVT,nValExc)   
Local cQueryUVT:= ""
Local aArea    := GetArea()         
Local cImpVar  := "RFT" 
Local lEsExcep := .F.  
Local cAliasTmp   := CriaTrab(Nil,.F.)   
  
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Seleciona la retencion UVT del pago mensualizado                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
	cQueryUVT := " SELECT  MAX(FF_IMPORTE) MAXUVT, MIN(FF_IMPORTE) MINUVT "
	cQueryUVT += " FROM "+RetSqlName("SFF")+" SFF "
	cQueryUVT += " WHERE SFF.D_E_L_E_T_='' " 
	cQueryUVT += " AND SFF.FF_FILIAL  = '"+XFILIAL("SFF")+"' "			                                   		
	cQueryUVT += " AND SFF.FF_IMPOSTO = '"+ cImpVar+"' "
		   
	cQueryUVT:=ChangeQuery(cQueryUVT)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryUVT),cAliasTmp, .T., .T.) 
	
	DbSelectArea(cAliastmp)
	If  (cAliasTmp)->(!Eof())           
		If  nBaseUVT<MINUVT   //Validar si es menor de 128.96
			lEsExcep := .T.	 
			nValExc  := 0
		Elseif nBaseUVT>MAXUVT //Validar si es mayor de 1136.92
		    lEsExcep := .T.	
		    nValExc  := (0.27 * nBaseUVT )- ObtUVT(nBaseUVT,2)  
		Endif	
		(cAliasTmp)->(DbCloseArea())
    EndIf  
    


RestArea(aArea)
Return lEsExcep
