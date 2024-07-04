#include "GCPA140.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Function GCPA140()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('CP8')
oBrowse:SetDescription(STR0001)//'Modalidade X Paragrafo'
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Função para criação do menu 

@author guilherme.pimentel
@since 06/09/2013
@version 1.0
@return aRotina 
/*/
//-------------------------------------------------------------------

Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 		ACTION 'VIEWDEF.GCPA140' 	OPERATION 2 ACCESS 0	//'Visualizar'
ADD OPTION aRotina TITLE STR0003    	ACTION 'VIEWDEF.GCPA140'		OPERATION 3 ACCESS 0	//'Incluir'
ADD OPTION aRotina TITLE STR0011	  	ACTION 'VIEWDEF.GCPA140'		OPERATION 4 ACCESS 0	//'Alterar'
ADD OPTION aRotina TITLE STR0004    	ACTION 'VIEWDEF.GCPA140' 	OPERATION 5 ACCESS 0	//'Excluir'
ADD OPTION aRotina TITLE STR0005   	ACTION 'VIEWDEF.GCPA140'		OPERATION 8 ACCESS 0	//'Imprimir'
ADD OPTION aRotina TITLE STR0006    	ACTION 'VIEWDEF.GCPA140'		OPERATION 9 ACCESS 0	//'Copiar'
ADD OPTION aRotina TITLE STR0012    	ACTION 'A140Carga'			OPERATION 3 ACCESS 0	//'Carregar Leis'

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author guilherme.pimentel

@since 23/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ModelDef()
Local oModel
Local oStrCP8:= FWFormStruct(1,'CP8')
Local oStrCP9:= FWFormStruct(1,'CP9')
Local oStrCPB:= FWFormStruct(1,'CPB')

oModel := MPFormModel():New('GCPA140',,{|oModel|GCP140PVld(oModel)})
oModel:AddFields('CP8MASTER',/*cOwner*/ , oStrCP8)
oModel:AddGrid(  'CP9DETAIL','CP8MASTER', oStrCP9)
oModel:AddGrid(  'CPBDETAIL','CP9DETAIL', oStrCPB)

oModel:SetRelation('CP9DETAIL', { { 'CP9_FILIAL', 'xFilial("CP9")' }, { 'CP9_LEI', 'CP8_LEI' }, { 'CP9_ARTIGO', 'CP8_ARTIGO' } }, CP9->(IndexKey(1)) )
oModel:SetRelation('CPBDETAIL', { { 'CPB_FILIAL', 'xFilial("CPB")' }, { 'CPB_LEI', 'CP8_LEI' }, { 'CPB_ARTIGO', 'CP8_ARTIGO' }, { 'CPB_PARAG', 'CP9_PARAG' } }, CPB->(IndexKey(1)) )

oModel:GetModel("CP9DETAIL"):SetUniqueLine({"CP9_LEI", "CP9_ARTIGO", "CP9_PARAG" })
oModel:GetModel("CPBDETAIL"):SetUniqueLine({"CPB_MODALI"})

oModel:GetModel('CP8MASTER'):SetDescription(STR0007)//'Edital X Artigo'
oModel:GetModel('CP9DETAIL'):SetDescription(STR0008)//'Artigo X Paragrafo'
oModel:GetModel('CPBDETAIL'):SetDescription(STR0009)//'Modalidade'

oModel:SetDescription(STR0010)//'Editais X Paragrafo'

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author guilherme.pimentel

@since 23/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrCP8:= FWFormStruct(2, 'CP8')
Local oStrCP9:= FWFormStruct(2, 'CP9',{|cCampo| !AllTrim(cCampo) $ "CP9_LEI, CP9_ARTIGO"})
Local oStrCPB:= FWFormStruct(2, 'CPB',{|cCampo| !AllTrim(cCampo) $ "CPB_LEI, CPB_ARTIGO, CPB_PARAG"})

oView := FWFormView():New()

oView:SetModel(oModel)

oView:AddField('VIEW_CP8' , oStrCP8, 'CP8MASTER' )
oView:AddGrid( 'VIEW_CP9' , oStrCP9, 'CP9DETAIL' )
oView:AddGrid( 'VIEW_CPB' , oStrCPB, 'CPBDETAIL' )  

oView:CreateHorizontalBox( 'CP8', 20)
oView:CreateHorizontalBox( 'CP9', 50)
oView:CreateHorizontalBox( 'CPB', 30)

oView:SetOwnerView('VIEW_CP8','CP8')
oView:SetOwnerView('VIEW_CP9','CP9')
oView:SetOwnerView('VIEW_CPB','CPB')

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} A140Carga()
Carga automática das leis

@author Guilherme Pimentel
@since 31/10/2013
@version P11
@return lRet 
/*/
//-------------------------------------------------------------------
Function A140Carga()
Local cTexto:= ""
Local nI	:= 0
Local aItens:= {}
Local nTamParag := TAMSX3("CP9_PARAG")[1]
Local nTamArt   := TAMSX3("CP9_ARTIGO")[1]

If IsBlind() .OR. MSGYESNO(STR0013, STR0014) // "Deseja efetuar a carga das Leis? " ## "Atenção" 

	Begin Transaction
	
	//-- ART. 24
	CP8->(DbSetOrder(1))
	If	CP8->( ! DbSeek(xFilial("CP8")+"1"+"24") )
		//-- Cabeçalho
		RecLock("CP8",.T.)
		CP8->CP8_FILIAL:=xFilial("CP8")
		CP8->CP8_LEI:="1"
		CP8->CP8_ARTIGO:="24"
		CP8->CP8_DESART:="Dispensável de licitação"
		MsUnLock()
		
		//-- Artigos
		aItens := {;
		{'1','24','I','para obras e serviços de engenharia de valor até 10% (dez por cento) do limite previsto na alínea a, do inciso I do artigo anterior, desde que não se refiram a parcelas de uma mesma obra ou serviço ou ainda para obras e serviços da mesma natureza e no mesmo local que possam ser realizadas conjunta e concomitantemente; (Redação dada pela Lei nº 9.648, de 1998)'},;
		{'1','24','II','para outros serviços e compras de valor até 10% (dez por cento) do limite previsto na alínea a, do inciso II do artigo anterior e para alienações, nos casos previstos nesta Lei, desde que não se refiram a parcelas de um mesmo serviço, compra ou alienação de maior vulto que possa ser realizada de uma só vez;  (Redação dada pela Lei nº 9.648, de 1998)'},;
		{'1','24','III','nos casos de guerra ou grave perturbação da ordem;'},;
		{'1','24','IV','nos casos de emergência ou de calamidade pública, quando caracterizada urgência de atendimento de situação que possa ocasionar prejuízo ou comprometer a segurança de pessoas, obras, serviços, equipamentos e outros bens, públicos ou particulares, e somente para os bens necessários ao atendimento da situação emergencial ou calamitosa e para as parcelas de obras e serviços que possam ser concluídas no prazo máximo de 180 (cento e oitenta) dias consecutivos e ininterruptos, contados da ocorrência da emergência ou calamidade, vedada a prorrogação dos respectivos contratos;'},;
		{'1','24','V','quando não acudirem interessados à licitação anterior e esta, justificadamente, não puder ser repetida sem prejuízo para a Administração, mantidas, neste caso, todas as condições preestabelecidas;'},;
		{'1','24','VI','quando a União tiver que intervir no domínio econômico para regular preços ou normalizar o abastecimento;'},;
		{'1','24','VII','quando as propostas apresentadas consignarem preços manifestamente superiores aos praticados no mercado nacional, ou forem incompatíveis com os fixados pelos órgãos oficiais competentes, casos em que, observado o parágrafo único do art. 48 desta Lei e, persistindo a situação, será admitida a adjudicação direta dos bens ou serviços, por valor não superior ao constante do registro de preços, ou dos serviços;     (Vide § 3º do art. 48)'},;
		{'1','24','VIII','para a aquisição, por pessoa jurídica de direito público interno, de bens produzidos ou serviços prestados por órgão ou entidade que integre a Administração Pública e que tenha sido criado para esse fim específico em data anterior à vigência desta Lei, desde que o preço contratado seja compatível com o praticado no mercado; (Redação dada pela Lei nº 8.883, de 1994)'},;
		{'1','24','IX','quando houver possibilidade de comprometimento da segurança nacional, nos casos estabelecidos em decreto do Presidente da República, ouvido o Conselho de Defesa Nacional; (Regulamento)'},;
		{'1','24','X','para a compra ou locação de imóvel destinado ao atendimento das finalidades precípuas da administração, cujas necessidades de instalação e localização condicionem a sua escolha, desde que o preço seja compatível com o valor de mercado, segundo avaliação prévia;(Redação dada pela Lei nº 8.883, de 1994)'},;
		{'1','24','XI','na contratação de remanescente de obra, serviço ou fornecimento, em conseqüência de rescisão contratual, desde que atendida a ordem de classificação da licitação anterior e aceitas as mesmas condições oferecidas pelo licitante vencedor, inclusive quanto ao preço, devidamente corrigido;'},;
		{'1','24','XII','nas compras de hortifrutigranjeiros, pão e outros gêneros perecíveis, no tempo necessário para a realização dos processos licitatórios correspondentes, realizadas diretamente com base no preço do dia; (Redação dada pela Lei nº 8.883, de 1994)'},;
		{'1','24','XIII','na contratação de instituição brasileira incumbida regimental ou estatutariamente da pesquisa, do ensino ou do desenvolvimento institucional, ou de instituição dedicada à recuperação social do preso, desde que a contratada detenha inquestionável reputação ético-profissional e não tenha fins lucrativos;(Redação dada pela Lei nº 8.883, de 1994)'},;
		{'1','24','XIV','para a aquisição de bens ou serviços nos termos de acordo internacional específico aprovado pelo Congresso Nacional, quando as condições ofertadas forem manifestamente vantajosas para o Poder Público;   (Redação dada pela Lei nº 8.883, de 1994)'},;
		{'1','24','XV','para a aquisição ou restauração de obras de arte e objetos históricos, de autenticidade certificada, desde que compatíveis ou inerentes às finalidades do órgão ou entidade.'},;
		{'1','24','XVI','para a impressão dos diários oficiais, de formulários padronizados de uso da administração, e de edições técnicas oficiais, bem como para prestação de serviços de informática a pessoa jurídica de direito público interno, por órgãos ou entidades que integrem a Administração Pública, criados para esse fim específico;(Incluído pela Lei nº 8.883, de 1994)'},;
		{'1','24','XVII','para a aquisição de componentes ou peças de origem nacional ou estrangeira, necessários à manutenção de equipamentos durante o período de garantia técnica, junto ao fornecedor original desses equipamentos, quando tal condição de exclusividade for indispensável para a vigência da garantia; (Incluído pela Lei nº 8.883, de 1994)'},;
		{'1','24','XVIII','nas compras ou contratações de serviços para o abastecimento de navios, embarcações, unidades aéreas ou tropas e seus meios de deslocamento quando em estada eventual de curta duração em portos, aeroportos ou localidades diferentes de suas sedes, por motivo de movimentação operacional ou de adestramento, quando a exiguidade dos prazos legais puder comprometer a normalidade e os propósitos das operações e desde que seu valor não exceda ao limite previsto na alínea a do inciso II do art. 23 desta Lei: (Incluído pela Lei nº 8.883, de 1994)'},;
		{'1','24','XIX','para as compras de material de uso pelas Forças Armadas, com exceção de materiais de uso pessoal e administrativo, quando houver necessidade de manter a padronização requerida pela estrutura de apoio logístico dos meios navais, aéreos e terrestres, mediante parecer de comissão instituída por decreto; (Incluído pela Lei nº 8.883, de 1994)'},;
		{'1','24','XX','na contratação de associação de portadores de deficiência física, sem fins lucrativos e de comprovada idoneidade, por órgãos ou entidades da Admininistração Pública, para a prestação de serviços ou fornecimento de mão-de-obra, desde que o preço contratado seja compatível com o praticado no mercado. (Incluído pela Lei nº 8.883, de 1994)'},;
		{'1','24','XXI','para a aquisição de bens e insumos destinados exclusivamente à pesquisa científica e tecnológica com recursos concedidos pela Capes, pela Finep, pelo CNPq ou por outras instituições de fomento a pesquisa credenciadas pelo CNPq para esse fim específico; (Redação dada pela Lei nº 12.349, de 2010)'},;
		{'1','24','XXII','na contratação de fornecimento ou suprimento de energia elétrica e gás natural com concessionário, permissionário ou autorizado, segundo as normas da legislação específica; (Incluído pela Lei nº 9.648, de 1998)'},;
		{'1','24','XXIII','na contratação realizada por empresa pública ou sociedade de economia mista com suas subsidiárias e controladas, para a aquisição ou alienação de bens, prestação ou obtenção de serviços, desde que o preço contratado seja compatível com o praticado no mercado. (Incluído pela Lei nº 9.648, de 1998)'},;
		{'1','24','XXIV','para a celebração de contratos de prestação de serviços com as organizações sociais, qualificadas no âmbito das respectivas esferas de governo, para atividades contempladas no contrato de gestão. (Incluído pela Lei nº 9.648, de 1998)'},;
		{'1','24','XXV','na contratação realizada por Instituição Científica e Tecnológica - ICT ou por agência de fomento para a transferência de tecnologia e para o licenciamento de direito de uso ou de exploração de criação protegida. (Incluído pela Lei nº 10.973, de 2004)'},;
		{'1','24','XXVI','na celebração de contrato de programa com ente da Federação ou com entidade de sua administração indireta, para a prestação de serviços públicos de forma associada nos termos do autorizado em contrato de consórcio público ou em convênio de cooperação. (Incluído pela Lei nº 11.107, de 2005)'},;
		{'1','24','XXVII','na contratação da coleta, processamento e comercialização de resíduos sólidos urbanos recicláveis ou reutilizáveis, em áreas com sistema de coleta seletiva de lixo, efetuados por associações ou cooperativas formadas exclusivamente por pessoas físicas de baixa renda reconhecidas pelo poder público como catadores de materiais recicláveis, com o uso de equipamentos compatíveis com as normas técnicas, ambientais e de saúde pública. (Redação dada pela Lei nº 11.445, de 2007).'},;
		{'1','24','XXVIII','para o fornecimento de bens e serviços, produzidos ou prestados no País, que envolvam, cumulativamente, alta complexidade tecnológica e defesa nacional, mediante parecer de comissão especialmente designada pela autoridade máxima do órgão. (Incluído pela Lei nº 11.484, de 2007).'},;
		{'1','24','XXIX','na aquisição de bens e contratação de serviços para atender aos contingentes militares das Forças Singulares brasileiras empregadas em operações de paz no exterior, necessariamente justificadas quanto ao preço e à escolha do fornecedor ou executante e ratificadas pelo Comandante da Força. (Incluído pela Lei nº 11.783, de 2008).'},;
		{'1','24','XXX','na contratação de instituição ou organização, pública ou privada, com ou sem fins lucrativos, para a prestação de serviços de assistência técnica e extensão rural no âmbito do Programa Nacional de Assistência Técnica e Extensão Rural na Agricultura Familiar e na Reforma Agrária, instituído por lei federal.   (Incluído pela Lei nº 12.188, de 2.010)  Vigência'},;
		{'1','24','XXXI','nas contratações visando ao cumprimento do disposto nos arts. 3o, 4o, 5o e 20 da Lei no 10.973, de 2 de dezembro de 2004, observados os princípios gerais de contratação dela constantes. (Incluído pela Lei nº 12.349, de 2010)'},;
		{'1','24','XXXII','na contratação em que houver transferência de tecnologia de produtos estratégicos para o Sistema Único de Saúde - SUS, no âmbito da Lei no 8.080, de 19 de setembro de 1990, conforme elencados em ato da direção nacional do SUS, inclusive por ocasião da aquisição destes produtos durante as etapas de absorção tecnológica. (Incluído pela Lei nº 12.715, de 2012)'},;
		{'1','24','XXXIII','na contratação de entidades privadas sem fins lucrativos, para a implementação de cisternas ou outras tecnologias sociais de acesso à água para consumo humano e produção de alimentos, para beneficiar as famílias rurais de baixa renda atingidas pela seca ou falta regular de água.  (Incluído pela Medida Provisória nº 619, de 2013)       (Vide Decreto nº 8.038, de 2013)'},;
		{'1','24','1º','Os percentuais referidos nos incisos I e II do caput deste artigo serão 20% (vinte por cento) para compras, obras e serviços contratados por consórcios públicos, sociedade de economia mista, empresa pública e por autarquia ou fundação qualificadas, na forma da lei, como Agências Executivas. (Incluído pela Lei nº 12.715, de 2012)'},;
		{'1','24','2º','O limite temporal de criação do órgão ou entidade que integre a administração pública estabelecido no inciso VIII do caput deste artigo não se aplica aos órgãos ou entidades que produzem produtos estratégicos para o SUS, no âmbito da Lei no 8.080, de 19 de setembro de 1990, conforme elencados em ato da direção nacional do SUS. (Incluído pela Lei nº 12.715, de 2012)'};
		}
		For nI := 1 to Len(aItens)
			RecLock("CP9",.T.)
			
			CP9->CP9_FILIAL:=xFilial("CP9")
			CP9->CP9_LEI:=aItens[nI,1]
			CP9->CP9_ARTIGO:=aItens[nI,2]
			CP9->CP9_PARAG:=aItens[nI,3] 
			CP9->CP9_DESPAR:=aItens[nI,4] 
			MsUnLock()
		Next

		//-- Modalidades
		aItens := {;
		{'1','24','I','DL'},;
		{'1','24','II','DL'},;
		{'1','24','III','DL'},;
		{'1','24','IV','DL'},;
		{'1','24','V','DL'},;
		{'1','24','VI','DL'},;
		{'1','24','VII','DL'},;
		{'1','24','VIII','DL'},;
		{'1','24','IX','DL'},;
		{'1','24','X','DL'},;
		{'1','24','XI','DL'},;
		{'1','24','XII','DL'},;
		{'1','24','XIII','DL'},;
		{'1','24','XIV','DL'},;
		{'1','24','XV','DL'},;
		{'1','24','XVI','DL'},;
		{'1','24','XVII','DL'},;
		{'1','24','XVIII','DL'},;
		{'1','24','XIX','DL'},;
		{'1','24','XX','DL'},;
		{'1','24','XXI','DL'},;
		{'1','24','XXII','DL'},;
		{'1','24','XXIII','DL'},;
		{'1','24','XXIV','DL'},;
		{'1','24','XXV','DL'},;
		{'1','24','XXVI','DL'},;
		{'1','24','XXVII','DL'},;
		{'1','24','XXVIII','DL'},;
		{'1','24','XXIX','DL'},;
		{'1','24','XXX','DL'},;
		{'1','24','XXXI','DL'},;
		{'1','24','XXXII','DL'},;
		{'1','24','XXXIII','DL'},;
		{'1','24','1º','DL'},;
		{'1','24','2º','DL'};
		}
		
		For nI := 1 to Len(aItens)
			RecLock("CPB",.T.)
			CPB->CPB_FILIAL:=xFilial("CPB")
			CPB->CPB_LEI:=aItens[nI,1]
			CPB->CPB_ARTIGO:=aItens[nI,2]
			CPB->CPB_PARAG:=aItens[nI,3]
			CPB->CPB_MODALI:=aItens[nI,4]
			MsUnLock()
		Next
	EndIf
	
	//-- ART. 25
	If	CP8->( ! DbSeek(xFilial("CP8")+"1"+"25") )
		//-- Cabeçalho
		RecLock("CP8",.T.)
		CP8->CP8_FILIAL:=xFilial("CP8")
		CP8->CP8_LEI:="1"
		CP8->CP8_ARTIGO:="25"
		CP8->CP8_DESART:="Inexigível de licitação"
		MsUnLock()	

		//-- Artigos
		aItens := {;
		{'1','25','I','para aquisição de materiais, equipamentos, ou gêneros que só possam ser fornecidos por produtor, empresa ou representante comercial exclusivo, vedada a preferência de marca, devendo a comprovação de exclusividade ser feita através de atestado fornecido pelo órgão de registro do comércio do local em que se realizaria a licitação ou a obra ou o serviço, pelo Sindicato, Federação ou Confederação Patronal, ou, ainda, pelas entidades equivalentes'},;
		{'1','25','II','para a contratação de serviços técnicos enumerados no art. 13 desta Lei, de natureza singular, com profissionais ou empresas de notória especialização, vedada a inexigibilidade para serviços de publicidade e divulgação'},;
		{'1','25','III','para contratação de profissional de qualquer setor artístico, diretamente ou através de empresário exclusivo, desde que consagrado pela crítica especializada ou pela opinião pública.'},;
		{'1','25','1º','Considera-se de notória especialização o profissional ou empresa cujo conceito no campo de sua especialidade, decorrente de desempenho anterior, estudos, experiências, publicações, organização, aparelhamento, equipe técnica, ou de outros requisitos relacionados com suas atividades, permita inferir que o seu trabalho é essencial e indiscutivelmente o mais adequado à plena satisfação do objeto do contrato.'},;
		{'1','25','2º','Na hipótese deste artigo e em qualquer dos casos de dispensa, se comprovado superfaturamento, respondem solidariamente pelo dano causado à Fazenda Pública o fornecedor ou o prestador de serviços e o agente público responsável, sem prejuízo de outras sanções legais cabíveis.'};
		}
		
		For nI := 1 to Len(aItens)
			RecLock("CP9",.T.)
			CP9->CP9_FILIAL:=xFilial("CP9")
			CP9->CP9_LEI:=aItens[nI,1]
			CP9->CP9_ARTIGO:=aItens[nI,2]
			CP9->CP9_PARAG:=aItens[nI,3] 
			CP9->CP9_DESPAR:=aItens[nI,4] 
			MsUnLock()
		Next

		//-- Modalidades
		aItens := {;
		{'1','25','I','IN'},;
		{'1','25','II','IN'},;
		{'1','25','III','IN'},;
		{'1','25','1º','IN'},;
		{'1','25','2º','IN'};
		}
		
		For nI := 1 to Len(aItens)
			RecLock("CPB",.T.)
			CPB->CPB_FILIAL:=xFilial("CPB")
			CPB->CPB_LEI:=aItens[nI,1]
			CPB->CPB_ARTIGO:=aItens[nI,2]
			CPB->CPB_PARAG:=aItens[nI,3]
			CPB->CPB_MODALI:=aItens[nI,4]
			MsUnLock()
		Next
		
	EndIf
	
	//-- ART. 26
	If	CP8->( ! DbSeek(xFilial("CP8")+"1"+"26") )
		//-- Cabeçalho
		RecLock("CP8",.T.)
		CP8->CP8_FILIAL:=xFilial("CP8")
		CP8->CP8_LEI:="1"
		CP8->CP8_ARTIGO:="26"
		CP8->CP8_DESART:="Dispensas Previstas"
		MsUnLock()	

		//-- Artigos
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="1"
		CP9->CP9_ARTIGO:="26"
		CP9->CP9_PARAG:="I" 
		CP9->CP9_DESPAR:="caracterização da situação emergencial ou calamitosa que justifique a dispensa, quando for o caso;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="1"
		CP9->CP9_ARTIGO:="26"
		CP9->CP9_PARAG:="II" 
		CP9->CP9_DESPAR:="razão da escolha do fornecedor ou executante;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="1"
		CP9->CP9_ARTIGO:="26"
		CP9->CP9_PARAG:="III" 
		CP9->CP9_DESPAR:="justificativa do preço." 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="1"
		CP9->CP9_ARTIGO:="26"
		CP9->CP9_PARAG:="IV" 
		CP9->CP9_DESPAR:="documento de aprovação dos projetos de pesquisa aos quais os bens serão alocados.  (Incluído pela Lei nº 9.648, de 1998)" 
		MsUnLock()
		
		//-- Modalidades
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="1"
		CPB->CPB_ARTIGO:="26"
		CPB->CPB_PARAG:="I" 
		CPB->CPB_MODALI:="IN" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="1"
		CPB->CPB_ARTIGO:="26"
		CPB->CPB_PARAG:="II" 
		CPB->CPB_MODALI:="IN"
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="1"
		CPB->CPB_ARTIGO:="26"
		CPB->CPB_PARAG:="III"
		CPB->CPB_MODALI:="IN" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="1"
		CPB->CPB_ARTIGO:="26"
		CPB->CPB_PARAG:="IV" 
		CPB->CPB_MODALI:="IN"
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="1"
		CPB->CPB_ARTIGO:="26"
		CPB->CPB_PARAG:="I" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="1"
		CPB->CPB_ARTIGO:="26"
		CPB->CPB_PARAG:="II" 
		CPB->CPB_MODALI:="DL"
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="1"
		CPB->CPB_ARTIGO:="26"
		CPB->CPB_PARAG:="III"
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="1"
		CPB->CPB_ARTIGO:="26"
		CPB->CPB_PARAG:="IV" 
		CPB->CPB_MODALI:="DL"
		MsUnLock()
				
		
	EndIf
	
	//-- ART. 01 - RDC	
	If	CP8->( ! DbSeek(xFilial("CP8")+"4"+"01") )
		RecLock("CP8",.T.)
		CP8->CP8_FILIAL:=xFilial("CP8")
		CP8->CP8_LEI:="4"
		CP8->CP8_ARTIGO:="01"
		CP8->CP8_DESART:="Aplicação RDC"
		MsUnLock()	
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="4"
		CP9->CP9_ARTIGO:="01"
		CP9->CP9_PARAG:="I" 
		CP9->CP9_DESPAR:="dos Jogos Olímpicos e Paraolímpicos de 2016, constantes da Carteira de Projetos Olímpicos a ser definida pela Autoridade Pública Olímpica (APO); " 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="4"
		CP9->CP9_ARTIGO:="01"
		CP9->CP9_PARAG:="II" 
		CP9->CP9_DESPAR:="da Copa das Confederações da Federação Internacional de Futebol Associação - Fifa 2013 e da Copa do Mundo Fifa 2014, definidos pelo Grupo Executivo - Gecopa 2014 do Comitê Gestor instituído para definir, aprovar e supervisionar as ações previstas no Plano Estratégico das Ações do Governo Brasileiro para a realização da Copa do Mundo Fifa 2014 - CGCOPA 2014, restringindo-se, no caso de obras públicas, às constantes da matriz de responsabilidades celebrada entre a União, Estados, Distrito Federal e Municípios;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="4"
		CP9->CP9_ARTIGO:="01"
		CP9->CP9_PARAG:="III" 
		CP9->CP9_DESPAR:="de obras de infraestrutura e de contratação de serviços para os aeroportos das capitais dos Estados da Federação distantes até 350 km (trezentos e cinquenta quilômetros) das cidades sedes dos mundiais referidos nos incisos I e II. " 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="4"
		CP9->CP9_ARTIGO:="01"
		CP9->CP9_PARAG:="IV" 
		CP9->CP9_DESPAR:="das ações integrantes do Programa de Aceleração do Crescimento (PAC)" 
		MsUnLock()		
				
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="4"
		CP9->CP9_ARTIGO:="01"
		CP9->CP9_PARAG:="V" 
		CP9->CP9_DESPAR:="das obras e serviços de engenharia no âmbito do Sistema Único de Saúde – SUS" 
		MsUnLock()		
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="4"
		CP9->CP9_ARTIGO:="01"
		CP9->CP9_PARAG:="VI" 
		CP9->CP9_DESPAR:="das obras e serviços de engenharia para construção, ampliação e reforma de estabelecimentos penais e unidades de atendimento socioeducativo. Para obras na área da Educação " 
		MsUnLock()		
		
		//-- Modalidades
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="4"
		CPB->CPB_ARTIGO:="01"
		CPB->CPB_PARAG:="I" 
		CPB->CPB_MODALI:="RD" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="4"
		CPB->CPB_ARTIGO:="01"
		CPB->CPB_PARAG:="II" 
		CPB->CPB_MODALI:="RD" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="4"
		CPB->CPB_ARTIGO:="01"
		CPB->CPB_PARAG:="III" 
		CPB->CPB_MODALI:="RD" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="4"
		CPB->CPB_ARTIGO:="01"
		CPB->CPB_PARAG:="IV" 
		CPB->CPB_MODALI:="RD" 
		MsUnLock()

		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="4"
		CPB->CPB_ARTIGO:="01"
		CPB->CPB_PARAG:="V" 
		CPB->CPB_MODALI:="RD" 
		MsUnLock()

		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="4"
		CPB->CPB_ARTIGO:="01"
		CPB->CPB_PARAG:="VI" 
		CPB->CPB_MODALI:="RD" 
		MsUnLock()
		
	EndIf
	
	//-- ART. 14 - RDC	
	If	CP8->( ! DbSeek(xFilial("CP8")+"4"+"14") )
		RecLock("CP8",.T.)
		CP8->CP8_FILIAL:=xFilial("CP8")
		CP8->CP8_LEI:="4"
		CP8->CP8_ARTIGO:="14"
		CP8->CP8_DESART:="Ampliação da oferta da educação infantil"
		MsUnLock()	
			
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="4"
		CP9->CP9_ARTIGO:="14"
		CP9->CP9_PARAG:="3º" 
		CP9->CP9_DESPAR:="o RDC também é aplicável às licitações e contratos necessários à realização de obras e serviços de engenharia no âmbito dos sistemas públicos de ensino. (NR)" 
		MsUnLock()	
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="4"
		CPB->CPB_ARTIGO:="14"
		CPB->CPB_PARAG:="3º" 
		CPB->CPB_MODALI:="RD" 
		MsUnLock()
		
	EndIf
	
	// ART 57
	//-- ART. 14 - RDC	
	If	CP8->( ! DbSeek(xFilial("CP8")+"1"+"57") )
		RecLock("CP8",.T.)
		CP8->CP8_FILIAL:=xFilial("CP8")
		CP8->CP8_LEI:="1"
		CP8->CP8_ARTIGO:="57"
		CP8->CP8_DESART:="Duração dos contratos regidos por esta Lei ficará adstrita à vigência dos respectivos créditos orçamentários"
		MsUnLock()	
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="1"
		CP9->CP9_ARTIGO:="57"
		CP9->CP9_PARAG:="I" 
		CP9->CP9_DESPAR:="aos projetos cujos produtos estejam contemplados nas metas estabelecidas no Plano Plurianual, os quais poderão ser prorrogados se houver interesse da Administração e desde que isso tenha sido previsto no ato convocatório;" 
		MsUnLock()	
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="1"
		CP9->CP9_ARTIGO:="57"
		CP9->CP9_PARAG:="II" 
		CP9->CP9_DESPAR:="à prestação de serviços a serem executados de forma contínua, que poderão ter a sua duração prorrogada por iguais e sucessivos períodos com vistas à obtenção de preços e condições mais vantajosas para a administração, limitada a sessenta meses;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="1"
		CP9->CP9_ARTIGO:="57"
		CP9->CP9_PARAG:="IV" 
		CP9->CP9_DESPAR:="ao aluguel de equipamentos e à utilização de programas de informática, podendo a duração estender-se pelo prazo de até 48 (quarenta e oito) meses após o início da vigência do contrato." 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="1"
		CP9->CP9_ARTIGO:="57"
		CP9->CP9_PARAG:="V" 
		CP9->CP9_DESPAR:="às hipóteses previstas nos incisos IX, XIX, XXVIII e XXXI do art. 24, cujos contratos poderão ter vigência por até 120 (cento e vinte) meses, caso haja interesse da administração." 
		MsUnLock()
		
	EndIf
	
	//-- ART. 48
	a017Artigos()
	
	//-- ART. 65 - Da Alteração dos Contratos - Lei 8.666	
	If	CP8->( ! DbSeek(xFilial("CP8")+"1"+"65") )
		RecLock("CP8",.T.)
		CP8->CP8_FILIAL:=xFilial("CP8")
		CP8->CP8_LEI:="1"
		CP8->CP8_ARTIGO:="65"
		CP8->CP8_DESART:="Os contratos regidos por esta Lei poderão ser alterados, com as devidas justificativas, nos seguintes casos:"
		MsUnLock()	
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="1"
		CP9->CP9_ARTIGO:="65"
		CP9->CP9_PARAG:="I" 
		CP9->CP9_DESPAR:="unilateralmente pela Administração:" 
		MsUnLock()	
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="1"
		CP9->CP9_ARTIGO:="65"
		CP9->CP9_PARAG:="II" 
		CP9->CP9_DESPAR:="por acordo das partes:" 
		MsUnLock()
		
	EndIf	
	
	//-- ART. 65 - Da Alteração dos Contratos - Lei 8.666	
	If	CP8->( ! DbSeek(xFilial("CP8")+"3"+"65") )
		
		//-- Artigo
		RecLock("CP8",.T.)
		CP8->CP8_FILIAL:=xFilial("CP8")
		CP8->CP8_LEI:="3"
		CP8->CP8_ARTIGO:="65"
		CP8->CP8_DESART:=STR0015 	//-- Alteração dos contratos. (Lei 8.666)                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
		MsUnLock()	
		
		//-- Paragrafos
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="3"
		CP9->CP9_ARTIGO:="65"
		CP9->CP9_PARAG:="I" 
		CP9->CP9_DESPAR:=STR0016	//-- Unilateralmente pela administração.                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
		MsUnLock()	
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="3"
		CP9->CP9_ARTIGO:="65"
		CP9->CP9_PARAG:="II" 
		CP9->CP9_DESPAR:=STR0017	//-- Por acordo das partes.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            	
		MsUnLock()
		
		//-- Modalidades
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="3"
		CPB->CPB_ARTIGO:="65"
		CPB->CPB_PARAG:="I" 
		CPB->CPB_MODALI:="PG" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="3"
		CPB->CPB_ARTIGO:="65"
		CPB->CPB_PARAG:="II" 
		CPB->CPB_MODALI:="PG" 
		MsUnLock()
		
	EndIf	
	
	//-- ART. 09 - RLC || Regulamentos de Licitações e Contratos do SENAI (fonte)
	CP8->(DbSetOrder(1))
	If	CP8->( ! DbSeek(xFilial("CP8")+"2"+"09") )
		//-- Cabeçalho
		RecLock("CP8",.T.)
		CP8->CP8_FILIAL:=xFilial("CP8")
		CP8->CP8_LEI:="2"
		CP8->CP8_ARTIGO:="09"
		CP8->CP8_DESART:="Dispensável de licitação"
		MsUnLock()
		
		//-- Artigos
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="2"
		CP9->CP9_ARTIGO:="09"
		CP9->CP9_PARAG:="I" 
		CP9->CP9_DESPAR:="nas contratações até os valores previstos nos incisos I, alínea “a” e II, alínea “a” do art. 6º;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="2"
		CP9->CP9_ARTIGO:="09"
		CP9->CP9_PARAG:="II" 
		CP9->CP9_DESPAR:="nas alienações de bens até o valor previsto no inciso III, alínea “a” do art. 6º;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="2"
		CP9->CP9_ARTIGO:="09"
		CP9->CP9_PARAG:="III" 
		CP9->CP9_DESPAR:="quando não acudirem interessados à licitação e esta não puder ser repetida sem prejuízo, mantidas, neste caso, as condições preestabelecidas;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="2"
		CP9->CP9_ARTIGO:="09"
		CP9->CP9_PARAG:="IV" 
		CP9->CP9_DESPAR:="nos casos de calamidade pública ou grave perturbação da ordem pública;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="2"
		CP9->CP9_ARTIGO:="09"
		CP9->CP9_PARAG:="V" 
		CP9->CP9_DESPAR:="nos casos de emergência, quando caracterizada a necessidade de atendimento a situação que possa ocasionar prejuízo ou comprometer a segurança de pessoas, obras, serviços, equipamentos e outros bens;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="2"
		CP9->CP9_ARTIGO:="09"
		CP9->CP9_PARAG:="VI" 
		CP9->CP9_DESPAR:="na aquisição, locação ou arrendamento de imóveis, sempre precedida de avaliação;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="2"
		CP9->CP9_ARTIGO:="09"
		CP9->CP9_PARAG:="VII" 
		CP9->CP9_DESPAR:="na aquisição de gêneros alimentícios perecíveis, com base no preço do dia;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="2"
		CP9->CP9_ARTIGO:="09"
		CP9->CP9_PARAG:="VIII" 
		CP9->CP9_DESPAR:="na contratação de entidade incumbida regimental ou estatutariamente da pesquisa, do ensino ou do desenvolvimento institucional, científico ou tecnológico, desde que sem fins lucrativos;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="2"
		CP9->CP9_ARTIGO:="09"
		CP9->CP9_PARAG:="IX" 
		CP9->CP9_DESPAR:="na contratação, com serviços sociais autônomos e com órgãos e entidades integrantes da Administração Pública, quando o objeto do contrato for compatível com as atividades finalísticas do contratado;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="2"
		CP9->CP9_ARTIGO:="09"
		CP9->CP9_PARAG:="X" 
		CP9->CP9_DESPAR:="na aquisição de componentes ou peças necessários à manutenção de equipamentos durante o período de garantia técnica, junto a fornecedor original desses equipamentos, quando tal condição for indispensável para a vigência da garantia;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="2"
		CP9->CP9_ARTIGO:="09"
		CP9->CP9_PARAG:="XI" 
		CP9->CP9_DESPAR:="nos casos de urgência para o atendimento de situações comprovadamente imprevistas ou imprevisíveis em tempo hábil para se realizar a licitação;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="2"
		CP9->CP9_ARTIGO:="09"
		CP9->CP9_PARAG:="XII" 
		CP9->CP9_DESPAR:="na contratação de pessoas físicas ou jurídicas para ministrar cursos ou prestar serviços de instrutoria vinculados às atividades finalísticas;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="2"
		CP9->CP9_ARTIGO:="09"
		CP9->CP9_PARAG:="XIII" 
		CP9->CP9_DESPAR:="na contratação de serviços de manutenção em que seja pré-condição indispensável para a realização da proposta a desmontagem do equipamento;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="2"
		CP9->CP9_ARTIGO:="09"
		CP9->CP9_PARAG:="XIV" 
		CP9->CP9_DESPAR:="na contratação de cursos abertos, destinados a treinamento e aperfeiçoamento dos empregados;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="2"
		CP9->CP9_ARTIGO:="09"
		CP9->CP9_PARAG:="XV" 
		CP9->CP9_DESPAR:="na venda de ações, que poderão ser negociadas em bolsas;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="2"
		CP9->CP9_ARTIGO:="09"
		CP9->CP9_PARAG:="XVI" 
		CP9->CP9_DESPAR:="para a aquisição ou restauração de obras de arte e objetos históricos, de autenticidade certificada, desde que compatíveis ou inerentes às finalidades da Entidade;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="2"
		CP9->CP9_ARTIGO:="09"
		CP9->CP9_PARAG:="XVII" 
		CP9->CP9_DESPAR:="na contratação de remanescente de obra, serviço ou fornecimento em conseqüência de rescisão contratual, desde que atendida a ordem de classificação da licitação anterior e aceitas as mesmas condições oferecidas pelo licitante vencedor, inclusive quanto ao preço, devidamente corrigido." 
		MsUnLock()		
		
									
		//-- Modalidades
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="2"
		CPB->CPB_ARTIGO:="09"
		CPB->CPB_PARAG:="I" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="2"
		CPB->CPB_ARTIGO:="09"
		CPB->CPB_PARAG:="II" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="2"
		CPB->CPB_ARTIGO:="09"
		CPB->CPB_PARAG:="III" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="2"
		CPB->CPB_ARTIGO:="09"
		CPB->CPB_PARAG:="IV" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="2"
		CPB->CPB_ARTIGO:="09"
		CPB->CPB_PARAG:="V" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="2"
		CPB->CPB_ARTIGO:="09"
		CPB->CPB_PARAG:="VI" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="2"
		CPB->CPB_ARTIGO:="09"
		CPB->CPB_PARAG:="VII" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="2"
		CPB->CPB_ARTIGO:="09"
		CPB->CPB_PARAG:="VIII" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="2"
		CPB->CPB_ARTIGO:="09"
		CPB->CPB_PARAG:="IX" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="2"
		CPB->CPB_ARTIGO:="09"
		CPB->CPB_PARAG:="X" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="2"
		CPB->CPB_ARTIGO:="09"
		CPB->CPB_PARAG:="XI" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="2"
		CPB->CPB_ARTIGO:="09"
		CPB->CPB_PARAG:="XII" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="2"
		CPB->CPB_ARTIGO:="09"
		CPB->CPB_PARAG:="XIII" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="2"
		CPB->CPB_ARTIGO:="09"
		CPB->CPB_PARAG:="XIV" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="2"
		CPB->CPB_ARTIGO:="09"
		CPB->CPB_PARAG:="XV" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="2"
		CPB->CPB_ARTIGO:="09"
		CPB->CPB_PARAG:="XVI" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="2"
		CPB->CPB_ARTIGO:="09"
		CPB->CPB_PARAG:="XVII" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()	
				
	EndIf
	
	//-- ART. 10 - RLC || Regulamentos de Licitações e Contratos do SENAI (fonte)
	CP8->(DbSetOrder(1))
	If	CP8->( ! DbSeek(xFilial("CP8")+"2"+"10") )
		//-- Cabeçalho
		RecLock("CP8",.T.)
		CP8->CP8_FILIAL:=xFilial("CP8")
		CP8->CP8_LEI:="2"
		CP8->CP8_ARTIGO:="10"
		CP8->CP8_DESART:="Inexigível de licitação"
		MsUnLock()
		
		//-- Artigos
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="2"
		CP9->CP9_ARTIGO:="10"
		CP9->CP9_PARAG:="I" 
		CP9->CP9_DESPAR:="na aquisição de materiais, equipamentos ou gêneros diretamente de produtor ou fornecedor exclusivo;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="2"
		CP9->CP9_ARTIGO:="10"
		CP9->CP9_PARAG:="II" 
		CP9->CP9_DESPAR:="na contratação de serviços com empresa ou profissional de notória especialização, assim entendido aqueles cujo conceito no campo de sua especialidade, decorrente de desempenho anterior, estudos, experiências, publicações, organização, aparelhamento, equipe técnica ou outros requisitos relacionados com sua atividade, permita inferir que o seu trabalho é o mais adequado à plena satisfação do objeto a ser contratado;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="2"
		CP9->CP9_ARTIGO:="10"
		CP9->CP9_PARAG:="III" 
		CP9->CP9_DESPAR:="na contratação de profissional de qualquer setor artístico;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="2"
		CP9->CP9_ARTIGO:="10"
		CP9->CP9_PARAG:="IV" 
		CP9->CP9_DESPAR:="na permuta ou dação em pagamento de bens, observada a avaliação atualizada;" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="2"
		CP9->CP9_ARTIGO:="10"
		CP9->CP9_PARAG:="V" 
		CP9->CP9_DESPAR:="na doação de bens." 
		MsUnLock()
		
		//-- Modalidades // -- Inexigibilidade
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="2"
		CPB->CPB_ARTIGO:="10"
		CPB->CPB_PARAG:="I" 
		CPB->CPB_MODALI:="IN" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="2"
		CPB->CPB_ARTIGO:="10"
		CPB->CPB_PARAG:="II" 
		CPB->CPB_MODALI:="IN" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="2"
		CPB->CPB_ARTIGO:="10"
		CPB->CPB_PARAG:="III" 
		CPB->CPB_MODALI:="IN" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="2"
		CPB->CPB_ARTIGO:="10"
		CPB->CPB_PARAG:="IV" 
		CPB->CPB_MODALI:="IN" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="2"
		CPB->CPB_ARTIGO:="10"
		CPB->CPB_PARAG:="V" 
		CPB->CPB_MODALI:="IN" 
		MsUnLock()
		
	EndIf
	//Artigos, incisos e parágrados da lei 13.303 para o Artigo 29 (DISPENSA DE LICITACAO)
	If	CP8->(!DbSeek(xFilial("CP8")+"5"+"29"))		
		//-- Cabeçalho
		RecLock("CP8",.T.)
		CP8->CP8_FILIAL:=xFilial("CP8")
		CP8->CP8_LEI:="5"
		CP8->CP8_ARTIGO:="29"
		CP8->CP8_DESART:="Dispensável de Licitação"
		MsUnLock()
		
		//-- Artigos
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="29"
		CP9->CP9_PARAG:="I" 
		CP9->CP9_DESPAR:="para obras e serviços de engenharia de valor até R$ 100.000,00 (cem mil reais), desde que não se refiram a parcelas de uma mesma obra ou serviço ou ainda a obras e serviços de mesma natureza e no mesmo local que possam ser realizadas conjunta e concomitantemente" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="29"
		CP9->CP9_PARAG:="II" 
		CP9->CP9_DESPAR:="para outros serviços e compras de valor até R$ 50.000,00 (cinquenta mil reais) e para alienações, nos casos previstos nesta Lei, desde que não se refiram a parcelas de um mesmo serviço, compra ou alienação de maior vulto que possa ser realizado de uma só vez" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="29"
		CP9->CP9_PARAG:="III" 
		CP9->CP9_DESPAR:="quando não acudirem interessados à licitação anterior e essa, justificadamente, não puder ser repetida sem prejuízo para a empresa pública ou a sociedade de economia mista, bem como para suas respectivas subsidiárias, desde que mantidas as condições preestabelecidas" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="29"
		CP9->CP9_PARAG:="IV" 
		CP9->CP9_DESPAR:="quando as propostas apresentadas consignarem preços manifestamente superiores aos praticados no mercado nacional ou incompatíveis com os fixados pelos órgãos oficiais competentes" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="29"
		CP9->CP9_PARAG:="V" 
		CP9->CP9_DESPAR:="para a compra ou locação de imóvel destinado ao atendimento de suas finalidades precípuas, quando as necessidades de instalação e localização condicionarem a escolha do imóvel, desde que o preço seja compatível com o valor de mercado, segundo avaliação prévia" 
		MsUnLock()

		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="29"
		CP9->CP9_PARAG:="VI" 
		CP9->CP9_DESPAR:="na contratação de remanescente de obra, de serviço ou de fornecimento, em consequência de rescisão contratual, desde que atendida a ordem de classificação da licitação anterior e aceitas as mesmas condições do contrato encerrado por rescisão ou distrato, inclusive quanto ao preço, devidamente corrigido" 
		MsUnLock()

		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="29"
		CP9->CP9_PARAG:="VII" 
		CP9->CP9_DESPAR:="na contratação de instituição brasileira incumbida regimental ou estatutariamente da pesquisa, do ensino ou do desenvolvimento institucional ou de instituição dedicada à recuperação social do preso, desde que a contratada detenha inquestionável reputação ético-profissional e não tenha fins lucrativos" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="29"
		CP9->CP9_PARAG:="VIII" 
		CP9->CP9_DESPAR:="para a aquisição de componentes ou peças de origem nacional ou estrangeira necessários à manutenção de equipamentos durante o período de garantia técnica, junto ao fornecedor original desses equipamentos, quando tal condição de exclusividade for indispensável para a vigência da garantia" 
		MsUnLock()

		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="29"
		CP9->CP9_PARAG:="IX" 
		CP9->CP9_DESPAR:="na contratação de associação de pessoas com deficiência física, sem fins lucrativos e de comprovada idoneidade, para a prestação de serviços ou fornecimento de mão de obra, desde que o preço contratado seja compatível com o praticado no mercado" 
		MsUnLock()

		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="29"
		CP9->CP9_PARAG:="X" 
		CP9->CP9_DESPAR:="na contratação de concessionário, permissionário ou autorizado para fornecimento ou suprimento de energia elétrica ou gás natural e de outras prestadoras de serviço público, segundo as normas da legislação específica, desde que o objeto do contrato tenha pertinência com o serviço público" 
		MsUnLock()

		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="29"
		CP9->CP9_PARAG:="XI" 
		CP9->CP9_DESPAR:="nas contratações entre empresas públicas ou sociedades de economia mista e suas respectivas subsidiárias, para aquisição ou alienação de bens e prestação ou obtenção de serviços, desde que os preços sejam compatíveis com os praticados no mercado e que o objeto do contrato tenha relação com a atividade da contratada prevista em seu estatuto social" 
		MsUnLock()

		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="29"
		CP9->CP9_PARAG:="XII" 
		CP9->CP9_DESPAR:="na contratação de coleta, processamento e comercialização de resíduos sólidos urbanos recicláveis ou reutilizáveis, em áreas com sistema de coleta seletiva de lixo, efetuados por associações ou cooperativas formadas exclusivamente por pessoas físicas de baixa renda que tenham como ocupação econômica a coleta de materiais recicláveis, com o uso de equipamentos compatíveis com as normas técnicas, ambientais e de saúde pública" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="29"
		CP9->CP9_PARAG:="XIII" 
		CP9->CP9_DESPAR:="para o fornecimento de bens e serviços, produzidos ou prestados no País, que envolvam, cumulativamente, alta complexidade tecnológica e defesa nacional, mediante parecer de comissão especialmente designada pelo dirigente máximo da empresa pública ou da sociedade de economia mista" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="29"
		CP9->CP9_PARAG:="XIV" 
		CP9->CP9_DESPAR:="nas contratações visando ao cumprimento do disposto nos arts. 3º, 4º, 5º e 20 da Lei no 10.973, de 2 de dezembro de 2004, observados os princípios gerais de contratação dela constantes" 
		MsUnLock()
														
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="29"
		CP9->CP9_PARAG:="XV" 
		CP9->CP9_DESPAR:="em situações de emergência, quando caracterizada urgência de atendimento de situação que possa ocasionar prejuízo ou comprometer a segurança de pessoas, obras, serviços, equipamentos e outros bens, públicos ou particulares, e somente para os bens necessários ao atendimento da situação emergencial e para as parcelas de obras e serviços que possam ser concluídas no prazo máximo de 180 (cento e oitenta) dias consecutivos e ininterruptos, contado da ocorrência da emergência, vedada a prorrogação dos respectivos contratos, observado o disposto no § 2o" 
		MsUnLock()

		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="29"
		CP9->CP9_PARAG:="XVI" 
		CP9->CP9_DESPAR:="na transferência de bens a órgãos e entidades da administração pública, inclusive quando efetivada mediante permuta" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="29"
		CP9->CP9_PARAG:="XVII" 
		CP9->CP9_DESPAR:="na doação de bens móveis para fins e usos de interesse social, após avaliação de sua oportunidade e conveniência socioeconômica relativamente à escolha de outra forma de alienação" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="29"
		CP9->CP9_PARAG:="XVIII" 
		CP9->CP9_DESPAR:="na compra e venda de ações, de títulos de crédito e de dívida e de bens que produzam ou comercializem" 
		MsUnLock()

		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="29"
		CP9->CP9_PARAG:="1º" 
		CP9->CP9_DESPAR:="Na hipótese de nenhum dos licitantes aceitar a contratação nos termos do inciso VI do caput, a empresa pública e a sociedade de economia mista poderão convocar os licitantes remanescentes, na ordem de classificação, para a celebração do contrato nas condições ofertadas por estes, desde que o respectivo valor seja igual ou inferior ao orçamento estimado para a contratação, inclusive quanto aos preços atualizados nos termos do instrumento convocatório" 
		MsUnLock()	

		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="29"
		CP9->CP9_PARAG:="2º" 
		CP9->CP9_DESPAR:="A contratação direta com base no inciso XV do caput não dispensará a responsabilização de quem, por ação ou omissão, tenha dado causa ao motivo ali descrito, inclusive no tocante ao disposto na Lei no 8.429, de 2 de junho de 1992" 
		MsUnLock()		

		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="29"
		CP9->CP9_PARAG:="3º" 
		CP9->CP9_DESPAR:="Os valores estabelecidos nos incisos I e II do caput podem ser alterados, para refletir a variação de custos, por deliberação do Conselho de Administração da empresa pública ou sociedade de economia mista, admitindo-se valores diferenciados para cada sociedade" 
		MsUnLock()
		
		//-- Modalidades
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="29"
		CPB->CPB_PARAG:="I" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="29"
		CPB->CPB_PARAG:="II" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="29"
		CPB->CPB_PARAG:="III" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="29"
		CPB->CPB_PARAG:="IV" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="29"
		CPB->CPB_PARAG:="V" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()

		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="29"
		CPB->CPB_PARAG:="VI" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()

		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="29"
		CPB->CPB_PARAG:="VII" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()

		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="29"
		CPB->CPB_PARAG:="VIII" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()

		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="29"
		CPB->CPB_PARAG:="IX" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()

		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="29"
		CPB->CPB_PARAG:="X" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()

		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="29"
		CPB->CPB_PARAG:="XI" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()

		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="29"
		CPB->CPB_PARAG:="XII" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="29"
		CPB->CPB_PARAG:="XIII" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()

		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="29"
		CPB->CPB_PARAG:="XIV" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
																				
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="29"
		CPB->CPB_PARAG:="XV" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()

		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="29"
		CPB->CPB_PARAG:="XVI" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()

		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="29"
		CPB->CPB_PARAG:="XVII" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()

		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="29"
		CPB->CPB_PARAG:="XVIII" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="29"
		CPB->CPB_PARAG:="1º" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="29"
		CPB->CPB_PARAG:="2º" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="29"
		CPB->CPB_PARAG:="3º" 
		CPB->CPB_MODALI:="DL" 
		MsUnLock()
	EndIf

	//Artigos, incisos e parágrados da lei 13.303 para o Artigo 29 (DISPENSA DE LICITACAO)
	If	CP8->(!DbSeek(xFilial("CP8")+"5"+"30"))		
		//-- Cabeçalho
		RecLock("CP8",.T.)
		CP8->CP8_FILIAL:=xFilial("CP8")
		CP8->CP8_LEI:="5"
		CP8->CP8_ARTIGO:="30"
		CP8->CP8_DESART:="Inexigível de Licitação"
		MsUnLock()
		
		//-- Artigos
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="30"
		CP9->CP9_PARAG:="I" 
		CP9->CP9_DESPAR:="aquisição de materiais, equipamentos ou gêneros que só possam ser fornecidos por produtor, empresa ou representante comercial exclusivo" 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="30"
		CP9->CP9_PARAG:="II" 
		cTexto	:= "contratação dos seguintes serviços técnicos especializados, com profissionais ou empresas de notória especialização, vedada a inexigibilidade para serviços de publicidade e divulgação: " + CRLF
		cTexto	+= "a) estudos técnicos, planejamentos e projetos básicos ou executivos; " + CRLF
		cTexto	+= "b) pareceres, perícias e avaliações em geral; " + CRLF
		cTexto	+= "c) assessorias ou consultorias técnicas e auditorias financeiras ou tributárias; " + CRLF
		cTexto	+= "d) fiscalização, supervisão ou gerenciamento de obras ou serviços; " + CRLF
		cTexto	+= "e) patrocínio ou defesa de causas judiciais ou administrativas; " + CRLF
		cTexto	+= "f) treinamento e aperfeiçoamento de pessoal; " + CRLF
		cTexto	+= "g) restauração de obras de arte e bens de valor histórico. " + CRLF
		
		CP9->CP9_DESPAR:= cTexto 
		MsUnLock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="30"
		CP9->CP9_PARAG:="1º" 
		CP9->CP9_DESPAR:="Considera-se de notória especialização o profissional ou a empresa cujo conceito no campo de sua especialidade, decorrente de desempenho anterior, estudos, experiência, publicações, organização, aparelhamento, equipe técnica ou outros requisitos relacionados com suas atividades, permita inferir que o seu trabalho é essencial e indiscutivelmente o mais adequado à plena satisfação do objeto do contrato" 
		MsUnLock()

		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="30"
		CP9->CP9_PARAG:="2º" 
		CP9->CP9_DESPAR:="Na hipótese do caput e em qualquer dos casos de dispensa, se comprovado, pelo órgão de controle externo, sobrepreço ou superfaturamento, respondem solidariamente pelo dano causado quem houver decidido pela contratação direta e o fornecedor ou o prestador de serviços" 
		MsUnLock()

		RecLock("CP9",.T.)
		CP9->CP9_FILIAL:=xFilial("CP9")
		CP9->CP9_LEI:="5"
		CP9->CP9_ARTIGO:="30"
		CP9->CP9_PARAG:="3º" 
		
		cTexto	:= "O processo de contratação direta será instruído, no que couber, com os seguintes elementos: " + CRLF		
		cTexto	+= "I-caracterização da situação emergencial ou calamitosa que justifique a dispensa, quando for o caso; " + CRLF
		cTexto	+= "II-razão da escolha do fornecedor ou do executante;  " + CRLF
		cTexto	+= "III-b) justificativa do preço." + CRLF
		CP9->CP9_DESPAR := cTexto 
		MsUnLock()
						
		//-- Modalidades
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="30"
		CPB->CPB_PARAG:="I" 
		CPB->CPB_MODALI:="IN" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="30"
		CPB->CPB_PARAG:="II" 
		CPB->CPB_MODALI:="IN" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="30"
		CPB->CPB_PARAG:="1º" 
		CPB->CPB_MODALI:="IN" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="30"
		CPB->CPB_PARAG:="2º" 
		CPB->CPB_MODALI:="IN" 
		MsUnLock()
		
		RecLock("CPB",.T.)
		CPB->CPB_FILIAL:=xFilial("CPB")
		CPB->CPB_LEI:="5"
		CPB->CPB_ARTIGO:="30"
		CPB->CPB_PARAG:="3º" 
		CPB->CPB_MODALI:="IN" 
		MsUnLock()
	EndIf	 
	
	//-- ART. 81 - Da Alteração dos Contratos - Lei 13.303 
	If  CP8->( !DbSeek(xFilial("CP8")+"5"+"81") )
		RecLock("CP8",.T.)
		CP8->CP8_FILIAL := xFilial("CP8")
		CP8->CP8_LEI := "5"
		CP8->CP8_ARTIGO := "81"
		CP8->CP8_DESART := "Os contratos celebrados nos regimes previstos nos incisos I a V do art. 43 contarão com cláusula que estabeleça a possibilidade de alteração, por acordo entre as partes, nos seguintes casos:"
		MsUnlock()
	
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL := xFilial("CP9")
		CP9->CP9_LEI := "5"
		CP9->CP9_ARTIGO := "81"
		CP9->CP9_PARAG := "I"
		CP9->CP9_DESPAR := "quando houver modificação do projeto ou das especificações, para melhor adequação técnica aos seus objetivos;"		
		MsUnlock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL := xFilial("CP9")
		CP9->CP9_LEI := "5"
		CP9->CP9_ARTIGO := "81"
		CP9->CP9_PARAG := "II"
		CP9->CP9_DESPAR := "quando necessária a modificação do valor contratual em decorrência de acréscimo ou diminuição quantitativa de seu objeto, nos limites permitidos por esta Lei;"
		MsUnlock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL := xFilial("CP9")
		CP9->CP9_LEI := "5"
		CP9->CP9_ARTIGO := "81"
		CP9->CP9_PARAG := "III"
		CP9->CP9_DESPAR := "quando conveniente a substituição da garantia de execução;"
		MsUnlock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL := xFilial("CP9")
		CP9->CP9_LEI := "5"
		CP9->CP9_ARTIGO := "81"
		CP9->CP9_PARAG := "IV"
		CP9->CP9_DESPAR	:= "quando necessária a modificação do regime de execução da obra ou serviço, bem como do modo de fornecimento, em face de verificação técnica da inaplicabilidade dos termos contratuais originários;"
		MsUnlock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL := xFilial("CP9")
		CP9->CP9_LEI := "5"
		CP9->CP9_ARTIGO := "81"
		CP9->CP9_PARAG := "V"
		CP9->CP9_DESPAR := "quando necessária a modificação da forma de pagamento, por imposição de circunstâncias supervenientes, mantido o valor inicial atualizado, vedada a antecipação do pagamento, com relação ao cronograma financeiro fixado, sem a correspondente contraprestação de fornecimento de bens ou execução de obra ou serviço;"
		MsUnlock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL := xFilial("CP9")
		CP9->CP9_LEI := "5"
		CP9->CP9_ARTIGO := "81"
		CP9->CP9_PARAG := "VI"
		CP9->CP9_DESPAR := "para restabelecer a relação que as partes pactuaram inicialmente entre os encargos do contratado e a retribuição da administração para a justa remuneração da obra, serviço ou fornecimento, objetivando a manutenção do equilíbrio econômico-financeiro inicial do contrato, na hipótese de sobrevirem fatos imprevisíveis, ou previsíveis porém de consequências incalculáveis, retardadores ou impeditivos da execução do ajustado, ou, ainda, em caso de força maior, caso fortuito ou fato do príncipe, configurando álea econômica extraordinária e extracontratual."
		MsUnlock()
	
	EndIf

	If	CP8->(!DbSeek(xFilial("CP8")+"5"+"32"))	

		RecLock("CP8",.T.)
		CP8->CP8_FILIAL := xFilial("CP8")
		CP8->CP8_LEI 	:= "5"
		CP8->CP8_ARTIGO := "32"
		CP8->CP8_DESART := "Nas licitações e contratos de que trata esta Lei serão observadas as seguintes diretrizes:"
		MsUnlock()
		
		RecLock("CP9",.T.)
		CP9->CP9_FILIAL := xFilial("CP9")
		CP9->CP9_LEI 	:= "5"
		CP9->CP9_ARTIGO := "32"
		CP9->CP9_PARAG 	:= "IV"
		CP9->CP9_DESPAR := "adoção preferencial da modalidade de licitação denominada pregão, instituída pela Lei nº 10.520, de 17 de julho de 2002 , para a aquisição de bens e serviços comuns, assim considerados aqueles cujos padrões de desempenho e qualidade possam ser objetivamente definidos pelo edital, por meio de especificações usuais no mercado;"
		MsUnlock()

		RecLock("CPB",.T.)
		CPB->CPB_FILIAL	:= xFilial("CPB")
		CPB->CPB_LEI	:= "5"
		CPB->CPB_ARTIGO	:= "32"
		CPB->CPB_PARAG	:= "IV" 
		CPB->CPB_MODALI	:= "PG" 
		MsUnlock()

	EndIf
	
	End Transaction
	
	CP8->(DbGoTop())
	
EndIf
		
Return                       
//-------------------------------------------------------------------
/*/{Protheus.doc} GCP140PVld()
Função executada na pós validação do modelo 

@author matheus.raimundo
@since 09/06/2015
@version 1.0
@return lRet	
/*/
//-------------------------------------------------------------------
Function GCP140PVld(oModel)
Local oCP8Master	:= oModel:GetModel('CP8MASTER')
Local lRet 		:= .T.

If oModel:GetOperation()==MODEL_OPERATION_INSERT
CP8->(DbSetOrder(1))
If	CP8->(DbSeek(xFilial("CP8")+oCP8Master:GetValue('CP8_LEI')+oCP8Master:GetValue('CP8_ARTIGO')))
	lRet := .F.
	Help('', 1, 'JAGRAVADO')			     
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP140Rela()
Função para inicialização do campo CPB_DESMOD

@author filipe.goncalves
@since 09/06/2015
@version 1.0
@return lRet	
/*/
//-------------------------------------------------------------------
Function GCP140Rela()
Local cCod		:= ""
Local oModel	:= FwModelActive()
Local oModCPB	:= oModel:GetModel("CPBDETAIL")
Local nL		:= oModCPB:GetLine()
	
If nL == 0 
	cCod := POSICIONE("SX5",1,XFILIAL("SX5")+"LF"+CPB->CPB_MODALI,"X5_DESCRI")
Else
	cCod := ""
EndIf

Return cCod
