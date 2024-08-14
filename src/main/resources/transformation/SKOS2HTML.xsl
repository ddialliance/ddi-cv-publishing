<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:gc="http://docs.oasis-open.org/codelist/ns/genericode/1.0/"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:ddi-cv="urn:ddi-cv"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    exclude-result-prefixes="xs rdf rdfs skos owl gc dcterms xsi"
    version="2.0">
    
    <xsl:output method="html" indent="yes"></xsl:output>
    
    <xsl:variable name="agency">int.ddi.cv</xsl:variable>
    <xsl:variable name="cvID" select="//rdf:Description[rdf:type/@rdf:resource='http://www.w3.org/2004/02/skos/core#ConceptScheme']/skos:notation"/>
    <xsl:variable name="cvVersion" select="//rdf:Description[rdf:type/@rdf:resource='http://www.w3.org/2004/02/skos/core#ConceptScheme']/owl:versionInfo"/>
    
    <xsl:template match="rdf:RDF">
		<html lang="en">
		<head>
			<meta http-equiv="content-type" content="text/html; charset=UTF-8" />
			<title>Controlled Vocabulary - <xsl:value-of select="//rdf:Description[rdf:type/@rdf:resource='http://www.w3.org/2004/02/skos/core#ConceptScheme']/dcterms:title[@xml:lang='en']"/></title>
			<link href='http://fonts.googleapis.com/css?family=Roboto' rel='stylesheet' type='text/css'/>
			<style type="text/css">
		
				body {
					font-family: 'Roboto', sans-serif;
					margin: 2em;
					font-size:0.8em;
					/*
		            font-size: 90%;
		            */
				}
				h2, caption {
					font-size: 130%;
				}
				div.UsageTitle {
					font-size: 110%;
					font-weight: bold;
				}
		        p {
		            margin: 0;
		            padding: 0;
		        }
				hr {
					clear: left;
					color: #D3D3D3; /*lightgrey */
					margin-top: 2em;
					margin-bottom: 2em;
					margin-left: 10%;
					margin-right: 10%;
				}
				table, th, td {
					border-style: solid;
					border-color: #D3D3D3; /*lightgrey */
					border-width: 1px;
					border-collapse: collapse;
				}
				caption {
					font-weight: bold;
					margin-bottom: 1em;
					text-align: left;
				}
				thead {
					font-size: 120%;
				}
				th, td {
					padding: 0.5em;
					vertical-align: top;
				}
				td.Code {
					font-weight: bold;
				}
				td.Term {
					white-space: nowrap;
				}
				dl {
					float: left;
				}
				dt {
					clear: left;
					float: left;
					font-weight: bold;
					width: 15em;
					margin-bottom: 0.3em;
					margin-right: 1em;
				}
				dd {
					float: left;
					margin: 0;
					margin-bottom: 0.3em;
				}
				span.LanguageCode{
					color: #D3D3D3; /*lightgrey */
					font-style: italic;
				}
				table.UsageDetails>thead>tr>th {
					width: 15em;
				}
				div.CodeList {
					page-break-before:always;
				}
				.URL {
					font-size:80%;
				}
		
				@page {
					@bottom-right {
						color: #97acc2;
						content: counter(page) " / " counter(pages);
					}
				}
		
				@media all
				{
					div.page{
						page-break-inside: avoid;
					}
		
					.pagebreak { page-break-before: always; }
				}
		
				.logo {
					width:120px;
				}
		
				.switch {
					float: right;
				}
				.switch button {
					border: 1px solid black;
					padding: 4px 10px;
					background-color: #fff;
				}
				.switch button.active {
					background-color: #dddddd;
				}
			</style>
			<script>
				/*<![CDATA[*/
				var callback = function(){
					var logo = "data:image\/png;base64,\/9j\/4AAQSkZJRgABAgAAAQABAAD\/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL\/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL\/wAARCABeASwDASIAAhEBAxEB\/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL\/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6\/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL\/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6\/9oADAMBAAIRAxEAPwD3+iiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooqnqep2ej2Et9fzpBbRDLu5\/T60A3Yt5qG7vLaxt2uLqZIYV+87nAFePXXxpuZ\/Elomn2QXSfOEchlH7yUHjI9K9O8V+HoPFPhy70i4bYs6ja+M7WBBB\/MVpKm4tc\/UyjVU0+TWxC\/jnwukmxtbsw3pvrQs9c0rUDi01C3mPokgNfOPi\/wFd+Cmsxdz21zFdFljeNcEFcZyMe4rm0RY3DxZicdGjO0j8q6VhoyV4s5ZYucJWkj7BzS183+HPiZ4i8PuiS3DajZjrDOcuB7NXuXhjxdpfizT\/tOnS\/OvEsD8PGfcf1rnqUZQ32OiliIVNtzeooorI3CkzVe+vrbTbSS7vJkhgjGWdjwK8i8SfFa9vJHt9BX7NbDj7Q4+d\/oO1XCnKexz18TToq82ewT3dvapunnjjHq7AVnt4o0NW2nVbUH08wV84XV1c38pkvbqa5c9TK5aoPKi\/55r+VdCw3dnmyzZ392J9Q22p2N4P9Gu4Zf91watZr5WjzA4eB3icdGjYqf0rsNA+JOuaM6JdSHULQcFJT84HsamWGa+FmtLNISdpqx71RWRoHiTTvElgLrT5g2PvxNw8Z9CK1x0rnaadmenGSkrx2CiiqOq6tZaNZNd306xRL69WPoB3qW0tWNtLVl7NQT3trajM9xFGP9pgK8l1v4h6rqbtHp2bG17N1kYf0rkZS9w5e4kknc9TKxb+dcssUl8Kuc0sSl8Kue+f8JFo+7H9pW2f98VcgvLa5XME8cg\/2WBr508iHGPKT\/vmpIWktXD200sDDoYnK1Kxb6olYp9UfR2eaK8g0P4i6npzrFqf+m23dxxIv+Nep6bqlnq9kl3ZTLLE3cdQfQjtXRTqxnsdFOrGexcoooNamgUmao6rrFno1obm8lCr\/AAqOWY+gFecat411TUnZLZzZWx6Bfvke57Vz1sTClo9+xLkkenz3ttbDM08cf+8wFVhrmlk4F\/Bn\/fFeLSDzmLTM8rHqZGLU3yYv+eaf981xvMJdIke0PdormGdd0UqOP9ls1JmvCoZJLVw9tNLCw6GNiK6rRvHt5ZusWqL9pg6eao+dfqO9a08fGTtNWKU11PTKQnHWobO8t7+2S5tZVlhcZDLWPrkslxepYB2SFbeS5l2nBcLgBc+mSPyrslNKPMirm2k0UhISRWI6gHNSVwNgftqs1nHDBPHai4E0GU8tuoVgQNwP412un3JvNPguCu0yICR71FKrzgncs1l+IdCsfEujT6VqCFreYDJU4KkHII9wa5\/4geOx4LTTtlsLmS5mO+Ldg+WAckH6la8yHxj8RrrwvHhhTTmcL9lZDwmeu71xXZCjOS5omNSvTi+WR2egfBvTdJ1iK+vL+a9WBt0UTAAZ7E+tdR4+1XUNF8F6jfaYjNdxqArKM7ASAWx7DJrO+IfjOfwv4Zt7vThC95dSKkYc5ABGSfw4rzez+L2tx6Ne2GpWsN7LKjJFOPlAzwQw7jmrjCpUtN6mcqlKleC0OLutS1jxDPGbu6utSmVS6rjO0dyABWa0yCMlWyegHfP0ru\/hRrh0fxjHZtbrLHqeImKrkxtkkEei8817dH4R0CLVpNTTSrYXb9X2D8\/rXROsqb5bHLTw\/tVzXPIfEfw7stI+GlvrsImOpLHHLMCcghsZGO2M1wui67d6BqsOp6XNidSMoORKO6kd6+r28mVWhby3BGChwePpWHB4N8OWWrvrEOlwJdhfvBeBjuB61hDEaNTVzonhfeTg7Fnw34gtvEuiwajbZXeMSxN96Jx1Uj2NassiRRtJI4RFGWYnAAryPwX41j1D4p6vbJD9nsr7Kwx4xmSPgsR6kA1vfFfXHsPD0enQPtmv2KEg8hB1rKVJ86j3NXXUaTm+h57418XzeKtSZI2ZdLgYiGPp5h\/vGszRvD2qeIZJk0yBZWhAL7mxjNZeAAAOAOlemfBv\/kI6v\/1zSuyX7uHungUr4mulUe5zv\/CuPFf\/AD4R\/wDfwUjfDrxWoz\/ZyH6SCvbtc1\/T\/DtgL3UpTHCXCAhc8msJPid4VeQJ\/aBXPdkOKwVao9Uj0ZYDDRdpSt8zxTUtF1XRz\/xMdPnt17OynafxqgDnkGvp2C5sNZsi8MkN3bSDBxhgR715L8QfAMejRPrOkRkWef8ASLcf8s8\/xD2rSnXu7SObE5e4R56bujjNF1m98ParHqNi5Dqfnj\/hkXuCK+h9C1q28QaPBqNqfkkHK90buDXzT16GvQPhNrZstbm0iR\/3F2u+MHs47D6g\/pRXp3XMtxZdiXCfs3sz2G+vYNOsZry5cJDCpZifavC9f1668Sak13ckiBTi3h7Ivr9TXZfFLV2\/0TRY24f99Pg9QOgP44Ned14WJqNy5Vsj0sRUbfKti\/pWiajrckyadCsjQgF9zY61pf8ACCeJv+fKL\/v5W38Kv+Qnqf8AuJXoGs69YaBaLdahKY4mcICBnk06dGEoc0mOnRhKHNJnkbeBfEyjP2BD9JKyb\/S9R0o\/8TCxmtx\/fK5U\/jXrUfxF8MySBPt+3PdkIFb8U9lqtoXieK5t3GDjDA0\/q9OXwyH7CEvhkfPYIIBByPUVreHfEFz4a1IXMJLWrnFxD2Yeo9xW\/wCOPBaaOratpaEWZP7+Af8ALP8A2h7VxXH1BrnlGVOXmc8lKnLzPoi0u4b20iurdw8Uqh0Ydwaj1LUINL0+a8uGAjjXJ9z6Vwnwv1dngutHlbPkHzYc\/wB09R+eaT4hamZ7630tG\/dxDzZQO57A\/rXXPEctH2nX9T0I1OaHMczqmqXOt3zXt0Tz\/q4u0a+n1qpzR+NH414rbbuzMsWNjc6ldraWiB5mBIBOBgVfufC2t2drLdXFsixRKXch84AqfwX\/AMjZb\/8AXNq9C8U\/8irqf\/Xu\/wDKuuhh41KTm90XGKauePg5AIo5pF+4vPYUv41xkGv4d1+bw\/egglrKQ\/vYvT\/aFek6lYnU4obyxmUTKh2N1WRGHKn2NeP4yMHmvRPh9qbT6dNp8rZe2OUz1KH\/AArvwdW79lLZ7FwfQt\/2RqF28cbW8VhGIfs8kkcm4vH024\/rXSwRJBAkUa7UQbVHtUlFenCmo7GiR4d8WNP1PVviDpNollcSWzRqkbopK8sN\/wBMAV2fxG8MQXHw8urexs0ae1RHjMcY3kJjI455ArvCqlgSoJHQkdKXg8cGuj2r93yMvYq8n3PAvA\/w7v8Axfam+1y6vYNPVSttHI53lvUA9AP1rktQ0J7LxbJ4ehuknkW4W3WbGBuJxz7ivqgoBHtjwuBgYHArxFPg74hv9dvLq\/1OC3SW6aYTRDc7ZbOfY10U6923J2RzVsNaKUVdnVeBvhg3hXWG1S9v1u7gRGONUTCpnqa0\/if4ivPDfg2W5sDtuZ5Vt0k\/555yd36VyHhrU9Z8I\/E4eFtW1S4vrK5TFs0mCcnofbnI\/CvTPEXh+y8TaJPpd8D5Uo4ZeqMOhFYzdpqU9UbwS9m4w0PmGHWNYsbr7bb6teC7Q7\/MaZiGPuCcEV9O+F9VfXPDGnanKgSS5hDsB69DXltv8DLg3wS81oPYg8hI8O6+mc8V7DaWtvptjFbW6CO3gTaijsBV4icJJcpnhqdSLfOed33wvuU8dp4l0rUUiH2kTyW7r6\/ewffJrnPixdNP4xhgJykFsMD0JJrD1Lxbq\/iXx\/HDDqNzHp7aikUNup2jarc5+uK1PijCYvHDE9JLZSPwzVwjJSXN2OTGSi6MuRdTjq9L+Df\/ACEdX\/65pXmlel\/Bv\/kI6v8A9c0rSt8DODAf7xE3vi\/\/AMiYn\/X0n8jXizcs2eea9p+L\/wDyJif9fSfyNeLt94\/Wpw\/wGuZ\/x\/kb\/gvxDP4c8QW7JIRZXDiO4iz8pB7getfQVzbx3tnNbSgNHKhRgR2Ir5ksLWS+1SztIVLSTTKqgfWvqAcDnjA5rHEpKSaOvK5SlCUZbHy9eWpsdQu7M5\/0ed4hn0BOP0xVrw\/dmw8SabdjrHOv454pNeuFuvEeqzp917t8fgcf0qHTIXuNYsYUGXedQB+NdW8dTyPhq+73Ou8a3BufG2psTkRFIl9sDmsOtfxbGYvGeroe8ob8CM1kV8tP4nc9mfxM7z4Vf8hPU\/8AcStf4p\/8i1B\/18p\/Osj4Vf8AIT1P\/cStf4p\/8i1B\/wBfKfzFdUf93fzOmP8AAZ5Y2DkEAj3ra8I61NoOvW5jci0uJBFNFn5eeA2OxzisU9ansbd7vVLG2iGZJLhAB9GBP6CuSLaaaOWLaaaPoG5t4ru1lt5VDxSoVYeoNfPM1u1ndXFo\/wB6CVo\/yr6JUbEC5+6MV8+6pMlzrmpXEfKSXLFT+NdeLWzOrFdGa\/ga5Nt40scE4mDRkfhUuu3BuvEmozH\/AJ67B+FVPB0TTeM9LVf4XZz9AKn1ZGi13UUYYYTk\/nXDWb9kl5\/oTR+D5lTij8KWjmuQ1N3wX\/yNlv8A9c2r0LxT\/wAirqX\/AF7v\/KvPfBf\/ACNlv\/1zavQvFP8AyKupf9e7\/wAq9PC\/7vL5\/kaR+E8eX7i\/7op3FNX7i\/7op1eYZhxXQ+BpzD4pVBwJomU\/of6Vz1bvgxC\/iu2I\/gRmP5VrQ\/ixt3Gtz1qiiivoDc89+Lmr67ovh23uNIuPs8LzeXcyqPnUEHBHpyOteKW3ibxDZ3IuINcvRIDn55CwP1Ga+nta0q21zR7rTLtQ0NwhQ+x7H8DivlzWtFvPDmsz6TfKRLCfkfHEqdmH4V24ZxceVrU8\/GKcZKSeh738OPG58X6ZNHdosepWhAnC\/dcHow+uDW54u1HUtJ8L317pNp9qvo0HlRDnJJAzjvgHOPavJvgjazyeJNTvEyLeKBY39CxPH5YNe06lqNppNhLfX06QW0Iy8jnAHOP5msKsVGpZHRRk50ryPn\/wR4otdC8V3ur+LIL176aP93cSxnKNzlcH14A+ldTa\/HOP+0pTfaPLHpxIEbxsDIo9WFUviV468OeItBfTtKJnuzKj+eIcAAHJ+bFeWsAwIPcYrrjTjU96Sscc60qT5Yu59T6t4m07R\/DB8QXDO1l5SyqUGWYNjaB9civOLb44xvrI+06TJFpTAASBgZFPqR6V57f+MdY1PwvB4duWh+ww7QGUHewXoD9Kw1WSWVI4kaSWRgqIoyWPpUww0UnzFVMXJtch6b4Zt9O8WfGW41bSbd49MtgZ3LDAeQjG4DtknNbvxi0tjHp+sIpIjJhlIHQHp\/Wul+HnhIeFPDqRzgG\/uf3ty3oey\/h0roNZ0q31rSbjTroZinQrn0PY1hKolUTWyNpYfnoOL3ep8zYr0v4N\/wDIQ1f\/AK5pXn+q6Xd6Jqc2m3qFZ4Twezr2YV1Hw78TaZ4Zu9Qk1KSRFnVQmxC2cfSumr70HY8XCWp4hc+lj0f4jaFqHiDw0tnpsaSTCdXIZscDNeaL8MfFMkmDb26An7xk4Feh\/wDC1vC3\/Pxcf9+WpD8V\/C4H+vuD7eS1c0HVirJHp1oYStLmlP8AEb4M+HcPhub7fezLdahjCkD5Ix7e\/vV3x94ph8O6DLHG4N\/cqY4IweRnqx9gK5XV\/jAGiaPRbBt5GBNccAe4FeaX1\/d6neveX9w9xcv1duw9AOwqo0pTlzTMquMo0afs6BXUEKASSe5Pc9zXW\/DfSn1Pxnby4\/dWQMzHHGegH8\/yrkwrO6xxoXkc7URRksT0Ar3zwD4X\/wCEa0ECdR9uucSTkdvRfw5\/Otq0+WNu5x4Cg6tVPotTkfibprWviGDUFU+Vdx7GOOjr0\/QVxle6eKNBj8Q6HNZHAl+\/C\/8AdcdP8Pxrw2WGa2uJba5Qx3ETbZEPY189iIcs79GepXhyzv3O6+FX\/IT1P\/cSun8e6Lf67okVtp8aPKsyuQ7YGAa4XwN4g0\/w9eX0uoSOizKoTahbOPpXa\/8ACyvDn\/Peb\/v0a1pSg6XLJmtKUHS5ZM4dfh74ld8GC3QH+IydK7fwn4Gi0Cb7ddzC5v8AG1WA+WMHrig\/Evw4Bnz5z7eSaxdU+KRaMx6RYtvPHmzjAHviiKoQfNe4JUYO97nR+NvEseg6O8cbg31wpSFAeRn+L6CvF0XYgXOT3Pqamurq5v7x7u9nae4fq7dvYDsKS3t57y6itLWMyXEzbUUfz+lc9Wo6krmFWo6krnafDHTmuNZutSZf3dunlIf9o9f0NO8cWDWfiUz4Pl3aBgf9odRXfeG9Ei0DRILFMF1G6Vv7znkmovFOhjXNIaFMC5iO+FvQ+n41vUw7dDl67nZCnywt1PI\/xo\/Gghld45UKSodroeqmjj0rxyTe8F\/8jZb\/APXNq9C8U\/8AIq6l\/wBe7\/yrzTw3qFtpevxXl25WFUYEgZ5NdZrfjLRtQ0O9tIJZTLLCyIDGRkkV6GGqQjQlFvXU0i1ynnq\/cXnsKX8aRRhVB6gUvHpXnmYfjXbfDqxZri81Fh8oHlJkde5\/lXHWlpPqF5FZ2qbppTgew9TXsuk6ZDpOmQ2UP3Yxyf7x7mu3BUnKfP0RcFrcvUUUV7BqFcz4x8Fad4xslhut0NxHzFcxj5k9vcV01FNNxd0KUVJWZj+HPDth4X0mPTtOjKxqdzu33pG7kmpNb0mw8SaPdaTeESQTDa4VuVIOQfqCBWoa5G7+H9hJfy3+nX2oabdyyGSR7e4bDk+qk4qk7u7epMlZWitDwPxP4em8K69NpEtwk4RQ8ciddh6Bh2NZPTqa9tvPgtbX9\/Ne3Wv301xM26SRwCW7VdsPgx4atZA901zeY\/hkcgfkK7ViYJas854Sbk7KyPDdO06+1i7W0021kupmOMIOB9TXufgH4Zw+G2XU9UZLnVCPlAHyQ\/T1PvXb6bpGn6PbiDTrOG2jHaNAM\/X1q8K56uIc9Fojqo4WMHd6sQCloornOo5rxd4OsvFVmFkPk3kQzDcKOV9j6ivDdb0DU\/Dt0YNStmQfwTKMo49Qa+l6gubS3vYWguYY5om6pIoIranWcNOhw4rAwr+8tGfLgIIyMGlr3DUfhV4dvXLwJLZsevkscflWOfgzbbuNYuMe6CulYiDPKlltdPTU8nqazs7rUrlbaxt5LidjgKgz+dew2Pwh0SB1a7uLm7x\/CzbQfyrs9M0bT9Hg8nT7SK3XuUUAn6nvUyxMV8JrSyuo3+8dkcb4I+HaaGyalqmyfUcZRBysP+Jr0AdKBS1ySk5O7PZpUoUo8sEBrkvF3gqHxCv2q2ZbfUUGFkxw49GrraKzlFSVmXKKkrM+eL+xvNKuWt9Qt3gkHcj5W9war\/lX0Le2FpqMBhvLeOaM9nUHFcne\/DHRbhy1s89rnsjZH5GuKWFkvhOSWGkvhPJ\/89KTOOpxXpP\/AAqiDP8AyFZ8f7orSsvhlols4e4M10R2kbA\/IVCw9RkLDzZ5bp2nXusXIt9Pt2mc9Wx8q+5Neu+E\/Btv4diM8rCfUJFw8uOFHotdDZ2VtYQiG0gjhjH8KKBViuqlQUNXqzpp0FDV6sB0oNFFdBucp4o8IJq5N5ZFYb4DnI+WQeh9\/evN7m3uLGcwXkLQSjsw4P0Ne51VvdPtNQi8q7t45l\/2lzj6VxV8HGo+aOjIlC54j+VL+Ar0i6+HmlTMWt5ZrfPZWyB+dVP+FbQ551KbH0FcLwVZdCORnAk464FWtN0y91ecQ2MJc55kPCr7k16JZ+ANHtmDTCS5I\/56Nx+VdJb20NrEIoIkijHRUXArangJP43Yah3Mfw34Zt9AgJz5t2\/+slI\/Qe1b1FFenCEYLljsaJWCiiiqGf\/Z";
					var images = document.getElementsByTagName('img');
					for(var i = 0; i < images.length; i++) {
						if( images[i].classList.contains('logo'))
							images[i].src = logo;
					}
		
					var buttons = document.getElementsByTagName('button');
					for(var i = 0; i < buttons.length; i++) {
						buttons[i].addEventListener("click", function(e) {
							toggleLang (buttons, e.currentTarget);
							e.stopPropagation();
						}, false);
					}
				};
		
				function toggleLang(buttons, currentButton){
					var id = currentButton.value;
					var divs = document.getElementsByClassName("cv");
					for (i = 0; i < divs.length; i++) {
						if( id !== "all")
							divs[i].style.display = "none";
						else
							divs[i].style.display = "block";
					}
					if( id !== "all")
						document.getElementById(id).style.display = "block";
		
					for(var i = 0; i < buttons.length; i++) {
						buttons[i].classList.remove('active');
					}
					currentButton.classList.add('active');
				}
		
				if ( document.readyState === "complete" || (document.readyState !== "loading" && !document.documentElement.doScroll)) {
					callback();
				} else {
					document.addEventListener("DOMContentLoaded", callback);
				}
				/*]]>*/
			</script>
		</head>
		<body>
		
			<div class="switch">
				<p>
					<button value="all" class="active">show all</button>
	                <xsl:for-each select="//rdf:Description[rdf:type/@rdf:resource='http://www.w3.org/2004/02/skos/core#ConceptScheme']/dcterms:title">
						<button>
	                        <xsl:attribute name="value">
	                            <xsl:value-of select="@xml:lang"/>
	                        </xsl:attribute>
	                        <xsl:attribute name="title">
	                            <xsl:value-of select="@xml:lang"/>
	                        </xsl:attribute>
	                        <xsl:value-of select="@xml:lang"/>
						</button>
	                </xsl:for-each>
				</p>
			</div>
            <xsl:for-each select="//rdf:Description[rdf:type/@rdf:resource='http://www.w3.org/2004/02/skos/core#ConceptScheme']/dcterms:title">
	            <xsl:variable name="mylang" select="@xml:lang"/>
		    	<div class="cv" id="en">
                     <xsl:attribute name="id">
                         <xsl:value-of select="$mylang"/>
                     </xsl:attribute>
					<div class="page">
						<div style="width: 100%;">
							<div style="width:130px;float:left;padding-right:15px">
								<img alt="agency-logo" class="logo" src="data:image/png;base64,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"/>
							</div>
							<div>
								<h1>DDI Alliance Controlled Vocabulary for <xsl:value-of select="."/></h1>
							</div>
						</div>
			
						<hr />
						<h2>CV definition</h2>
						<p><xsl:value-of select="../dcterms:description[@xml:lang=$mylang]"/></p>
						<hr />
						<h2>Details</h2>
						<dl>
							<dt>CV short name:</dt>
							<dd><xsl:value-of select="../skos:notation"/></dd>
							<dt>CV name:</dt>
							<dd><xsl:value-of select="."/></dd>
			                <dt>CV notes:</dt>
			                <dd>This vocabulary was first published by the DDI Alliance. Please see: https://ddialliance.org/controlled-vocabularies/all.</dd>
							<dt>Language:</dt>
							<dd><xsl:value-of select="$mylang"/></dd>
							<dt>Version:</dt>
							<dd><xsl:value-of select="$cvVersion"/></dd>
							<dt>Version notes:</dt>
							<dd>
								<p>For detailed version information, please go to 
									<a rel="noopener noreferrer" target="_blank" style="color: rgb(30, 135, 240); background-color: transparent;">
					                    <xsl:attribute name="href">
					                    	<xsl:text>https://vocabularies.cessda.eu/vocabulary/</xsl:text>
					                        <xsl:value-of select="$cvID"/>
					                    </xsl:attribute>
										CESSDA Controled Vocabulary Service
									</a>, where this CV is managed. This information is located on the "Versions" tab.
								</p>
							</dd>
							<dt>Canonical URI:</dt>
							<dd>
								<a rel="canonical URI this version" href="http://rdf-vocabulary.ddialliance.org/cv/AggregationMethod/1.1.2/">
				                    <xsl:attribute name="href">
				                        <xsl:value-of select="../@rdf:about"/>
				                    </xsl:attribute>
									<xsl:value-of select="../@rdf:about"/>
								</a>
							</dd>
							<dt>Canonical URN:</dt>
							<dd>
								urn:ddi:int.ddi.cv:<xsl:value-of select="$cvID"/>:<xsl:value-of select="$cvVersion"/>
							</dd>
							<dt>Agency: </dt>
							<dd>
								<a href="http://www.ddialliance.org/">DDI Alliance</a>
							</dd>
						</dl>
						<hr/>
						<div class="CodeList page">
							<table aria-describedby="page-heading">
								<caption>Code list</caption>
								<thead>
								<tr>
				                    <th scope="col" style="width: 25%;">Code value</th>
				                    <th scope="col" style="width: 25%;">Code descriptive term</th>
				                    <th scope="col" style="width: 50%;">Code definition</th>
								</tr>
								</thead>
								<tbody>
			                    <xsl:apply-templates select="../skos:hasTopConcept" mode="Code">
			                    	<xsl:with-param name="mylang" select="$mylang"/>
			                    </xsl:apply-templates>
								</tbody>
							</table>
						</div>
						<hr />
						<div class="Usage page">
							<h2>Usage</h2>
							<p>For detailed usage information, please go to 
								<a rel="noopener noreferrer" target="_blank" style="color: rgb(30, 135, 240); background-color: transparent;">
				                    <xsl:attribute name="href">
				                    	<xsl:text>https://vocabularies.cessda.eu/vocabulary/</xsl:text>
				                        <xsl:value-of select="$cvID"/>
				                    </xsl:attribute>
									CESSDA Controled Vocabulary Service
								</a>, where this CV is managed. This information is located on the "Usage" tab.
							</p>
						</div>
						<hr />
				        <h2>License and citation</h2>
				        <p><xsl:value-of select="../dcterms:rights"/>.</p>
				        <p>
				            <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">
				                <img style="border-width:0;width:140px" alt="Creative Commons Attribution 4.0 International" src="data:image/png;base64,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" title="Creative Commons Attribution 4.0 International" />
				            </a>
				            <span>This work is licensed under a
										<a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International</a>.
									</span>
				        </p>
						<p><br/></p>
				        <p>Citation:
				            <span>DDI Alliance. (2019). Aggregation Method (Version <xsl:value-of select="$cvVersion"/>) [Controlled vocabulary]. urn:ddi:int.ddi.cv:<xsl:value-of select="$cvID"/>:<xsl:value-of select="$cvVersion"/> </span> Available from:
				            <a>
			                    <xsl:attribute name="href">
			                        <xsl:value-of select="../@rdf:about"/>
			                    </xsl:attribute>
				            	<xsl:value-of select="../@rdf:about"/>
			            	</a>
				        </p>
						<br/><br/><br/><br/>
					</div>
				</div>
			</xsl:for-each>
            </body>
        </html>
    </xsl:template>
    
    <xsl:template match="skos:hasTopConcept" mode="Code">
    	<xsl:param name="mylang"/>
        <xsl:variable name="descriptionID" select="@rdf:resource"/>
        <xsl:apply-templates select="//rdf:Description[@rdf:about=$descriptionID]" mode="Code">
        	<xsl:with-param name="mylang" select="$mylang"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="rdf:Description" mode="Code">
    	<xsl:param name="mylang"/>
    	<xsl:param name="paddingleft">0.5</xsl:param>
		<tr>
            <td style="width:25%;white-space:pre-line;word-break:break-all;word-wrap:break-word;">
                <xsl:attribute name="style">
                	<xsl:text>width:25%;white-space:pre-line;word-break:break-all;word-wrap:break-word;padding-left:</xsl:text>
                    <xsl:value-of select="$paddingleft"/>
                    <xsl:text>em;</xsl:text>
                </xsl:attribute>
            	<xsl:value-of select="skos:notation"/>
           	</td>
            <td style="width: 25%;"><xsl:value-of select="skos:prefLabel[@xml:lang=$mylang]"/></td>
            <td style="width: 50%;"><xsl:value-of select="skos:definition[@xml:lang=$mylang]"/></td>
		</tr>
        <xsl:for-each select="skos:narrower">
            <xsl:variable name="descriptionID" select="@rdf:resource"/>
            <xsl:apply-templates select="//rdf:Description[@rdf:about=$descriptionID]" mode="Code">
            	<xsl:with-param name="mylang" select="$mylang"/>
            	<xsl:with-param name="paddingleft" select="$paddingleft+1.5"/>
            </xsl:apply-templates>
        </xsl:for-each>
    </xsl:template>
    

</xsl:stylesheet>