#include "GCPA210.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWEVENTVIEWCONSTS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPCNIniIn
Rotina responsalvel pelo processo de integraçao com o portal ComprasNet

@author alexandre.gimenez	

@param oModel - Modelo de dados
@return lRet
@since 02/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function GCPCNIniIn(oModel)
Local lRet		:= .F.
Local lLote	:= oModel:GetValue("CO1MASTER","CO1_AVAL") <> "1"
Local cXml		:= "" 
Local cXmlIt	:= ""
Local cXmlLt	:= ""
Local aHeadOut:= {}
Local aUsrPws := {}
Local cUsr64	:= ""
Local cUsr		:= ""
Local cPwsToken := ""
Local nX		:= 0
Local nIt		:= 0
Local nQtdIt	:= 0
Local lProLote:= .T.
Local aAnaMerc:= {}
Local aResult	:= {}
Local cResult	:= ""
Local nMargemP:= ""
Local nNumIt	:= 0
Local cNumPro := oModel:GetValue('CO1MASTER','CO1_NUMPRO')
Local cObj := oModel:GetValue('CO1MASTER','CO1_OBJETO')
Local nIncProd		:= 0
Local nIncLote		:= 0
Local n25		:= 0
Local c100    := ""
Local c75     := ""
Local c25     := ""
Local cNumGrupo	:= ""
Local cTipoBene	:= ""
Local cNome	:= ""	
Local cFuncao	:= ""

//-- Tratamento devido a uma validação do ComprasNET que exige o Objeto com letras maiusculas e minusculas.
cObj := StrCpNet(cObj)

Private oXMLGCPCN := Nil //-- Declarado como private para poder utlizar a funcao type no meio do processo.

//-- Identifica quantidade de Itens
If lLote
	For nX := 1 to oModel:GetModel("CP3DETAIL"):Length()
		oModel:GetModel("CP3DETAIL"):GoLine(nX)
   		nQtdIt +=  oModel:GetModel("CO2DETAIL"):Length(.T.)	
	Next nX
Else
	nQtdIt :=  oModel:GetModel("CO2DETAIL"):Length(.T.)	
EndIf

//-- Recupera senha ComprasNet 
aUsrPws := GCPCNUser(1) 

If ValType(aUsrPws) == 'A'

	cUsr64 := aUsrPws[1]		//(Usuario Portal + Senha Portal) em Base64
	cPwsToken := aUsrPws[2]		//Senha do Token
	cUsr := aUsrPws[3]			//Usuario Portal
	cPsw := aUsrPws[4]			//Senha Portal
    cNome := aUsrPws[5]      //Nome
    cFuncao := aUsrPws[6]    //Funcao  
	
	//-- Monta Header
	aHeadOut := GCPCNHead(cUsr64)
	
	//-- Monta XML de Inclusao do Proc. Licitatório
	cXml:='<?xml version="1.0" encoding="UTF-8" ?>'
	cXml+="<soapenv:Envelope xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/' xmlns:sias='siasgnet.ws.divulgacao'>"
	cXml+= "   <soapenv:Body>"
	cXml+= "      <sias:incluirLicitacaoSISPP>"
	
	//-- Identificaçao da licitacao
	cXml+= GCPCNIdLic(oModel)
	
	//-- Dados da Licitacao
	cXml+= "         <DadosLicitacao>"
	cXml+= "            <TipoLicitacao>1</TipoLicitacao>" // Menor Preço
	cXml+= "            <FormaRealizacao>1</FormaRealizacao>" // 1 Eletronica // 2 Presencial
	cXml+= "            <NumeroProcesso>"+EncodeUtf8(cNumPro)+"</NumeroProcesso>"
	cXml+= "            <EqualizacaoICMS>N</EqualizacaoICMS>" // Sim ou Nao
	//cXml+= "            <EqualizacaoICMS>"+IIF(oModel:GetValue('CO1MASTER','CO1_EQICMS') == '1','S','N')+"</EqualizacaoICMS>" // Sim ou Nao
	cXml+= "            <LicitacaoInternacional>N</LicitacaoInternacional>" // 'N' Somente valido para concorrencia
	cXml+= "            <QuantidadeItens>"+EncodeUtf8(Alltrim(Str(nQtdIt)))+"</QuantidadeItens>"
	//cXml+= "            <JustificativaNaoUtilizacaoPregao>Sempre Será Pregao</JustificativaNaoUtilizacaoPregao>"
	cXml+= "            <Objeto>"+ EncodeUtf8(cObj) +"</Objeto>"
	cXml+= "            <InformacoesGerais>"+ EncodeUtf8(StrCpNet(oModel:GetValue('CO1MASTER','CO1_OBS1'))) +"</InformacoesGerais>"
	cXml+= "            <LicitacaoExclusivaMEEPPCooperativas>"+IIF(oModel:GetValue('CO1MASTER','CO1_MEEPP') == '1','S','N')+"</LicitacaoExclusivaMEEPPCooperativas>" // ????????????? Sim Ou Não
	cXml+= "            <ObrasServicosEngenharia>"+ IIF(oModel:GetValue('CO1MASTER','CO1_ESPECI') == '1','S','N') +"</ObrasServicosEngenharia>"
	
	cXml+= "            <Recurso>"
	cXml+= "               <TipoRecurso>1</TipoRecurso>" // Considera apenas itens nacionais
	//cXml+= "               <OrigemRecurso>1</OrigemRecurso>"
	//cXml+= "               <OutrasOrigens>outra</OutrasOrigens>"
	//cXml+= "               <ValorContrapartida>100</ValorContrapartida>"
	//cXml+= "               <NumeroContrato>contrato</NumeroContrato>"
	cXml+= "            </Recurso>"
	cXml+= "            <ResponsavelAutorizacao>"
    cXml+= "               <CPF>"+EncodeUtf8(AllTrim(cUsr))+"</CPF>"
    cXml+= "               <Nome>"+EncodeUtf8(AllTrim(cNome))+"</Nome>"
    cXml+= "               <Funcao>"+EncodeUtf8(AllTrim(cFuncao))+"</Funcao>"
	cXml+= "            </ResponsavelAutorizacao>"
	cXml+= "         </DadosLicitacao>"
	
	cXml+= "      </sias:incluirLicitacaoSISPP>"
	cXml+= "   </soapenv:Body>"
	cXml+= "</soapenv:Envelope>"
	
	//-- Post Inclusao do Proc. Licitatório
	lRet := GCPCNPost('Lic',"",cXml,aHeadOut,@aResult,cPwsToken,aUsrPws,'incluirLicitacaoSISPP',.F.)
	
	If lRet
		//-- Abre SB5 Para detalhes dos produtos
		DbSelectArea("SB5")
		DbSetOrder(1)
		//-- Em caso de lote posiciona no primeiro
		If lLote
			oModel:GetModel("CP3DETAIL"):GoLine(1)
		EndIf
		//-- Processa enquanto Tiver lote ou uma unica vez para item
		While lProLote .And. lRet
			//-- Inclusao do grupo no compras net
			If lLote
				cXmlLt := "<soapenv:Envelope xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/' xmlns:sias='siasgnet.ws.divulgacao'>"
				cXmlLt += "   <soapenv:Body>"
				cXmlLt += "      <sias:incluirGruposPrecoGlobal>"
				cXmlLt += GCPCNIdLic(oModel)//-- Identificaçao da licitacao
				cXmlLt += "         <GruposPrecoGlobal>"
				cXmlLt += "            <GrupoPrecoGlobal>"
                cNumGrupo := EncodeUtf8(AllTrim(Str(Val(oModel:GetValue('CP3DETAIL','CP3_LOTE')) + nIncLote  )))
                cXmlLt += "               <NumeroGrupo>"+cNumGrupo+"</NumeroGrupo>"
                        
                If oModel:GetValue('CP3DETAIL','CP3_PARTEX') $ '1|2|3'
                	cXmlLt += "               <TipoBeneficio>"+oModel:GetValue('CP3DETAIL','CP3_PARTEX')+"</TipoBeneficio>"                 
                EndIf
                        
				cXmlLt += "               <JustificativaFormacao>"+EncodeUtf8(AllTrim(oModel:GetValue('CP3DETAIL','CP3_JUSTIF')))+"</JustificativaFormacao>"
                If oModel:GetValue('CP3DETAIL','CP3_PARTEX') $ '1|2|3'       
                	nIncLote += 1               
                    cXmlLt += "               <NumeroGrupoParticipacaoExclusiva>" + EncodeUtf8(AllTrim(Str(Val(oModel:GetValue('CP3DETAIL','CP3_LOTE')) + nIncLote)))+"</NumeroGrupoParticipacaoExclusiva>"
				//cXmlLt += "               <PercentualMargemPreferencia></PercentualMargemPreferencia>"
                EndIf
				cXmlLt += "            </GrupoPrecoGlobal>"
				cXmlLt += "         </GruposPrecoGlobal>"
				cXmlLt += "      </sias:incluirGruposPrecoGlobal>"
				cXmlLt += "   </soapenv:Body>"
				cXmlLt += "</soapenv:Envelope>"

				//-- Post Inclusao do Lote
			
				lRet := GCPCNPost('Lote',Alltrim(oModel:GetValue('CP3DETAIL','CP3_LOTE')),cXmlLt,aHeadOut,@aResult,cPwsToken,aUsrPws,'incluirGruposPrecoGlobal',.T.)		
			EndIf
			
			
			//-- Pocessa Itens
			If lRet
				For nIt := 1 to oModel:GetModel('CO2DETAIL'):Length()
					oModel:GetModel('CO2DETAIL'):GoLine(nIt)
					++nNumIt
                    //Verifica tipo de beneficio

             		cTipoBene := If(lLote,oModel:GetValue('CP3DETAIL','CP3_PARTEX'),oModel:GetValue("CO2DETAIL","CO2_PARTEX"))
                             
					// Somente se ainda nao tiver sido enviado
					If Empty(oModel:GetValue("CO2DETAIL","CO2_ITEMCN"))
						//-- Posiciona SB5
						SB5->(DbSeek(xFilial("SB5")+oModel:GetValue('CO2DETAIL','CO2_CODPRO')))
						cXmlIt:="<soapenv:Envelope xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/' xmlns:sias='siasgnet.ws.divulgacao'>"
						cXmlIt+="   <soapenv:Body>"
						cXmlIt+="      <sias:incluirItensLicitacao>"
						cXmlIt+= GCPCNIdLic(oModel)//-- Identificaçao da licitacao  
						cXmlIt+="         <ItensLicitacao>"
						cXmlIt+="            <ItemLicitacao>"
                                   cXmlIt+="               <NumeroItem>"+EncodeUtf8(AllTrim(Str(nNumIt+nIncProd))) +"</NumeroItem>"
						cXmlIt+="               <TipoItem>"+EncodeUtf8(AllTrim(Str(Val(SB5->B5_TIPO))))+"</TipoItem>" // 1- Material // 2- servico
						cXmlIt+="               <CodigoCatalogo>"+EncodeUtf8(AllTrim(SB5->B5_CATMAT))+"</CodigoCatalogo>"
						
						If !Empty(SB5->B5_CEME)
							cXmlIt+="               <DescricaoDetalhada>"+EncodeUtf8(AllTrim(SB5->B5_CEME))+"</DescricaoDetalhada>"
						Else
							cXmlIt+="               <DescricaoDetalhada>"+EncodeUtf8(oModel:GetValue('CO2DETAIL','CO2_DESCR'))+"</DescricaoDetalhada>"
						EndIf
						cXmlIt+="               <QuantidadeTotal>"+EncodeUtf8(GCPCNConvP(oModel:GetValue('CO2DETAIL','CO2_QUANT'),0))+"</QuantidadeTotal>"
						cXmlIt+="               <UnidadeFornecimento>"+EncodeUtf8(AllTrim(Posicione('SAH',1,xFilial('SAH')+oModel:GetValue('CO2DETAIL','CO2_UM'),"AH_DESCPO")))+"</UnidadeFornecimento>"
						cXmlIt+="               <SiglaUnidadeFornecimento>"+EncodeUtf8(oModel:GetValue('CO2DETAIL','CO2_UM'))+"</SiglaUnidadeFornecimento>"
						//cXmlIt+="               <CapacidadeUnidadeMedida>?</CapacidadeUnidadeMedida>"
						//cXmlIt+="               <SiglaUnidadeMedida>?</SiglaUnidadeMedida>"
						cXmlIt+="               <CriterioJulgamento>1</CriterioJulgamento>" // 1 Menor Preco // 2 Maior Desconto
						cXmlIt+="               <ValorTotalEstimado>"+EncodeUtf8(GCPCNConvP(oModel:GetValue('CO2DETAIL','CO2_QUANT') * oModel:GetValue('CO2DETAIL','CO2_VLESTI'), 2))+"</ValorTotalEstimado>"
						If lLote
                                         cXmlIt+="               <NumeroGrupo>"+cNumGrupo+"</NumeroGrupo>"
						EndIf
						//-- Tratamento decreto 7174/2010
						cXmlIt+="               <TratamentoDecreto7174>"+IIF(SB5->B5_DEC7174 == '1','S','N')+"</TratamentoDecreto7174>" // Tratamento decreto 7174
                                   If cTipoBene $ '1|2|3'
                                         nIncProd += 1
							cXmlIt+="               <Beneficio>"
                                         cXmlIt+="                  <TipoBeneficio>"+cTipoBene+"</TipoBeneficio>"
                                         If cTipoBene $ '2|3'
	                                         cXmlIt+="                  <PercentualMinimoSubcontratacao>"+EncodeUtf8(If(cTipoBene=="3","25","1"))+"</PercentualMinimoSubcontratacao>"
	                                         cXmlIt+="                  <PercentualMaximoSubcontratacao>"+EncodeUtf8(If(cTipoBene=="3","25","99"))+"</PercentualMaximoSubcontratacao>"
	                                    	   
	                                    	   c25 :=	GCPCNConvP(Int(oModel:GetValue('CO2DETAIL','CO2_QUANT') * 0.25) ,0)
	                                    	   c75 :=	GCPCNConvP(Int(oModel:GetValue('CO2DETAIL','CO2_QUANT') -val(c25)) ,0)
	                                    	   c100 :=	GCPCNConvP(Int(oModel:GetValue('CO2DETAIL','CO2_QUANT')) ,0)
	                                    	   
	                                         If cTipoBene == '3'
		                                         cXmlIt+="                  <QuantidadeItemParticipacaoAberta>" + EncodeUtf8(If(cTipoBene=="3",c75,"0")) + "</QuantidadeItemParticipacaoAberta>"
		                                         cXmlIt+="                  <QuantidadeItemParticipacaoExclusiva>"+ EncodeUtf8(If(cTipoBene=="3",c25,c100)) +"</QuantidadeItemParticipacaoExclusiva>"
		                                         cXmlIt+="                  <NumeroItemParticipacaoExclusiva>" + EncodeUtf8(AllTrim(Str(nNumIt+nIncProd)))+ "</NumeroItemParticipacaoExclusiva>"
							cXmlIt+="                  <LocaisEntregaItemParticipacaoExclusiva>"
							cXmlIt+="                     <!--Zero or more repetitions:-->"
		                                         
		                                         For nX := 1 to oModel:GetModel('CPTDETAIL'):Length()
	                                               oModel:GetModel('CPTDETAIL'):GoLine(nX)
							cXmlIt+="                     <LocalEntregaItemParticipacaoExclusiva>"
			                                         cXmlIt+="                        <CodigoMunicipio>"+EncodeUtf8(AllTrim(Str(Val(oModel:GetValue('CPTDETAIL','CPT_CODMUN')))))+"</CodigoMunicipio>"
			                                         cXmlIt+="                        <Quantidade>"+EncodeUtf8(GCPCNConvP(Int(oModel:GetValue('CPTDETAIL','CPT_QUANT') * 0.25) ,0))+"</Quantidade>"
							cXmlIt+="                     </LocalEntregaItemParticipacaoExclusiva>"
			                                      Next nX
							cXmlIt+="                  </LocaisEntregaItemParticipacaoExclusiva>"
	                                         EndIf
	                                         
	                                         If .F.
							cXmlIt+="                  <FatoresEqualizacaoICMSItemParticipacaoExclusiva>"
							cXmlIt+="                     <FatorAC>?</FatorAC>"
							cXmlIt+="                     <FatorAL>?</FatorAL>"
							cXmlIt+="                     <FatorAM>?</FatorAM>"
							cXmlIt+="                     <FatorAP>?</FatorAP>"
							cXmlIt+="                     <FatorBA>?</FatorBA>"
							cXmlIt+="                     <FatorCE>?</FatorCE>"
							cXmlIt+="                     <FatorDF>?</FatorDF>"
		                                         cXmlIt+="                     <FatorES>?</FatorES>
							cXmlIt+="                     <FatorGO>?</FatorGO>"
							cXmlIt+="                     <FatorMA>?</FatorMA>"
							cXmlIt+="                     <FatorMG>?</FatorMG>"
							cXmlIt+="                     <FatorMS>?</FatorMS>"
							cXmlIt+="                     <FatorMT>?</FatorMT>"
							cXmlIt+="                     <FatorPA>?</FatorPA>"
							cXmlIt+="                     <FatorPB>?</FatorPB>"
							cXmlIt+="                     <FatorPE>?</FatorPE>"
							cXmlIt+="                     <FatorPI>?</FatorPI>"
							cXmlIt+="                     <FatorPR>?</FatorPR>"
							cXmlIt+="                     <FatorRJ>?</FatorRJ>"
							cXmlIt+="                     <FatorRN>?</FatorRN>"
							cXmlIt+="                     <FatorRO>?</FatorRO>"
							cXmlIt+="                     <FatorRR>?</FatorRR>"
							cXmlIt+="                     <FatorRS>?</FatorRS>"
							cXmlIt+="                     <FatorSC>?</FatorSC>"
							cXmlIt+="                     <FatorSE>?</FatorSE>"
							cXmlIt+="                     <FatorSP>?</FatorSP>"
							cXmlIt+="                     <FatorTO>?</FatorTO>"
							cXmlIt+="                  </FatoresEqualizacaoICMSItemParticipacaoExclusiva>"
												  EndIf
	                                     EndIf
							cXmlIt+="               </Beneficio>"
						EndIf
						If ( nMargemP := SB5->B5_MARGPRE ) > 0
							cXmlIt+="               <PercentualMargemPreferenciaNormal>"+EncodeUtf8(GCPCNConvP(nMargemP, 2))+"</PercentualMargemPreferenciaNormal>"
						EndIf
						//-- Valida Locais de Entrega
						If !Empty(oModel:GetValue('CPTDETAIL','CPT_CODMUN'))
							cXmlIt+="               <LocaisEntrega>"
							For nX := 1 to oModel:GetModel('CPTDETAIL'):Length() 
								oModel:GetModel('CPTDETAIL'):GoLine(nX) 
								cXmlIt+="                  <LocalEntrega>"
								//cXmlIt+="                     <CodigoMunicipio>50308</CodigoMunicipio>"
                                               n25 := If(cTipoBene == '3',Int(oModel:GetValue('CPTDETAIL','CPT_QUANT') * 0.25),0 )
                                               
								cXmlIt+="                     <CodigoMunicipio>"+EncodeUtf8(AllTrim(Str(Val(oModel:GetValue('CPTDETAIL','CPT_CODMUN')))))+"</CodigoMunicipio>"
                                               cXmlIt+="                     <Quantidade>"+EncodeUtf8(GCPCNConvP((oModel:GetValue('CPTDETAIL','CPT_QUANT')-n25),0))+"</Quantidade>"
								cXmlIt+="                  </LocalEntrega>"
							Next nX
							cXmlIt+="               </LocaisEntrega>"
						EndIf
						//-- Valida Analise de Mercado
						aAnaMerc := GCPCNAnaM(oModel)
						If Len(aAnaMerc) > 0
							cXmlIt+="               <PesquisasPrecoMercado>"
							cXmlIt+="                  <!--Zero or more repetitions:-->"
							For nX := 1 To Len(aAnaMerc)
								cXmlIt+="                  <PesquisaPrecoMercado>"
								cXmlIt+="                     <DataPesquisa>"+EncodeUtf8(aAnaMerc[nX,1])+"</DataPesquisa>"
								cXmlIt+="                     <ValorTotal>"+EncodeUtf8(aAnaMerc[nX,2])+"</ValorTotal>"
								cXmlIt+="                     <TipoFornecedor>"+EncodeUtf8(aAnaMerc[nX,3])+"</TipoFornecedor>" // 1 Fisica //2 Juridica // 3 Estrangeiro 
								If aAnaMerc[nX,3] == '1' 
									cXmlIt+="                     <Cpf>"+EncodeUtf8(aAnaMerc[nX,4])+"</Cpf>"
								Else
									cXmlIt+="                     <Cnpj>"+EncodeUtf8(aAnaMerc[nX,5])+"</Cnpj>"
								EndIf
								cXmlIt+="                     <NomeOuRazaoSocial>"+EncodeUtf8(aAnaMerc[nX,6])+"</NomeOuRazaoSocial>"
								cXmlIt+="                     <MarcaItem>"+EncodeUtf8(aAnaMerc[nX,7])+"</MarcaItem>"
								cXmlIt+="                     <FabricanteItem>"+EncodeUtf8(aAnaMerc[nX,8])+"</FabricanteItem>"
								cXmlIt+="                  </PesquisaPrecoMercado>"
							Next nX
							cXmlIt+="               </PesquisasPrecoMercado>"
						EndIf
						//-- Valida equalizacao de ICMS
						If .F.
							cXmlIt+="               <FatoresEqualizacaoICMS>"
							cXmlIt+="                  <FatorAC>?</FatorAC>"
							cXmlIt+="                  <FatorAL>?</FatorAL>"
							cXmlIt+="                  <FatorAM>?</FatorAM>"
							cXmlIt+="                  <FatorAP>?</FatorAP>"
							cXmlIt+="                  <FatorBA>?</FatorBA>"
							cXmlIt+="                  <FatorCE>?</FatorCE>"
							cXmlIt+="                  <FatorDF>?</FatorDF>"
							cXmlIt+="                  <FatorES>?</FatorES>"
							cXmlIt+="                  <FatorGO>?</FatorGO>"
							cXmlIt+="                  <FatorMA>?</FatorMA>"
							cXmlIt+="                  <FatorMG>?</FatorMG>"
							cXmlIt+="                  <FatorMS>?</FatorMS>"
							cXmlIt+="                  <FatorMT>?</FatorMT>"
							cXmlIt+="                  <FatorPA>?</FatorPA>"
							cXmlIt+="                  <FatorPB>?</FatorPB>"
							cXmlIt+="                  <FatorPE>?</FatorPE>"
							cXmlIt+="                  <FatorPI>?</FatorPI>"
							cXmlIt+="                  <FatorPR>?</FatorPR>"
							cXmlIt+="                  <FatorRJ>?</FatorRJ>"
							cXmlIt+="                  <FatorRN>?</FatorRN>"
							cXmlIt+="                  <FatorRO>?</FatorRO>"
							cXmlIt+="                  <FatorRR>?</FatorRR>"
							cXmlIt+="                  <FatorRS>?</FatorRS>"
							cXmlIt+="                  <FatorSC>?</FatorSC>"
							cXmlIt+="                  <FatorSE>?</FatorSE>"
							cXmlIt+="                  <FatorSP>?</FatorSP>"
							cXmlIt+="                  <FatorTO>?</FatorTO>"
							cXmlIt+="               </FatoresEqualizacaoICMS>"
						EndIf
						If oModel:GetValue('CO2DETAIL','CO2_DIFMIN') > 0 
							cXmlIt+="               <DiferencaMinimaEntreLances>"+EncodeUtf8(Alltrim(Str(oModel:GetValue('CO2DETAIL','CO2_DIFMIN'))))+"</DiferencaMinimaEntreLances>"
						EndIf
						cXmlIt+="            </ItemLicitacao>"
						cXmlIt+="         </ItensLicitacao>"
						cXmlIt+="      </sias:incluirItensLicitacao>"
						cXmlIt+="   </soapenv:Body>"
						cXmlIt+="</soapenv:Envelope>		
						//-- Post Inclusao do Item
						lRet := GCPCNPost('Item',Str(nNumIt),cXmlIt,aHeadOut,@aResult,cPwsToken,aUsrPws,'incluirItensLicitacao',.T.)
						If lRet
							//-- Atualiza numero do item.
							oModel:LoadValue("CO2DETAIL","CO2_ITEMCN",nNumIt)
						Else
							Exit
						EndIf
					EndIf
				Next nIt
			EndIf
			
			//-- Posiciona o Lote ou Para Processamento
			If lRet .And. lLote
				If oModel:GetModel("CP3DETAIL"):GetLine() == oModel:GetModel("CP3DETAIL"):Length()
					lProLote := .F. // Ultimo lote nao processa mais
				Else
					oModel:GetModel("CP3DETAIL"):GoLine(oModel:GetModel("CP3DETAIL"):GetLine()+1) // Vai para Proxima Linha
				EndIf
			Else
				lProLote := .F. // Somente uma vez para item	
			EndIf
		End
	EndIf
	
	If lRet 
		aAdd(aResult,STR0001)//"***Resultado Final*** Integração realizada com SUCESSO."
	Else
		aAdd(aResult,STR0002)//"***Resultado Final*** Integração NÃO realizada."
	EndIf
	For nX:= 1 to Len(aResult)
		cResult += aResult[nX]+CRLF
	Next nX
	
	Aviso(STR0003,cResult,{STR0004})//"Resultado"//"Ok"
EndIf	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPCNExcl
Rotina responsalvel por excluir integracao com o portal ComprasNet

@author alexandre.gimenez	

@param oModel - Modelo de dados
@return lRet
@since 02/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function GCPCNExcl()
Local lRet		:= .F.
Local cXml		:= "" 
Local aHeadOut:= {}
Local cUsr64	:= ""
Local aResult	:= {}
Local cResult	:= ""
Local nX		:= 0
Local cUsr 		:= ""
Local cPsw 		:= ""
Local cPwsToken := ""	
Local aUsrPws   := {}
Local cCodEdt := Alltrim(CO1->CO1_CODEDT)

Private oXMLGCPCN := Nil //-- Declarado como private para poder utlizar a funcao type no meio do processo.

If CO1->CO1_STATUS == '7' .And. CO1->CO1_INTEGR == '2'
	
	//-- Recupera senha ComprasNet 
	aUsrPws := GCPCNUser(1)


	cUsr64 := aUsrPws[1]		//(Usuario Portal + Senha Portal) em Base64
	cUsr := aUsrPws[3]			//Usuario Portal
	cPsw := aUsrPws[4]			//Senha Portal
	cPwsToken := aUsrPws[2]	
	
	//-- Monta Header
	//aHeadOut := GCPCNHead(cUsr64)
	
	//-- Monta XML de Inclusao do Proc. Licitatório
	cXml:="<soapenv:Envelope xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/' xmlns:sias='siasgnet.ws.divulgacao'>"
	cXml+= "   <soapenv:Body>"
	cXml+= "      <sias:excluirLicitacaoSISPP>"
	cXml+= "         <IdentificacaoLicitacao>"
	cXml+= "            <NumeroUasg>"+AllTrim(SuperGetMv("MV_GCPUASG",.F.,""))+"</NumeroUasg>" //168001
	cXml+= "            <ModalidadeLicitacao>5</ModalidadeLicitacao>" // somente 05 pregrao
	cXml+= "            <NumeroLicitacao>"+AllTrim(Substr(cCodEdt,Len(cCodEdt) -4,5))+"</NumeroLicitacao>"
	cXml+= "            <AnoLicitacao>"+AllTrim(Str(Year(CO1->CO1_DTABER),4))+"</AnoLicitacao>"
	cXml+= "         </IdentificacaoLicitacao>"
	cXml+= "      </sias:excluirLicitacaoSISPP>"
	cXml+= "   </soapenv:Body>"
	cXml+= "</soapenv:Envelope>"
	
	//-- Post Inclusao do Proc. Licitatório
	lRet := GCPCNPost('Exc',"",cXml,aHeadOut,@aResult,cPwsToken,aUsrPws,'excluirLicitacaoSISPP',.F.)
	
	If lRet 
		aAdd(aResult,STR0005)//"***Resultado Final*** Integração realizada com SUCESSO."
		RecLock("CO1",.F.)
			CO1->CO1_ETAPA 	:= 'PB'
			CO1->CO1_STATUS	:= '1'
		CO1->(MsUnlock())
		// Limpa Item de controle da integracao Integracao
		DbSelectArea("CO2")
		DbSetOrder(1)
		If CO2->(DbSeek(xFilial("CO2")+CO1->(CO1_CODEDT+CO1_NUMPRO)))
			While xFilial("CO2")+CO1->(CO1_CODEDT+CO1_NUMPRO) ==  CO2->(CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO)
				RecLock("CO2",.F.)
				CO2->CO2_ITEMCN	:= 0
				CO2->(MsUnlock())
				CO2->(DbSkip())
			End		
		EndIf
	Else
		aAdd(aResult,STR0006)//"***Resultado Final*** Integração NÃO realizada."
	EndIf
	For nX:= 1 to Len(aResult)
		cResult += aResult[nX]+CRLF
	Next nX

	Aviso(STR0007,cResult,{STR0008})//"Resultado"//"Ok"
Else
	Help(' ', 1,'A200CNNOINT') //Este edital não econtra-se integrado com o portal ComprasNet     
EndIf	

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPCNHead
Rotina responsalvel por montar o Header que será utilizado no Post Http

@author alexandre.gimenez	

@param cUsr64 - usuario:senha
@return aRet - aHeadOut
@since 02/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GCPCNHead(cUsr64)	
Local aRet:= {}

aadd(aRet,"Accept:text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8")
aadd(aRet,"Authorization:Basic "+cUsr64)
//aadd(aHeadOut,"Authorization: Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==")
aadd(aRet,"Content-Type: text/xml;charset=UTF-8")
aadd(aRet,"Host:treinamento2.comprasnet.gov.br")
aadd(aRet,"Origin:null")
aadd(aRet,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')')

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPCNIdLic
Rotina responsalvel por montar a tag IdentificacaoLicitacao 

@author alexandre.gimenez	

@param oModel - Modelo de Dados
@return cRet - cXml com Tag
@since 02/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GCPCNIdLic(oModel)
Local cRet := ""
Local cUasg:= SuperGetMv("MV_GCPUASG",.F.,"")
Local cCodEdt := Alltrim(oModel:GetValue('CO1MASTER','CO1_CODEDT'))

cRet+= "         <IdentificacaoLicitacao>"
cRet+= "            <NumeroUasg>"+EncodeUtf8(AllTrim(cUasg))+"</NumeroUasg>" //168001
cRet+= "            <ModalidadeLicitacao>5</ModalidadeLicitacao>" // somente 05 pregrao
cRet+= "            <NumeroLicitacao>"+EncodeUtf8(AllTrim(Substr(cCodEdt,Len(cCodEdt)-4,5)))+"</NumeroLicitacao>"
cRet+= "            <AnoLicitacao>"+EncodeUtf8(AllTrim(Str(Year(oModel:GetValue('CO1MASTER','CO1_DTABER')),4)))+"</AnoLicitacao>"
cRet+= "         </IdentificacaoLicitacao>"

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPCNUser
Interface para recuper usuario e senha utilizado no ComprasNet 

@author alexandre.gimenez	

@param TipRet - Tipo de Retorno 1-Usuario:Senha(Criptografado) 2- Array com Usuario e Senha
@return xRet - Usuario e senha conforme tipo de retorno
@since 02/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GCPCNUser(nTipRet)
Local cUserLogin := Space(20)
Local cPassword  := Space(20)
Local cPassToken  := Space(20)
Local lRetorno   := .F.
Local xRet
Local oFont
Local oGet
Local oDlg
Local cAmbient  := ""
Local oGroup1
Local oGroup2	  		  	
Local cNome := Space(50)
Local cFuncao	:= Space(50)
Local oTBitmap1	


If SuperGetMv("MV_GCPACN",.F.,"1") == '1'
	cAmbient := "Treinamento"		
Else
	cAmbient := "Produção"
EndIf

Define Font oFont   Name STR0037 Size 07,17	//"Consolas"
DEFINE FONT oFntBld NAME STR0037 SIZE 07,17 BOLD	//"Consolas"

Define MsDialog oDlg Title STR0009 From 0,0 To 270,400 Of oDlg Pixel //"Autenticacao ComprasNet"

oGroup1:= TGroup():New(012,5,050,197,STR0038,oDlg,,,.T.)	//'Dados Pregoeiro ComprasNet'
oGroup2:= TGroup():New(051,5,103,197,STR0039,oDlg,,,.T.)	//'Autenticação ComprasNet'

@ 04,068 SAY I18N(STR0040 + cAmbient) 		SIZE 200,20 PIXEL OF oDlg FONT oFntBld //'Ambiente:'//"Loginad do usuário*"//"Login do usuário"

@ 020,22 SAY I18N(STR0041)             	SIZE 050,009 PIXEL OF oDlg FONT oFont //"Nome:"//"Login do usuário*"//"Login do usuário"
@ 020,47 GET oGet VAR cNome  SIZE 120,009 PIXEL OF oDlg PICTURE "@S30"

@ 034,22 SAY I18N(STR0042)            		SIZE 050,009 PIXEL OF oDlg FONT oFont //'Função:'//"Login do usuário*"//"Login do usuário"
@ 034,47 GET oGet VAR cFuncao  SIZE 120,009 PIXEL OF oDlg PICTURE "@S30"


@ 060,022	 SAY I18N(STR0043)             	SIZE 050,009 PIXEL OF oDlg FONT oFont //'CPF:'//"Login do usuário*"//"Login do usuário"
@ 060,47 GET oGet VAR cUserLogin  SIZE 120,009 PIXEL OF oDlg PICTURE "@S30A"

@ 074,022 SAY I18N(STR0044)     			SIZE 060,009 PIXEL OF oDlg FONT oFont  //"Senha*"//"Senha"
@ 074,047 MSGET cPassword          		SIZE 120,009 PIXEL OF oDlg PASSWORD

@ 088,022 SAY I18N(STR0045)         		SIZE 060,009 PIXEL OF oDlg FONT oFont  //'Token:'//"Senha*"//"Senha"
@ 088,047 MSGET cPassToken          		SIZE 120,009 PIXEL OF oDlg PASSWORD

@ 112,005 BUTTON STR0012     SIZE 050, 015 PIXEL OF oDlg ACTION (lRetorno:= .T. , oDlg:End())//"Enviar"
@ 112,060 BUTTON STR0013     SIZE 050, 015 PIXEL OF oDlg ACTION (lRetorno:= .F.,xRet := Nil, oDlg:End())//"Cancelar"

oTBitmap1 := TBitmap():New(107,115,82,22,,"ComprasNet.jpg",.F.,oDlg,;
       {||},,.F.,.F.,,,.F.,,.T.,,.F.)
       	
oTBitmap1:lStretch:= .T.

ACTIVATE MSDIALOG oDlg CENTER
 
If lRetorno
	If nTipRet == 1
		xRet:= {}
		If lRetorno
			aAdd(xRet,Encode64(Alltrim(cUserLogin) + ":" + AllTrim(cPassword)))
			aAdd(xRet,AllTrim(cPassToken))
			aAdd(xRet,AllTrim(cUserLogin))
			aAdd(xRet,AllTrim(cPassword))
                  aAdd(xRet,AllTrim(cNome))
                  aAdd(xRet,AllTrim(cFuncao))
		Else
			aAdd(xRet,"")
			aAdd(xRet,"")
		EndIf
	ElseIf nTipRet == 2
		xRet:= {}
		If lRetorno 
			aAdd(xRet,AllTrim(cUserLogin))
			aAdd(xRet,AllTrim(cPassword))
			aAdd(xRet,AllTrim(cPassToken))
		Else
			aAdd(xRet,"")
			aAdd(xRet,"")
			aAdd(xRet,"")
		EndIf
	EndIf 
EndIf 
Return xRet


//-------------------------------------------------------------------
/*/{Protheus.doc} GCPCNAnaM
Funcao responsavel por montar array com dados de analise de mercado
do item posicionado no modelo, para incluir no XML do comprasnet

@author alexandre.gimenez	

@param oModel - Modelo de Dados
@return aRet - Array com analises de mercado
@since 02/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GCPCNAnaM(oModel)
Local aRet 		:= {}
Local cAliasSql	:= GetNextAlias()
Local cCodEdt		:= oModel:GetValue('CO1MASTER','CO1_CODEDT')
Local cNumPro		:= oModel:GetValue('CO1MASTER','CO1_NUMPRO')
Local cCodPro		:= oModel:GetValue('CO2DETAIL','CO2_CODPRO')
Local nTam			:= 0
Local lLote		:= oModel:GetValue("CO1MASTER","CO1_AVAL") <> "1"
Local cFiltro		:= ''

If lLote
	cFiltro := 'COP.COP_CODIGO AND CON.CON_LOTE = COP.COP_LOTE' 
Else
	cFiltro := 'COP.COP_CODIGO AND CON.CON_CODPRO = COP.COP_CODPRO'
EndIf
cFiltro := "%"+cFiltro+"%"

BeginSQL Alias cAliasSql
			
	SELECT 
		COM.COM_DATA,CON.CON_VALEST,SA2.A2_EST,SA2.A2_TIPO,SA2.A2_CGC,CO6.CO6_CNPJ,
		SA2.A2_NOME,CO6.CO6_NOME,COP.COP_MARCA,COP.COP_FABRIC,
		COP.COP_TIPO,COP.COP_CODFOR,COP.COP_LOJFOR,COY_VLRTOT,COP_VALTOT
	FROM 
		%table:COM% COM
	Join %table:CON% CON ON CON.CON_FILIAL = %xFilial:CON% 
		AND COM.COM_CODIGO = CON.CON_CODIGO
	Join %table:COP% COP ON COP.COP_FILIAL = %xFilial:COP% 
		AND COM.COM_CODIGO = %Exp:cFiltro%
	left Join %Table:SA2% SA2 ON SA2.A2_FILIAL = %xFilial:SA2%
		AND SA2.A2_COD = COP.COP_CODFOR
		AND SA2.A2_LOJA = COP.COP_LOJFOR
	Left Join %Table:CO6% CO6 ON CO6.CO6_FILIAL = %xFilial:CO6%
		AND CO6.CO6_CODIGO = COP.COP_CODFOR
		AND CO6.CO6_LOJFOR = COP.COP_LOJFOR
	Left Join %Table:COY% COY ON COY.COY_FILIAL = %xFilial:COY%
		AND COM.COM_CODIGO = COY.COY_CODIGO
		AND CON.CON_CODPRO = COY.COY_CODPRO
		AND CON.CON_LOTE = COY.COY_LOTE 
		AND COP.COP_CODFOR = COY.COY_CODFOR
		AND COP.COP_LOJFOR = COY.COY_LOJFOR
	WHERE 
			COM.COM_FILIAL = %xfilial:COM%
		AND COM.COM_CODEDT = %exp:cCodEdt%
		AND COM.COM_NUMPRO = %exp:cNumPro%
		AND CON.CON_CODPRO = %exp:cCodPro%
		AND COM.%NotDel%	
		AND CON.%NotDel%	
		AND COP.%NotDel%						
EndSql

While !(cAliasSql)->(eof())
	aAdd(aRet,Array(8))
	nTam:= Len(aRet)
	aRet[nTam,1] := DToC(StoD((cAliasSql)->COM_DATA)) //DataPesquisa
	//-- Valor Por Item ou Lote
	If Empty((cAliasSql)->COY_VLRTOT)
		aRet[nTam,2] := GCPCNConvP((cAliasSql)->COP_VALTOT,2) //ValorTotal
	Else
		aRet[nTam,2] := GCPCNConvP((cAliasSql)->COY_VLRTOT,2) //ValorTotal	
	EndIf
	If (cAliasSql)->COP_TIPO == '1' //Pre Fornecedor
		aRet[nTam,3] := '2' //TipoFornecedor
            aRet[nTam,4] := RemoveEsp((cAliasSql)->CO6_CNPJ) //Cpf
            aRet[nTam,5] := RemoveEsp((cAliasSql)->CO6_CNPJ) //Cnpj
            aRet[nTam,6] := RemoveEsp((cAliasSql)->CO6_NOME) //NomeOuRazaoSocial
	Else
		If (cAliasSql)->A2_EST == 'EX'
			aRet[nTam,3] := '3' //TipoFornecedor
		Else
			If (cAliasSql)->A2_TIPO == 'F'
				aRet[nTam,3] := '1' //TipoFornecedor
			Else
				aRet[nTam,3] := '2' //TipoFornecedor
			End
		EndIf
		aRet[nTam,4] := (cAliasSql)->A2_CGC //Cpf
		aRet[nTam,5] := (cAliasSql)->A2_CGC //Cnpj
            aRet[nTam,6] := RemoveEsp((cAliasSql)->A2_Nome) //NomeOuRazaoSocial
	EndIf
	If !Empty((cAliasSql)->COP_MARCA)
            aRet[nTam,7] := RemoveEsp(SubStr((cAliasSql)->COP_MARCA,1,20)) //MarcaItem
	Else
		aRet[nTam,7] := "" //MarcaItem
	EndIf
	If !Empty((cAliasSql)->COP_FABRIC)
            aRet[nTam,8] := RemoveEsp(SubStr((cAliasSql)->COP_FABRIC ,1,20))//FabricanteItem
	Else
		aRet[nTam,8] := "" //FabricanteItem
	EndIf
	(cAliasSql)->(DbSkip())
End


Return aRet 


//-------------------------------------------------------------------
/*/{Protheus.doc} GCPCNConvP
Funcao responsavel converter valor numerico em string substituindo 
ponto por virgula

@author alexandre.gimenez	

@param nValue - Valor numerico
@param nDecim	- Numero de casas decimais
@return cRet - Valor convertido em string
@since 02/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function GCPCNConvP(nValue,nDecim)
Local cRet 	:= ""
Local cValue 	:= ""
Default nDecim:= 0

nValue := Round(nValue,nDecim)
cValue:= Str(nValue)
If At('.',cValue) > 0 
	cRet := SubStr(cValue,1,At('.',cValue)-1)
	cRet += ","+SubStr(cValue,At('.',cValue)+1)
Else
	cRet := cValue
EndIf

Return AllTrim(cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPCNConvP
Funcao responsavel converter valor String com virgula para numerico com
ponto

@author alexandre.gimenez	

@param nValue - Valor String
@return nRet - Valor convertido em string
@since 02/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function GCPCNConvV(cValue)
Local nRet 	:= 0
Local cRet		:= ''

If At(',',cValue) > 0 
	cRet := SubStr(cValue,1,At(',',cValue)-1)
	cRet += "."+SubStr(cValue,At(',',cValue)+1)
Else
	cRet := cValue
EndIf

nRet := Val(cRet)

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPCNPost
Funcao responsavel pela execuçao do Post no portal ComprasNet

@author alexandre.gimenez	

@param nValue - Valor numerico
@param nDecim	- Numero de casas decimais

@return lRet - Retorno com status da operacao
@since 02/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GCPCNPost(cTipo,cCod,cXml,aHeadOut,aResult,cPassPhrase,aUsr,cMethodName,lIsReady)
Local lRet 			:= .T.
Local nX			:= 0
Local cAmbient		:= SuperGetMv("MV_GCPACN",.F.,"1") // 1=Treinamento e 2=Producao // Parametro???
Local cPreUrl		:= ""
Local cUrl			:= ""
Local cHeadRet		:= ""
Local cError		:= ""
Local cWarning		:= ""
Local cPostRet 		:= ""
Local cMsg			:= ""
Local cCert 		:= ""
Local cKey 			:= ""
Local nError		:= 0
Local lOk			:= .F.
Default lIsReady	:= .F.

//-- Tratamento de Ambiente
If cAmbient == "2"
	cPreUrl		:= "https://www2." 
Else
	cPreUrl		:= "https://treinamento2."
EndIf
cUrl			:= cPreUrl+"comprasnet.gov.br/siasgnet-ws-sistemasexternos/IntegracaoSistemasExternosServico"

//Prepara o Token
If !lIsReady
	lOk := GCPHSMInit(cPassPhrase,@cCert,@cKey) 
Else
	//Se token foi preparado antes, nao prepara denovo.
	lOk := .T.
EndIf

If lOk

	//Elaboro o cabecalho da comunicacao
	aHeadOut := {}
	AAdd( aHeadOut, "User-Agent: wsdlpull/2.0" )
	AAdd( aHeadOut, "Accept-Encoding: deflate, gzip" )
	AAdd( aHeadOut, 'SOAPAction: "urn:' + cMethodName + '"' )
	AAdd( aHeadOut, "Content-Type: text/xml; charset=UTF-8" )	
	HttpSetPass(aUsr[3],aUsr[4], .T. )

	//Realiza o Post
	Conout('[GCP][INT][INFO] HSM CERTIFICATE: ' + cCert)
	Conout('[GCP][INT][INFO] HSM KEY: ' + cKey)

	cPostRet := HTTPSPost(cURL, cCert, cKey, cPassPhrase, , cXml,120, aHeadOut, @cHeadRet, .T. )	
	
	//Verifico o Status: Erro ou OK ?
	If Empty(cPostRet)
		nError := HttpGetStatus( @cError, .T. )
		lRet := .F.
		Aviso( STR0046, STR0047+ alltrim(str(nError)) + chr(13) + chr(10) + Iif(!Empty(cError), STR0048 + cError,''), {STR0049}) //'Sem conexão' ## 'Não foi possivel estabelecer uma conexão com o ambiente do ComprasNET. Código de Erro: ' ##"'Detalhes: '"  ##"Finalizar"
	Else
    	If SuperGetMv("MV_GCPCNMS",.F.,.F.)
      		Aviso(STR0050,STR0051 + cPostRet , {STR0049})	//'Retorno ComprasNet'  ## 'Mensagem Retorno ComprasNet: '
      	EndIf  
		//Resposta Integra	
		oXMLGCPCN 	:= XmlParser(cPostRet, 'WS', @cError, @cWarning)
		
		//-- Validacao de Erro
		If ValType(oXMLGCPCN) == 'O'
			
			//Valida Erro
			If Type("oXMLGCPCN:_SOAP_ENVELOPE:_SOAP_BODY:_SOAP_FAULT") == 'O'
				aAdd( aResult, "SOAP Fault: " + oXMLGCPCN:_SOAP_ENVELOPE:_SOAP_BODY:_SOAP_FAULT:_FAULTSTRING:Text )
				lRet:= .F.
			
			//-- Validaçao de licitacao
			ElseIf cTipo == 'Lic'
				
				//Tratamento em caso de ERRO
				If Type("oXMLGCPCN:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_INCLUIRLICITACAOSISPPRESPONSE:_RETURN:_ERRO") == 'A' 
					//Mais de um erro no retorno
					For nX := 1 to len(oXMLGCPCN:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_INCLUIRLICITACAOSISPPRESPONSE:_RETURN:_ERRO)
						aAdd( aResult, "INCLUIRLICITACAOSISPPRESPONSE Erro " + cValToChar(nX) + ": " + oXMLGCPCN:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_INCLUIRLICITACAOSISPPRESPONSE:_RETURN:_ERRO[nX]:Text )
					Next nX
					lRet := .F.
				ElseIf Type('oXMLGCPCN:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_INCLUIRLICITACAOSISPPRESPONSE:_RETURN:_ERRO') == 'O'	
					//Apenas um erro no retorno
					If "JÁ EXISTE UMA LICITAÇÃO" $ AllTrim( Upper( oXMLGCPCN:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_INCLUIRLICITACAOSISPPRESPONSE:_RETURN:_ERRO:Text ) )
						Conout( "[GCP][INT][WARN] INCLUIRLICITACAOSISPPRESPONSE:_RETURN:_ERRO:TEXT - " + AllTrim( oXMLGCPCN:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_INCLUIRLICITACAOSISPPRESPONSE:_RETURN:_ERRO:Text ) )
						lRet := .T.
					Else
						//Algum outro erro desconhecido
						aAdd( aResult, "INCLUIRLICITACAOSISPPRESPONSE: " + oXMLGCPCN:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_INCLUIRLICITACAOSISPPRESPONSE:_RETURN:_ERRO:Text )
						lRet := .F.
					EndIf									
				ElseIf Type("oXMLGCPCN:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_INCLUIRLICITACAOSISPPRESPONSE:_RETURN:_INFO") == 'O'
					//Tratamento em caso de sucesso
					If Type("oXMLGCPCN:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_INCLUIRLICITACAOSISPPRESPONSE:_RETURN:_INFO:TEXT") == "C"
						If AllTrim( Upper( oXMLGCPCN:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_INCLUIRLICITACAOSISPPRESPONSE:_RETURN:_INFO:TEXT ) ) $ "LICITAÇÃO INCLUÍDA"
							aAdd( aResult, STR0014 ) //"Licitação incluida com sucesso."
							lRet := .T.
						Else
							Conout( "[GCP][INT][WARN] INCLUIRLICITACAOSISPPRESPONSE:_RETURN:_INFO:TEXT - " + AllTrim( oXMLGCPCN:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_INCLUIRLICITACAOSISPPRESPONSE:_RETURN:_INFO:TEXT ) )
						EndIf*/
					Else
						aAdd( aResult, STR0075 + "'INCLUIRLICITACAOSISPPRESPONSE:_RETURN:_INFO'." ) //"Tipo de retorno inesperado para "
						lRet := .F.
					EndIf
				Else
					aAdd( aResult, STR0075 + "'INCLUIRLICITACAOSISPPRESPONSE'." ) //"Tipo de retorno inesperado para "
					lRet := .F.
				EndIf
				
			//-- Validaçao de Lote
			ElseIf cTipo == 'Lote'
				
				cMsg := STR0015 + AllTrim(cCod) + " - " //"Lote: "
				If Type("oXMLGCPCN:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_INCLUIRGRUPOSPRECOGLOBALRESPONSE:_RETURN:_ERRO") == 'O'					
					aAdd( aResult, "INCLUIRGRUPOSPRECOGLOBALRESPONSE: " + AllTrim( cMsg + oXMLGCPCN:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_INCLUIRGRUPOSPRECOGLOBALRESPONSE:_RETURN:_ERRO:Text ) )
					If !( "JÁ EXISTE UM GRUPO" $ Upper( aResult[Len(aResult)] ) )						
						lRet := .F.
					Else
						Conout( "[GCP][INT][WARN] INCLUIRGRUPOSPRECOGLOBALRESPONSE:_RETURN:_ERRO:TEXT - " + aResult[Len(aResult)] )
					EndIf
				ElseIf Type("oXMLGCPCN:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_INCLUIRGRUPOSPRECOGLOBALRESPONSE:_RETURN:_ERRO") == 'A'
					For nX := 1 to Len(oXMLGCPCN:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_INCLUIRGRUPOSPRECOGLOBALRESPONSE:_RETURN:_ERRO)
						aAdd( aResult, "INCLUIRGRUPOSPRECOGLOBALRESPONSE Erro " + cValToChar(nX) + ": " + cMsg + oXMLGCPCN:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_INCLUIRGRUPOSPRECOGLOBALRESPONSE:_RETURN:_ERRO[nX]:Text )
					Next nX
					lRet := .F.
				ElseIf Type("oXMLGCPCN:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_INCLUIRGRUPOSPRECOGLOBALRESPONSE:_RETURN:_INFO") == 'O'
					aAdd( aResult, cMsg + STR0016 ) //"Incluido com sucesso."
				Else
					aAdd( aResult, STR0075 + "'INCLUIRGRUPOSPRECOGLOBALRESPONSE'." ) //"Tipo de retorno inesperado para "
					lRet := .F.
				EndIf
				
			//-- Validacao de Item
			ElseIf cTipo == 'Item'
				
				cMsg := STR0017 + AllTrim(cCod) + " - " //"Item: "
				If Type("oXMLGCPCN:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_INCLUIRITENSLICITACAORESPONSE:_RETURN:_ERRO") == 'O'					
					aAdd( aResult, "INCLUIRITENSLICITACAORESPONSE: " + AllTrim( cMsg + oXMLGCPCN:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_INCLUIRITENSLICITACAORESPONSE:_RETURN:_ERRO:Text ) )
					If !( "JÁ EXISTE UM ITEM" $ Upper( aResult[Len(aResult)] ) ) .And. !( "JÁ POSSUI PESQUISA DE PREÇO DE MERCADO PARA" $ Upper( aResult[Len(aResult)] ) )						
						lRet := .F.
					Else
						Conout( "[GCP][INT][WARN] INCLUIRITENSLICITACAORESPONSE:_RETURN:_ERRO:TEXT - " + aResult[Len(aResult)] )
					EndIf
				ElseIf Type("oXMLGCPCN:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_INCLUIRITENSLICITACAORESPONSE:_RETURN:_ERRO") == 'A'
					For nX := 1 to Len(oXMLGCPCN:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_INCLUIRITENSLICITACAORESPONSE:_RETURN:_ERRO)
						aAdd( aResult, "INCLUIRITENSLICITACAORESPONSE Erro " + cValToChar(nX) + ": " + cMsg + oXMLGCPCN:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_INCLUIRITENSLICITACAORESPONSE:_RETURN:_ERRO[nX]:Text )
					Next nX
					lRet := .F.
				ElseIf Type("oXMLGCPCN:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_INCLUIRITENSLICITACAORESPONSE:_RETURN:_INFO") == 'O'
					aAdd( aResult, cMsg + STR0018 ) //"Incluido com sucesso."
				Else
					aAdd( aResult, STR0075 + "'INCLUIRITENSLICITACAORESPONSE'." ) //"Tipo de retorno inesperado para "
					lRet := .F.
				EndIf
				
			//-- Validacao de Exclusao	
			ElseIf cTipo == 'Exc'
				
				If Type("oXMLGCPCN:_SOAP_ENVELOPE:_SOAP_BODY:_SIAS_EXCLUIRLICITACAORESPONSE:_RETURN:_ERRO") == 'O'
					aAdd( aResult, "EXCLUIRLICITACAORESPONSE: " + cMsg + oXMLGCPCN:_SOAP_ENVELOPE:_SOAP_BODY:_SIAS_EXCLUIRLICITACAORESPONSE:_RETURN:_ERRO:Text )
					lRet := .F.
				ElseIf Type("oXMLGCPCN:_SOAP_ENVELOPE:_SOAP_BODY:_SIAS_EXCLUIRLICITACAORESPONSE:_RETURN:_ERRO") == 'A'
					For nX := 1 to Len(oXMLGCPCN:_SOAP_ENVELOPE:_SOAP_BODY:_SIAS_EXCLUIRLICITACAORESPONSE:_RETURN:_ERRO)
						aAdd( aResult, "EXCLUIRLICITACAORESPONSE Erro " + cValToChar(nX) + ": " + cMsg + oXMLGCPCN:_SOAP_ENVELOPE:_SOAP_BODY:_SIAS_EXCLUIRLICITACAORESPONSE:_RETURN:_ERRO[nX]:Text )
					Next nX
					lRet := .F.
				ElseIf Type("oXMLGCPCN:_SOAP_ENVELOPE:_SOAP_BODY:_SIAS_EXCLUIRLICITACAORESPONSE:_RETURN:_INFO") == 'O'
					aAdd( aResult, cMsg + STR0019 ) //"Excluido com sucesso."
				Else
					aAdd( aResult, STR0075 + "'EXCLUIRLICITACAORESPONSE'." ) //"Tipo de retorno inesperado para "
					lRet := .F.
				EndIf
				
			EndIf
			
		Else
		
			//Exibe a descricao do erro no parser do retorno.
			If !Empty(cError)
				Aviso(STR0052, STR0053 + chr(13) + chr(10) + STR0048 + cError,{STR0049}) 	//'Falha de comunicação' ## 'Um ou mais erros ocorreram na comunicação com o ambiente do ComprasNET. '
			ElseIf !Empty(cWarning)
				Aviso(STR0052, STR0053 + chr(13) + chr(10) + STR0048 + cWarning,{STR0049}) 	//'Falha de comunicação' ## 'Um ou mais erros ocorreram na comunicação com o ambiente do ComprasNET. '
			EndIf
			
			AAdd( aResult, STR0020 ) //"Não Foi possível conectar ao comprasnet, verifique sua conexão ou sua auteticação pode estar incorreta."
			lRet := .F.
			
		EndIf
	EndIf			
Else
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPCNVldCN
Funcao responsavel pela validação das informações do modelo antes
do envio para o compras net.

@author alexandre.gimenez	

@param oModel - Modelo de dados

@return lRet - Retorno com status da validacao
@since 02/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function GCPCNVldCN(oModel)
Local aArea		:= GetArea() 
Local aSaveLines	:= FWSaveRows()
Local lRet 	:= .T.
Local lLote	:= oModel:GetValue("CO1MASTER","CO1_AVAL") <> "1"
Local nX		:= 0
Local nI		:= 0
Local nY		:= 0
Local nLotes	:= IIF(lLote,oModel:GetModel('CP3DETAIL'):Length(),1)
Local nFor		:= 0
Local lMsg		:= .F.

//-- Validar se o campos no B5 tem valor
For nX := 1 to nLotes
	If lLote
		oModel:GetModel('CP3DETAIL'):GoLine(nX)
	EndIf
	For nY := 1 to oModel:GetModel('CO2DETAIL'):Length()
		oModel:GetModel('CO2DETAIL'):GoLine(nY)
		If SB5->(DbSeek(xFilial("SB5")+oModel:GetValue('CO2DETAIL','CO2_CODPRO')))
			If Empty(SB5->B5_TIPO)
				lRet := .F.
				Help(' ', 1,STR0061,,STR0021+oModel:GetValue('CO2DETAIL','CO2_CODPRO')+STR0022,1,0)//"O produto '"//"' não possui Tipo de produto(B5_TIPO) Material ou Servico"
			ElseIf Empty(SB5->B5_CATMAT)
				lRet := .F.
				Help(' ', 1,STR0062,,STR0023+oModel:GetValue('CO2DETAIL','CO2_CODPRO')+STR0024,1,0)//"O produto '"//"' não esta vinculado ao CATMAT (B5_CATMAT)"
			ElseIf Empty(SB5->B5_DEC7174)
				Help(' ', 1,STR0063,,STR0025+oModel:GetValue('CO2DETAIL','CO2_CODPRO')+STR0026,1,0)//"O produto '"//"' não especifica se o atende o Decreto 7174(B5_DEC7174)Sim ou Não"
			EndIf
			//CEME
			//MARGPRE
		Else 
			lRet := .F.
			Help(' ', 1,STR0064,,STR0027+oModel:GetValue('CO2DETAIL','CO2_CODPRO')+"'",1,0)//"Não existem dados complemetares(SB5) para o produto '"
		EndIf
		If !lRet
			Exit
		EndIf
	Next nY
	If !lRet
		Exit
	EndIf
Next nX

//-- Validar justificativa para lote.
If lLote .And. lRet
	For nX := 1 to oModel:GetModel("CP3DETAIL"):Length()
		If Empty(oModel:GetValue("CP3DETAIL","CP3_JUSTIF"))
			lRet:= .F.
			Help(' ', 1,'A200CNJUSTIF') //É obrigatório informar uma justificativa pela formação do lote, sua formação não favorece a concorrência.             
			Exit			
		EndIf	
	Next nX
	
	//-- Validacao de consistencia do lote
	If lRet
		//-- Margem de Preferencia
		lRet := GCPCNVldLt(oModel,"B5_MARGPRE","SB5",{{'CO2DETAIL','CO2_CODPRO'}},1)
		//-- Decreto 7174
		If lRet
			lRet := GCPCNVldLt(oModel,"B5_DEC7174","SB5",{{'CO2DETAIL','CO2_CODPRO'}},1)
		EndIf
		//-- Diferenca Minima entre lances
		If lRet
			lRet := GCPCNVldLt(oModel,"CO2_DIFMIN")
		EndIf
	EndIf
EndIf

//-- Valida Locais de entrega
If lRet
	lRet := A200VldLcE(oModel,.T.)
	If !lRet
		Help(' ', 1,'A200CNLOCALENT')//A soma das quantidades nos locais de entrega não coincidem com as quantidades licitadas
	EndIf
EndIf

//-- Valida se existem fornecedores
If lRet
	If lLote
		nFor := oModel:GetModel("CP3DETAIL"):Length()
	Else
		nFor := oModel:GetModel("CO2DETAIL"):Length()
	EndIf
	For nX := 1 to nFor
		If lLote
			oModel:GetModel("CP3DETAIL"):GoLine(nX)
		Else
			oModel:GetModel("CO2DETAIL"):GoLine(nX)	
		EndIf
		If !oModel:GetModel("CO3DETAIL"):IsEmpty()
			If !lMsg
				lRet := MSGYESNO(STR0028,STR0029)//"Existem Licitantes cadastrados, para proseguir com a integração é necessario exclui-los. Deseja exclui-los?"//"Atenção"
				lMsg := .T.
			EndIf
			If lRet
				For nI := 1 to oModel:GetModel("CO3DETAIL"):Length()
					oModel:GetModel("CO3DETAIL"):GoLine(nI)
					oModel:GetModel("CO3DETAIL"):DeleteLine()
				Next nI
			EndIf
		EndIf
	Next nX
EndIf
RestArea(aArea)
FWRestRows( aSaveLines )
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A200MsgCN
Inicia Processo de busca resultado no Compras Net.

@author Matheus Lando Raimundo
@param oModel
@since 08/01/2014
@version P11.90
@return lRet
/*/
//-----------------------------------------------------------------			--
Function A200MsgCN()

MsgRun(STR0030,STR0031,{||A200AtCpNet()}) //'Integrando Compras Net'//'Compras Net'

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} A200AtCpNet
Rotina que executa a integração com o Compras Net.

@author Matheus Lando Raimundo
@param oModel
@since 08/01/2014
@version P11.90
@return lRet
/*/
//-------------------------------------------------------------------
Static Function A200AtCpNet()
Local cAmbient		:= SuperGetMv("MV_GCPACN",.F.,1) // 1=Treinamento e 2=Producao // Parametro???
Local lLote		:= CO1->CO1_AVAL <> "1"
Local cUrl 	 	:= ""
Local nTimeOut 	:= 120
Local aEdital 	 	:= {}
Local aProds		:= {}
Local oModel 		:= Nil
Local oCO1Master 	:= Nil  	
Local oCO2Detail 	:= Nil  
Local nI	       	:= 0 			
Local nY			:= 0
Local nLotes		:= 0

If lLote
	oModel :=	FWLoadModel('GCPA201')
Else
	oModel :=	FWLoadModel('GCPA200')
EndIf

If CO1->CO1_STATUS == '7' .And. CO1->CO1_INTEGR == '2'

	oModel:SetOperation(MODEL_OPERATION_UPDATE)
	oModel:Activate()
	oCO1Master :=  oModel:GetModel('CO1MASTER')
	oCO2Detail :=  oModel:GetModel('CO2DETAIL')
	
	//-- Tratamento de Ambiente
	If cAmbient == '2'
		cUrl := "https://www.comprasnet.gov.br/XML/producao/resultado.asp"
		Aadd(aEdital, 'produção')
	Else
		cUrl := "https://www.comprasnet.gov.br/XML/treinamento/resultado.asp"
		Aadd(aEdital, 'treinamento')
	EndIf	
		
	Aadd(aEdital, SuperGetMV("MV_GCPUASG", .F., ""))	 
	Aadd(aEdital, A200MdCNt(oCO1Master:GetValue('CO1_MODALI'))) 
	Aadd(aEdital, oCO1Master:GetValue('CO1_CODEDT')) 
	Aadd(aEdital, Str(Year(oCO1Master:GetValue('CO1_DTABER'))))
	Aadd(aEdital, STR0032)//'Protheus'

	nLotes := IIF(lLote,oModel:GetModel('CP3DETAIL'):Length(),1)	
	For nY := 1 To nLotes
		If lLote
			oModel:GetModel('CP3DETAIL'):GoLine(nY)
		EndIf
		For nI := 1 To oCO2Detail:Length()
			oCO2Detail:GoLine(nI)
			Aadd(aProds, {AllTrim(Str(oCO2Detail:GetValue('CO2_ITEMCN'))),oCO2Detail:GetValue('CO2_ITEM'),oCO2Detail:GetValue('CO2_LOTE')  } )
		Next nI	
	Next nY
	
	Aadd(aEdital, aProds)
	
	A200CpNet(cUrl, nTimeOut, aEdital, @oModel,lLote)
Else
	Help(' ', 1,'A200CNNOINT') //Este edital não econtra-se integrado com o portal ComprasNet    
EndIf	
	
Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} A200CpNet
Rotina que executa a integração com o Compras Net.

@author Matheus Lando Raimundo
@param oModel
@since 08/01/2014
@version P11.90
@return lRet
/*/
//-------------------------------------------------------------------
Function A200CpNet(cUrl, nTimeOut, aEdital, oModel,lLote) 
Local lRet		:= .F.
Local sPostRet	:= "" 
Local aHeadOut	:= {}
Local cHeadRet	:= ""
Local nI			:= 0
Local nY			:= 0
Local cError 		:= ''
Local cWarning	:= ''
Local oXML			:= Nil
Local aUser		:= Nil
Local nItem		:= 0
Local cCodEdt 	:= Alltrim(aEdital[4])
Local cCodCN   	:= AllTrim(Substr(cCodEdt,Len(cCodEdt) -4,5)) + AllTrim(aEdital[5])
Local lCont		:= .F.
Local cGCPRes     := SuperGetMv("MV_GCPCNRE",.F.,"2")	

//-- Recupera usuario e senha
aUser := GCPCNUser(2)

If ValType(aUser) == 'A' .And. Len(aUser) > 0 
cXmlR := '<?xml version="1.0" encoding="ISO-8859-1"?>'
cXmlR += '<cnet xmlns="cnet_resultado">'
cXmlR += " <ambiente>"+aEdital[1]+"</ambiente>"
cXmlR += " <cpf>"+AllTrim(aUser[1])+"</cpf>" //
cXmlR += " <senha>"+AllTrim(aUser[2])+"</senha>" //
cXmlR += " <uasg>"+aEdital[2]+"</uasg>"
cXmlR += " <modalidade>"+aEdital[3]+"</modalidade>"
cXmlR += " <numero>"+aEdital[4]+"</numero>"
cXmlR += " <ano>"+aEdital[5]+"</ano>"
cXmlR += " <sistema>"+aEdital[6]+"</sistema>"
cXmlR += " <itens>"
For nI := 1 To Len(aEdital[7])	
	cXmlR += "  <item>"
	cXmlR += "   <acao_item>consulta</acao_item>"
	cXmlR += "   <num_item>"+Alltrim(Str(Val(aEdital[7,nI,1])))+"</num_item>"
	cXmlR += "   <cpfcnpj></cpfcnpj>"
	cXmlR += "   <marca></marca>"
	cXmlR += "   <quantidade></quantidade>"
	cXmlR += "   <valor_total></valor_total>"
	cXmlR += "  </item>"
Next nI

cXmlR += " </itens>"
cXmlR += "</cnet>"

cXmlR := "xml=" + FWPercentEncode(cXmlR)

/*
Vetor que passa os dados para o site
aEdital[1] = Ambiente  = Treinamento
aEdital[2] = UASG = 158122
aEdital[3] = Código da Modalidade = 5
aEdital[4] = Número do Edital = 1
aEdital[5] = Ano do Edital = 2010
aEdital[6] = Sistema  = testexml
aEdital[7][1] = ItemCN = 00001
aEdital[7][2] = Item = 00001
aEdital[7][3] = Lote = 00001
*/

nLotes := IIF(lLote,oModel:GetModel('CP3DETAIL'):Length(),1)
If cGCPRes == "1"
	If Len(aUser) > 0

	aadd(aHeadOut,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')')
	aadd(aHeadOut,'Content-Type: application/x-www-form-urlencoded')
	sPostRet := HttpPost(cUrl,"",cXmlR,nTimeOut,aHeadOut,@cHeadRet)
	oXML := XmlParser( sPostRet, 'WS', @cError, @cWarning )
	If oXML:_CNET:_ERROXML:Text == '0' 
		If Alltrim(oXML:_CNET:_Resultado:Text) == 'RESULTADO DA LICITACAO ENCERRADO'
			If Len(aEdital[7]) > 1					
				For nY := 1 To nLotes
					If lLote
						oModel:GetModel('CP3DETAIL'):GoLine(nY)
					EndIf
					For nI := 1 To oModel:GetModel('CO2DETAIL'):Length()
						oModel:GetModel('CO2DETAIL'):GoLine(nI)
						nItem++											
						A200ExstF(oXML:_CNET:_DADOS:_DADO[nItem], @oModel)	
					Next nI	
				Next nY
			Else
				A200ExstF(oXML:_CNET:_DADOS:_DADO, @oModel)			
				lCont := .T.		
			EndIf
		Else
			Help('', 1, 'GCPCNAOFIM')//O edital no portal ComprasNet não encontra-se finalizado.       
		EndIf
	Else
		Help('', 1, STR0065, ,STR0033 + oXML:_CNET:_ERROXML:Text , 4)			//'Erro Integração, código erro:'
	EndIf										
Else
		Help(' ', 1,STR0066,,STR0067 ,1,0)	//"Integração não realizada, Informe os dados para autenticação"
		EndIf
Else
			cPrgCod := GetPrgCodCN(aEdital[2],cCodCN)
      //
      
			If !Empty(cPrgCod)												
	  		If lLote
	      		nTotal := oModel:GetModel('CP3DETAIL'):Length(.T.)
      			
      			
      			For nY := 1 To oModel:GetModel('CP3DETAIL'):Length()
					oModel:GetModel('CP3DETAIL'):GoLine(nY)
      				nItem++
      				 
                                                                                                          
                	aResult := GetVencCN(Str(nItem),nY == nTotal,aEdital[2],cPrgCod,@nItem,lLote,.F.)
                                    	                             
			
			lRet  := !Empty(cPrgCod) .And. Len(aResult) > 0						
			
			If lRet
                		A200ExstF(Nil,@oModel,aResult,If(Len(aResult[4]) > 0,75,0),lLote)
				lCont := .T.						
			EndIf							
	Next nY
			Else
				nTotal := oModel:GetModel('CO2DETAIL'):Length(.T.)
				For nI := 1 To oModel:GetModel('CO2DETAIL'):Length()
					oModel:GetModel('CO2DETAIL'):GoLine(nI)
					nItem++
							
					If !Empty(cPrgCod)												
                        aResult := GetVencCN(Str(nItem),nI == nTotal,aEdital[2],cPrgCod,@nItem,lLote,.F.)    
					EndIf						
			
					lRet  := !Empty(cPrgCod) .And. Len(aResult) > 0						
			
					If lRet
                		A200ExstF(Nil,@oModel,aResult,If(Len(aResult[4]) > 0 ,75,0))
						lCont := .T.						
					EndIf							
				Next nI	
			
			EndIf	      			
   		Else
      		Help(' ', 1,STR0068,,STR0054 ,1,0)	//"Integração não realizada, O Edital não foi localizado no comprasnet "
      	EndIf

EndIf
	
//-- Executa a funcao condicional da etapa
//Atualizar etapa e chamar andamento.
If lCont
	oModel:LoadValue('CO1MASTER','CO1_ETAPA','AD')
	oModel:LoadValue('CO1MASTER','CO1_STATUS','1')
	lRet := GCPWinner(oModel)
	If lRet .And. oModel:VldData()
		oModel:CommitData()	
		oModel:DeActivate()
		If CO1->CO1_STATUS == '1' 
			GCP200Perm()
		EndIf
	Else	  	
	 	Help(' ', 1,STR0068,, STR0055 + CRLF + Alltrim(oModel:AerrorMessage[6]) ,1,0)	//"Integração não realizada, erro de validação: " 
	EndIf
Else
	Help(' ', 1,STR0069,, STR0056,1,0)	//"Pregão sem vencedores, integração não realizada" 				
EndIf						
EndIf    
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A200ExstF(oProd, oModel)
Rotina que trata os fornecedores vindo do Compras Net.

@author Matheus Lando Raimundo
@param oModel
@since 08/01/2014
@version P11.90
@return lRet
/*/
//-----------------------------------------------------------------			--
Function A200ExstF(oProd, oModel, aCNet, nPerc,lLote)
Local lRet 	:= .T.
Local cCodigo := ""
Local cLoja	:= ""
Local cCNPJ 	:= ""//oProd:_CPFCNPJ_VENCEDOR:Text
Local cProd   	:= ""//oProd:_CODIGO_MAT_SERV:Text
Local nVlUnit 	:= ""//GCPCNConvV(oProd:_VALOR_UNITARIO:Text)
Local aDadosPreF := {}
Local cForn 	:= ""

Default nPerc := 0
 
If Len(aCnet) > 0
	cCNPJ 		:= aCnet[1]	
	nVlUnit 	:= aCnet[2]
	cForn		:= aCnet[3]
ElseIf ValType(oProd) == 'O'
	cCNPJ 	 := oProd:_CPFCNPJ_VENCEDOR:Text
 	cProd   := oProd:_CODIGO_MAT_SERV:Text
	nVlUnit := GCPCNConvV(oProd:_VALOR_UNITARIO:Text)
	cForn := oProd:_RAZAO_SOCIAL_VENCEDOR:TEXT
EndIf


SA2->(DbSetOrder(3))
CO6->(DbSetOrder(2))

If !Empty(cCNPJ) //Valida se existe Vencedor 
	//Já existe o Fornecedor
	If SA2->(DbSeek(xFilial("SA2")+cCNPJ))
		cCodigo := SA2->A2_COD
		cLoja 	 := SA2->A2_LOJA
            GCPCNAddWn(cProd, cLoja, cCodigo, '2', nVlUnit,nPerc,If(lLote,aCNet[5],{}))     
	Else
		If CO6->(DbSeek(xFilial("CO6")+cCNPJ))
			cCodigo := CO6->CO6_CODIGO
			cLoja 	 := CO6->CO6_LOJFOR
		Else
			//--Inclui como pre fornecedor
			cCodigo := GetSXENum('CO6','CO6_CODIGO')
			cLoja 	 := '1' 
			Aadd(aDadosPreF, cCodigo)
			Aadd(aDadosPreF, 'F')
			Aadd(aDadosPreF, cCNPJ)
			Aadd(aDadosPreF, cForn)
			Aadd(aDadosPreF, cLoja)	
			lRet := GCPIncPreF(aDadosPreF)
			If lRet
				ConfirmSX8()
			EndIf		
			//-- Restaura o modelo antigo
			oModel:Activate()		
		EndIf
		If lRet
                  GCPCNAddWn(cProd, cLoja, cCodigo, '1', nVlUnit,nPerc,If(lLote,aCNet[5],{}))
		EndIf		 		
	EndIf
Else
	lRet:= .F.
EndIf

If Len(aCNet[4]) > 0       
	A200ExstF(oProd, oModel, aCNet[4],25)
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} GCPCNAddWn
Rotina que adiciona o licitante vencedor do comprasnet.

@author Matheus Lando Raimundo
@param oModel
@since 08/01/2014
@version P11.90
@return lRet
/*/
//-------------------------------------------------------------------
Function GCPCNAddWn(cProd, cLoja, cCodigo, cTipo, nVlUnit,nPerc,aCompLote)
Local oModel 	  	:= FWModelActive()
Local oCO3Detail	:= oModel:GetModel('CO3DETAIL')
Local oCP6Detail 	:= Nil 
Local lLote		:= CO1->CO1_AVAL <> "1"	
Local nI			:= 0

Default nPerc := 0
Default aCompLote := {}


//-- Abre o Modelo
CNTA300BlMd(oCO3Detail, .F.)		
 
If !Empty(oCO3Detail:GetValue('CO3_CODIGO'))
	oCO3Detail:AddLine()
EndIf

If nPerc == 75 .Or. nPerc == 25
	oCO3Detail:LoadValue('CO3_PERCEN',nPerc)
	If lLote
		oModel:GetModel('CO2DETAIL'):LoadValue('CO2_PARTEX','3')
	Else
		oModel:GetModel('CP3DETAIL'):LoadValue('CP3_PARTEX','3')
	
	EndIf			
EndIf

oCO3Detail:SetValue('CO3_TIPO', cTipo)
oCO3Detail:SetValue('CO3_CODIGO', cCodigo)	
oCO3Detail:SetValue('CO3_LOJA',cLoja)				
oCO3Detail:LoadValue('CO3_STATUS','5')

If lLote
	oCP6Detail := oModel:GetModel('CP6DETAIL')
	oCP6Detail:GetStruct():setProperty('CP6_PRCUN',MODEL_FIELD_WHEN,{||.T.})
	oCP6Detail:GetStruct():setProperty('CP6_PRCUN2',MODEL_FIELD_WHEN,{||.T.})
	
	oCP6Detail:SetNoUpdateLine(.F.)	
	For nI := 1 To Len(aCompLote)
   		oCP6Detail:GoLine(nI)
  		If nPerc <> 25 
  			oCP6Detail:SetValue('CP6_PRCUN',aCompLote[nI,3])
Else
			oCP6Detail:SetValue('CP6_PRCUN2',aCompLote[nI,3])
		EndIf  			
	Next nI
EndIf
	oCO3Detail:SetValue('CO3_VLUNIT',nVlUnit)

//-- fecha o Modelo
CNTA300BlMd(oCO3Detail, .T.)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPIncPreF(aDados)
Função que inclui um pré fornecedor

@author Matheus Lando
@since 02/12/2013
@version P11.90
@return lRet
/*/
//-------------------------------------------------------------------
Function GCPIncPreF(aDados)
Local lRet 		:= .F.
Local oModel  	:= FWLoadModel('GCPA003')
Local oCO6Master 	:= oModel:GetModel('CO6MASTER')
Local nTam 		:= TamSx3("CO6_NOME")[1]

oModel:SetOperation(3)                                 
oModel:Activate()

oCO6Master:SetValue('CO6_CODIGO',aDados[1])
//oCO6Master:LoadValue('CO6_TIPO',aDados[2]) // Inicializador padrao F
oCO6Master:SetValue('CO6_CNPJ',aDados[3])
oCO6Master:SetValue('CO6_NOME',AllTrim(SubStr(aDados[4],1,nTam )))
oCO6Master:SetValue('CO6_LOJFOR',aDados[5])

If oModel:VldData()
	lRet := .T.  
	oModel:CommitData()	
EndIf	

oModel:DeActivate()		

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} A200MdCNt
Rotina que rotona a modalidade de acordo com o código do compras net.

@author Matheus Lando Raimundo
@param oModel
@since 08/01/2014
@version P11.90
@return lRet
/*/
//-------------------------------------------------------------------
Function A200MdCNt(cModali)
cRet := ""

Do Case
	Case cModali == 'CV'        
    	cRet := '01'
   	Case cModali == 'TP'        
    	cRet := '02'
	Case cModali == 'CC'        
    	cRet := '03'
    Case cModali == 'CI'        
    	cRet := '04'
	Case cModali == 'PG'        
    	cRet := '05'    	    	                                                      
EndCase	
	
Return cRet 


//-------------------------------------------------------------------
/*/{Protheus.doc} GCPCNVldLt
Função com a finalidade de verificar se todos os produtos de um lote
possuiem o mesmo valor em um determinado campo.

@author alexandre.gimenez
@param oModel - Modelo de Dados
@param cCampoBsc - Campo que será verificado
@param cAliasBsc - Alias de Busca - Padrão CO2 propria tabela
@param aChaveBsc - Campos que compoe a chave de busca {Modelo,Campo}- Não necessario para Alias CO2
@param nIndcBsc - Indice de busca - Não necessario para Alias CO2

@since 10/04/2014
@version P12
@return lRet
/*/
//-------------------------------------------------------------------
Static Function GCPCNVldLt(oModel,cCampoBsc,cAliasBsc,aChaveBsc,nIndcBsc)
Local lRet		:=  .T.
Local nL		:= 0
Local nI		:= 0
Local nC		:= 0
Local xRef		:= Nil
Local xValue	:= Nil 
Local cChave	:= ''
Local lBsc		:= .T.

Default cAliasBsc := 'CO2'
Default aChaveBsc := {}
Default nIndcBsc	:= 1

//-- Verifica se busca externa
lBsc := cAliasBsc # 'CO2'

For nL := 1 to oModel:GetModel("CP3DETAIL"):Length()
	oModel:GetModel("CP3DETAIL"):GoLine(nL)
	oModel:GetModel("CO2DETAIL"):GoLine(1)
	//-- Valor de Referencia
	If lBsc
		cChave := xFilial(cAliasBsc)
		For nC := 1 to Len(aChaveBsc)
			cChave += oModel:GetValue(aChaveBsc[nC,1],aChaveBsc[nC,2])
		Next nC
		xRef := Posicione(cAliasBsc,nIndcBsc,cChave,cCampoBsc)
	Else
		xRef := oModel:GetValue('CO2DETAIL',cCampoBsc)
	EndIf
	
	For nI := 1 to oModel:GetModel("CO2DETAIL"):Length()
		oModel:GetModel("CO2DETAIL"):GoLine(nI)
		//-- Valor de cada item
		If lBsc
			cChave := xFilial(cAliasBsc)
			For nC := 1 to Len(aChaveBsc)
				cChave += oModel:GetValue(aChaveBsc[nC,1],aChaveBsc[nC,2])
			Next nC
			xValue := Posicione(cAliasBsc,nIndcBsc,cChave,cCampoBsc)
		Else
			xValue := oModel:GetValue('CO2DETAIL',cCampoBsc)
		EndIf
		
		//-- Validacao
		If !(xRef == xValue)
			lRet := .F.
			Help('', 1, STR0070, ,STR0034+oModel:GetValue('CP3DETAIL','CP3_LOTE')+STR0035+cCampoBsc+STR0036, 4)//'Valores diferentes no lote: '//' campo: '//'. Todos devem ser iguais dentro do lote.'
			Exit
		EndIf		
	Next nI
	If !lRet
		Exit
	EndIf
Next nL

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A200VldLcE
Funcao para validar locais de entrega

@author alexandre.gimenez
@param oModel - Modelo de Dados
@param lAll   - Valida todo os produtos ou somente o Posicionado, Padrao Posicionado
@since 10/04/2014
@version P12
@return lRet
/*/
//-------------------------------------------------------------------
Function A200VldLcE(oModel,lAll)
Local lRet		:= .T.
Local lProLote:= .T.
Local lProItem:= .T.
Local nE		:= 0
Local nSum		:= 0
Local lLote	:= oModel:GetValue("CO1MASTER","CO1_AVAL") <> "1"

Default lAll := .F.

//-- Posiciona para rodar todos os itens
If lAll
	If lLote
		oModel:GetModel("CP3DETAIL"):GoLine(1)
	EndIf
	oModel:GetModel("CO2DETAIL"):GoLine(1)
EndIf

While lProLote
	//--Processa Lote
	While lProItem
		//-- Processa Item
		nSum := 0 //-- Zera soma
		For nE := 1 To oModel:GetModel('CPTDETAIL'):Length()
			oModel:GetModel('CPTDETAIL'):GoLine(nE)
			nSum += oModel:GetValue('CPTDETAIL','CPT_QUANT')
		Next nE
		If nSum # oModel:GetValue('CO2DETAIL','CO2_QUANT') 
			lRet := .F.
		EndIf

		//-- Validacoes para continuar processando item
		If lRet .And. lAll .And. oModel:GetModel("CO2DETAIL"):GetLine() <> oModel:GetModel("CO2DETAIL"):Length()
			//-- Proximo item
			oModel:GetModel("CO2DETAIL"):GoLine(oModel:GetModel("CO2DETAIL"):GetLine()+1) 
		Else
			//-- Erro de Validaçao, Somente Poscionado ou Ultima Linha
			lProItem := .F.
		EndIf
	End
	//-- Validaccoes para continuar processando lote
	If lRet .And. lLote .And. lAll .And. oModel:GetModel("CP3DETAIL"):GetLine() <> oModel:GetModel("CP3DETAIL"):Length()
		//-- Vai para Proximo Lote
		oModel:GetModel("CP3DETAIL"):GoLine(oModel:GetModel("CP3DETAIL"):GetLine()+1) // Vai para Proxima Linha
		lProItem := .T.
	Else
		//-- Erro de Validacao, não usa lote, Somente Poscionado ou Ultima Linha
		lProLote := .F. // Ultimo lote nao processa mais
	EndIf
End

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPRevgEdt()
Função para revogar todos os itens do edital, e move-lo para finalizado

@author alexandre.gimenez
@param oModel - Modelo de Dados
@since 10/04/2014
@version P12
@return lRet
/*/
//-------------------------------------------------------------------
Function GCPRevgEdt(oModel)
	Local lLote	   := oModel:GetValue("CO1MASTER","CO1_AVAL") <> "1"
	Local nLotes	   := IIF(lLote,oModel:GetModel('CP3DETAIL'):Length(),1)
	Local nX		   := 0
	Local nY		   := 0
	Local lCO2Update := oModel:GetModel('CO2DETAIL'):CanUpdateLine()
	Local lCP3Update := IIF(lLote,oModel:GetModel('CP3DETAIL'):CanUpdateLine(),.F.)
	Local lFunGrv		:= IsInCallStack("GCP200Grv")
	Local lLei13303		:= oModel:GetValue('CO1MASTER','CO1_LEI') == "5"
	
	If !lCO2Update
		oModel:GetModel('CO2DETAIL'):SetNoUpdateLine(.F.)
	EndIf	

	For nX := 1 to nLotes
		If lLote
			If !lCP3Update
				oModel:GetModel('CP3DETAIL'):SetNoUpdateLine(.F.)
			EndIf	
			oModel:GetModel('CP3DETAIL'):GoLine(nX)
			oModel:LoadValue('CP3DETAIL','CP3_STATUS','2')
			If !lCP3Update
				oModel:GetModel('CP3DETAIL'):SetNoUpdateLine(.T.)
			EndIf
		EndIf
		For nY := 1 to oModel:GetModel('CO2DETAIL'):Length()
			oModel:GetModel('CO2DETAIL'):GoLine(nY)
			oModel:LoadValue('CO2DETAIL','CO2_STATUS','2')
			Next nY
	Next nX
	oModel:LoadValue('CO1MASTER','CO1_ETAPA','FI')

	If IsIncallStack("GCP200RvAn") //Anulado
		oModel:LoadValue('CO1MASTER','CO1_STATUS','8')
	ElseIf IsIncallStack("GCP200RvCn") //Cancelado
		oModel:LoadValue('CO1MASTER','CO1_STATUS','9')
	ElseIf IsIncallStack("GCP200RvRv") .Or. (lLei13303 .And. lFunGrv)//Revogado
		oModel:LoadValue('CO1MASTER','CO1_STATUS','A')
	Else
		oModel:LoadValue('CO1MASTER','CO1_STATUS','5')
	EndIf
		
	If !lCO2Update
		oModel:GetModel('CO2DETAIL'):SetNoUpdateLine(.T.)
	EndIf
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} StrCpNet()
Formatação de string para o compras net.

@author Matheus Lando Raimundo
/*/
//-------------------------------------------------------------------
Function StrCpNet(cStr)

cStr := Upper(SubStr(cStr,1,1)) + Lower(SubStr(cStr,2,Len(cStr)))

Return cStr


//-------------------------------------------------------------------
/*/{Protheus.doc} GetVencCN()
Retorna o vencedor de um item do Edital no ComprasNet.

@author Matheus Lando Raimundo
/*/
//-------------------------------------------------------------------
Function GetVencCN(cItem,lLast,cUasg,cPrgCod,nItem,lLote,lItemLote,cItemLote) 
Local cAux		:= ""
Local cItemIni := ""
Local cItemFim := ""
Local nIni     := 0
Local nFim     := 0
Local cCNPJ    := ''
Local nCNPJ    := 0
Local aItens	 := {}
Local aResult	 := {}
Local cValor	 := ""
Local nForn    := 0
Local cForn    := ""
Local nI		 := 0
Local nQtd		 := 0
Local nQuant	 := 0
Local cHtml        := ""
Local lCota      := .F.
Local cAval	 := ""
Local aCompLote	:= {}


If !lLote
	cAval := "Item: "
Else
	cAval := "Grupo "
EndIf

//-- =^.^=
If SuperGetMv("MV_GCPACN",.F.,"1") == '1'
      cHtml := Httpget('http://treinamento.comprasnet.gov.br/livre/pregao/termojulg.asp?prgcod=' + cPrgCod + '&Acao=A&co_no_uasg=' + cUasg + '&numprp='  + cPrgCod + '&f_lstSrp=&f_Uf=&f_numPrp=' +cPrgCod + '&f_coduasg=' + cUasg + '&f_tpPregao=E&f_lstICMS=&f_dtAberturaIni=&f_dtAberturaFim=')         
Else
      cHtml := Httpget('http://comprasnet.gov.br/livre/pregao/termojulg.asp?prgcod=' + cPrgCod + '&Acao=A&co_no_uasg=' + cUasg + '&numprp='  + cPrgCod + '&f_lstSrp=&f_Uf=&f_numPrp=' +cPrgCod + '&f_coduasg=' + cUasg + '&f_tpPregao=E&f_lstICMS=&f_dtAberturaIni=&f_dtAberturaFim=')
EndIf
If ValType(cHtml) == 'C'
	If !(Upper('Este pregão não possui termo de adjudicação') $ cHtml)
    	If lItemLote
        	cItemIni := UPPER('Item: '+ Alltrim(Str(Val(cItemLote))) + ' - GRUPO ' + Alltrim(Str(Val(cItem))))
        Else
        	cItemIni := UPPER(cAval + Alltrim(Str(Val(cItem))))
		EndIf                       
		If !lLast	
        	If !Empty(cItemLote)
            	cItemFim := UPPER('Item: '+ Soma1(Alltrim(Str(Val(cItemLote)))) + ' - GRUPO ' + Alltrim(Str(Val(cItem))))	
           	Else
            	cItemFim := UPPER(cAval + Soma1(Alltrim(Str(Val(cItem)))))	
           	EndIf 
		Else
			cItemFim := UPPER('Voltar')
		EndIf
				
		cHtml := UPPER(cHtml)
		nIni := At(cItemIni,cHtml)
		nFim := At(cItemFim,cHtml)
          
		
		cAux	:= Substr(cHtml,nIni,nFim-nIni)
            
            
        If (Upper('Item Participação Aberta') $ cAux) .And. cItemFim  <> UPPER('Voltar')  
        	lCota := .T.
        EndIf
            
        If !lLote
		nIni   := At('QUANTIDADE:',cAux)			
		Else
			nIni   := At('ADJUDICADO PARA:',cAux)
		EndIf            	              
		
		cAux := SubStr(cAux,nIni,nFim-nIni)
		
            
		nCNPJ  := At('CNPJ/CPF:',cAux)
		If nCNPJ > 0		
			While .T.
				If "  " $ cAux
					cAux := Replace(cAux,"  "," ")	
				Else
					exit
				EndIf		
			EndDo
			
			aItens := Separa(cAux, " ")
	        If !lItemLote      
			nForn := aScan(aItens,'FORNECEDOR:')
			nCNPJ := aScan(aItens,'CNPJ/CPF:')	
			
	        	If aItens[nCNPJ] == 'CNPJ/CPF:' 
	        		cCNPJ := aItens[nCNPJ+1]                  	
	        	Else                       
	        		cCNPJ := SubStr(aItens[nCNPJ],10,Len(aItens[nCNPJ]))                                                	
				EndIf                  	
			 
	            cCNPJ := Replace(cCNPJ,'/','')
				cCNPJ := Replace(cCNPJ,'.','')
				cCNPJ := Replace(cCNPJ,'-','')
				cCNPJ := Replace(cCNPJ,',','')
			
	                 	 
				For nI := 1 To Len(aItens)
	        		If aItens[nForn] == 'FORNECEDOR:'
						If aItens[nForn + nI] <> 'CNPJ/CPF:'
							cForn += aItens[nForn + nI] + " "
						Else
							Exit
						EndIf			
					Else
						If nI == 1
							cForn += Substr(aItens[nForn],12,Len(aItens[nForn])) + " "
						EndIf										
						If aItens[nForn + nI] <> 'CNPJ/CPF:'
	                		cForn += aItens[nForn + nI] + " "
	                	Else
	                		Exit
	                	EndIf
								
					EndIf                        		            
				Next nI		
			
				cForn := AllTrim(Replace(cForn,",",""))
				cForn := AllTrim(Replace(cForn,".",""))
	        	Aadd(aResult,cCNPJ)
	    	EndIf
			nQuant := aScan(aItens,'QUANTIDADE:')
			nNeg := aScan(aItens,'NEGOCIADO')
			nQtd := Val(aItens[nQuant+1])
			
			cValor := aItens[nNeg+3]
			cValor := Replace(cValor,'.','')
			cValor := Replace(cValor,',','.')
			cValor := SubStr(cValor,1,Len(cValor) -1)
			 
	        	
			
            If !lItemLote
	        	If !lLote                 
			Aadd(aResult,Val(cValor) / nQtd)
				Else
					Aadd(aResult,Val(cValor))
				EndIf                  		
			Aadd(aResult,cForn)
		Else
				Aadd(aResult,Val(cItemLote))
				Aadd(aResult,nQtd)
				Aadd(aResult,Val(cValor)/ nQtd)
			EndIf	                  
        EndIf
            
		If lCota
        	nItem += 1
           	Aadd(aResult, GetVencCN(Str(nItem),lLast,cUasg,cPrgCod,nItem))
        Else
        	Aadd(aResult,{})	
        EndIf  
           
        If lLote 
           	aPrds := GetProdLote()
           	For nI := 1 To Len(aPrds)
           		Aadd(aCompLote,GetVencCN(Str(nItem),nI == Len(aPrds),cUasg,cPrgCod,Alltrim(aPrds[nI]),,.T.,aPrds[nI]))
           	Next nI
           	Aadd(aResult,aCompLote)	
		EndIf			
	Else
		Help(' ', 1,STR0071,,STR0057,1,0)	//"Este pregão não possui termo de adjudicação, verifique"
	EndIf		
Else
      Help(' ', 1,STR0072,,STR0058,1,0)	//"Houve uma falha de comunicação com o portal do ComprasNet, integração não realizada" 
EndIf

If Len(aResult) > 3 .And. Len(aResult[4]) > 0
	If aResult[1] == aResult[4,1]
		aResult[2] += aResult[4,2]
		aResult[4] := {}
	EndIf
EndIf

Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} GetPrgCodCN()
Retorna o Código do pregão no ComprasNet

@author Matheus Lando Raimundo
/*/
//-------------------------------------------------------------------
Function GetPrgCodCN(cUasg,cCodEd)
Local cHtml := ""
Local cIni := UPPER('prgcod=')
Local cPrgCod := ""
Local cNumbers := "0123456789"
Local cAux := ""
Local nI	:= 0
Local nIni := 0

If SuperGetMv("MV_GCPACN",.F.,"1") == '1'
      cHtml := Httpget('http://treinamento.comprasnet.gov.br/livre/pregao/ata2.asp?co_no_uasg=' + cUasg + '&numprp=' + cCodEd + '&f_lstSrp=T&f_Uf=&f_numPrp=0&f_codUasg='+cUasg + '&f_tpPregao=E&f_lstICMS=T&f_dtAberturaIni=&f_dtAberturaFim=')        
Else
      cHtml := Httpget('http://comprasnet.gov.br/livre/pregao/ata2.asp?co_no_uasg=' + cUasg + '&numprp=' + cCodEd + '&f_lstSrp=T&f_Uf=&f_numPrp=0&f_codUasg='+cUasg + '&f_tpPregao=E&f_lstICMS=T&f_dtAberturaIni=&f_dtAberturaFim=')
EndIf
 
If ValType(cHtml) == "C"	
	If !(Upper('Pregão abandonado') $ cHtml)

		cHtml := Upper(cHtml)
		nIni := At(cIni,cHtml)
		
		cPrgCod := Substr(cHtml,nIni+7,50)
		
		cAux := ""
		For nI := 1 to len(cPrgCod)
			If substr(cPrgCod,nI,1) $ cNumbers 
				cAux += substr(cPrgCod,nI,1)
			Else
				Exit
			EndIf  
		Next nI
		
		cPrgCod := cAux
	Else
		Help(' ', 1,STR0073,,STR0059,1,0)	//'A200NPABN' ## "Este Pregão encontra-se abandonado no ComprasNet, integração não realizada" 
	EndIf		
Else
	Help(' ', 1,STR0074,,STR0060,1,0)	//'A200NNET' ## "Houve uma falha de comunicação com o portal do ComprasNet, integração não realizada" 
EndIf	

Return cPrgCod

//-------------------------------------------------------------------
/*/{Protheus.doc} GetProdLote()
Retorna os produtos do lote
 
@author Matheus Lando Raimundo
/*/
//-------------------------------------------------------------------
Function GetProdLote()
Local nI := 1
Local oModel := FwModelActive()
Local oCO2Detail := oModel:GetModel('CO2DETAIL')
Local aProds	:= {}	

For nI := 1 To oCO2Detail:Length()
	oCO2Detail:GoLine(nI)
	Aadd(aProds,oCO2Detail:GetValue('CO2_ITEM'))
Next nI

Return aProds
