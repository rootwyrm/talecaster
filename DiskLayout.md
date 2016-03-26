# TaleCaster Application Server Disk Layout

*DO NOT DEVIATE FROM THIS LAYOUT.*

| Device 	| Type 	| VG     	| Size 	| Use             	|
|--------	|------	|--------	|------	|-----------------	|
| sda    	| LVM  	| rootvg 	| 32GB 	| OS              	|
| sdb    	| Raw  	| swap   	| 4GB  	| swap            	|
| sdc    	| LVM  	| tcavg  	| 8GB  	| Application     	|
| sdd    	| LVM  	| tccvg  	| 4GB  	| Containers      	|
| sde    	| LVM  	| tccvg  	| 4GB  	| Containers      	|
| sdf    	| LVM  	| tccvg  	| 4GB  	| Containers      	|
| sdg    	| LVM  	| tcsvg  	| 50GB 	| Transient Media 	|
| sdh    	| LVM  	| tcsvg  	| 50GB 	| Transient Media 	|
| sdi    	| LVM  	| tcsvg  	| 50GB 	| Transient Media 	|

* FS Layout

| FS               	| Size  	| Format 	| VG     	| Notes                                  	|
|------------------	|-------	|--------	|--------	|----------------------------------------	|
| /boot            	| 512MB 	| xfs    	|        	| Partition (of course)                  	|
| /                	| 2GB   	| ext4   	| rootvg 	|                                        	|
| /usr             	| 8GB   	| ext4   	| rootvg 	|                                        	|
| /var             	| 8GB   	| xfs    	| rootvg 	| Must be XFS, container logs write here 	|
| /home            	| 4GB   	| ext4   	| rootvg 	|                                        	|
| /opt             	| 8GB   	| xfs    	| rootvg 	| XFS for application auto-build speed   	|
| /opt/talecaster  	| 8GB   	| xfs    	| tcavg  	| DO NOT CHANGE MOUNT OPTIONS!           	|
| docker.storage   	| 12GB  	| auto   	| tccvg  	| Used for base-image storage            	|
| /media/downloads 	| 150GB 	| xfs    	| tcsvg  	| Download storage, thin LV              	|
| /media/transcode 	| 50GB  	| xfs    	| tcsvg  	| Transcode temp storage, thin LV        	|
